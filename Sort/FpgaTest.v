/* 
*  
*/

module Fpga(input CLK, input RST, input [11:0] DIN, input VALID, output [11:0] DOUT, output [7:0] N_CELLS);


Sorter #(12,32) Dut(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .DO(DOUT), .N_CELLS(N_CELLS));


endmodule

