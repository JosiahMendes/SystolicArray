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
// fill in your code here
input clk, rstnPipe, rstnPsum;
input wire [31:0] ipA, ipB;
output reg [31:0] opA, opB, opC;

// multiplication and accumulation (combinational logic)
// fill in your code here
wire [31:0] opC_wire = ipA * ipB + opC;


// update opA, opB (sequential logic, reset with rstnPipe)
// fill in your code here
// opA should be updated a cycle after inA, same for opB

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
// fill in your code here

always @(posedge clk) begin
	if (!rstnPsum) begin
	opC <= 32'b0;
	end
	else begin
	opC <= opC_wire;
	end
end


endmodule
