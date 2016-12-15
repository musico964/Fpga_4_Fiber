`timescale 100ps/1ps

module ads5281(PATTERN, CLK, LCLK, ADCLK, OUT18);

input [1:0] PATTERN;
input	CLK;
output	LCLK, ADCLK; 
output [7:0] OUT18;

parameter ADC_ONE = 12'hB00;
parameter ADC_ZERO = 12'h200;

reg outX;
reg [11:0] OutSr, i, x;
reg [11:0] patcnt;
wire clk1, clk6, clk12;

assign #8 OUT18 = {outX, outX, outX, outX, outX, outX, outX, outX};

assign #20 ADCLK = ~clk1;
assign #10 LCLK = clk6;

ADS5281_Pll Pll(.inclk0(CLK), .c0(clk1), .c1(clk6), .c2(clk12));

initial
begin
	x <= 0;
	outX <= 0;
	patcnt <= 0;
	OutSr <= ADC_ZERO;
end

always @(posedge clk12)
begin
	patcnt <= patcnt + 1;
	case( PATTERN )
		2'b00: outX <= ~outX;	// Deskew pattern
		2'b01: if( (patcnt % 6) == 0 )	// Sync pattern
				outX <= ~outX;
		2'b10: begin outX <= OutSr[0]; OutSr <= {OutSr[0], OutSr[11:1]}; end
		2'b11: begin outX <= OutSr[0]; OutSr <= {OutSr[0], OutSr[11:1]}; end
	endcase
end

// APV frame and pulses
always @(negedge clk1)
begin
	x <= x + 1;
	if( PATTERN == 2'b10 )
		ApvSync;
	if( PATTERN == 2'b11 )
		ApvFrame(x);
end

task ApvSync;
begin
	OutSr <= ADC_ONE;
	@(negedge clk1);
	OutSr <= ADC_ZERO;
	repeat( 33 )
		@(negedge clk1);
end
endtask // ApvSync

task ApvFrame;
input [11:0] seed;
begin
	OutSr <= ADC_ONE;
	repeat(3)
		@(negedge clk1);
	OutSr <= ADC_ZERO;
	@(negedge clk1);
	OutSr <= ADC_ONE;
	@(negedge clk1);
	OutSr <= ADC_ZERO;
	@(negedge clk1);
	OutSr <= ADC_ONE;
	@(negedge clk1);
	OutSr <= ADC_ZERO;
	@(negedge clk1);
	OutSr <= ADC_ONE;
	@(negedge clk1);
	OutSr <= ADC_ZERO;
	@(negedge clk1);
	OutSr <= ADC_ONE;
	@(negedge clk1);
	OutSr <= ADC_ZERO;
	for(i=1; i<=128; i=i+1)
	begin
		@(negedge clk1);
		OutSr <= (i+ADC_ZERO+seed) ? (i+ADC_ZERO+seed) : 12'h1;	// always > 0
	end
end
endtask // ApvFrame

endmodule

