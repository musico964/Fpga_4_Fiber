/* EPCS128 = 134217728 bit = 128 Mbit = 16 Mbyte --> Addr size = 24 bit
 *			262144 bytes per sector, 64 sectors, 1024 pages per sector, 65536 total pages, 256 bytes per page
 *
 * For a EP1AGX50 or EP1AGX60 configuration data size = 16951824 bit = 2118978 bytes (0x205542)
 * Factory image loaded from sector 0: addr = 0
 * Application image loaded from sector 12: addr = 0x300000
 * Free for other use (i.e. NIOS II accesses) from sector 24: addr = 0x600000
 * Refers to: "Active Serial Memory Interface (ALTASMI_PARALLEL) Megafunction User Guide"
 *
 * WRITE OPERATIONS:
 *	USER_ADDR = 0 --> write data register is selected = {ASMI_ADDR[23:0], ASMI_DATAIN[7:0]}
 *	USER_ADDR = 1 --> control register is selected
 *		CmdRegister[2:0] = 1: READ ID (EPCS128 returns 0x18)
 *		CmdRegister[2:0] = 2: BYTE READ
 *		CmdRegister[2:0] = 3: BYTE WRITE
 *		CmdRegister[2:0] = 4: SECTOR ERASE (0, 0x40000, 0x80000, 0xC0000, 0x100000, 0x140000, ...)
 *		CmdRegister[2:0] = 5: READ STATUS
 *		CmdRegister[2:0] = 7: RESET
 *
 * READ OPERATIONS:
 *		Always returns: {ASMI_BUSY, ASMI_ILL_ERASE, ASMI_ILL_WR, 2'b0, CmdRegister[2:0], ASMI_STATUS, ASMI_RDID_OUT, ASMI_DATAOUT}
 *	note that ASMI_ILL_ERASE and ASMI_ILL_WR are active only for 2 ASMI_CLK cycles and are not latched
 *	BUSY must be checked by software
 */

module AsmiIf(
	input CLK, input RESETb,
	input USER_ADDR,
	input [31:0] USER_DATA_IN, output [31:0] USER_DATA_OUT, input USER_CEb,
	input USER_WEb, input USER_REb, input USER_OEb,
	output [23:0] ASMI_ADDR,
	input ASMI_CK,
	output [7:0] ASMI_DATAIN,
	output ASMI_RDEN,
	output reg ASMI_RD,
	output reg ASMI_RDID,
	output reg ASMI_RDSTATUS,
	output reg ASMI_RESET,
	output reg ASMI_SECTOR_ERASE,
	output reg ASMI_WR,
	input ASMI_BUSY,
	input ASMI_DV,
	input [7:0] ASMI_DATAOUT,
	input ASMI_ILL_ERASE,
	input ASMI_ILL_WR,
	input [7:0] ASMI_RDID_OUT,
	input [7:0] ASMI_STATUS
	);
	
reg [31:0] WrDataRegister, RdDataRegister;
reg [2:0] CmdRegister, AsmiCmdRegister;
reg [7:0] epcs_data_out;
reg [7:0] fsm_status;
reg ClrCmdRegister, ASMI_RDID_x, ASMI_RD_x, ASMI_WR_x, ASMI_RESET_x, ASMI_SECTOR_ERASE_x, ASMI_RDSTATUS_x;
wire [31:0] StatusRegister;

	assign ASMI_RDEN = ASMI_RD;	// allow only single byte read
	assign ASMI_DATAIN = WrDataRegister[7:0];
	assign ASMI_ADDR = WrDataRegister[31:8];
	assign StatusRegister = {ASMI_BUSY, ASMI_ILL_ERASE, ASMI_ILL_WR, 2'b0, CmdRegister,
							ASMI_STATUS, ASMI_RDID_OUT, epcs_data_out};
//	assign USER_DATA = (USER_CEb == 0 && USER_OEb == 0) ?  StatusRegister : 32'bz;
	assign USER_DATA_OUT = StatusRegister;

// Write to Registers
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			WrDataRegister <= 0;
			CmdRegister <= 0;
		end
		else
		begin
			if( USER_CEb == 0 && USER_WEb == 0 )
			begin
				if( USER_ADDR == 0 )
					WrDataRegister <= USER_DATA_IN;
				else
					CmdRegister <= USER_DATA_IN[2:0];
			end
			if( ClrCmdRegister == 1 )
				CmdRegister <= 0;
		end
	end

// Store EPCS data out if Data valid is set
	always @(posedge ASMI_CK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			epcs_data_out <= 0;
			AsmiCmdRegister <= 0;
		end
		else
		begin
			if( ClrCmdRegister == 1 )
				AsmiCmdRegister <= 0;
			else
				AsmiCmdRegister <= CmdRegister;	// sync CtrlRegister with slower clock
			if( ASMI_DV == 1 )
			begin
				epcs_data_out <= ASMI_DATAOUT;
			end
		end
	end
	
// sync output signals on falling edge of ASMI clock
	always @(negedge ASMI_CK)
	begin
		ASMI_RDID <= ASMI_RDID_x;
		ASMI_RD <= ASMI_RD_x;
		ASMI_WR <= ASMI_WR_x;
		ASMI_RESET <= ASMI_RESET_x;
		ASMI_SECTOR_ERASE <= ASMI_SECTOR_ERASE_x;
		ASMI_RDSTATUS <= ASMI_RDSTATUS_x;
	end

// State machine to handle EPCS accesses
	always @(posedge ASMI_CK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			fsm_status <= 0;
			ClrCmdRegister <= 0;
			ASMI_RDID_x <= 0;
			ASMI_RD_x <= 0;
			ASMI_WR_x <= 0;
			ASMI_RESET_x <= 1;
			ASMI_SECTOR_ERASE_x <= 0;
			ASMI_RDSTATUS_x <= 0;
		end
		else
		begin
			case( fsm_status )
				0:	begin
						ClrCmdRegister <= 0;
						ASMI_RDID_x <= 0;
						ASMI_RD_x <= 0;
						ASMI_WR_x <= 0;
						ASMI_RESET_x <= 0;
						ASMI_SECTOR_ERASE_x <= 0;
						ASMI_RDSTATUS_x <= 0;
						case( AsmiCmdRegister )
							3'h1: fsm_status <= 1;
							3'h2: fsm_status <= 2;
							3'h3: fsm_status <= 3;
							3'h4: fsm_status <= 4;
							3'h5: fsm_status <= 8;
							3'h7: fsm_status <= 5;
							default: fsm_status <= 0;
						endcase
					end
				1:	begin
						ASMI_RDID_x <= 1;
						ClrCmdRegister <= 1;
						fsm_status <= 7;
					end
				2:	begin
						ASMI_RD_x <= 1;
						ClrCmdRegister <= 1;
						fsm_status <= 7;
					end
				3:	begin
						ASMI_WR_x <= 1;
						ClrCmdRegister <= 1;
						fsm_status <= 7;
					end
				4:	begin
						ASMI_SECTOR_ERASE_x <= 1;
						ClrCmdRegister <= 1;
						fsm_status <= 7;
					end
				5:	begin
						ASMI_RESET_x <= 1;
						ClrCmdRegister <= 1;
						fsm_status <= 6;
					end
				6:	begin
						ClrCmdRegister <= 0;
						fsm_status <= 7;
					end
				7:	begin
						ASMI_RDID_x <= 0;
						ASMI_RD_x <= 0;
						ASMI_WR_x <= 0;
						ASMI_RESET_x <= 0;
						ASMI_SECTOR_ERASE_x <= 0;
						ASMI_RDSTATUS_x <= 0;
						ClrCmdRegister <= 0;
						fsm_status <= 0;
					end
				8:	begin
						ASMI_RDSTATUS_x <= 1;
						ClrCmdRegister <= 1;
						fsm_status <= 7;
					end
				default: fsm_status <= 0;
			endcase
		end
	end
	
endmodule
