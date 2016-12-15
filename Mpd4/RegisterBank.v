`include "CompileTime.v"

`define CONSTANT_STRING	32'h43_52_4F_4D	// ASCII 'C', 'R', 'O', 'M'
`define CERN_ID			32'h00_08_00_30	// CERN Manufacturer ID
`define MPD_ID			32'h00_03_09_04	// Board ID = 394
`define MPD_REVISION	32'h04_00_00_04	// Board Revision ID = 4, FPGA Revision ID = 4

`ifdef QUESTA_SIMULATION
`include "./Mpd_Common/AddressDefines.v"
`else
`include "../Mpd_Common/AddressDefines.v"
`endif

module RegisterBank(
	RSTb, CLK, ADDR, DATA_IN, DATA_OUT, WEb, REb, OEb, CEb, 
	USER_RESET,//	RESET_REG,
	SAMPLE_PER_EVENT, EVENT_PER_BLOCK,
	BUSY_THRESHOLD, BUSY_THRESHOLD_LOCAL,
	IO_CONFIG, READOUT_CONFIG, TRIGGER_CONFIG,
	TRIGGER_DELAY, SYNC_PERIOD, MARKER_CHANNEL,
	CHANNEL_ENABLE,	ZERO_THRESHOLD, ONE_THRESHOLD,
	FIR0_COEFF, FIR1_COEFF, FIR2_COEFF, FIR3_COEFF, FIR4_COEFF, FIR5_COEFF,
	FIR6_COEFF, FIR7_COEFF, FIR8_COEFF, FIR9_COEFF, FIR10_COEFF, FIR11_COEFF,
	FIR12_COEFF, FIR13_COEFF, FIR14_COEFF, FIR15_COEFF);

	input RSTb, CLK;
	input [17:0] ADDR;
	input [31:0] DATA_IN;
	output [31:0] DATA_OUT;
	input WEb, REb, OEb, CEb;
	output USER_RESET;
//	output [7:0] RESET_REG;
	output [4:0] SAMPLE_PER_EVENT;
	output [7:0] EVENT_PER_BLOCK;
	output [31:0] BUSY_THRESHOLD, BUSY_THRESHOLD_LOCAL;
	output [31:0] IO_CONFIG, READOUT_CONFIG, TRIGGER_CONFIG;
	output [7:0] TRIGGER_DELAY, SYNC_PERIOD, MARKER_CHANNEL;
	output [15:0] CHANNEL_ENABLE;
	output [11:0] ZERO_THRESHOLD, ONE_THRESHOLD;
	output [15:0] FIR0_COEFF, FIR1_COEFF, FIR2_COEFF, FIR3_COEFF, FIR4_COEFF, FIR5_COEFF,
					FIR6_COEFF, FIR7_COEFF, FIR8_COEFF, FIR9_COEFF, FIR10_COEFF, FIR11_COEFF,
					FIR12_COEFF, FIR13_COEFF, FIR14_COEFF, FIR15_COEFF;

	reg USER_RESET;
//	reg [7:0] RESET_REG;
	reg [4:0] SAMPLE_PER_EVENT;
	reg [7:0] EVENT_PER_BLOCK;
	reg [31:0] BUSY_THRESHOLD, BUSY_THRESHOLD_LOCAL;
	reg [31:0] READOUT_CONFIG, TRIGGER_CONFIG, IO_CONFIG;
	reg [7:0] TRIGGER_DELAY, SYNC_PERIOD, MARKER_CHANNEL;
	reg [15:0] CHANNEL_ENABLE;
	reg [11:0] ZERO_THRESHOLD, ONE_THRESHOLD;
	reg	[15:0] FIR0_COEFF, FIR1_COEFF, FIR2_COEFF, FIR3_COEFF, FIR4_COEFF, FIR5_COEFF,
					FIR6_COEFF, FIR7_COEFF, FIR8_COEFF, FIR9_COEFF, FIR10_COEFF, FIR11_COEFF,
					FIR12_COEFF, FIR13_COEFF, FIR14_COEFF, FIR15_COEFF;
	
	reg [31:0] DATA_OUT;

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
//			RESET_REG <= 0;
			USER_RESET <= 0;
			SAMPLE_PER_EVENT <= 0;
			EVENT_PER_BLOCK <= 0;
			BUSY_THRESHOLD <= 0;
			BUSY_THRESHOLD_LOCAL <= 0;
			READOUT_CONFIG <= 0;
			TRIGGER_CONFIG <= 0;
			IO_CONFIG <= 0;
			TRIGGER_DELAY <= 0;
			SYNC_PERIOD <= 0;
			MARKER_CHANNEL <= 0;
			CHANNEL_ENABLE <= 0;
			ZERO_THRESHOLD <= 0;
			ONE_THRESHOLD <= 0;
			FIR1_COEFF <= 0; FIR0_COEFF <= 0;
			FIR3_COEFF <= 0; FIR2_COEFF <= 0;
			FIR5_COEFF <= 0; FIR4_COEFF <= 0;
			FIR7_COEFF <= 0; FIR6_COEFF <= 0;
			FIR9_COEFF <= 0; FIR8_COEFF <= 0;
			FIR11_COEFF <= 0; FIR10_COEFF <= 0;
			FIR13_COEFF <= 0; FIR12_COEFF <= 0;
			FIR15_COEFF <= 0; FIR14_COEFF <= 0;
		end
		else
		begin
			if( CEb == 0 && WEb == 0 )
				case( ADDR )
//					`RESET_REG_A:		RESET_REG <= DATA_IN[7:0];
					`RESET_REG_A:		USER_RESET <= DATA_IN[0];
					`IO_CONFIG_A:		IO_CONFIG <= DATA_IN;
					`SAMPLE_PER_EVENT_A:	SAMPLE_PER_EVENT <= DATA_IN[4:0];
					`EVENT_PER_BLOCK_A:	EVENT_PER_BLOCK <= DATA_IN[7:0];
					`BUSY_THRESHOLD_A:	BUSY_THRESHOLD <= DATA_IN;
					`BUSY_THRESHOLD_LOCAL_A:BUSY_THRESHOLD_LOCAL <= DATA_IN;
					`READOUT_CONFIG_A:	READOUT_CONFIG <= DATA_IN;
					`TRIGGER_CONFIG_A:	TRIGGER_CONFIG <= DATA_IN;
					`TRIGGER_DELAY_A:	TRIGGER_DELAY <= DATA_IN[7:0];
					`SYNC_PERIOD_A:		SYNC_PERIOD <= DATA_IN[7:0];
					`MARKER_CHANNEL_A: 	MARKER_CHANNEL <= DATA_IN[7:0];
					`CHANNEL_ENABLE_A:	CHANNEL_ENABLE <= DATA_IN[15:0];
					`ZERO_THRESHOLD_A:	ZERO_THRESHOLD <= DATA_IN[11:0];
					`ONE_THRESHOLD_A:	ONE_THRESHOLD <= DATA_IN[11:0];
					`FIR_01_A:			{FIR1_COEFF,FIR0_COEFF} <= DATA_IN;
					`FIR_23_A:			{FIR3_COEFF,FIR2_COEFF} <= DATA_IN;
					`FIR_45_A:			{FIR5_COEFF,FIR4_COEFF} <= DATA_IN;
					`FIR_67_A:			{FIR7_COEFF,FIR6_COEFF} <= DATA_IN;
					`FIR_89_A:			{FIR9_COEFF,FIR8_COEFF} <= DATA_IN;
					`FIR_1011_A:		{FIR11_COEFF,FIR10_COEFF} <= DATA_IN;
					`FIR_1213_A:		{FIR13_COEFF,FIR12_COEFF} <= DATA_IN;
					`FIR_1415_A:		{FIR15_COEFF,FIR14_COEFF} <= DATA_IN;
				endcase
		end
	end

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			DATA_OUT <= 0;
		end
		else
		begin
			case( ADDR )
// Configurarion ROM
				`C_STRING:				DATA_OUT <= `CONSTANT_STRING;
				`MANUFACTURER_ID:		DATA_OUT <= `CERN_ID;
				`BOARD_ID:				DATA_OUT <= `MPD_ID;
				`BOARD_REVISION:		DATA_OUT <= `MPD_REVISION;
				`C_TIME:				DATA_OUT <= `COMPILE_TIME;

// Configuration Registers
//				`RESET_REG_A:			DATA_OUT <= {24'h0, RESET_REG};
				`IO_CONFIG_A:			DATA_OUT <= IO_CONFIG;
				`SAMPLE_PER_EVENT_A:	DATA_OUT <= {27'h0, SAMPLE_PER_EVENT};
				`EVENT_PER_BLOCK_A:		DATA_OUT <= {24'h0, EVENT_PER_BLOCK};
				`BUSY_THRESHOLD_A:		DATA_OUT <= BUSY_THRESHOLD;
				`BUSY_THRESHOLD_LOCAL_A:DATA_OUT <= BUSY_THRESHOLD_LOCAL;
				`READOUT_CONFIG_A:		DATA_OUT <= READOUT_CONFIG;
				`TRIGGER_CONFIG_A:		DATA_OUT <= TRIGGER_CONFIG;
				`TRIGGER_DELAY_A:		DATA_OUT <= {24'h0, TRIGGER_DELAY};
				`SYNC_PERIOD_A:			DATA_OUT <= {24'h0, SYNC_PERIOD};
				`MARKER_CHANNEL_A:		DATA_OUT <= {24'h0, MARKER_CHANNEL};
				`CHANNEL_ENABLE_A:		DATA_OUT <= {16'h0, CHANNEL_ENABLE};
				`ZERO_THRESHOLD_A:		DATA_OUT <= {20'h0, ZERO_THRESHOLD};
				`ONE_THRESHOLD_A: 		DATA_OUT <= {20'h0, ONE_THRESHOLD};
				`FIR_01_A:				DATA_OUT <= {FIR1_COEFF,FIR0_COEFF};
				`FIR_23_A:				DATA_OUT <= {FIR3_COEFF,FIR2_COEFF};
				`FIR_45_A:				DATA_OUT <= {FIR5_COEFF,FIR4_COEFF};
				`FIR_67_A:				DATA_OUT <= {FIR7_COEFF,FIR6_COEFF};
				`FIR_89_A:				DATA_OUT <= {FIR9_COEFF,FIR8_COEFF};
				`FIR_1011_A:			DATA_OUT <= {FIR11_COEFF,FIR10_COEFF};
				`FIR_1213_A:			DATA_OUT <= {FIR13_COEFF,FIR12_COEFF};
				`FIR_1415_A:			DATA_OUT <= {FIR15_COEFF,FIR14_COEFF};
				default:				DATA_OUT <= `DUMMY_CONSTANT;
			endcase
		end
	end

endmodule