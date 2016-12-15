
module AdcDeser(
	ADC_SDATA, LCLK, ADCLK,
	ADC_PDATA0, ADC_PDATA1, ADC_PDATA2, ADC_PDATA3,
	ADC_PDATA4, ADC_PDATA5, ADC_PDATA6, ADC_PDATA7
);

input [7:0] ADC_SDATA;
input LCLK, ADCLK;
output [11:0] ADC_PDATA0, ADC_PDATA1, ADC_PDATA2, ADC_PDATA3;
output [11:0] ADC_PDATA4, ADC_PDATA5, ADC_PDATA6, ADC_PDATA7;

wire [7:0] ADC_SDATA_H, ADC_SDATA_L;

DdrIn DdrIn0(.datain(ADC_SDATA), .inclock(LCLK),
	.dataout_h(ADC_SDATA_H), .dataout_l(ADC_SDATA_L));	// L = even, H = odd, LSB first

AdcOneDeser Deser0(.PDATA(ADC_PDATA0), .SDATA_H(ADC_SDATA_H[0]), .SDATA_L(ADC_SDATA_L[0]),
	.LCLK(LCLK), .ADCLK(ADCLK));
AdcOneDeser Deser1(.PDATA(ADC_PDATA1), .SDATA_H(ADC_SDATA_H[1]), .SDATA_L(ADC_SDATA_L[1]),
	.LCLK(LCLK), .ADCLK(ADCLK));
AdcOneDeser Deser2(.PDATA(ADC_PDATA2), .SDATA_H(ADC_SDATA_H[2]), .SDATA_L(ADC_SDATA_L[2]),
	.LCLK(LCLK), .ADCLK(ADCLK));
AdcOneDeser Deser3(.PDATA(ADC_PDATA3), .SDATA_H(ADC_SDATA_H[3]), .SDATA_L(ADC_SDATA_L[3]),
	.LCLK(LCLK), .ADCLK(ADCLK));
AdcOneDeser Deser4(.PDATA(ADC_PDATA4), .SDATA_H(ADC_SDATA_H[4]), .SDATA_L(ADC_SDATA_L[4]),
	.LCLK(LCLK), .ADCLK(ADCLK));
AdcOneDeser Deser5(.PDATA(ADC_PDATA5), .SDATA_H(ADC_SDATA_H[5]), .SDATA_L(ADC_SDATA_L[5]),
	.LCLK(LCLK), .ADCLK(ADCLK));
AdcOneDeser Deser6(.PDATA(ADC_PDATA6), .SDATA_H(ADC_SDATA_H[6]), .SDATA_L(ADC_SDATA_L[6]),
	.LCLK(LCLK), .ADCLK(ADCLK));
AdcOneDeser Deser7(.PDATA(ADC_PDATA7), .SDATA_H(ADC_SDATA_H[7]), .SDATA_L(ADC_SDATA_L[7]),
	.LCLK(LCLK), .ADCLK(ADCLK));

endmodule


module AdcOneDeser(PDATA, SDATA_H, SDATA_L, LCLK, ADCLK);
output [11:0] PDATA;
input SDATA_H, SDATA_L, LCLK, ADCLK;	// L = even, H = odd, LSB first

reg [11:0] PDATA, int_PDATA;
reg old_adclk, data_ready;
reg [5:0] sr_h, sr_l;

	always @(posedge LCLK)
	begin
		sr_h <= {SDATA_H, sr_h[5:1]};
		sr_l <= {SDATA_L, sr_l[5:1]};
		old_adclk <= ADCLK;
		if( old_adclk == 0 && ADCLK == 1 )
			data_ready <= 1;
		else
			data_ready <= 0;
	end

	always @(posedge LCLK)
		if( data_ready )
			int_PDATA <= {sr_h[5],sr_l[5],sr_h[4], sr_l[4],sr_h[3],sr_l[3],
				sr_h[2],sr_l[2],sr_h[1],sr_l[1],sr_h[0],sr_l[0]};

	always @(posedge ADCLK)
		PDATA <= int_PDATA;
endmodule
