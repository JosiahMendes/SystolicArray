module OSPE_TB;

reg clk, rstnPipe, rstnPsum;
reg [31:0] ipA, ipB;
wire [31:0] opA, opB, opC;

initial begin
	$dumpfile("results.vcd");
	$dumpvars(0, OSPE_TB);
	$dumpon;
	// $vcdplusfile("results.vpd");
	// $vcdpluson(0, OSPE_TB);
	clk = 1;
	rstnPipe = 0;
	rstnPsum = 0;
	ipA = 0;
	ipB = 0;
	#2 rstnPipe = 1;
 	   rstnPsum = 1;
	#2
	ipA = 1;
	ipB = 1;
	#2
	ipA = 0;
	ipB = 0;
	#2
	rstnPipe = 0;
	#8
	// $vcdplusoff(0, OSPE_TB);
	$dumpoff;
	$finish;
end

always begin
	#1 clk = ~clk;
end

OSPE instance1 (clk, rstnPipe, rstnPsum, ipA, ipB, opA, opB, opC);

endmodule