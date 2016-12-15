`define COARSE_BIT	4	// Coarse bit count = COARSE_BIT_MSB
`define FINE_BIT	4	// Fine bit count = FINE_BIT_MSB
`define DELAY_BIT	(1<<`FINE_BIT)	// Tapped delay line bit count
`define TIME_BIT	(`COARSE_BIT + `FINE_BIT)

// If 64 delay taps are needed we can store (and code) 1 out of 4 (the OR of 4) tap.

module HiResTdc(CLK, RSTb, START, STOP, TIME, VALID);
input CLK, RSTb, START, STOP;
output [`TIME_BIT-1:0] TIME;
output VALID;

reg [`TIME_BIT-1:0] TIME;
reg VALID;
reg x_valid, old_valid, old_start, clear;

wire [`DELAY_BIT-1:0] delay_tapped;
reg [`DELAY_BIT-1:0] delay_tapped_register;
wire [`FINE_BIT-1:0] fine_time;
reg [`COARSE_BIT-1:0] coarse_time, coarse_time_register;

	DelayChain TappedDelayLine(STOP, delay_tapped);
//	PriEnc8to3 FineTimeEncoder(delay_tapped_register, fine_time);
	PriEnc16to4 FineTimeEncoder(delay_tapped_register, fine_time);

// Coarse time counter
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			coarse_time <= 0;
		else
			if( clear == 1 )
				coarse_time <= 0;
			else
				coarse_time <= coarse_time + 1;
	end
	
// Output register
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			delay_tapped_register <= 0;
			coarse_time_register <= 0;
			x_valid <= 0;
			old_valid <= 0;
			old_start <= 0;
			clear <= 0;
			TIME <= 0;
			VALID <= 0;
		end
		else
		begin
			old_start <= START;
			clear <= 0;
			if( old_start == 0 && START == 1 )
				clear <= 1;

			delay_tapped_register <= delay_tapped;
			coarse_time_register <= coarse_time;
			x_valid <= delay_tapped != 0;
			old_valid <= x_valid;

			TIME <= {coarse_time_register, fine_time};
			VALID <= (old_valid == 0 && x_valid != 0) ? 1 : 0;
		end
	end

endmodule

module DelayChain(DIN, DOUT);
input DIN;
output [`DELAY_BIT-1:0] DOUT;

	carry_sum dly_bit0 (.sin(1'b0), .cin(DIN), .sout(), .cout(DOUT[0]));
	
	genvar i;
	generate
		for(i=1; i<`DELAY_BIT; i=i+1)
		begin: dly_generate
			carry_sum dly_biti (.sin(1'b0), .cin(DOUT[i-1]), .sout(), .cout(DOUT[i]));
		end
	endgenerate
/*
	carry_sum dly0 (.sin(1'b0), .cin(DIN),     .sout(), .cout(DOUT[0]);
	carry_sum dly1 (.sin(1'b0), .cin(DOUT[0]), .sout(), .cout(DOUT[1]);
	carry_sum dly2 (.sin(1'b0), .cin(DOUT[1]), .sout(), .cout(DOUT[2]);
	carry_sum dly3 (.sin(1'b0), .cin(DOUT[2]), .sout(), .cout(DOUT[3]);
*/
endmodule
/*
module PriEnc8to3(DIN, DOUT);
input [7:0] DIN;
output [2:0] DOUT;

reg [2:0] DOUT;

	always @(*)
	begin
		casex( DIN )
			8'b00000001:	DOUT <= 0;
			8'b0000001?:	DOUT <= 1;
			8'b000001??:	DOUT <= 2;
			8'b00001???:	DOUT <= 3;
			8'b0001????:	DOUT <= 4;
			8'b001?????:	DOUT <= 5;
			8'b01??????:	DOUT <= 6;
			8'b1???????:	DOUT <= 7;
			default:	DOUT <= 0;
		endcase
	end

endmodule
*/
module PriEnc16to4(DIN, DOUT);
input [15:0] DIN;
output [3:0] DOUT;

reg [3:0] DOUT;

	always @(*)
	begin
		casex( DIN )
			16'b00000000_00000001:	DOUT <= 0;
			16'b00000000_0000001?:	DOUT <= 1;
			16'b00000000_000001??:	DOUT <= 2;
			16'b00000000_00001???:	DOUT <= 3;
			16'b00000000_0001????:	DOUT <= 4;
			16'b00000000_001?????:	DOUT <= 5;
			16'b00000000_01??????:	DOUT <= 6;
			16'b00000000_1???????:	DOUT <= 7;
			16'b00000001_????????:	DOUT <= 8;
			16'b0000001?_????????:	DOUT <= 9;
			16'b000001??_????????:	DOUT <= 10;
			16'b00001???_????????:	DOUT <= 11;
			16'b0001????_????????:	DOUT <= 12;
			16'b001?????_????????:	DOUT <= 13;
			16'b01??????_????????:	DOUT <= 14;
			16'b1???????_????????:	DOUT <= 15;
			default:	DOUT <= 0;
		endcase
	end

endmodule



module LoResTdc(CLK, RSTb, START, STOP, TIME, VALID);
input CLK, RSTb, START, STOP;
output [7:0] TIME;
output VALID;

reg [7:0] TIME;
reg VALID;

reg clear, old_start, old_stop;

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			old_start <= 0;
			old_stop <= 0;
			clear <= 0;
			VALID <= 0;
		end
		else
		begin
			old_start <= START;
			old_stop <= STOP;
			clear <= 0;
			VALID <= 0;
			if( old_start == 0 && START == 1 )
				clear <= 1;
			if( old_stop == 0 && STOP == 1 )
				VALID <= 1;
		end
	end

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			TIME <= 0;
		end
		else
		begin
			if( clear == 1 )
				TIME <= 0;
			else
				TIME <= TIME + 1;
		end
	end

endmodule

