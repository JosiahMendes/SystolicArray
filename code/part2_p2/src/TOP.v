////////////////////////////////////////////////////////////////
// input ports
// clk                           -clock signal
// rstnSys                       -synchronous reset, to reset the system (active low)
// startSys                      -start systolic calculation (matrix A[8*4] * matrix B[4*4])
// MemOutputA0                   -from testbench, test cases for the first column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA1                   -from testbench, test cases for the second column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA2                   -from testbench, test cases for the third column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputA3                   -from testbench, test cases for the fourth column of matrix A (8 elements * 32 bits = 256 bits)
// MemOutputB                    -from testbench, test cases for matrix B (4*4 elements * 32 bits = 512 bits)
// ipPsum                        -from testbench, to initialize ipPsum port for the first row of the PE array

// output ports
// OpC30, OpC31, OpC32, OpC33    -4 elements in each row of the calculation output (4 32-bit elements)
// BankAddr                      -to testbench, to select test case (10-bit address)
// start_check                   -to testbench, to start storing of calculation results, to be activated when the first row of the product is generated (active high)
////////////////////////////////////////////////////////////////

module TOP (clk, rstnSys, startSys, MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3, MemOutputB, ipPsum, OpC30, OpC31, OpC32, OpC33, BankAddr, start_check);

// port definition
input clk, rstnSys, startSys;
input [255:0] MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3;
input [511:0] MemOutputB;
input [31:0] ipPsum;

output [31:0] OpC30, OpC31, OpC32, OpC33;
output [9:0] BankAddr;
output start_check;


// wire definition
wire [15:0] rstnPsum;
wire rstnPipe, rstnAddr, addrInc;
wire [3:0] latCnt;


// instantiate your CTRL.v and DATA.v here
// fill in your code here

// CTRL.v
CTRL ctrl(  clk, rstnSys, startSys,
            rstnPsum,
            rstnPipe, rstnAddr, addrInc,
            latCnt, start_check
        );

// DATA.v
DATA data(  clk, rstnPsum, rstnPipe,
            rstnAddr, addrInc, latCnt,
            MemOutputA0, MemOutputA1, MemOutputA2, MemOutputA3, MemOutputB,
            ipPsum, OpC30, OpC31, OpC32, OpC33, BankAddr
        );


endmodule
