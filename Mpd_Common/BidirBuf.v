// Mimic the behavior of the SN74VMEH22501A 8-bit UBT transceiver
module BidirBuf(A, B, OEb, DIR);
parameter data_size = 32;
inout [data_size-1:0] A;
inout [data_size-1:0] B;
input OEb, DIR;

assign A = (DIR == 0 && OEb == 0) ? B : 'bz;
assign B = (DIR == 1 && OEb == 0) ? A : 'bz;

endmodule
