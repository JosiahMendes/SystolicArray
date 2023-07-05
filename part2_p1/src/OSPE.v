////////////////////////////////////////////////////////////////
// input ports
// clk -clock signal
// rstnPipe -synchronous reset, to reset ipA/ipB's systolic movement (opA/opB's storage)
// rstnPsum -synchronous reset, to reset accumulation
// ipA -32-bit positive integer
// ipB -32-bit positive integer

// output ports
// opA -32-bit positive integer
// opB -32-bit positive integer
// opC -32-bit positive integer
////////////////////////////////////////////////////////////////

module OSPE (clk, rstnPipe, rstnPsum, ipA, ipB, opA, opB, opC);

// port definition
input clk, rstnPipe, rstnPsum;
input [31:0] ipA, ipB;
output reg [31:0] opA, opB, opC;

// multiplication and accumulation (combinational logic)
wire [31:0] opC_wire = ipA * ipB + opC;

// update opA, opB (sequential logic, reset with rstnPipe)
always @(posedge clk) begin
	if (!rstnPipe) begin
	opA <= 32'b0;
	opB <= 32'b0;
	end
else begin
	opA <= ipA;
	opB <= ipB;
	end
end

// update opC (sequential logic, reset with rstnPsum)
always @(posedge clk) begin
	if (!rstnPsum) opC <= 32'b0;
	else  opC <= opC_wire;
end

endmodule
