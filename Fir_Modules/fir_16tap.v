
module fir_16tap(input CLK, input ENABLE_FIR, input [11:0] DATA_IN, output reg [11:0] DATA_OUT,
	input [15:0] COEFF_0, input [15:0] COEFF_1, input [15:0] COEFF_2, input [15:0] COEFF_3,
	input [15:0] COEFF_4, input [15:0] COEFF_5, input [15:0] COEFF_6, input [15:0] COEFF_7,
	input [15:0] COEFF_8, input [15:0] COEFF_9, input [15:0] COEFF_10, input [15:0] COEFF_11,
	input [15:0] COEFF_12, input [15:0] COEFF_13, input [15:0] COEFF_14, input [15:0] COEFF_15);

	wire [33:0] result, result_a, result_b, result_0, result_1;
	reg [33:0] result_3_0, result_7_4, result_11_8, result_15_12, result_x, result_y;

	reg [11:0] data_1, data_2, data_3, data_4, data_5, data_6, data_7,
				data_8, data_9, data_10, data_11, data_12, data_13, data_14, data_15;

// FIR coefficients are multipied by 2^13

	always @(posedge CLK)	// Delay elements
	begin
		data_1 <= DATA_IN;
		data_2 <= data_1;
		data_3 <= data_2;
		data_4 <= data_3;
		data_5 <= data_4;
		data_6 <= data_5;
		data_7 <= data_6;
		data_8 <= data_7;
		data_9 <= data_8;
		data_10 <= data_9;
		data_11 <= data_10;
		data_12 <= data_11;
		data_13 <= data_12;
		data_14 <= data_13;
		data_15 <= data_14;
	end
	
MultAdd4 mult_add_0(
	.dataa_0(CLK ? {4'h0,data_4} : {4'h0,DATA_IN}),
	.dataa_1(CLK ? {4'h0,data_5} : {4'h0,data_1}),
	.dataa_2(CLK ? {4'h0,data_6} : {4'h0,data_2}),
	.dataa_3(CLK ? {4'h0,data_7} : {4'h0,data_3}),
	.datab_0(CLK ? COEFF_4 : COEFF_0),
	.datab_1(CLK ? COEFF_5 : COEFF_1),
	.datab_2(CLK ? COEFF_6 : COEFF_2),
	.datab_3(CLK ? COEFF_7 : COEFF_3),
	.result(result_0));

MultAdd4 mult_add_1(
	.dataa_0(CLK ? {4'h0,data_12} : {4'h0,data_8}),
	.dataa_1(CLK ? {4'h0,data_13} : {4'h0,data_9}),
	.dataa_2(CLK ? {4'h0,data_14} : {4'h0,data_10}),
	.dataa_3(CLK ? {4'h0,data_15} : {4'h0,data_11}),
	.datab_0(CLK ? COEFF_12 : COEFF_8),
	.datab_1(CLK ? COEFF_13 : COEFF_9),
	.datab_2(CLK ? COEFF_14 : COEFF_10),
	.datab_3(CLK ? COEFF_15 : COEFF_11),
	.result(result_1));

	always @(posedge CLK)	// MultAdd Storage
	begin
		result_3_0 <= result_0;
		result_11_8 <= result_1;
	end

	always @(negedge CLK)	// MultAdd Storage
	begin
		result_7_4 <= result_0;
		result_15_12 <= result_1;
	end

	add32 output_adder1(
		.dataa(result_3_0),
		.datab(result_7_4),
		.result(result_a));

	add32 output_adder2(
		.dataa(result_11_8),
		.datab(result_15_12),
		.result(result_b));

	always @(posedge CLK)	// add32 Storage
	begin
		result_x <= result_a;
		result_y <= result_b;
	end

	add32 output_adder(
		.dataa(result_x),
		.datab(result_y),
		.result(result));

	always @(posedge CLK)	// Output register
		if( ENABLE_FIR )
			DATA_OUT <= result[24:13];	// Divide by 2^13
		else
			DATA_OUT <= DATA_IN;
		
endmodule
