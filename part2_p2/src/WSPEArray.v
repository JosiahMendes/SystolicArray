////////////////////////////////////////////////////////////////
// input ports
// clk         -clock signals
// rstnPsum    -synchronous reset, to reset accumulation of products (16 bits, each bit controls a PE)
// rstnPipe    -synchronous reset, to reset all systolic movements (1 bit)
// ipA0        -32-bit positive integer, input to the first row of the WSPE array
// ipA1        -32-bit positive integer, input to the second row of the WSPE array
// ipA2        -32-bit positive integer, input to the third row of the WSPE array
// ipA3        -32-bit positive integer, input to the fourth row of the WSPE array
// ipPsum0     -32-bit positive integer, input to the first column of the WSPE array
// ipPsum1     -32-bit positive integer, input to the second column of the WSPE array
// ipPsum2     -32-bit positive integer, input to the third column of the WSPE array
// ipPsum3     -32-bit positive integer, input to the fourth column of the WSPE array
// opB00       -32-bit positive integer, input to the WSPE(0,0)
// opB01       -32-bit positive integer, input to the WSPE(0,1)
// opB02       -32-bit positive integer, input to the WSPE(0,2)
// opB03       -32-bit positive integer, input to the WSPE(0,3)
// opB10       -32-bit positive integer, input to the WSPE(1,0)
// opB11       -32-bit positive integer, input to the WSPE(1,1)
// opB12       -32-bit positive integer, input to the WSPE(1,2)
// opB13       -32-bit positive integer, input to the WSPE(1,3)
// opB20       -32-bit positive integer, input to the WSPE(2,0)
// opB21       -32-bit positive integer, input to the WSPE(2,1)
// opB22       -32-bit positive integer, input to the WSPE(2,2)
// opB23       -32-bit positive integer, input to the WSPE(2,3)
// opB30       -32-bit positive integer, input to the WSPE(3,0)
// opB31       -32-bit positive integer, input to the WSPE(3,1)
// opB32       -32-bit positive integer, input to the WSPE(3,2)
// opB33       -32-bit positive integer, input to the WSPE(3,3)

// output ports
// opC30       -32-bit positive integer, output from the WSPE(3,0)
// opC31       -32-bit positive integer, output from the WSPE(3,1)
// opC32       -32-bit positive integer, output from the WSPE(3,2)
// opC33       -32-bit positive integer, output from the WSPE(3,3)
////////////////////////////////////////////////////////////////

module WSPEArray (clk, rstnPsum, rstnPipe, ipA0, ipA1, ipA2, ipA3, ipPsum0, ipPsum1, ipPsum2, ipPsum3, ipB00, ipB01, ipB02, ipB03, ipB10, ipB11, ipB12, ipB13, ipB20, ipB21, ipB22, ipB23, ipB30, ipB31, ipB32, ipB33, opC30, opC31, opC32, opC33);

// port definition
input clk, rstnPipe;
input [15:0] rstnPsum;
input [31:0] ipA0, ipA1, ipA2, ipA3, ipPsum0, ipPsum1, ipPsum2, ipPsum3, ipB00, ipB01, ipB02, ipB03, ipB10, ipB11, ipB12, ipB13, ipB20, ipB21, ipB22, ipB23, ipB30, ipB31, ipB32, ipB33;
output [31:0] opC30, opC31, opC32, opC33;

// input delay for synchronization
// reset with rstnPipe
// delay ipA1 by 1 cycle
// delay ipA2 by 2 cycles
// delay ipA3 by 3 cycles
reg [31:0] ipA1_d1, ipA2_d1, ipA2_d2, ipA3_d1, ipA3_d2, ipA3_d3;
reg [31:0] ipPsum1_d1, ipPsum2_d1, ipPsum2_d2, ipPsum3_d1, ipPsum3_d2, ipPsum3_d3;
always @(posedge clk) begin
	if (!rstnPipe) begin
		ipA1_d1 <= 32'b0;
		ipA2_d1 <= 32'b0;
		ipA2_d2 <= 32'b0;
		ipA3_d1 <= 32'b0;
		ipA3_d2 <= 32'b0;
		ipA3_d3 <= 32'b0;

		ipPsum1_d1 <= 32'b0;
		ipPsum2_d1 <= 32'b0;
		ipPsum2_d2 <= 32'b0;
		ipPsum3_d1 <= 32'b0;
		ipPsum3_d2 <= 32'b0;
		ipPsum3_d3 <= 32'b0;
	end else begin
		ipA1_d1 <= ipA1;
		ipA2_d1 <= ipA2;
		ipA3_d1 <= ipA3;

		ipA2_d2 <= ipA2_d1;
		ipA3_d2 <= ipA3_d1;

		ipA3_d3 <= ipA3_d2;

		ipPsum1_d1 <= ipPsum1;
		ipPsum2_d1 <= ipPsum2;
		ipPsum3_d1 <= ipPsum3;

		ipPsum2_d2 <= ipPsum2_d1;
		ipPsum3_d2 <= ipPsum3_d1;

		ipPsum3_d3 <= ipPsum3_d2;
	end
end

// 4*4 WSPEs, reset with rstnPipe and rstnPsum
// rstnPipe has 1 bit (shared by 16 PEs)
// rstnPsum has 16 bits (the LSBs are mapped to PE00, PE01, PE02, PE03,...)
// instantiate WSPE module by 16 times with correct interconnection
wire [31:0] opPsum00, opPsum01, opPsum02, opPsum03;
wire [31:0] opPsum10, opPsum11, opPsum12, opPsum13;
wire [31:0] opPsum20, opPsum21, opPsum22, opPsum23;
wire [31:0] opA00, opA01, opA02, opA03;
wire [31:0] opA10, opA11, opA12, opA13;
wire [31:0] opA20, opA21, opA22, opA23;
wire [31:0] opA30, opA31, opA32, opA33;


WSPE wspe00 (clk, rstnPsum[00], rstnPipe, ipA0,    ipB00, ipPsum0,     opA00, opPsum00);
WSPE wspe01 (clk, rstnPsum[01], rstnPipe, opA00,   ipB01, ipPsum1_d1,  opA01, opPsum01);
WSPE wspe02 (clk, rstnPsum[02], rstnPipe, opA01,   ipB02, ipPsum2_d2,  opA02, opPsum02);
WSPE wspe03 (clk, rstnPsum[03], rstnPipe, opA02,   ipB03, ipPsum3_d3,  opA03, opPsum03);
WSPE wspe10 (clk, rstnPsum[04], rstnPipe, ipA1_d1, ipB10, opPsum00,    opA10, opPsum10);
WSPE wspe11 (clk, rstnPsum[05], rstnPipe, opA10,   ipB11, opPsum01,    opA11, opPsum11);
WSPE wspe12 (clk, rstnPsum[06], rstnPipe, opA11,   ipB12, opPsum02,    opA12, opPsum12);
WSPE wspe13 (clk, rstnPsum[07], rstnPipe, opA12,   ipB13, opPsum03,    opA13, opPsum13);
WSPE wspe20 (clk, rstnPsum[08], rstnPipe, ipA2_d2, ipB20, opPsum10,    opA20, opPsum20);
WSPE wspe21 (clk, rstnPsum[09], rstnPipe, opA20,   ipB21, opPsum11,    opA21, opPsum21);
WSPE wspe22 (clk, rstnPsum[10], rstnPipe, opA21,   ipB22, opPsum12,    opA22, opPsum22);
WSPE wspe23 (clk, rstnPsum[11], rstnPipe, opA22,   ipB23, opPsum13,    opA23, opPsum23);
WSPE wspe30 (clk, rstnPsum[12], rstnPipe, ipA3_d3, ipB30, opPsum20,    opA30, opC30);
WSPE wspe31 (clk, rstnPsum[13], rstnPipe, opA30,   ipB31, opPsum21,    opA31, opC31);
WSPE wspe32 (clk, rstnPsum[14], rstnPipe, opA31,   ipB32, opPsum22,    opA32, opC32);
WSPE wspe33 (clk, rstnPsum[15], rstnPipe, opA32,   ipB33, opPsum23,    opA33, opC33);

endmodule
