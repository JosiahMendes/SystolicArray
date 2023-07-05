////////////////////////////////////////////////////////////////
// input ports
// clk                           -clock signal
// rstnSys                       -synchronous reset, to reset the system (active low)
// startSys                      -start systolic calculation (matrix A[4*8] * matrix B[8*4])
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
// start_check                   -to testbench, to start storing of calculation results, to be activated when calculation is done (active high)
////////////////////////////////////////////////////////////////

module TOP (clk, rstnSys, startSys, MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3, MemOutputB0, MemOutputB1, MemOutputB2, MemOutputB3, OpC00, OpC01, OpC02, OpC03, OpC10, OpC11, OpC12, OpC13, OpC20, OpC21, OpC22, OpC23, OpC30, OpC31, OpC32, OpC33, BankAddr, start_check);

// port definition
// fill in your code here
input clk, rstnSys, startSys;
input [255:0] MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3;
input [255:0] MemOutputB0, MemOutputB1, MemOutputB2, MemOutputB3;

output [31:0] OpC00, OpC01, OpC02, OpC03;
output [31:0] OpC10, OpC11, OpC12, OpC13;
output [31:0] OpC20, OpC21, OpC22, OpC23;
output [31:0] OpC30, OpC31, OpC32, OpC33;
output [9:0] BankAddr;
output start_check;

// wire definition
// fill in your code here
wire [15:0] rstnPsum;
wire rstnPipe, rstnAddr, addrInc;
wire [3:0] latCnt;


// instantiate your CTRL.v and DATA.v here

CTRL ctrl(  clk, rstnSys, startSys,
            rstnPsum,
            rstnPipe, rstnAddr, addrInc,
            latCnt, start_check
        );
DATA data(  clk,  rstnPipe, rstnAddr, addrInc,
            rstnPsum,
            latCnt,
            MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3,
            MemOutputB0, MemOutputB1, MemOutputB2, MemOutputB3,
            OpC00, OpC01, OpC02, OpC03, OpC10, OpC11, OpC12, OpC13,
            OpC20, OpC21, OpC22, OpC23, OpC30, OpC31, OpC32, OpC33,
            BankAddr
        );
endmodule
