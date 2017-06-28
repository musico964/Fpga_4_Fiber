/*
 * based on idea found in: http://hackaday.com/2016/01/20/a-linear-time-sorting-algorithm-for-fpgas/
 */

module Sorter(CLK, RST, DIN, VALID, DO, N_CELLS);
parameter data_size = 8;
parameter depth = 4;	// 256 maximum

input CLK, RST, VALID;
input [data_size-1:0] DIN;
output [data_size-1:0] DO;
output [7:0] N_CELLS;

wire [depth-1:0] s, p, e;
wire [data_size-1:0] dout [depth-1:0];
wire [depth-1:1] pp;

assign DO = dout[N_CELLS>>1];	// get median value

/*
assign pp[1] = |p[0:0];
assign pp[2] = |p[0:1];
assign pp[3] = |p[0:2];
assign pp[4] = |p[0:3];
assign pp[5] = |p[0:4];

SortCell #(data_size) SortCell0(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(8'b0), .PREV_STATUS(1'b1), .PREV_PUSH(1'b0), .DO_NOTHING(1'b0),
	.STATUS(s[0]), .PUSH(p[0]), .EQUAL(e[0]), .DOUT(dout[0]));
SortCell #(data_size) SortCell1(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(dout[0]), .PREV_STATUS(s[0]), .PREV_PUSH(pp[1]), .DO_NOTHING(|e),
	.STATUS(s[1]), .PUSH(p[1]), .EQUAL(e[1]), .DOUT(dout[1]));
SortCell #(data_size) SortCell2(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(dout[1]), .PREV_STATUS(s[1]), .PREV_PUSH(pp[2]), .DO_NOTHING(|e),
	.STATUS(s[2]), .PUSH(p[2]), .EQUAL(e[2]), .DOUT(dout[2]));
SortCell #(data_size) SortCell3(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(dout[2]), .PREV_STATUS(s[2]), .PREV_PUSH(pp[3]), .DO_NOTHING(|e),
	.STATUS(s[3]), .PUSH(p[3]), .EQUAL(e[3]), .DOUT(dout[3]));
SortCell #(data_size) SortCell4(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(dout[3]), .PREV_STATUS(s[3]), .PREV_PUSH(pp[4]), .DO_NOTHING(|e),
	.STATUS(s[4]), .PUSH(p[4]), .EQUAL(e[4]), .DOUT(dout[4]));
SortCell #(data_size) SortCell5(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(dout[4]), .PREV_STATUS(s[4]), .PREV_PUSH(pp[5]), .DO_NOTHING(|e),
	.STATUS(s[5]), .PUSH(p[5]), .EQUAL(e[5]), .DOUT(dout[5]));
*/

generate
	genvar k;
	for(k=1; k<depth; k=k+1)
	begin:PrevPush
		assign pp[k] = |p[k-1:0];
	end
endgenerate

SortCell #(data_size) Sort0(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(0), .PREV_STATUS(1'b1), .PREV_PUSH(1'b0), .DO_NOTHING(1'b0),
	.STATUS(s[0]), .PUSH(p[0]), .EQUAL(e[0]), .DOUT(dout[0]));
generate
	genvar i;
	for(i=1; i<depth; i=i+1)
	begin:Sort
		SortCell #(data_size) Sort(.CLK(CLK), .RST(RST), .DIN(DIN), .VALID(VALID), .PREV_DATA(dout[i-1]), .PREV_STATUS(s[i-1]), .PREV_PUSH(pp[i]), .DO_NOTHING(|e),
			.STATUS(s[i]), .PUSH(p[i]), .EQUAL(e[i]), .DOUT(dout[i]));
	end
endgenerate

Count1 #(depth) CountOnes(.CLK(CLK), .RST(RST), .DIN(s), .ONES(N_CELLS));

endmodule


module SortCell(CLK, RST, DIN, VALID, PREV_DATA, PREV_STATUS, PREV_PUSH, DO_NOTHING, STATUS, PUSH, EQUAL, DOUT);
parameter data_size = 8;
input CLK, RST, VALID, PREV_STATUS, PREV_PUSH, DO_NOTHING;
input [data_size-1:0] DIN, PREV_DATA;
output STATUS, PUSH, EQUAL;
output [data_size-1:0] DOUT;

reg STATUS;
reg [data_size-1:0] DOUT;

assign PUSH = (DIN < DOUT) & STATUS;
assign EQUAL = (DIN == DOUT) & STATUS;

always @(posedge CLK)
begin
	if( RST )
	begin
		STATUS <= 0;
		DOUT <= 0;
	end
	else
	begin
		if( VALID )
			case({STATUS, PREV_STATUS, PREV_PUSH})
				3'b000:	begin end // do nothing: preceding cell is empty
				3'b001:	begin end // do nothing: preceding cell is empty
				3'b010:	begin if( DO_NOTHING == 0 ) begin DOUT <= DIN; STATUS <= 1; end end
				3'b011:	begin if( DO_NOTHING == 0 ) begin DOUT <= PREV_DATA; STATUS <= 1; end end
				3'b100:	begin end // impossible: preceding cell is empty
				3'b101:	begin end // impossible: preceding cell is empty
				3'b110:	begin if( DO_NOTHING == 0 & PUSH ) DOUT <= DIN; end
				3'b111:	begin if( DO_NOTHING == 0 ) DOUT <= PREV_DATA; end
			endcase
	end
end

endmodule

module Count1(CLK, RST, DIN, ONES);
parameter size = 8;
input CLK, RST;
input [size-1:0] DIN;
output [7:0] ONES;

reg [7:0] ONES;

always @(posedge CLK)
begin
	if( RST )
		ONES <= 0;
	else
		ONES <= c_1(DIN);
end

function [7:0] c_1;
input [size-1:0] D;
integer i;
begin
	c_1 = 0;
	for(i=0; i<size; i=i+1)
		if( D[i] )
			c_1 = c_1 + 1;
end
endfunction

endmodule
