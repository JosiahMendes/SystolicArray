////////////////////////////////////////////////////////////////
//Do Not Touch This Module. 
////////////////////////////////////////////////////////////////

module MockSRAM (clk, cs, we, addr, din, dout);

    parameter DEPTH      = 16;
    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;

    input clk;
    input cs;
    input we;
    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] din;

    output [DATA_WIDTH-1:0] dout;

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    reg [DATA_WIDTH-1:0] tmp_data;

    integer i;

    always @ (posedge clk) begin
        if (cs & ~we) begin
            tmp_data <= memory[addr];
        end
        else if (cs & we) begin
            memory[addr] <= din;
        end
    end

    assign dout = (cs & ~we) ? tmp_data : 'hz;

endmodule
