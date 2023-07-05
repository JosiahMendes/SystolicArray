////////////////////////////////////////////////////////////////
// clk                           -clock signal
// rstnPsum                      -from controller (CTRL.v), synchronous reset, to reset accumulation of products (16 bits, each bit controls a PE)
// rstnPipe                      -from controller (CTRL.v), synchronous reset, to reset all systolic movements (1 bit)
// rstnAddr                      -from controller (CTRL.v), synchronous reset, to reset test case address (1 bit)
// addrInc                       -from controller (CTRL.v), to increase test case address by 1
// latCnt                        -from controller (CTRL.v), to count cycles of calculation in each test case and select correct input element into the PE array (4-bit counter)
// MemOutputA0                   -from testbench, test cases for the first column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA1                   -from testbench, test cases for the second column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA2                   -from testbench, test cases for the third column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA3                   -from testbench, test cases for the fourth column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputB                    -from testbench, test cases for matrix B (4*4 elements * 32 bits = 512 bits)
// ipPsum                        -from testbench, to initialize ipPsum port for the first row of the PE array

// OpC30, OpC31, OpC32, OpC33    -4 elements in each row of the calculation output (4 32-bit elements)
// BankAddr                      -to testbench, to select test case (10-bit address)
////////////////////////////////////////////////////////////////

module DATA (clk, rstnPsum, rstnPipe, rstnAddr, addrInc, latCnt, MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3, MemOutputB, ipPsum, OpC30, OpC31, OpC32, OpC33, BankAddr);

// port definition
input clk, rstnPipe, rstnAddr, addrInc;
input [15:0] rstnPsum;
input [3:0] latCnt;
input [255:0] MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3;
input [511:0] MemOutputB;
input [31:0] ipPsum;
output [31:0] OpC30, OpC31, OpC32, OpC33;
output reg [9:0] BankAddr;


// test case reading address increment (reset with rstnAddr)
// increase BankAddr by 1 if addrInc is activated
always @(posedge clk) begin
	if (!rstnAddr) BankAddr <= 10'b0;
	else if (addrInc) BankAddr <= BankAddr + 10'b1;
	else BankAddr <= BankAddr;
end


// input data MUX A, depends on latCnt, select 1 element from 8 (a row/column) into WSPE array
// input: 256 bits, MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3
// output: 32 bits, ipA0, ipA1, ipA2, ipA3
// selection signal: latCnt (e.g. when latCnt = 0, ipA0 = MemOutputA0[31:0], ...)
reg [31:0] ipA0, ipA1, ipA2, ipA3;

`define SET_IP(BIT1, BIT2) \
	begin                              \
		ipA0 = MemOutputA0[BIT1:BIT2]; \
		ipA1 = MemOutputA1[BIT1:BIT2]; \
		ipA2 = MemOutputA2[BIT1:BIT2]; \
		ipA3 = MemOutputA3[BIT1:BIT2]; \
	end


always @(*) begin
	case (latCnt)
		4'd0: `SET_IP(31, 0)
		4'd1: `SET_IP(63, 32)
		4'd2: `SET_IP(95, 64)
		4'd3: `SET_IP(127, 96)
		4'd4: `SET_IP(159, 128)
		4'd5: `SET_IP(191, 160)
		4'd6: `SET_IP(223, 192)
		4'd7: `SET_IP(255, 224)
		default: begin
			ipA0 = 32'b0;
			ipA1 = 32'b0;
			ipA2 = 32'b0;
			ipA3 = 32'b0;
		end
	endcase
end

// Input data MUX B, fixed mapping ("weight stationary")
// input: 512 bits, MemOutputB
// output : 32 bits, ipB00 ,ipB01, ipB02, ipB03, ipB10, ipB11, ipB12, ipB13, ipB20, ipB21, ipB22, ipB23, ipB30, ipB31, ipB32, ipB33
// e.g. ipB00 = MemOutputB[511:480], ipB01 = MemOutputB[479:448], ..., ipB33 = MemOutputB [31:0]

reg [31:0] ipB00, ipB01, ipB02, ipB03, ipB10, ipB11, ipB12, ipB13, ipB20, ipB21, ipB22, ipB23, ipB30, ipB31, ipB32, ipB33;

always @(*) begin
	ipB00 = MemOutputB[511:480];
	ipB01 = MemOutputB[479:448];
	ipB02 = MemOutputB[447:416];
	ipB03 = MemOutputB[415:384];
	ipB10 = MemOutputB[383:352];
	ipB11 = MemOutputB[351:320];
	ipB12 = MemOutputB[319:288];
	ipB13 = MemOutputB[287:256];
	ipB20 = MemOutputB[255:224];
	ipB21 = MemOutputB[223:192];
	ipB22 = MemOutputB[191:160];
	ipB23 = MemOutputB[159:128];
	ipB30 = MemOutputB[127:96];
	ipB31 = MemOutputB[95:64];
	ipB32 = MemOutputB[63:32];
	ipB33 = MemOutputB[31:0];
end

wire [31:0] opC30_out, opC31_out, opC32_out;

// systolic array
WSPEArray wspe_array(	clk, rstnPsum, rstnPipe,
						ipA0, ipA1, ipA2, ipA3,
						ipPsum, ipPsum, ipPsum, ipPsum,
						ipB00, ipB01, ipB02, ipB03, ipB10, ipB11, ipB12, ipB13,
						ipB20, ipB21, ipB22, ipB23, ipB30, ipB31, ipB32, ipB33,
						opC30_out, opC31_out, opC32_out, OpC33
					);



// systolic output synchronization (due to the systolic movement, outputs are not ready at the same clock cycle)
// reset with rstnPipe
// delay opC30 by 3 cycles
// delay opC31 by 2 cycles
// delay opC32 by 1 cycles
// as a result, all the outputs will be synchronized to the same clock cycle

reg [31:0] opC30_d3, opC30_d2, opC30_d1;
reg [31:0] opC31_d1, opC31_d2;
reg [31:0] opC32_d1;

assign OpC30 = opC30_d1;
assign OpC31 = opC31_d1;
assign OpC32 = opC32_d1;

always @(posedge clk) begin
	if (!rstnPipe) begin
		opC30_d3 <= 32'b0;
		opC30_d2 <= 32'b0;
		opC30_d1 <= 32'b0;
		opC31_d1 <= 32'b0;
		opC31_d2 <= 32'b0;
		opC32_d1 <= 32'b0;
	end
	else begin
		opC30_d3 <= opC30_out;
		opC30_d2 <= opC30_d3;
		opC30_d1 <= opC30_d2;

		opC31_d2 <= opC31_out;
		opC31_d1 <= opC31_d2;

		opC32_d1 <= opC32_out;
	end
end


endmodule
