
module TrigGen(APV_TRG, RESET101, RSTb, CLK, MAX_TRIG_OUT, TRIG_PULSE, TRIG_MODE,
	TRIG_CMD, RESET_CMD, MISSING_TRIGGER_CNT, APV_TRIGGER_CNT, INCOMING_TRIGGER_CNT, MAX_RESET_LATENCY, CALIB_LATENCY,
	NO_MORE_SPACE, SPACE_AVAILABLE, OUTPUT_FIFO_ALMOST_FULL, TRIGGER_DISABLED, TRIGGER_DELAY);
output APV_TRG, RESET101;
input RSTb, CLK;
input [3:0] MAX_TRIG_OUT;
input [2:0] TRIG_MODE;
output TRIG_PULSE;
input TRIG_CMD, RESET_CMD;
output [31:0] MISSING_TRIGGER_CNT, APV_TRIGGER_CNT, INCOMING_TRIGGER_CNT;
input [7:0] MAX_RESET_LATENCY;
input [7:0] CALIB_LATENCY;
input NO_MORE_SPACE, SPACE_AVAILABLE, OUTPUT_FIFO_ALMOST_FULL;
output TRIGGER_DISABLED;
input [7:0] TRIGGER_DELAY;

reg APV_TRG_int, RESET101;
reg [31:0] MISSING_TRIGGER_CNT, APV_TRIGGER_CNT, INCOMING_TRIGGER_CNT;
reg TRIGGER_DISABLED;
reg TRIG_PULSE;
reg [3:0] trig_cnt;
reg [7:0] reset_latency, calibration_latency;
reg [7:0] fsm_status;
reg [7:0] fsm2_status;
reg old_trig_cmd, trigger_pulse, old_reset_cmd;
reg trigger100_cmd, reset101_cmd, calib110_cmd;
reg clear_reset_latency;
reg TRIG_CMD_reg, RESET_CMD_reg;
reg enable, enable_dly0, enable_dly1, enable_dly2, enable_pulse;
reg hw_trig_enable;
reg trig_disable, trig_apv_normal, trig_apv_multiple, calib_trig_apv;
reg multi_trig100, clr_trig_cnt, load_calibration_latency, calib_trig_pulse;

Delay31 ApvTrigDelay(.CLK(CLK), .RSTb(RSTb), .IN(APV_TRG_int), .OUT(APV_TRG), .DELAY(TRIGGER_DELAY[4:0]));

// Synchronizer
always @(posedge CLK)
begin
	RESET101 <= reset101_cmd;
	TRIG_CMD_reg <= TRIG_CMD;
	RESET_CMD_reg <= RESET_CMD;

	trig_disable <= (TRIG_MODE == 3'b000) ? 1 : 0;
	trig_apv_normal <= (TRIG_MODE == 3'b001) ? 1 : 0;
	trig_apv_multiple <= (TRIG_MODE == 3'b010) ? 1 : 0;
	calib_trig_apv <= (TRIG_MODE == 3'b011) ? 1 : 0;

	enable <= ~trig_disable;

	TRIGGER_DISABLED <= ~hw_trig_enable | trig_disable;
	
	TRIG_PULSE <= trigger100_cmd | (multi_trig100 && (trig_cnt == 0));
end

// HW Trigger Enabling logic: permit trigger generation only if there is space available in all input FIFOs
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		hw_trig_enable <= 0;
	end
	else
	begin
		if( SPACE_AVAILABLE )
			hw_trig_enable <= 1;
		else
//			if( NO_MORE_SPACE )
			if( NO_MORE_SPACE | OUTPUT_FIFO_ALMOST_FULL )
				hw_trig_enable <= 0;
	end
end

// Generate a pulse when enable is set to trigger a reset101
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		enable_dly0 <= 0;
		enable_dly1 <= 0;
		enable_dly2 <= 0;
		enable_pulse <= 0;
	end
	else
	begin
		enable_dly0 <= enable;
		enable_dly1 <= enable_dly0;
		enable_dly2 <= enable_dly1;
		if( enable_dly2 == 0 && enable_dly1 == 1 )
			enable_pulse <= 1;
		else
			enable_pulse <= 0;
	end
end

// Pulse generator
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		old_trig_cmd <= 0;
		old_reset_cmd <= 0;
		trigger_pulse <= 0;
		trigger100_cmd <= 0;
		reset101_cmd <= 0;
		calib110_cmd <= 0;
	end
	else
	begin
		old_trig_cmd <= TRIG_CMD_reg;
		old_reset_cmd <= RESET_CMD_reg;

		if( (old_trig_cmd == 0 && TRIG_CMD_reg == 1) )
				trigger_pulse <= 1;
			else
				trigger_pulse <= 0;

		if( (old_trig_cmd == 0 && TRIG_CMD_reg == 1) &&
			hw_trig_enable == 1 && trig_apv_normal == 1)
				trigger100_cmd <= 1;
			else
				trigger100_cmd <= 0;

		if( (old_trig_cmd == 0 && TRIG_CMD_reg == 1) &&
			calib_trig_apv == 1)
				calib110_cmd <= 1;
			else
				calib110_cmd <= 0;

		if( (old_reset_cmd == 0 && RESET_CMD_reg == 1) ||
			enable_pulse == 1 )
				reset101_cmd <= 1;
			else
				reset101_cmd <= 0;
	end
end

// reset_latency
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		reset_latency <= 0;
	end
	else
	begin
		if( clear_reset_latency == 1 )
			reset_latency <= 0;
		else
			if( reset_latency < MAX_RESET_LATENCY )
				reset_latency <= reset_latency + 1;
	end
end

// Latency counter from Calibration to Trigger
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		calibration_latency <= 0;
	end
	else
	begin
		if( load_calibration_latency == 1 )
			calibration_latency <= CALIB_LATENCY;
		else
			if( calibration_latency != 0 )
				calibration_latency <= calibration_latency - 1;
	end
end

// APV_TRIGGER_CNT
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		APV_TRIGGER_CNT <= 0;
	end
	else
	begin
//		if( APV_TRG == 1 )
		if( trigger100_cmd | multi_trig100 )
			APV_TRIGGER_CNT <= APV_TRIGGER_CNT + 1;
		else
			if( reset101_cmd == 1 )
				APV_TRIGGER_CNT <= 0;
	end
end

// MISSING_TRIGGER_CNT
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		MISSING_TRIGGER_CNT <= 0;
	end
	else
	begin
		if( enable == 1 && trigger_pulse == 1 && hw_trig_enable  == 0 )
			MISSING_TRIGGER_CNT <= MISSING_TRIGGER_CNT + 1;
		else
			if( reset101_cmd == 1 )
				MISSING_TRIGGER_CNT <= 0;
	end
end

// INCOMING_TRIGGER_CNT
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		INCOMING_TRIGGER_CNT <= 0;
	end
	else
	begin
		if( trigger_pulse == 1 )
			INCOMING_TRIGGER_CNT <= INCOMING_TRIGGER_CNT + 1;
		else
			if( reset101_cmd == 1 )
				INCOMING_TRIGGER_CNT <= 0;
	end
end

// State Machine: APV_TRG_int generation
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		fsm_status <= 0;
		APV_TRG_int <= 0;
//		TRIG_PULSE <= 0;
		clear_reset_latency <= 0;
		load_calibration_latency <= 0;
		calib_trig_pulse <= 0;
	end
	else
	begin
		case( fsm_status )
			0:	begin
					calib_trig_pulse <= 0;
					APV_TRG_int <= 0;
					if( enable )
					begin
						case( {trigger100_cmd|multi_trig100, reset101_cmd, calib110_cmd} )
							3'b100: fsm_status <= 1;
							3'b010: fsm_status <= 3;
							3'b001: fsm_status <= 6;
							default: fsm_status <= 0;
						endcase
					end
				end
			1:	begin
					if( reset_latency < MAX_RESET_LATENCY )
						fsm_status <= 0;
					else
					begin
						APV_TRG_int <= 1;
//						TRIG_PULSE <= 1;
						fsm_status <= 2;
					end
				end
			2:	begin
					APV_TRG_int <= 0;
//					TRIG_PULSE <= 0;
					fsm_status <= 0;
				end
			3:	begin
					clear_reset_latency <= 1;
					APV_TRG_int <= 1;
					fsm_status <= 4;
				end
			4:	begin
					clear_reset_latency <= 0;
					APV_TRG_int <= 0;
					fsm_status <= 5;
				end
			5:	begin
					APV_TRG_int <= 1;
					fsm_status <= 0;
				end
			6:	begin	// Calibration (110) followed by N Trigger (100)
					APV_TRG_int <= 1;
					load_calibration_latency <= 1;
					fsm_status <= 7;
				end
			7:	begin
					load_calibration_latency <= 0;
					fsm_status <= 8;
				end
			8:	begin
					APV_TRG_int <= 0;
					if( calibration_latency == 0 )
//						fsm_status <= 5;
						fsm_status <= 9;
					else
						fsm_status <= 8;
				end
			9:	begin
					calib_trig_pulse <= 1;
					fsm_status <= 0;
				end
			default: fsm_status <= 0;
		endcase
	end
end

// State Machine: generates N times 100 pulses every trigger_pulse
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		multi_trig100 <= 0;
		clr_trig_cnt <= 0;
		fsm2_status <= 0;
	end
	else
	begin
		case( fsm2_status )
			0:	begin
					clr_trig_cnt <= 0;
					multi_trig100 <= 0;
					if( hw_trig_enable & 
						((trig_apv_multiple & trigger_pulse) | (calib_trig_apv & calib_trig_pulse)) )
						fsm2_status <= 1;
					else
						fsm2_status <= 0;
				end
			1:	begin
					multi_trig100 <= 1;
					fsm2_status <= 2;
				end
			2:	begin
					multi_trig100 <= 0;
					fsm2_status <= 3;
				end
			3:	begin
					multi_trig100 <= 0;
					if( trig_cnt == MAX_TRIG_OUT )
						fsm2_status <= 4;
					else
						fsm2_status <= 1;
				end
			4:	begin
					clr_trig_cnt <= 1;
					fsm2_status <= 0;
				end
			default: fsm2_status <= 0;
		endcase
	end
end

// trig_cnt
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		trig_cnt <= 0;
	end
	else
	begin
		if( multi_trig100 == 1 && (trig_cnt != 4'hF) )
			trig_cnt <= trig_cnt + 1;
		else
		begin
			if( reset101_cmd == 1 || clr_trig_cnt == 1 )
				trig_cnt <= 0;
		end
	end
end

endmodule

module Delay31(CLK, RSTb, IN, OUT, DELAY);
input CLK, RSTb, IN;
output OUT;
input [4:0] DELAY;

reg OUT;
reg [30:0] delay_line;

always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		delay_line <= 0;
		OUT <= 0;
	end
	else
	begin
		delay_line <= {delay_line[29:0], IN};
		case( DELAY )
			0:	OUT <= IN;
			1:	OUT <= delay_line[0];
			2:	OUT <= delay_line[1];
			3:	OUT <= delay_line[2];
			4:	OUT <= delay_line[3];
			5:	OUT <= delay_line[4];
			6:	OUT <= delay_line[5];
			7:	OUT <= delay_line[6];
			8:	OUT <= delay_line[7];
			9:	OUT <= delay_line[8];
			10:	OUT <= delay_line[9];
			11:	OUT <= delay_line[10];
			12:	OUT <= delay_line[11];
			13:	OUT <= delay_line[12];
			14:	OUT <= delay_line[13];
			15:	OUT <= delay_line[14];
			16:	OUT <= delay_line[15];
			17:	OUT <= delay_line[16];
			18:	OUT <= delay_line[17];
			19:	OUT <= delay_line[18];
			20:	OUT <= delay_line[19];
			21:	OUT <= delay_line[20];
			22:	OUT <= delay_line[21];
			23:	OUT <= delay_line[22];
			24:	OUT <= delay_line[23];
			25:	OUT <= delay_line[24];
			26:	OUT <= delay_line[25];
			27:	OUT <= delay_line[26];
			28:	OUT <= delay_line[27];
			29:	OUT <= delay_line[28];
			30:	OUT <= delay_line[29];
			31:	OUT <= delay_line[30];
		endcase
	end
end

endmodule

