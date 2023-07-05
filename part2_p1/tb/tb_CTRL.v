module CTRL_TB;

reg clk, rstnSys, startSys;
wire [15:0] rstnPsum;
wire rstnPipe, rstnAddr, addrInc;
wire [3:0] latCnt;
wire start_check;

initial begin
	// $dumpfile("results.vcd");
	// $dumpvars(0, OSPE_TB);
	// $dumpon;
	$vcdplusfile("results.vpd");
	$vcdpluson(0, CTRL_TB);
	clk = 0;
	rstnSys = 1;
	startSys = 0;
	#2 rstnSys = 0;
	#2 rstnSys = 1;
	#6 startSys = 1;
	#100;
	$vcdplusoff(0, CTRL_TB);
	// $dumpoff;
	$finish;
end

always begin
	#1 clk = ~clk;
end

CTRL inst (clk, rstnSys, startSys, rstnPsum, rstnPipe, rstnAddr, addrInc, latCnt, start_check);


endmodule