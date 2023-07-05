module tb_TOP();

    parameter num_of_test_case  = 1024;
    parameter cycles_of_each_case = 17;
    parameter num_of_test_loops = num_of_test_case*cycles_of_each_case-1;

    reg clk;
    reg rstnSys;
    reg startSys;

    wire [255:0] MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3;
    wire [511:0] MemOutputB;
    wire [31:0] ipPsum;
    wire [31:0] OpC30, OpC31, OpC32, OpC33;
    wire [9:0] BankAddr;
    wire start_check;

    // TOP module
    assign ipPsum = 32'd0;
    TOP TOP_INST   
        (
            .clk(clk),
            .rstnSys(rstnSys),
            .startSys(startSys),
            .MemOutputA0(MemOutputA0),
            .MemOutputA1(MemOutputA1),
            .MemOutputA2(MemOutputA2),
            .MemOutputA3(MemOutputA3),
            .MemOutputB(MemOutputB),
            .ipPsum(ipPsum),
            .OpC30(OpC30),
            .OpC31(OpC31),
            .OpC32(OpC32),
            .OpC33(OpC33),
            .BankAddr(BankAddr),
            .start_check(start_check)
        );

    // clock signal
    parameter period = 5;
    initial begin
        clk = 1'b0;
        forever #2.5 clk = ~clk;
    end

    // Mock SRAM module
    reg EnMemory, EnWrite;
    reg [255:0] DataInput256;
    reg [511:0] DataInput512;

    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA0 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput256), .dout(MemOutputA0));
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA1 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput256), .dout(MemOutputA1));
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA2 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput256), .dout(MemOutputA2));
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA3 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput256), .dout(MemOutputA3));
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(512)) SRAMBANKB ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput512), .dout(MemOutputB));

    // Load DATA from external txt file into testbench Memory.
    reg  [1023:0] output_bits_reference  [0:num_of_test_case-1];
    initial begin
        $readmemb("../ref/tb_input_data_a0_bin.txt", SRAMBANKA0.memory);
        $readmemb("../ref/tb_input_data_a1_bin.txt", SRAMBANKA1.memory);
        $readmemb("../ref/tb_input_data_a2_bin.txt", SRAMBANKA2.memory);
        $readmemb("../ref/tb_input_data_a3_bin.txt", SRAMBANKA3.memory);
        $readmemb("../ref/tb_input_data_b_bin.txt", SRAMBANKB.memory);
        $readmemb("../ref/tb_output_data_bin.txt", output_bits_reference);
    end

    // Testbench
    integer i, j;
    integer num_of_errors;

    initial begin
        $vcdplusfile("waveform.vpd");
        $vcdpluson();
        // initialization
        clk = 1'b0;
        rstnSys = 1'b1;
        startSys = 1'b0;
        EnMemory = 1'b1;
        EnWrite = 1'b0;
        DataInput256 = 256'hz;
        DataInput512 = 512'hz;
        #period;
        // reset
        rstnSys = 1'b0;
        #period;
        rstnSys = 1'b1;
        #period;
        #period;
        #period;
        // start
        startSys = 1'b1;
        for (i=0;i<num_of_test_loops;i=i+1) begin
            #period;
        end
        #period;
        #period;
        #period;
        // stop
        $vcdplusoff();
        $finish;
    end

    // record output
    wire [127:0] output_bits_current;
    reg  [127:0] output_bits_round7 [0:num_of_test_case-1];
    reg  [127:0] output_bits_round8 [0:num_of_test_case-1];
    reg  [127:0] output_bits_round9 [0:num_of_test_case-1];
    reg  [127:0] output_bits_round10 [0:num_of_test_case-1];
    reg  [127:0] output_bits_round11 [0:num_of_test_case-1];
    reg  [127:0] output_bits_round12 [0:num_of_test_case-1];
    reg  [127:0] output_bits_round13 [0:num_of_test_case-1];
    reg  [127:0] output_bits_round14 [0:num_of_test_case-1];
    reg  [1023:0] output_bits [0:num_of_test_case-1];
    assign output_bits_current = {OpC30, OpC31, OpC32, OpC33};

    always@(negedge clk) begin
        if (startSys) begin
            if (start_check) begin
                output_bits_round7[BankAddr] = output_bits_current;
                #period;
                output_bits_round8[BankAddr] = output_bits_current;
                #period;
                output_bits_round9[BankAddr] = output_bits_current;
                #period;
                output_bits_round10[BankAddr] = output_bits_current;
                #period;
                output_bits_round11[BankAddr] = output_bits_current;
                #period;
                output_bits_round12[BankAddr] = output_bits_current;
                #period;
                output_bits_round13[BankAddr] = output_bits_current;
                #period;
                output_bits_round14[BankAddr] = output_bits_current;
                if (BankAddr == (num_of_test_case-1)) begin
                    $writememb("output_bits_round7.txt",output_bits_round7);
                    $writememb("output_bits_round8.txt",output_bits_round8);
                    $writememb("output_bits_round9.txt",output_bits_round9);
                    $writememb("output_bits_round10.txt",output_bits_round10);
                    $writememb("output_bits_round11.txt",output_bits_round11);
                    $writememb("output_bits_round12.txt",output_bits_round12);
                    $writememb("output_bits_round13.txt",output_bits_round13);
                    $writememb("output_bits_round14.txt",output_bits_round14);
                    for (j = 0;j < num_of_test_case;j = j + 1) begin
	                output_bits[j] = {output_bits_round14[j], output_bits_round13[j], output_bits_round12[j], output_bits_round11[j], output_bits_round10[j], output_bits_round9[j], output_bits_round8[j], output_bits_round7[j]};
	            end
                    num_of_errors = 0;
                    for (j = 0;j < num_of_test_case;j = j + 1) begin
                        if (output_bits[j] != output_bits_reference[j]) begin
                            num_of_errors = num_of_errors + 1;
                        end
                    end
                    if (num_of_errors == 0) begin
                        $display("\n\n\nCongratulations, your code passed all the %d tests...\n\n\n", num_of_test_case);
                    end
                    else begin
                        $display("\n\n\n%d out of %d test cases failed\n\n\n", num_of_errors, num_of_test_case);
                    end
                end
            end
        end
    end

endmodule

