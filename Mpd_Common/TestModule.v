module TestModule(RSTb, CLK, REb, OEb, CEb, ADDR, USER_DATA);
input RSTb, CLK, REb, OEb, CEb;
input [21:0] ADDR;
output [63:0] USER_DATA;

reg [63:0] internal_data;
wire [15:0] xxx;

assign USER_DATA = (CEb == 0 && OEb == 0) ? {xxx, swap_bits(xxx), ~swap_bits(xxx), ~xxx} : 64'bz;

lfsr16_counter lfsr_counter(.clk(CLK), .resetB(RSTb) , .ceB(CEb|REb), .lfsr_done(), .lfsr(xxx));
/*
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
		internal_data <= 0;
	else
		if( REb == 0 )
			internal_data <= {10'h15F, ADDR[0], ADDR[1],  ADDR[2], ADDR[3], ADDR[4], ADDR[5], ADDR[7], ADDR[7],
				ADDR[8], ADDR[9],  ADDR[10], ADDR[11], ADDR[12], ADDR[13], ADDR[14], ADDR[15],
				ADDR[16], ADDR[17],  ADDR[18], ADDR[19], ADDR[20], ADDR[21],
				10'h2A0, ADDR};
end
*/

function [15:0] swap_bits;
input [15:0] y;
begin
	swap_bits[15] = y[0];
	swap_bits[14] = y[1];
	swap_bits[13] = y[2];
	swap_bits[12] = y[3];
	swap_bits[11] = y[4];
	swap_bits[10] = y[5];
	swap_bits[9] = y[6];
	swap_bits[8] = y[7];
	swap_bits[7] = y[8];
	swap_bits[6] = y[9];
	swap_bits[5] = y[10];
	swap_bits[4] = y[11];
	swap_bits[3] = y[12];
	swap_bits[2] = y[13];
	swap_bits[1] = y[14];
	swap_bits[0] = y[15];
end
endfunction

endmodule

// 16-bit LFSR counter
module lfsr16_counter(input clk, input resetB, input ceB, output reg lfsr_done, output reg [15:0] lfsr);

wire d0, lfsr_equal;

xnor(d0, lfsr[15], lfsr[14], lfsr[12], lfsr[3]);	// d0 = 0 if number of '1' is even
assign lfsr_equal = (lfsr == 16'h8000);

always @(posedge clk or negedge resetB)
begin
    if( resetB == 0 ) begin
        lfsr <= 0;
        lfsr_done <= 0;
    end
    else
	begin
        if( ceB == 0 )
            lfsr <= lfsr_equal ? 16'h0 : {lfsr[14:0],d0};
		lfsr_done <= lfsr_equal;
    end
end
endmodule


