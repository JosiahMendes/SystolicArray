////////////////////////////////////////////////////////////////
// input ports
// clk         -clock signals
// rstnPipe    -synchronous reset, to reset all systolic movements (1 bit)
// rstnPsum    -synchronous reset, to reset accumulation of products (16 bits, each bit controls a PE)
// ipA0        -32-bit positive integer, input to the first row of the OSPE array
// ipA1        -32-bit positive integer, input to the second row of the OSPE array
// ipA2        -32-bit positive integer, input to the third row of the OSPE array
// ipA3        -32-bit positive integer, input to the fourth row of the OSPE array
// ipB0        -32-bit positive integer, input to the first column of the OSPE array
// ipB1        -32-bit positive integer, input to the second column of the OSPE array
// ipB2        -32-bit positive integer, input to the third column of the OSPE array
// ipB3        -32-bit positive integer, input to the fourth column of the OSPE array

// output ports
// opC00       -32-bit positive integer, output from the OSPE(0,0)
// opC01       -32-bit positive integer, output from the OSPE(0,1)
// opC02       -32-bit positive integer, output from the OSPE(0,2)
// opC03       -32-bit positive integer, output from the OSPE(0,3)
// opC10       -32-bit positive integer, output from the OSPE(1,0)
// opC11       -32-bit positive integer, output from the OSPE(1,1)
// opC12       -32-bit positive integer, output from the OSPE(1,2)
// opC13       -32-bit positive integer, output from the OSPE(1,3)
// opC20       -32-bit positive integer, output from the OSPE(2,0)
// opC21       -32-bit positive integer, output from the OSPE(2,1)
// opC22       -32-bit positive integer, output from the OSPE(2,2)
// opC23       -32-bit positive integer, output from the OSPE(2,3)
// opC30       -32-bit positive integer, output from the OSPE(3,0)
// opC31       -32-bit positive integer, output from the OSPE(3,1)
// opC32       -32-bit positive integer, output from the OSPE(3,2)
// opC33       -32-bit positive integer, output from the OSPE(3,3)
////////////////////////////////////////////////////////////////

module OSPEArray (clk, rstnPipe, rstnPsum, ipA0, ipA1, ipA2, ipA3, ipB0, ipB1, ipB2, ipB3, opC00, opC01, opC02, opC03, opC10, opC11, opC12, opC13, opC20, opC21, opC22, opC23, opC30, opC31, opC32, opC33);

// port definition
input clk, rstnPipe;
input [15:0] rstnPsum;
input [31:0] ipA0, ipA1, ipA2, ipA3, ipB0, ipB1, ipB2, ipB3;
output [31:0] 	opC00, opC01, opC02, opC03, opC10, opC11, opC12, opC13,
				opC20, opC21, opC22, opC23, opC30, opC31, opC32, opC33;


// input delay for synchronization
// reset with rstnPipe
// delay ipA1, ipB1 by 1 cycle
// delay ipA2, ipB2 by 2 cycles
// delay ipA3, ipB3 by 3 cycles
reg [31:0] ipA1_d1, ipB1_d1;
reg [31:0] ipA2_d1, ipA2_d2, ipB2_d1, ipB2_d2;
reg [31:0] ipA3_d1, ipA3_d2, ipA3_d3, ipB3_d1, ipB3_d2, ipB3_d3;
always @(posedge clk) begin
	if (!rstnPipe) begin
		ipA1_d1 <= 32'b0;
		ipB1_d1 <= 32'b0;
		ipA2_d1 <= 32'b0;
		ipA2_d2 <= 32'b0;
		ipB2_d1 <= 32'b0;
		ipB2_d2 <= 32'b0;
		ipA3_d1 <= 32'b0;
		ipA3_d2 <= 32'b0;
		ipA3_d3 <= 32'b0;
		ipB3_d1 <= 32'b0;
		ipB3_d2 <= 32'b0;
		ipB3_d3 <= 32'b0;
	end else begin
		ipA1_d1 <= ipA1;
		ipA2_d1 <= ipA2;
		ipA3_d1 <= ipA3;
		ipB1_d1 <= ipB1;
		ipB2_d1 <= ipB2;
		ipB3_d1 <= ipB3;

		ipA2_d2 <= ipA2_d1;
		ipA3_d2 <= ipA3_d1;
		ipB2_d2 <= ipB2_d1;
		ipB3_d2 <= ipB3_d1;

		ipA3_d3 <= ipA3_d2;
		ipB3_d3 <= ipB3_d2;
	end
end


// 4*4 OSPEs, reset with rstnPipe and rstnPsum
// rstnPipe has 1 bit (shared by 16 PEs)
// rstnPsum has 16 bits (the LSBs are mapped to PE00, PE01, PE02, PE03,...)
// instantiate OSPE module by 16 times with correct interconnection
wire [31:0] opA00, opA01, opA02, opA03, opA10, opA11, opA12, opA13, opA20, opA21, opA22, opA23, opA30, opA31, opA32, opA33;
wire [31:0] opB00, opB01, opB02, opB03, opB10, opB11, opB12, opB13, opB20, opB21, opB22, opB23, opB30, opB31, opB32, opB33;


OSPE ospe00 (clk, rstnPipe, rstnPsum[00], ipA0, ipB0, opA00, opB00, opC00);
OSPE ospe01 (clk, rstnPipe, rstnPsum[01], opA00, ipB1_d1, opA01, opB01, opC01);
OSPE ospe02 (clk, rstnPipe, rstnPsum[02], opA01, ipB2_d2, opA02, opB02, opC02);
OSPE ospe03 (clk, rstnPipe, rstnPsum[03], opA02, ipB3_d3, opA03, opB03, opC03);
OSPE ospe10 (clk, rstnPipe, rstnPsum[04], ipA1_d1, opB00, opA10, opB10, opC10);
OSPE ospe11 (clk, rstnPipe, rstnPsum[05], opA10, opB01, opA11, opB11, opC11);
OSPE ospe12 (clk, rstnPipe, rstnPsum[06], opA11, opB02, opA12, opB12, opC12);
OSPE ospe13 (clk, rstnPipe, rstnPsum[07], opA12, opB03, opA13, opB13, opC13);
OSPE ospe20 (clk, rstnPipe, rstnPsum[08], ipA2_d2, opB10, opA20, opB20, opC20);
OSPE ospe21 (clk, rstnPipe, rstnPsum[09], opA20, opB11, opA21, opB21, opC21);
OSPE ospe22 (clk, rstnPipe, rstnPsum[10], opA21, opB12, opA22, opB22, opC22);
OSPE ospe23 (clk, rstnPipe, rstnPsum[11], opA22, opB13, opA23, opB23, opC23);
OSPE ospe30 (clk, rstnPipe, rstnPsum[12], ipA3_d3, opB20, opA30, opB30, opC30);
OSPE ospe31 (clk, rstnPipe, rstnPsum[13], opA30, opB21, opA31, opB31, opC31);
OSPE ospe32 (clk, rstnPipe, rstnPsum[14], opA31, opB22, opA32, opB32, opC32);
OSPE ospe33 (clk, rstnPipe, rstnPsum[15], opA32, opB23, opA33, opB33, opC33);
endmodule
