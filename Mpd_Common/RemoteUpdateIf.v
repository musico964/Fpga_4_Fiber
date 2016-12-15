/* Refers to: "ALTREMOTE_UPDATE Megafunction"
 *
 * WRITE OPERATIONS:
 *	USER_ADDR = 0 --> write data register is selected = {13'hx, RUPD_PARAM[2:0], 4'hx, RUPD_DATAIN[11:0]}
 *	USER_ADDR = 1 --> control register is selected
 *		CrtlRegister[0] = READ PARAM
 *		CrtlRegister[1] = WRITE PARAM
 *		CrtlRegister[2] = WATCHDOG RESET
 *		CtrlRegister[6:3] = Not Used
 *		CrtlRegister[7] = RECONFIGURE
 *
 * READ OPERATIONS:
 *		Always returns: {RUPD_BUSY, 7'h0, CtrlRegister, 4'h0, RUPD_DATAOUT}
 *	BUSY must be checked by software
 *
 * Starting address for configuration should be: StAdd[23..0] = {1'b0, PGM[6:0], 16'b0}
 *
 * Sequence of operaions:
 * Write_Param with RUPD_PARAM = 0, RUPD_DATAIN = 4: select configuration reset triggered from logic array signal
 * Write_Param with RUPD_PARAM = 4, RUPD_DATAIN = PGM[6:0]: select starting address for application code PGM = 6'h30
 * Write_Param with RUPD_PARAM = 5, RUPD_DATAIN = 1: select application image for update (altera reccomend to set to 1)
 * RECONFIGURE
 *
 * Read_Param  with RUPD_PARAM = 5: returns the current configuration loaded
 */
 
module RemoteUpdateIf(
	input CLK, input RESETb,
	input [1:0] USER_ADDR,
	input [31:0] USER_DATA_IN, output [31:0] USER_DATA_OUT, input USER_CEb,
	input USER_WEb, input USER_REb, input USER_OEb,
	output [2:0] RUPD_PARAM,
	input RUPD_CK,
	output [11:0] RUPD_DATAIN,
	output reg RUPD_RD,
	output reg RUPD_TRESET,
	output reg RUPD_WR,
	input RUPD_BUSY,
	output reg RUPD_RECONFIG,
	input [11:0] RUPD_DATAOUT);

reg [31:0] WrDataRegister;
reg [7:0] CtrlRegister, RupdCtrlRegister;
reg [7:0] fsm_status;
wire [31:0] StatusRegister;
reg ClrCtrlRegister, RUPD_RD_x, RUPD_TRESET_x, RUPD_WR_x, RUPD_RECONFIG_x;

	assign RUPD_DATAIN = WrDataRegister[11:0];
	assign RUPD_PARAM = WrDataRegister[18:16];
	assign StatusRegister = {RUPD_BUSY, 7'h0, CtrlRegister, 4'h0, RUPD_DATAOUT};
//	assign USER_DATA = (USER_CEb == 0 && USER_OEb == 0) ?  StatusRegister : 32'bz;
	assign USER_DATA_OUT = StatusRegister;

// Write to Registers
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			WrDataRegister <= 0;
			CtrlRegister <= 0;
		end
		else
		begin
			if( USER_CEb == 0 && USER_WEb == 0 )
			begin
				if( USER_ADDR == 0 )
					WrDataRegister <= USER_DATA_IN;
				else
					CtrlRegister <= USER_DATA_IN[7:0];
			end
			if( ClrCtrlRegister == 1 )
				CtrlRegister <= 0;
		end
	end

	always @(posedge RUPD_CK)
		RupdCtrlRegister <= CtrlRegister;

// sync output signals on falling edge of ASMI clock
	always @(negedge RUPD_CK)
	begin
		RUPD_RD <= RUPD_RD_x;
		RUPD_TRESET <= RUPD_TRESET_x;
		RUPD_WR <= RUPD_WR_x;
		RUPD_RECONFIG <= RUPD_RECONFIG_x;
	end
	
// State machine
	always @(posedge RUPD_CK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			fsm_status <= 0;
			ClrCtrlRegister <= 0;
			RUPD_RD_x <= 0;
			RUPD_TRESET_x <= 0;
			RUPD_WR_x <= 0;
			RUPD_RECONFIG_x <= 0;
		end
		else
		begin
			case( fsm_status )
				0:	begin
						ClrCtrlRegister <= 0;
						RUPD_RD_x <= 0;
						RUPD_TRESET_x <= 0;
						RUPD_WR_x <= 0;
						RUPD_RECONFIG_x <= 0;
						case( CtrlRegister )
							8'h01: fsm_status <= 1;
							8'h02: fsm_status <= 2;
							8'h04: fsm_status <= 3;
							8'h80: fsm_status <= 4;
							default: fsm_status <= 0;
						endcase
					end
				1:	begin
						RUPD_RD_x <= 1;
						ClrCtrlRegister <= 1;
						fsm_status <= 5;
					end
				2:	begin
						RUPD_WR_x <= 1;
						ClrCtrlRegister <= 1;
						fsm_status <= 5;
					end
				3:	begin
						RUPD_TRESET_x <= 1;
						ClrCtrlRegister <= 1;
						fsm_status <= 5;
					end
				4:	begin
						RUPD_RECONFIG_x <= 1;
						ClrCtrlRegister <= 1;
						fsm_status <= 5;
					end
				5:	begin
						ClrCtrlRegister <= 0;
						RUPD_RD_x <= 0;
						RUPD_TRESET_x <= 0;
						RUPD_WR_x <= 0;
						RUPD_RECONFIG_x <= 0;
						fsm_status <= 0;
					end
				default: fsm_status <= 0;
			endcase
		end
	end

endmodule
