////////////////////////////////////////////////////////////////
// input ports
// clk                           -clock signal
// rstnPsum                      -from controller (CTRL.v), synchronous reset, to reset accumulation of products (16 bits, each bit controls a PE)
// rstnPipe                      -from controller (CTRL.v), synchronous reset, to reset all systolic movements (1 bit)
// rstnAddr                      -from controller (CTRL.v), synchronous reset, to reset test case address (1 bit)
// addrInc                       -from controller (CTRL.v), to increase test case address by 1
// latCnt                        -from controller (CTRL.v), to count cycles of calculation in each test case and select correct input element into the PE array (4-bit counter)
// MemOutputA0                   -from testbench, test cases for the first row of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA1                   -from testbench, test cases for the second row of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA2                   -from testbench, test cases for the third row of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA3                   -from testbench, test cases for the fourth row of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputB0                   -from testbench, test cases for the first column of matrix B (8 elements * 32 bits = 256 bits)
// MemOutputB1                   -from testbench, test cases for the second column of matrix B (8 elements * 32 bits = 256 bits)
// MemOutputB2                   -from testbench, test cases for the third column of matrix B (8 elements * 32 bits = 256 bits)
// MemOutputB3                   -from testbench, test cases for the fourth column of matrix B (8 elements * 32 bits = 256 bits)

// output ports
// OpC00, OpC01, OpC02, OpC03    -4 elements in the first row of the calculation output (4 32-bit elements)
// OpC10, OpC11, OpC12, OpC13    -4 elements in the second row of the calculation output (4 32-bit elements)
// OpC20, OpC21, OpC22, OpC23    -4 elements in the third row of the calculation output (4 32-bit elements)
// OpC30, OpC31, OpC32, OpC33    -4 elements in the fourth row of the calculation output (4 32-bit elements)
// BankAddr                      -to testbench, to select test case (10-bit address)
////////////////////////////////////////////////////////////////

module DATA (clk, rstnPipe, rstnAddr, addrInc, rstnPsum, latCnt, MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3, MemOutputB0, MemOutputB1, MemOutputB2, MemOutputB3, OpC00, OpC01, OpC02, OpC03, OpC10, OpC11, OpC12, OpC13, OpC20, OpC21, OpC22, OpC23, OpC30, OpC31, OpC32, OpC33, BankAddr);

// port definition
input clk, rstnPipe, rstnAddr, addrInc;
input [15:0] rstnPsum;
input [3:0] latCnt;
input [255:0] MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3;
input [255:0] MemOutputB0, MemOutputB1, MemOutputB2, MemOutputB3;

output [31:0] OpC00, OpC01, OpC02, OpC03;
output [31:0] OpC10, OpC11, OpC12, OpC13;
output [31:0] OpC20, OpC21, OpC22, OpC23;
output [31:0] OpC30, OpC31, OpC32, OpC33;
output reg [9:0] BankAddr;


// test case reading address increment (synchronous reset with rstnAddr)
// increase BankAddr by 1 if addrInc is activated
always @(posedge clk) begin
	if (!rstnAddr) BankAddr <= 10'b0;
	else if (addrInc) BankAddr <= BankAddr + 10'b1;
	else BankAddr <= BankAddr;
end



// input data MUX, depends on latCnt, select 1 element from 8 (a row/column) into OSPE array
// input: 256 bits, MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3, MemOutputB0, MemOutputB1, MemOutputB2, MemOutputB3
// output: 32 bits, ipA0, ipA1, ipA2, ipA3, ipB0, ipB1, ipB2, ipB3
// selection signal: latCnt (e.g. when latCnt = 0, ipA0 = MemOutputA0[31:0], ..., ipB0 = MemOutputB0[31:0], ...)
reg [31:0] ipA0, ipA1, ipA2, ipA3;
reg [31:0] ipB0, ipB1, ipB2, ipB3;

`define SET_IP(BIT1, BIT2) \
	begin                              \
		ipA0 = MemOutputA0[BIT1:BIT2]; \
		ipA1 = MemOutputA1[BIT1:BIT2]; \
		ipA2 = MemOutputA2[BIT1:BIT2]; \
		ipA3 = MemOutputA3[BIT1:BIT2]; \
		ipB0 = MemOutputB0[BIT1:BIT2]; \
		ipB1 = MemOutputB1[BIT1:BIT2]; \
		ipB2 = MemOutputB2[BIT1:BIT2]; \
		ipB3 = MemOutputB3[BIT1:BIT2]; \
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
			ipB0 = 32'b0;
			ipB1 = 32'b0;
			ipB2 = 32'b0;
			ipB3 = 32'b0;
		end
	endcase
end


wire [31:0] opC00_out, opC01_out, opC02_out, opC03_out,
			opC10_out, opC11_out, opC12_out, opC13_out,
			opC20_out, opC21_out, opC22_out, opC23_out,
			opC30_out, opC31_out, opC32_out, opC33_out;


// systolic array
OSPEArray ospe_array (	clk, rstnPipe, rstnPsum,
						ipA0, ipA1, ipA2, ipA3,
						ipB0, ipB1, ipB2, ipB3,
						opC00_out, opC01_out, opC02_out, opC03_out,
						opC10_out, opC11_out, opC12_out, opC13_out,
						opC20_out, opC21_out, opC22_out, opC23_out,
						opC30_out, opC31_out, opC32_out, OpC33
					);


// systolic output synchronization (due to the systolic movement, outputs are not ready at the same clock cycle)
// reset with rstnPipe
// delay C00 by 6 cycles
// delay C01, C10 by 5 cycles
// delay C02, C11, C20 by 4 cycles
// delay C03, C12, C21, C30 by 3 cycles
// delay C13, C22, C31 by 2 cycles
// delay C23, C32 by 1 cycle
reg [31:0] opC00_d6, opC00_d5, opC00_d4, opC00_d3, opC00_d2, opC00_d1;
reg [31:0] opC01_d5, opC01_d4, opC01_d3, opC01_d2, opC01_d1;
reg [31:0] opC10_d5, opC10_d4, opC10_d3, opC10_d2, opC10_d1;
reg [31:0] opC02_d4, opC02_d3, opC02_d2, opC02_d1;
reg [31:0] opC11_d4, opC11_d3, opC11_d2, opC11_d1;
reg [31:0] opC20_d4, opC20_d3, opC20_d2, opC20_d1;
reg [31:0] opC03_d3, opC03_d2, opC03_d1;
reg [31:0] opC12_d3, opC12_d2, opC12_d1;
reg [31:0] opC21_d3, opC21_d2, opC21_d1;
reg [31:0] opC30_d3, opC30_d2, opC30_d1;
reg [31:0] opC13_d2, opC13_d1;
reg [31:0] opC22_d2, opC22_d1;
reg [31:0] opC31_d2, opC31_d1;
reg [31:0] opC23_d1;
reg [31:0] opC32_d1;

assign OpC00 = opC00_d1;
assign OpC01 = opC01_d1;
assign OpC02 = opC02_d1;
assign OpC03 = opC03_d1;
assign OpC10 = opC10_d1;
assign OpC11 = opC11_d1;
assign OpC12 = opC12_d1;
assign OpC13 = opC13_d1;
assign OpC20 = opC20_d1;
assign OpC21 = opC21_d1;
assign OpC22 = opC22_d1;
assign OpC23 = opC23_d1;
assign OpC30 = opC30_d1;
assign OpC31 = opC31_d1;
assign OpC32 = opC32_d1;



always @ (posedge clk) begin
	if (rstnPipe) begin
		opC00_d6 <= opC00_out;
		opC00_d5 <= opC00_d6;
		opC00_d4 <= opC00_d5;
		opC00_d3 <= opC00_d4;
		opC00_d2 <= opC00_d3;
		opC00_d1 <= opC00_d2;
		// OpC00    <= opC00_d1;

		opC01_d5 <= opC01_out;
		opC01_d4 <= opC01_d5;
		opC01_d3 <= opC01_d4;
		opC01_d2 <= opC01_d3;
		opC01_d1 <= opC01_d2;
		// OpC01    <= opC01_d1;

		opC10_d5 <= opC10_out;
		opC10_d4 <= opC10_d5;
		opC10_d3 <= opC10_d4;
		opC10_d2 <= opC10_d3;
		opC10_d1 <= opC10_d2;
		// OpC10    <= opC10_d1;

		opC02_d4 <= opC02_out;
		opC02_d3 <= opC02_d4;
		opC02_d2 <= opC02_d3;
		opC02_d1 <= opC02_d2;
		// OpC02    <= opC02_d1;

		opC11_d4 <= opC11_out;
		opC11_d3 <= opC11_d4;
		opC11_d2 <= opC11_d3;
		opC11_d1 <= opC11_d2;
		// OpC11    <= opC11_d1;

		opC20_d4 <= opC20_out;
		opC20_d3 <= opC20_d4;
		opC20_d2 <= opC20_d3;
		opC20_d1 <= opC20_d2;
		// OpC20    <= opC20_d1;

		opC03_d3 <= opC03_out;
		opC03_d2 <= opC03_d3;
		opC03_d1 <= opC03_d2;
		// OpC03    <= opC03_d1;

		opC12_d3 <= opC12_out;
		opC12_d2 <= opC12_d3;
		opC12_d1 <= opC12_d2;
		// OpC12    <= opC12_d1;

		opC21_d3 <= opC21_out;
		opC21_d2 <= opC21_d3;
		opC21_d1 <= opC21_d2;
		// OpC21    <= opC21_d1;

		opC30_d3 <= opC30_out;
		opC30_d2 <= opC30_d3;
		opC30_d1 <= opC30_d2;
		// OpC30    <= opC30_d1;

		opC13_d2 <= opC13_out;
		opC13_d1 <= opC13_d2;
		// OpC13    <= opC13_d1;

		opC22_d2 <= opC22_out;
		opC22_d1 <= opC22_d2;
		// OpC22    <= opC22_d1;

		opC31_d2 <= opC31_out;
		opC31_d1 <= opC31_d2;
		// OpC31    <= opC31_d1;

		opC23_d1 <= opC23_out;
		// OpC23    <= opC23_d1;

		opC32_d1 <= opC32_out;
		// OpC32    <= opC32_d1;

		// OpC33    <= opC33_out;
	end
	else begin
		opC00_d5 <= 32'b0;
		opC00_d4 <= 32'b0;
		opC00_d3 <= 32'b0;
		opC00_d2 <= 32'b0;
		opC00_d1 <= 32'b0;
	// OpC00    <= opC00_d1;


		opC01_d5 <= 32'b0;
		opC01_d4 <= 32'b0;
		opC01_d3 <= 32'b0;
		opC01_d2 <= 32'b0;
		opC01_d1 <= 32'b0;
		// OpC01    <= 32'b0;

		opC10_d5 <= 32'b0;
		opC10_d4 <= 32'b0;
		opC10_d3 <= 32'b0;
		opC10_d2 <= 32'b0;
		opC10_d1 <= 32'b0;
		// OpC10    <= 32'b0;

		opC02_d4 <= 32'b0;
		opC02_d3 <= 32'b0;
		opC02_d2 <= 32'b0;
		opC02_d1 <= 32'b0;
		// OpC02    <= 32'b0;

		opC11_d4 <= 32'b0;
		opC11_d3 <= 32'b0;
		opC11_d2 <= 32'b0;
		opC11_d1 <= 32'b0;
		// OpC11    <= 32'b0;

		opC20_d4 <= 32'b0;
		opC20_d3 <= 32'b0;
		opC20_d2 <= 32'b0;
		opC20_d1 <= 32'b0;
		// OpC20    <= 32'b0;

		opC03_d3 <= 32'b0;
		opC03_d2 <= 32'b0;
		opC03_d1 <= 32'b0;
		// OpC03    <= 32'b0;

		opC12_d3 <= 32'b0;
		opC12_d2 <= 32'b0;
		opC12_d1 <= 32'b0;
		// OpC12    <= 32'b0;

		opC21_d3 <= 32'b0;
		opC21_d2 <= 32'b0;
		opC21_d1 <= 32'b0;
		// OpC21    <= 32'b0;

		opC30_d3 <= 32'b0;
		opC30_d2 <= 32'b0;
		opC30_d1 <= 32'b0;
		// OpC30    <= 32'b0;

		opC13_d2 <= 32'b0;
		opC13_d1 <= 32'b0;
		// OpC13    <= 32'b0;

		opC22_d2 <= 32'b0;
		opC22_d1 <= 32'b0;
		// OpC22    <= 32'b0;

		opC31_d2 <= 32'b0;
		opC31_d1 <= 32'b0;
		// OpC31    <= 32'b0;

		opC23_d1 <= 32'b0;
		// OpC23    <= 32'b0;

		opC32_d1 <= 32'b0;
		// OpC32    <= 32'b0;

		// OpC33    <= 32'b0;


	end
end





endmodule
