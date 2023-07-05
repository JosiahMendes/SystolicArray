module tb_TOP();

    parameter num_of_test_case  = 1024;
    parameter cycles_of_each_case = 17;
    parameter num_of_test_loops = num_of_test_case*cycles_of_each_case-1;

    reg clk;
    reg rstnSys;
    reg startSys;

    wire [255:0] MemOutputA0,MemOutputA1,MemOutputA2,MemOutputA3,MemOutputB0,MemOutputB1,MemOutputB2,MemOutputB3;
    wire [31:0] OpC00,OpC01,OpC02,OpC03,OpC10,OpC11,OpC12,OpC13,OpC20,OpC21,OpC22,OpC23,OpC30,OpC31,OpC32,OpC33;
    wire [9:0] BankAddr;
    wire start_check;

    // TOP module
    TOP TOP_INST
        (
            .clk(clk),
            .rstnSys(rstnSys),
            .startSys(startSys),
            .MemOutputA0(MemOutputA0),
            .MemOutputA1(MemOutputA1),
            .MemOutputA2(MemOutputA2),
            .MemOutputA3(MemOutputA3), 
            .MemOutputB0(MemOutputB0),
            .MemOutputB1(MemOutputB1),
            .MemOutputB2(MemOutputB2),
            .MemOutputB3(MemOutputB3),
            .OpC00(OpC00),
            .OpC01(OpC01),
            .OpC02(OpC02),
            .OpC03(OpC03),
            .OpC10(OpC10),
            .OpC11(OpC11),
            .OpC12(OpC12),
            .OpC13(OpC13),
            .OpC20(OpC20),
            .OpC21(OpC21),
            .OpC22(OpC22),
            .OpC23(OpC23),
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
    reg [255:0] DataInput;

    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA0 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputA0) );
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA1 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputA1) );
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA2 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputA2) );
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKA3 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputA3) );
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKB0 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputB0) );
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKB1 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputB1) );
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKB2 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputB2) );
    MockSRAM #(.DEPTH(num_of_test_case), .ADDR_WIDTH(10), .DATA_WIDTH(256)) SRAMBANKB3 ( .clk(clk), .cs(EnMemory), .we(EnWrite), .addr(BankAddr), .din(DataInput), .dout(MemOutputB3) );

    // Load DATA from external txt file into testbench Memory.
    reg [511:0] output_bits_reference  [0:num_of_test_case-1];
    initial begin
        $readmemb("../ref/tb_input_data_a0_bin.txt", SRAMBANKA0.memory);
        $readmemb("../ref/tb_input_data_a1_bin.txt", SRAMBANKA1.memory);
        $readmemb("../ref/tb_input_data_a2_bin.txt", SRAMBANKA2.memory);
        $readmemb("../ref/tb_input_data_a3_bin.txt", SRAMBANKA3.memory);
        $readmemb("../ref/tb_input_data_b0_bin.txt", SRAMBANKB0.memory);
        $readmemb("../ref/tb_input_data_b1_bin.txt", SRAMBANKB1.memory);
        $readmemb("../ref/tb_input_data_b2_bin.txt", SRAMBANKB2.memory);
        $readmemb("../ref/tb_input_data_b3_bin.txt", SRAMBANKB3.memory);
        $readmemb("../ref/tb_output_data_bin.txt", output_bits_reference);
    end

    // Testbench
    integer i, j;
    integer num_of_errors;

    initial begin
        $vcdplusfile("waveform.vpd");
        $vcdpluson();
        // initialization
        rstnSys = 1'b1;
        startSys = 1'b0;
        EnMemory = 1'b1;
        EnWrite = 1'b0;
        DataInput = 256'hz;
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
    wire [511:0] output_bits_current;
    reg  [511:0] output_bits  [0:num_of_test_case-1];
    assign output_bits_current = {OpC00,OpC01,OpC02,OpC03,OpC10,OpC11,OpC12,OpC13,OpC20,OpC21,OpC22,OpC23,OpC30,OpC31,OpC32,OpC33};

    always @(negedge clk) begin
        if (startSys) begin
	    if (start_check) begin
	        output_bits[BankAddr] = output_bits_current;
                if (BankAddr == (num_of_test_case-1)) begin
                    $writememb("output_bits.txt",output_bits);
                    num_of_errors = 0;
    	            for (j = 0;j< num_of_test_case;j = j + 1) begin
                        if (output_bits[j] != output_bits_reference[j])
                            num_of_errors = num_of_errors + 1;
    		    end
    		    if (num_of_errors == 0)
                        $display("\n\n\nCongratulations, your code passed all the %d tests...\n\n\n", num_of_test_case);
    		    else
        	        $display("\n\n\n%d out of %d test cases failed\n\n\n", num_of_errors, num_of_test_case);
                end
            end
        end
    end

endmodule

