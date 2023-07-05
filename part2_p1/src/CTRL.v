////////////////////////////////////////////////////////////////
// Note: the controller is exactly the same for both p1 and p2. You do not have to rewrite it.
////////////////////////////////////////////////////////////////
// input ports
// clk            -clock signal
// rstnSys        -reset the system (synchronous reset, active low)
// startSys       -start systolic calculation, active high (matrix A[4*8] * matrix B[8*4])

// output ports
// rstnPsum       -control signal, synchronous reset, to reset accumulation of products (16 bits, each bit controls a PE)
// rstnPipe       -control signal, synchronous reset, to reset all systolic movements (1 bit)
// rstnAddr       -control signal, synchronous reset, to reset test case address (1 bit)
// addrInc        -control signal, to increase test case address by 1
// latCnt         -to count cycles of calculation in each test case and select correct input element into the PE array (4-bit counter)
// start_check    -to testbench, to start storing of calculation results, to be activated when calculation is done (active high)
////////////////////////////////////////////////////////////////

module CTRL (clk, rstnSys, startSys, rstnPsum, rstnPipe, rstnAddr, addrInc, latCnt, start_check);

// port definition
    input clk, rstnSys, startSys;
    output reg [15:0] rstnPsum;
    output reg rstnPipe, rstnAddr, addrInc;
    output reg [3:0] latCnt;
    output reg start_check;


// state define
    localparam INIT = 2'd0;
    localparam CAL = 2'd1;
    localparam LOAD_NEXT = 2'd2;
    localparam LOAD_NEXT_IDLE = 2'd3;

// cycles needed for calculation in each test case
    localparam SYSTOLIC_LATENCY = 4'd14;

// update current states (sequential logic, reset with rstnSys)
    reg [1:0] currentState;
    reg [1:0] nextState;

    always @ (posedge clk) begin
        if (!rstnSys) currentState <= INIT;
        else currentState <= nextState;
    end

// next state generation (combinational logic)
    always @ (*) begin
        case (currentState)
            INIT: begin
                if (startSys) nextState = CAL;
                else nextState = INIT;
            end
            CAL: begin
                if (latCnt == SYSTOLIC_LATENCY)
                     nextState = LOAD_NEXT;
                else nextState = CAL;
            end
            LOAD_NEXT: begin
                nextState = LOAD_NEXT_IDLE;
            end
            LOAD_NEXT_IDLE: begin
                nextState = CAL;
            end
            default: nextState = INIT;
        endcase
    end



// output generation (combinational logic)
always @ (*) begin
    rstnAddr = currentState == INIT ? 1'b0 : 1'b1;
    rstnPipe = currentState != CAL ? 1'b0 : 1'b1;
    addrInc = currentState == LOAD_NEXT ? 1'b1 : 1'b0;
    start_check = latCnt == SYSTOLIC_LATENCY ? 1'b1 : 1'b0;
end

// update control signals (sequential logic, reset with rstnSys)
// each bit of rstnPsum controls each element of the PE array.
// rstnPsum[0] controls the element in the top-left corner of the PE array.
// rstnPsum[15] controls the element in the bottom-right corner of the PE array.
// default state should be ffff,

always @ (posedge clk) begin
    if (!rstnSys) rstnPsum <= 16'h0000;
    else if (currentState == INIT && !startSys) rstnPsum <= rstnPsum;
    else if (currentState == LOAD_NEXT) rstnPsum <= rstnPsum;
    else if (currentState == CAL) begin
        case (latCnt)
            SYSTOLIC_LATENCY - 6: rstnPsum <= 16'hfffe;
            SYSTOLIC_LATENCY - 5: rstnPsum <= 16'hffec;
            SYSTOLIC_LATENCY - 4: rstnPsum <= 16'hfec8;
            SYSTOLIC_LATENCY - 3: rstnPsum <= 16'hec80;
            SYSTOLIC_LATENCY - 2: rstnPsum <= 16'hc800;
            SYSTOLIC_LATENCY - 1: rstnPsum <= 16'h8000;
            SYSTOLIC_LATENCY - 0: rstnPsum <= 16'h0000;
            default: rstnPsum <= 16'hffff;
        endcase
    end
    else rstnPsum <= 16'hffff;
end



// latCnt, 4-bit counter (sequential logic, reset with rstnSys)
always @ (posedge clk) begin
    if (!rstnSys) latCnt <= 4'd0;
    else if (currentState == CAL) latCnt <= latCnt + 4'd1;
    else latCnt <= 4'd0;
end



endmodule

