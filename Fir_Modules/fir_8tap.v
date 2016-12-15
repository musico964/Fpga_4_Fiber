
module fir_8tap(input CLK, input ENABLE_FIR, input [11:0] DATA_IN, output reg [11:0] DATA_OUT,
	input [15:0] COEFF_0, input [15:0] COEFF_1, input [15:0] COEFF_2, input [15:0] COEFF_3,
	input [15:0] COEFF_4, input [15:0] COEFF_5, input [15:0] COEFF_6, input [15:0] COEFF_7);

	wire [15:0] data_mid;
	wire [33:0] result, result_3_0, result_7_4;

// FIR coefficients are multipied by 2^13

	multadd mult_add_3_0(
		.clock0(CLK),
		.dataa_0({4'b0,DATA_IN}),
		.datab_0(COEFF_0),
		.datab_1(COEFF_1),
		.datab_2(COEFF_2),
		.datab_3(COEFF_3),
		.result(result_3_0),
		.shiftouta(data_mid));

	multadd mult_add_7_4(
		.clock0(CLK),
		.dataa_0(data_mid),
		.datab_0(COEFF_4),
		.datab_1(COEFF_5),
		.datab_2(COEFF_6),
		.datab_3(COEFF_7),
		.result(result_7_4),
		.shiftouta());
	
	add32 output_adder(
		.dataa(result_3_0),
		.datab(result_7_4),
		.result(result));

	always @(posedge CLK)
		if( ENABLE_FIR )
			DATA_OUT <= result[24:13];	// Divide by 2^13
		else
			DATA_OUT <= DATA_IN;
		
endmodule
