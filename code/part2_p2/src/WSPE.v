////////////////////////////////////////////////////////////////
// input ports
// clk -clock signal
// rstnPsum -synchronous reset, to reset accumulation
// rstnPipe -synchronous reset, to reset ipA/ipB's systolic movement (opA/opB's storage)
// ipA -32-bit positive integer
// ipB -32-bit positive integer
// ipPsum -32-bit positive integer

// output ports
// opA -32-bit positive integer
// opPsum -32-bit positive integer
////////////////////////////////////////////////////////////////

module WSPE (clk, rstnPsum, rstnPipe, ipA, ipB, ipPsum, opA, opPsum);

// port definition
input clk, rstnPipe, rstnPsum;
input [31:0] ipA, ipB, ipPsum;
output reg [31:0] opA, opPsum;


// multiplication and accumulation (combinational logic)
wire [31:0] opPsum_wire = ipA * ipB + ipPsum;

// update opA (sequential logic, reset with rstnPipe)
always @(posedge clk) begin
	if (rstnPipe == 1'b0) begin
	opA <= 32'b0;
	end
else begin
	opA <= ipA;
	end
end

// update opPsum (sequential logic, reset with rstnPsum)
always @(posedge clk) begin
	if (rstnPsum == 1'b0) opPsum <= 32'b0;
	else opPsum <= opPsum_wire;
end


endmodule
