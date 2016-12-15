/* VmeSlaveIf.v - VME64x Slave Interface
 * Adaptation for MPD v 4.0
 *
 * Author: Paolo Musico
 * Date:   1 February 2013
 * Rev:    2.0
 *
 * This is a slave VME64x interface Verilog synthetizable model with the following capabilities:
 * - A24-D32 for accessing CR/CSR space
 * - A32-D32 for standard accesses
 * - A32-D32 Block Transfers (BLT)
 * - A32-D64 Block Transfers (MBLT)
 * - A32-D64 2eVME (master/slave terminated)
 * - A32-D64 2eSST (master/slave terminated)
 *
 * Unaligned data transfers are not permitted.
 *
 * On the user side the interface will provide a standard non muxed bus as following:
 *           _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _
 * CLK     _| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
 *          ____ _______ _______ _______ _______ _______ _______ _______ _______ _______ ___
 * A[31:0]  ____X_______X_______X_______X_______X_______X_______X_______X_______X_______X___
 *               _______ _______            _____           ______ ______
 * D[63:0] -----X_______X_______X----------X_____X---------X______X______X------------------
 *          ____ _______ _______ _______ _______ _______ _______ _______ ___________________
 * CEb[7:0]     X_______X_______X       X_______X       X_______X_______X
 *         _________     ___     ___________________________________________________________
 * WEb              |___|   |___|
 *         _____________________________     ___________     ___     _______________________
 * REb                                  |___|           |___|   |___|    
 *         _____________________________         _______                 ___________________
 * OEb                                  |_______|       |_______________|
 *
 * The above diagram show that WEb and REb pulse are always 1 CLK cycle wide.
 * Async device can write with the rising edge of WEb, sync device can use
 * the rising edge of CLK at the end of WEb.
 * REb pulses can be used to extract data from sync (with CLK) or async devices.
 *
 * Only 32 and 64 bit aligned data transfers are allowed.
 * The user data bus width can be limited to 32 bit.
 *
 *
 *
 */

`ifdef QUESTA_SIMULATION
`include "./Mpd_Common/AddressDefines.v"
`else
`include "./AddressDefines.v"
`endif

`define	d_A32_2eSST	8'h11	// 6U A32_D64_2eSST
`define	d_A32_2eVME	8'h01	// 6U A32_D64_2eVME
`define	d_SST_160	4'h0	// 6U D64 SST with 50 ns strobe width: 160 MB/sec (6 ck cycles = 60 ns)
`define	d_SST_267	4'h1	// 6U D64 SST with 30 ns strobe width: 267 MB/sec (4 ck cycles = 40 ns)
`define	d_SST_320	4'h2	// 6U D64 SST with 25 ns strobe width: 320 MB/sec (3 ck cycles = 30 ns)

module VmeSlaveIf(
	VME_A, VME_AM, VME_D, VME_ASb, VME_DS1b, VME_DS0b, VME_WRITEb, VME_LWORDb, VME_IACKb,
	VME_IackInb, VME_IackOutb, VME_IRQ, VME_DTACK, VME_BERR, VME_GAb, VME_GAPb,
	VME_DATA_DIR, VME_DBUF_OEb, VME_ADDR_DIR, VME_ABUF_OEb,
	VME_DTACK_EN, VME_BERR_EN,
	VME_RETRY, VME_RETRY_EN,
	USER_D64,
	USER_ADDR,
	USER_DATA_IN, // 64 bit
	USER_DATA_OUT, //32 bit
	USER_WEb, USER_REb, USER_OEb, USER_CEb, HISTO_REG, USER_WAITb, SLAVE_TERMINATE_2E,
	RESETb, CLK,
	CONFIG_CEb, SDRAM_CEb, OBUF_CEb,
	ASMI_CEb, RUPD_CEb,
	TOKEN_IN, END_OF_DATA, TOKEN_OUT, TOKEN,
	GXB_TX_DISABLE, GXB_PRESENT, GXB_RX_LOS,
	FIBER_RESET, FIBER_DISABLE, FIBER_UP, FIBER_HARD_ERR, FIBER_FRAME_ERR, FIBER_ERR_COUNT, SDRAM_BANK
);
	inout [31:1] VME_A;	// VME address lines, also D[63:33] in 64 bit transfers
	input [5:0] VME_AM;	// VME address modifier lines
	inout [31:0] VME_D;	// VME data lines
	input VME_ASb;		// VME address strobe (active low)
	input VME_DS1b;		// VME data strobe 1 (active low)
	input VME_DS0b;		// VME data strobe 0 (active low)
	input VME_WRITEb;	// VME write line (active low)
	inout VME_LWORDb;	// VME longword line (active low), also A[0]-D[32] in A64-D64 cycles
	input VME_IACKb;	// VME interrupt acknowledge line (active low)
	input VME_IackInb;	// VME interrupt acknowledge line in (active low)
	output VME_IackOutb;	// VME interrupt acknowledge line out (active low)
	output [7:1] VME_IRQ;	// VME interrupt request (active high): MUST DRIVE AN OPEN DRAIN BUFFER
	output VME_DTACK;	// VME data acknowledge line (active low): MUST DRIVE A TRISTATE BUFFER
	output VME_BERR;	// VME bus error line (active low): MUST DRIVE A TRISTATE BUFFER
	input [4:0] VME_GAb;	// Slot ID for geographical addressing (active low) (pullup-ed)
	input VME_GAPb;		// Slot ID parity for geographical addressing (active low) (pullup-ed)

	output VME_DATA_DIR;	// Direction signal for VME data buffers D[31:0]
	output VME_DBUF_OEb;	// Enable signal for VME data buffers D[31:0] (active low)
	output VME_ADDR_DIR;	// Direction signal for VME data buffers A[31:1] and LWORD
	output VME_ABUF_OEb;	// Enable signal for VME data buffers A[31:1] and LWORD (active low)
	output VME_DTACK_EN;	// Enable signal for DTACK buffer (active high)
	output VME_BERR_EN;	// Enable signal for BERR buffer (active high)
	output VME_RETRY;	// VME RETRY signal (active low): MUST DRIVE A TRISTATE BUFFER
	output VME_RETRY_EN;	// Enable signal for RETRY buffer (active high)

	input USER_D64;		// Indicate the use of 64 bit bus on user side: STATIC SIGNAL (pullup-ed)
	output [21:0] USER_ADDR;// User side address lines
	input [63:0] USER_DATA_IN;	// User side data lines (pullup-ed)
	output [31:0] USER_DATA_OUT;	// User side data lines
	output USER_WEb;	// User side write pulse (active low)
	output USER_REb;	// User side read pulse (active low)
	output USER_OEb;	// User side output enable line (active low)
	output [7:0] USER_CEb;	// User side chip enable line (active low)
	output [1:0] HISTO_REG;
	input USER_WAITb;	// User side wait line (active low) (pullup-ed)
	input SLAVE_TERMINATE_2E;

	input RESETb;		// System reset (active low)
	input CLK;		// System free running 40 MHz clock


	output CONFIG_CEb, SDRAM_CEb, OBUF_CEb;
	output ASMI_CEb, RUPD_CEb;
	input TOKEN_IN, END_OF_DATA;
	output TOKEN_OUT, TOKEN;
	output GXB_TX_DISABLE;
	input GXB_PRESENT, GXB_RX_LOS;
	output FIBER_RESET, FIBER_DISABLE;
	input FIBER_UP, FIBER_HARD_ERR, FIBER_FRAME_ERR;
	input [7:0] FIBER_ERR_COUNT;
	output [3:0] SDRAM_BANK;
	

	parameter
			A24_CRCSR = 6'h2F,
			A24_SINGLE1 = 6'h39,
			A24_SINGLE2 = 6'h3A,
			A24_SINGLE3 = 6'h3D,
			A24_SINGLE4 = 6'h3E,
			A24_BLT1 = 6'h3B,	// Non privileged block transfer
			A24_BLT2 = 6'h3F,	// Supervisory block transfer
			A32_SINGLE1 = 6'h09,	// Non privileged data space
			A32_SINGLE2 = 6'h0D,	// Supervisory data space
			A32_SINGLE3 = 6'h0A,	// Non privileged program space
			A32_SINGLE4 = 6'h0E,	// Supervisory program space
			A32_BLT1 = 6'h0B,	// Non privileged block transfer
			A32_BLT2 = 6'h0F,	// Supervisory block transfer
			A32_MBLT1 = 6'h08,	// Non privileged muxed block transfer
			A32_MBLT2 = 6'h0C,	// Supervisory muxed block transfer
			A32_2eVME_3U = 6'h21,	// 3U 2e
			A32_2eVME_6U = 6'h20;	// 6U 2e
	parameter
			A32_2eSST = `d_A32_2eSST,	// 6U A32_D64_2eSST
			A32_2eVME = `d_A32_2eVME;	// 6U A32_D64_2eVME
	parameter
			SST_160 = `d_SST_160,		// 6U D64 SST with 50 ns strobe width: 160 MB/sec (6 ck cycles = 54 ns)
			SST_267 = `d_SST_267,		// 6U D64 SST with 30 ns strobe width: 267 MB/sec (4 ck cycles = 36 ns)
			SST_320 = `d_SST_320;		// 6U D64 SST with 25 ns strobe width: 320 MB/sec (3 ck cycles = 27 ns)


	reg [31:0] USER_DATA_OUT;
	wire LOCAL_DTACK, LOCAL_BERR, LOCAL_RETRY;
	reg asB, ds0B, ds1B, writeB, lwordB, a1, iackB;
//	reg iackInB;
	reg [5:0] am;
	reg old_asB, old_ds1B, ld_addr_counter;
	reg [7:0] xam, beats;
	wire [29:0] addr_counter;
	reg [3:0] transfer_rate;
	reg a24_cycle, a32_cycle, single_cycle, blt_cycle, mblt_cycle, bad_cycle;
	reg a32d64_2evme_cycle, a32d64_2esst_cycle;
	reg d64_2e_cycle;
	wire [4:0] ga;
	wire [7:0] bar;
	wire [31:0] cfg_dataout;
	wire [63:0] internal_data;
//	wire [7:0] irq_id1, irq_id2, irq_id3, irq_id4, irq_id5, irq_id6, irq_id7, irq_enable;
	wire incr_addr_counter;
	reg module_selected;
	wire ld_a7_0, data_enable, addr_dir, data_dir;
	wire [31:0] Multiboard_Add_Low, Multiboard_Add_High, Multiboard_Config;
	wire Multiboard_Enabled, Multiboard_First, Multiboard_Last;
	wire internal_detect;
	wire [3:0] Fiber_ctrl;
	wire [31:0] OutputBuffer_Base, Sdram_Base;

	
	assign FIBER_DISABLE = Fiber_ctrl[0];
	assign GXB_TX_DISABLE = Fiber_ctrl[1];
	assign FIBER_RESET = Fiber_ctrl[3];
	
	assign VME_IackOutb = 1;
	assign VME_IRQ = 7'h0;
	assign VME_DTACK = ~LOCAL_DTACK;
	assign VME_BERR = ~LOCAL_BERR;
	assign VME_RETRY = ~LOCAL_RETRY;
	assign VME_DTACK_EN = module_selected;
	assign VME_BERR_EN = module_selected;
	assign VME_RETRY_EN = module_selected;

	always @(posedge CLK)
		module_selected <= (~(&USER_CEb) | ~CONFIG_CEb | ~OBUF_CEb | ~SDRAM_CEb | ~ASMI_CEb | ~RUPD_CEb | internal_detect);

	assign VME_DATA_DIR = data_dir;
	assign VME_ADDR_DIR = addr_dir;
	assign VME_DBUF_OEb = ~module_selected;
	assign VME_ABUF_OEb = 0;		// Address lines always enabled

	assign USER_ADDR = addr_counter[21:0];

	always @(posedge CLK)
		USER_DATA_OUT <= VME_D;


	assign internal_data = ( internal_detect ) ? {32'b0, cfg_dataout} : USER_DATA_IN;

	assign VME_D = (data_dir & module_selected) ? internal_data[31:0] : 32'bz;
	assign VME_LWORDb  = addr_dir ? internal_data[32] : 1'bz;
	assign VME_A[31:1] = addr_dir ? internal_data[63:33] : 31'bz;

	assign ga = ~VME_GAb;

	assign Multiboard_Enabled = Multiboard_Config[0];
	assign Multiboard_First = Multiboard_Config[1];
	assign Multiboard_Last = Multiboard_Config[2];


// Sychronize all inputs
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			asB <= 0; ds0B <= 0; ds1B <= 0; writeB <= 0; lwordB <= 0;
			iackB <= 0; am <= 0; xam <= 0; beats <= 0;
//			iackInB <= 0;
			old_asB <= 0; old_ds1B <= 0; transfer_rate <= 0;
		end
		else
		begin
			asB <= VME_ASb;
			ds0B <= VME_DS0b;
			ds1B <= VME_DS1b;
			writeB <= VME_WRITEb;
			lwordB <= VME_LWORDb;
			iackB <= VME_IACKb;
//			iackInB <= VME_IackInb;
			am <= VME_AM;
			xam <= {VME_A[7:1], VME_LWORDb};
			beats <= VME_A[15:8];
			transfer_rate <= VME_D[3:0];

			old_asB <= asB;
			old_ds1B <= ds1B;
		end
	end

// Load the address counter on falling edge of AS and decode the cycle
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			ld_addr_counter <= 0;
			a24_cycle <= 0; a32_cycle <= 0; single_cycle <= 0; blt_cycle <= 0; mblt_cycle <= 0;
			a32d64_2evme_cycle <= 0;
			a32d64_2esst_cycle <= 0;
			d64_2e_cycle <= 0;
			bad_cycle <= 0;
			a1 <= 0;
		end
		else
		begin
			if( old_asB == 0 && asB == 1 )	// rising edge of ASb: cycle end
			begin
				a24_cycle <= 0;
				a32_cycle <= 0;
				single_cycle <= 0;
				blt_cycle <= 0;
				mblt_cycle <= 0;
				a32d64_2evme_cycle <= 0;
				a32d64_2esst_cycle <= 0;
				d64_2e_cycle <= 0;
				bad_cycle <= 0;
			end

			if( old_asB == 1 && asB == 0 )	// falling edge of ASb: cycle start
			begin
				ld_addr_counter <= 1;
				a1 <= VME_A[1];
//				if( iackB == 1 )	// this seems driven low after a 2eXXX cycle...
				case( am )
					A24_CRCSR,
					A24_SINGLE1,
					A24_SINGLE2,
					A24_SINGLE3,
					A24_SINGLE4:
						begin
							a24_cycle <= 1;
							a32_cycle <= 0;
							single_cycle <= 0;
							blt_cycle <= 0;
							mblt_cycle <= 0;
							a32d64_2evme_cycle <= 0;
							a32d64_2esst_cycle <= 0;
							d64_2e_cycle <= 0;
							bad_cycle <= 0;
						end
						
					A24_BLT1,
					A24_BLT2:
						begin
							a24_cycle <= 1;
							a32_cycle <= 0;
							single_cycle <= 0;
							blt_cycle <= 1;
							mblt_cycle <= 0;
							a32d64_2evme_cycle <= 0;
							a32d64_2esst_cycle <= 0;
							d64_2e_cycle <= 0;
							bad_cycle <= 0;
						end
						
					A32_SINGLE1,
					A32_SINGLE2,
					A32_SINGLE3,
					A32_SINGLE4:
						begin
							a24_cycle <= 0;
							a32_cycle <= 1;
							single_cycle <= 1;
							blt_cycle <= 0;
							mblt_cycle <= 0;
							a32d64_2evme_cycle <= 0;
							a32d64_2esst_cycle <= 0;
							d64_2e_cycle <= 0;
							bad_cycle <= 0;
						end

					A32_BLT1,
					A32_BLT2:
						begin
							a24_cycle <= 0;
							a32_cycle <= 1;
							single_cycle <= 0;
							blt_cycle <= 1;
							mblt_cycle <= 0;
							a32d64_2evme_cycle <= 0;
							a32d64_2esst_cycle <= 0;
							d64_2e_cycle <= 0;
							bad_cycle <= 0;
						end

					A32_MBLT1,
					A32_MBLT2:
						begin
							a24_cycle <= 0;
							a32_cycle <= 1;
							single_cycle <= 0;
							blt_cycle <= 0;
							mblt_cycle <= USER_D64;
							a32d64_2evme_cycle <= 0;
							a32d64_2esst_cycle <= 0;
							d64_2e_cycle <= 0;
							bad_cycle <= ~USER_D64;
						end
/*
					A32_2eVME_3U:	// 3U Dual edge transfer not supported
						begin
							a24_cycle <= 0;
							a32_cycle <= 0;
							single_cycle <= 0;
							blt_cycle <= 0;
							mblt_cycle <= 0;
							a32d64_2evme_cycle <= 0;
							a32d64_2esst_cycle <= 0;
							d64_2e_cycle <= 0;
							bad_cycle <= 1;
						end
*/
					A32_2eVME_6U:	// 6U Dual edge transfer
						case( xam )
							A32_2eSST:
								begin
									a24_cycle <= 0;
									a32_cycle <= 1;
									single_cycle <= 0;
									blt_cycle <= 0;
									mblt_cycle <= 0;
									a32d64_2evme_cycle <= 0;
									a32d64_2esst_cycle <= USER_D64;
									d64_2e_cycle <= USER_D64;
									bad_cycle <= ~USER_D64;
								end
							A32_2eVME:
								begin
									a24_cycle <= 0;
									a32_cycle <= 1;
									single_cycle <= 0;
									blt_cycle <= 0;
									mblt_cycle <= 0;
									a32d64_2evme_cycle <= USER_D64;
									a32d64_2esst_cycle <= 0;
									d64_2e_cycle <= USER_D64;
									bad_cycle <= ~USER_D64;
								end
							default:
								begin
									a24_cycle <= 0;
									a32_cycle <= 0;
									single_cycle <= 0;
									blt_cycle <= 0;
									mblt_cycle <= 0;
									a32d64_2evme_cycle <= 0;
									a32d64_2esst_cycle <= 0;
									d64_2e_cycle <= 0;
									bad_cycle <= 1;
								end
						endcase

					default:
						begin
							a24_cycle <= 0;
							a32_cycle <= 0;
							single_cycle <= 0;
							blt_cycle <= 0;
							mblt_cycle <= 0;
							a32d64_2evme_cycle <= 0;
							a32d64_2esst_cycle <= 0;
							d64_2e_cycle <= 0;
							bad_cycle <= 1;
						end
				endcase
			end
			else
				ld_addr_counter <= 0;
		end
	end
/*
// DTACK synchronizer
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
			LOCAL_DTACK <= 0;
		else
			LOCAL_DTACK <= DataDtack;
	end
*/
	
	AdCnt AddressCounter(.CLK(CLK), .RESETb(RESETb), .U_ADDR(addr_counter), .VME_ADDR(VME_A),
		.A24_CYCLE(a24_cycle), .TWO_EDGE(d64_2e_cycle), .LD(ld_addr_counter), .LD_A7_0(ld_a7_0),
		.INCR(incr_addr_counter));

	PheripheralDecoder AddressDecoder(.ADDR(addr_counter), .BAR(bar[7:2]),
		.A24_CYCLE(a24_cycle), .A32_CYCLE(a32_cycle),
		.CLK(CLK), .RESETb(RESETb), .SDRAM_BASE_ADDRESS(Sdram_Base),
		.OUTPUT_BUFFER_BASE_ADDRESS(OutputBuffer_Base),
		.MULTIBOARD_ENABLED(Multiboard_Enabled),
		.MULTIBOARD_ADD_LOW(Multiboard_Add_Low), .MULTIBOARD_ADD_HIGH(Multiboard_Add_High),
		// A24 decoder
		.CROM_CEb(CONFIG_CEb),
		.OBUF_STATUS_CEb(USER_CEb[0]), .ADC_CEb(USER_CEb[1]), .I2C_CEb(USER_CEb[2]),
		.HISTO0_CEb(USER_CEb[3]), .HISTO1_CEb(USER_CEb[4]), .HISTO_REG(HISTO_REG),
		.CHANNELS_CEb(USER_CEb[5]), .THR_RAM_CEb(USER_CEb[6]), .PED_RAM_CEb(USER_CEb[7]),
		.ASMI_CEb(ASMI_CEb), .RUPD_CEb(RUPD_CEb), .INTERNAL_DETECT(internal_detect),
		// A32 decoder
		.SDRAM_CEb(SDRAM_CEb), .OBUF_CEb(OBUF_CEb)
		);
	
	ConfigRegisters CFG(.DATAIN(USER_DATA_OUT), .DATAOUT(cfg_dataout), .ADDR(addr_counter[15:0]),
		.CLK(CLK), .WEb(USER_WEb), .RESETb(RESETb), .CFG_EN(internal_detect), .GA(ga),
		.A24_BAR(bar),
		.FIBER_ST({FIBER_UP, 15'h0,		// 16 bit
			GXB_RX_LOS, GXB_PRESENT, FIBER_HARD_ERR, FIBER_FRAME_ERR, FIBER_ERR_COUNT}),	// 12 bit
		.FIBER_CTRL(Fiber_ctrl),
		.MULTIBOARD_CONFIG(Multiboard_Config),
		.MULTIBOARD_ADD_LOW(Multiboard_Add_Low), .MULTIBOARD_ADD_HIGH(Multiboard_Add_High),
		.OUTPUT_BUFFER_BASE_ADDRESS(OutputBuffer_Base), .SDRAM_BASE_ADDRESS(Sdram_Base), .SDRAM_BANK(SDRAM_BANK));

	CtrlFsm DataCycleController(
		.CLK(CLK), .RESETb(RESETb), .DTACK(LOCAL_DTACK), .BERR(LOCAL_BERR), .RETRY(LOCAL_RETRY), .ASb(asB),
		.DS0b(ds0B), .DS1b(ds1B), .LWORDb(lwordB), .A1(a1), .WRITEb(writeB), .IACKb(iackB),
		.BEATS(beats), .RATE(transfer_rate), .XAM(xam),
		.START_CYCLE(ld_addr_counter),
		.A24_CYCLE(a24_cycle), .SINGLE_CYCLE(single_cycle), .SELECTED(module_selected),
		.BLT_CYCLE(blt_cycle), .MBLT_CYCLE(mblt_cycle), .TWO_EDGE(d64_2e_cycle),
		.BAD_CYCLE(bad_cycle), .INCR_ADDR_COUNTER(incr_addr_counter),
		.LD_A7_0(ld_a7_0),
		.USER_WAITb(USER_WAITb), .USER_WEb(USER_WEb), .USER_REb(USER_REb), .USER_OEb(USER_OEb),
		.ADDR_DIR(addr_dir), .DATA_ENABLE(data_enable), .DATA_DIR(data_dir),
		.SLAVE_TERMINATE_2E(SLAVE_TERMINATE_2E)
		);

	TokenHandler TokenH(
		.CLK(CLK), .RESETb(RESETb),
		.TOKEN_IN(TOKEN_IN), .TOKEN_OUT(TOKEN_OUT), .TOKEN(TOKEN), .END_OF_DATA(END_OF_DATA),
		.MULTIBOARD_ENABLED(Multiboard_Enabled), .MULTIBOARD_DECODED(~OBUF_CEb),
		.MULTIBOARD_FIRST(Multiboard_First), .MULTIBOARD_LAST(Multiboard_Last)
		);

endmodule

// Address counter: since only D32 (or D64) aligned transfers are allowed, it counts only double-words
module AdCnt(CLK, RESETb, U_ADDR, VME_ADDR, A24_CYCLE, TWO_EDGE, LD, LD_A7_0, INCR);
input CLK, RESETb, LD, LD_A7_0, INCR, A24_CYCLE, TWO_EDGE;
input [31:1] VME_ADDR;
output [29:0] U_ADDR;

reg [29:0] addr_counter;

assign U_ADDR = addr_counter;

	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
			addr_counter <= 0;
		else
		begin
			if( LD == 1 )
				addr_counter <= (A24_CYCLE == 1) ? {10'b0, VME_ADDR[23:2]} :
					(TWO_EDGE ? {VME_ADDR[31:8], 6'b0} : VME_ADDR[31:2]);
				if( LD_A7_0 == 1 )
					addr_counter <= {addr_counter[29:6], VME_ADDR[7:2]};
					if( INCR == 1 )
						addr_counter <= addr_counter + 1;
		end
	end

endmodule


module PheripheralDecoder(ADDR, BAR, A24_CYCLE, A32_CYCLE, CLK, RESETb, SDRAM_BASE_ADDRESS, OUTPUT_BUFFER_BASE_ADDRESS,
	MULTIBOARD_ENABLED, MULTIBOARD_ADD_LOW, MULTIBOARD_ADD_HIGH, CROM_CEb,
	OBUF_STATUS_CEb, ADC_CEb, I2C_CEb, HISTO0_CEb, HISTO1_CEb, HISTO_REG, CHANNELS_CEb, THR_RAM_CEb,
	PED_RAM_CEb, ASMI_CEb, RUPD_CEb, INTERNAL_DETECT, SDRAM_CEb, OBUF_CEb
	);

	input [29:0] ADDR;
	input [31:0] SDRAM_BASE_ADDRESS, OUTPUT_BUFFER_BASE_ADDRESS, MULTIBOARD_ADD_LOW, MULTIBOARD_ADD_HIGH;
	input [5:0] BAR;
	input A24_CYCLE, A32_CYCLE, MULTIBOARD_ENABLED;
	input CLK, RESETb;
	output CROM_CEb, OBUF_STATUS_CEb, ADC_CEb, I2C_CEb, HISTO0_CEb, HISTO1_CEb, CHANNELS_CEb, THR_RAM_CEb;
	output [1:0] HISTO_REG;
	output PED_RAM_CEb, ASMI_CEb, RUPD_CEb, INTERNAL_DETECT;
	output SDRAM_CEb, OBUF_CEb;

	reg CROM_CEb, OBUF_STATUS_CEb, ADC_CEb, I2C_CEb, HISTO0_CEb, HISTO1_CEb, CHANNELS_CEb, THR_RAM_CEb;
	reg PED_RAM_CEb, SDRAM_CEb, OBUF_CEb, ASMI_CEb, RUPD_CEb;
	reg INTERNAL_DETECT;
	reg [1:0] HISTO_REG;

	
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			OBUF_STATUS_CEb  <= 1;
			ADC_CEb <= 1;
			ASMI_CEb <= 1;
			RUPD_CEb <= 1;
			I2C_CEb <= 1;
			HISTO0_CEb <= 1;
			HISTO1_CEb <= 1;
			CHANNELS_CEb <= 1;
			THR_RAM_CEb <= 1;
			PED_RAM_CEb <= 1;
			SDRAM_CEb <= 1;
			OBUF_CEb <= 1;
			CROM_CEb  <= 1;
			INTERNAL_DETECT <= 0;
			HISTO_REG <= 0;
		end
		else
		begin
			CROM_CEb  <= 1;
			OBUF_STATUS_CEb  <= 1;
			ADC_CEb <= 1;
			ASMI_CEb <= 1;
			RUPD_CEb <= 1;
			I2C_CEb <= 1;
			HISTO0_CEb <= 1;
			HISTO1_CEb <= 1;
			HISTO_REG <= 0;
			CHANNELS_CEb <= 1;
			THR_RAM_CEb <= 1;
			PED_RAM_CEb <= 1;
			SDRAM_CEb <= 1;
			OBUF_CEb <= 1;
			INTERNAL_DETECT <= 0;
			if( A24_CYCLE == 1 )
			begin
// A24 Decoder
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `INTERNAL_LO_A && ADDR[15:0] < `INTERNAL_HI_A )
					INTERNAL_DETECT <= 1;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `CROM_LO_A && ADDR[15:0] <= `FIR_1415_A )
					CROM_CEb  <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `OBUF_STATUS_LO && ADDR[15:0] < `OBUF_STATUS_HI )
					OBUF_STATUS_CEb  <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `ADC_CONFIG_LO && ADDR[15:0] < `ADC_CONFIG_HI )
					ADC_CEb  <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `ASMI_A_LO && ADDR[15:0] < `ASMI_A_HI )
					ASMI_CEb  <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `RUPD_A_LO && ADDR[15:0] < `RUPD_A_HI )
					RUPD_CEb  <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `I2C_CONFIG_LO && ADDR[15:0] < `I2C_CONFIG_HI )
					I2C_CEb <= 0;
				if( (ADDR[21:16] == BAR) && ((ADDR[15:0] >= `HISTO0_LO && ADDR[15:0] < `HISTO0_HI) ||
						(ADDR[15:0] >= `HISTO0_REG_LO && ADDR[15:0] < `HISTO0_REG_HI)) )
					HISTO0_CEb <= 0;
				if( (ADDR[21:16] == BAR) && ((ADDR[15:0] >= `HISTO1_LO && ADDR[15:0] < `HISTO1_HI) ||
						(ADDR[15:0] >= `HISTO1_REG_LO && ADDR[15:0] < `HISTO1_REG_HI)) )
					HISTO1_CEb <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `CHANNELS_LO && ADDR[15:0] < `CHANNELS_HI )
					CHANNELS_CEb <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `PED_RAM_LO && ADDR[15:0] < `PED_RAM_HI )
					PED_RAM_CEb <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `THR_RAM_LO && ADDR[15:0] < `THR_RAM_HI )
					THR_RAM_CEb <= 0;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `HISTO0_REG_LO && ADDR[15:0] < `HISTO0_REG_HI )
					HISTO_REG[0] <= 1;
				if( (ADDR[21:16] == BAR) && ADDR[15:0] >= `HISTO1_REG_LO && ADDR[15:0] < `HISTO1_REG_HI )
					HISTO_REG[1] <= 1;
			end
			else
			begin
// A32 Decoder
				if( A32_CYCLE == 1 )
				begin
					if( (ADDR[29:0] >= SDRAM_BASE_ADDRESS[29:0] && ADDR[29:0] < (SDRAM_BASE_ADDRESS[29:0]+30'h0020_0000)) &&
						SDRAM_BASE_ADDRESS != 32'h0 )	// 8 MB
							SDRAM_CEb <= 0;
					if( (MULTIBOARD_ENABLED == 0 && ((
						(ADDR[29:0] >= OUTPUT_BUFFER_BASE_ADDRESS[29:0]) && (ADDR[29:0] < (OUTPUT_BUFFER_BASE_ADDRESS[29:0]+30'h0020_0000))) &&
						(OUTPUT_BUFFER_BASE_ADDRESS != 32'h0) )) ||	// 8 MB
						(MULTIBOARD_ENABLED == 1 && (
						(ADDR[29:0] >= MULTIBOARD_ADD_LOW[29:0]  && ADDR[29:0] < MULTIBOARD_ADD_HIGH[29:0]) ))
						)
							OBUF_CEb <= 0;
				end
			end
		end
	end

endmodule


module ConfigRegisters(
	DATAIN, DATAOUT, ADDR, CLK, WEb, RESETb, CFG_EN, GA,
	A24_BAR, MULTIBOARD_CONFIG, MULTIBOARD_ADD_LOW, MULTIBOARD_ADD_HIGH,
	FIBER_ST,
	FIBER_CTRL, OUTPUT_BUFFER_BASE_ADDRESS, SDRAM_BASE_ADDRESS, SDRAM_BANK
);
	input [31:0] DATAIN;
	output [31:0] DATAOUT;
	input [15:0] ADDR;
	input [4:0] GA;
	input CLK;
	input WEb;
	input RESETb;
	input CFG_EN;
	output [7:0] A24_BAR;
	output [31:0] MULTIBOARD_CONFIG, MULTIBOARD_ADD_LOW, MULTIBOARD_ADD_HIGH;
	input [27:0] FIBER_ST;
	output [3:0] FIBER_CTRL;
	output [31:0] OUTPUT_BUFFER_BASE_ADDRESS, SDRAM_BASE_ADDRESS;
	output [3:0] SDRAM_BANK;
	
	reg [31:0] DATAOUT;
	reg [7:0] A24_BAR;
	reg [31:0] MULTIBOARD_CONFIG, MULTIBOARD_ADD_LOW, MULTIBOARD_ADD_HIGH;
	reg [3:0] FIBER_CTRL;
	reg [31:0] OUTPUT_BUFFER_BASE_ADDRESS, SDRAM_BASE_ADDRESS;
	reg [3:0] SDRAM_BANK;

	reg time0_init;
// Writing to the registers
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			A24_BAR <= {GA, 3'b0};
			MULTIBOARD_CONFIG <= 0;
			MULTIBOARD_ADD_LOW <= 0;
			MULTIBOARD_ADD_HIGH <= 0;
			FIBER_CTRL <= 0;
			OUTPUT_BUFFER_BASE_ADDRESS <= 0;
			SDRAM_BASE_ADDRESS <= 0;
			SDRAM_BANK <= 0;
			time0_init <= 0;
		end
		else
		begin
			if( time0_init == 0 )
			begin
				time0_init <= 1;
				A24_BAR <= {GA, 3'b0};
				FIBER_CTRL <= 0;
			end
			if( time0_init == 1 && WEb == 0 && CFG_EN )
			begin
				case( ADDR )
					`A24_BAR_A:				A24_BAR <= DATAIN[7:0];
					`MULTIBOARD_CONFIG_A:	MULTIBOARD_CONFIG <= DATAIN;
					`MULTIBOARD_ADD_LOW_A:	MULTIBOARD_ADD_LOW <= DATAIN;
					`MULTIBOARD_ADD_HIGH_A:	MULTIBOARD_ADD_HIGH <= DATAIN;
					`FIBER_STCTRL_A: 		FIBER_CTRL <= DATAIN[3:0];
					`OBUF_BASE_ADDRESS_A:	OUTPUT_BUFFER_BASE_ADDRESS <= DATAIN[31:0];
					`SDRAM_BASE_ADDRESS_A:	SDRAM_BASE_ADDRESS <= DATAIN[31:0];
					`SDRAM_BANK_A:			SDRAM_BANK <= DATAIN[3:0];
				endcase
			end
		end
	end

// Reading from the registers
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			DATAOUT <= 0;
		end
		else
		begin
			case( ADDR )
				`A24_BAR_A:				DATAOUT <= {24'h0, A24_BAR};
				`MULTIBOARD_CONFIG_A:	DATAOUT <= MULTIBOARD_CONFIG;
				`MULTIBOARD_ADD_LOW_A:	DATAOUT <= MULTIBOARD_ADD_LOW;
				`MULTIBOARD_ADD_HIGH_A:	DATAOUT <= MULTIBOARD_ADD_HIGH;
				`FIBER_STCTRL_A: 		DATAOUT <= {FIBER_ST, FIBER_CTRL};
				`OBUF_BASE_ADDRESS_A:	DATAOUT <= OUTPUT_BUFFER_BASE_ADDRESS;
				`SDRAM_BASE_ADDRESS_A:	DATAOUT <= SDRAM_BASE_ADDRESS;
				`SDRAM_BANK_A:			DATAOUT <= {28'h0,SDRAM_BANK};
				default:				DATAOUT <= `DUMMY_CONSTANT;
			endcase
		end
	end

endmodule

// State machine for transaction control
module CtrlFsm(
	CLK, RESETb, DTACK, BERR, RETRY, ASb, DS0b, DS1b, LWORDb, A1, WRITEb, IACKb,
	BEATS, RATE, XAM,
	START_CYCLE, SELECTED, A24_CYCLE, SINGLE_CYCLE, BLT_CYCLE, MBLT_CYCLE, TWO_EDGE,
	BAD_CYCLE,
	LD_A7_0,
	INCR_ADDR_COUNTER, USER_WAITb, USER_WEb, USER_REb, USER_OEb, ADDR_DIR, DATA_ENABLE, DATA_DIR,
	SLAVE_TERMINATE_2E
);
	input CLK, RESETb, ASb, DS0b, DS1b, LWORDb, A1, WRITEb, IACKb, START_CYCLE, SELECTED;
	input A24_CYCLE, SINGLE_CYCLE, BLT_CYCLE, MBLT_CYCLE, TWO_EDGE, USER_WAITb;
	input BAD_CYCLE;
	input [7:0] BEATS;
	input [3:0] RATE;
	input [7:0] XAM;
	output DTACK, BERR, RETRY, USER_WEb, USER_REb, USER_OEb, INCR_ADDR_COUNTER, LD_A7_0;
	output ADDR_DIR, DATA_ENABLE, DATA_DIR;
	input SLAVE_TERMINATE_2E;

	reg DTACK, RETRY;
	reg BERR, INCR_ADDR_COUNTER, USER_WEb, USER_REb, USER_OEb, LD_A7_0;
	reg ADDR_DIR, DATA_ENABLE, DATA_DIR;
	reg [7:0] status;
	reg [8:0] beat_counter;
	reg [3:0] rate_code;
	reg [7:0] xam_local;
	wire d32_bad, d32u_bad, d16_bad, d08_bad;
	reg any_bad;
	wire two_edges, two_edges_w;
	reg ld_beat_counter, decr_beat_counter, even_cycle;
	

	parameter	S00 = 0, S01 = 1, S02 = 2, S03 = 3, S04 = 4, S05 = 5, S06 = 6, S07 = 7,
			S08 = 8, S09 = 9, S10 = 10, S11 = 11, S12 = 12, S13 = 13, S14 = 14, S15 = 15,
			S16 = 16, S17 = 17, S18 = 18, S19 = 19, S20 = 20, S21 = 21, S22 = 22, S23 = 23,
			S24 = 24, S25 = 25, S26 = 26, S27 = 27, S28 = 28, S29 = 29, S30 = 30, S31 = 31,
			S32 = 32, S33 = 33, S34 = 34, S35 = 35, S36 = 36, S37 = 37, S38 = 38, S39 = 39,
			S40 = 40, S41 = 41, S42 = 42, S43 = 43, S44 = 44, S50 = 50, S51 = 51;


	assign d32_bad  = SELECTED & ~DS0b & ~DS1b & ~LWORDb & ~A1 & IACKb & BAD_CYCLE;
	assign d32u_bad = SELECTED & ~DS0b & ~DS1b & ~LWORDb & A1 & IACKb;
	assign d16_bad  = SELECTED & ~DS0b & ~DS1b & LWORDb & IACKb;
	assign d08_bad  = SELECTED & ((~DS0b & DS1b) | (DS0b & ~DS1b)) & IACKb;
	assign two_edges = TWO_EDGE & WRITEb;
	assign two_edges_w = TWO_EDGE & ~WRITEb;

	always @(posedge CLK)
		any_bad <= d32_bad | d32u_bad | d16_bad | d08_bad | BAD_CYCLE | two_edges_w;

// Beat counter for 2e transfers
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			beat_counter <= 0;
			rate_code <= 0;
		end
		else
		begin
			if( ld_beat_counter == 1 )
			begin
				beat_counter <= {BEATS, 1'b0};
				rate_code <= RATE;
			end
			else
				if( decr_beat_counter == 1 )
					beat_counter <= beat_counter - 1;
		end
	end

	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			status <= S00;
			DTACK <= 0;
			BERR <= 0;
			RETRY <= 0;
			USER_OEb <= 1;
			USER_REb <= 1;
			USER_WEb <= 1;
			INCR_ADDR_COUNTER <= 0;
			LD_A7_0 <= 0;
			ld_beat_counter <= 0;
			decr_beat_counter <= 0;
			xam_local <= 0;			
			even_cycle <= 0;
			ADDR_DIR <= 0;
			DATA_ENABLE <= 0;
			DATA_DIR <= 0;
		end
		else
		begin
		case( status )
			S00:	begin	// Idle state: everything starts here
						DTACK <= 0;
						BERR <= 0;
						RETRY <= 0;
						USER_OEb <= 1;
						USER_REb <= 1;
						USER_WEb <= 1;
						INCR_ADDR_COUNTER <= 0;
						even_cycle <= 0;
						ADDR_DIR <= 0;
						DATA_ENABLE <= 0;
						DATA_DIR <= WRITEb;	// 1 = RD, 0 = WR
						ld_beat_counter <= 0;
						decr_beat_counter <= 0;
						if( (A24_CYCLE | SINGLE_CYCLE | BLT_CYCLE) & SELECTED )
							status <= S02;
						else
							if( MBLT_CYCLE & SELECTED )
							begin
								status <= S07;
							end
							else
								if( two_edges & SELECTED )
								begin
									status <= S09;
								end
//								else
//									if( any_bad )
//									begin
//										status <= S01;
//										BERR <= 1;
//									end
					end
					
			S01:	begin	// Issue BERR to any decoded bad cycle
						BERR <= 1;
						if( DS0b == 1 && DS1b == 1 )
							status <= S02;
						else
							status <= S01;
					end

			S02:	begin	// From S02 to S06 single, blt and mblt A24/A32 data cycles
						DTACK <= 0;
						INCR_ADDR_COUNTER <= 0;
						ADDR_DIR <= MBLT_CYCLE & WRITEb;
						DATA_ENABLE <= 1;
						DATA_DIR <= WRITEb;	// 1 = RD, 0 = WR
						if( USER_WAITb == 0 )
							status <= S02;
						else
						begin
							if( ASb == 1 )
								status <= S00;
							else
								if( DS0b == 1 && DS1b == 1 )
									status <= S02;
								else
								begin
									if( WRITEb == 1 )	// Read cycle
									begin
										USER_OEb <= 0;
//										USER_REb <= 0;
//										status <= S06;
										status <= S19;
									end
									else				// Write cycle
									begin
//										USER_WEb <= 0;
										status <= S03;
									end
								end
						end
					end
			S03:	begin
						USER_WEb <= 0;
						DTACK <= 1;
						status <= S41;
					end
			S41:	begin
						USER_WEb <= 1;
						DTACK <= 1;
						status <= S04;
					end
			S04:	begin
						if( DS0b == 1 && DS1b == 1 )
						begin
							USER_OEb <= 1;
							DTACK <= 0;
							INCR_ADDR_COUNTER <= 1;
							status <= S05;
						end
						else
							status <= S04;
					end
			S05:	begin
						INCR_ADDR_COUNTER <= 0;
						if( BLT_CYCLE == 1 || MBLT_CYCLE == 1 )
							status <= S02;
						else	// single word
							status <= S00;
					end
			S19:	begin
						USER_REb <= 0;
						status <= S40;
					end
			S40:	begin
						USER_REb <= 1;
						status <= S06;
					end
			S06:	begin
						if( USER_WAITb == 0 )
							status <= S06;
						else
							status <= S41;
					end
					
			S07:	begin	// MBLT addr cycle: S07, S08
						if( DS0b == 1 && DS1b == 1 )
							status <= S07;
						else
						begin
							DTACK <= 1;
							status <= S08;
						end
					end
			S08:	begin
						if( DS0b == 1 && DS1b == 1 )
							status <= S02;
						else
							status <= S08;
					end

			S09:	begin	// READ ONLY Dual Edges cycles: S09, S10, S11, S12 addressing phase
						DATA_DIR <= 0;	// 1 = RD, 0 = WR
						if( DS0b == 1 )
							status <= S09;
						else
						begin
							xam_local <= XAM;
							DTACK <= 1;
							status <= S10;
						end
					end
			S10:	begin
						if( DS0b == 0 )
							status <= S10;
						else
						begin
							LD_A7_0 <= 1;
							ld_beat_counter <= 1;
							DTACK <= 0;
							status <= S11;
						end
					end
			S11:	begin
						LD_A7_0 <= 0;
						ld_beat_counter <= 0;
						if( DS0b == 1 )
							status <= S11;
						else
						begin
							DTACK <= 1;
							even_cycle <= 1;
							status <= S12;
						end
					end
			S12:	begin
						if( DS1b == 1 )
							status <= S12;
						else
						begin
							DATA_DIR <= 1;	// 1 = RD, 0 = WR
							ADDR_DIR <= 1;
							USER_OEb <= 0;
							USER_REb <= 0;
							case( xam_local )
								`d_A32_2eVME: status <= S13;	// 2eVME
								`d_A32_2eSST: status <= S20;	// 2eSST
//								default: status <= S01;
								default: status <= S00;
							endcase
						end
					end

			S13:	begin	// 2eVME read data phase: TO BE REVISED FOR MULTIBOARD
						USER_REb <= 1;
/*
						if( SLAVE_TERMINATE_2E == 1 )
							status <= S26;	// for slave termination
						else
*/
							if( beat_counter == 0 )
							begin
								status <= S50;	// never goes to S50: always exit from S16
//								status <= S26;	// for slave termination
							end
							else
								status <= S14;
/*
							else
							begin
								if( USER_WAITb == 0 )
									status <= S13;
								else
									status <= S14;
							end
*/
					end
			S14:	begin
						INCR_ADDR_COUNTER <= 1;
						decr_beat_counter <= 1;
						DTACK <= ~even_cycle;
						even_cycle <= ~even_cycle;
						status <= S15;
					end
			S15:	begin
						INCR_ADDR_COUNTER <= 0;
						decr_beat_counter <= 0;
						if( (DS1b & ~even_cycle) | (~DS1b & even_cycle) | DS0b )
							status <= S16;
						else
							status <= S15;
					end
			S16:	begin
						if( DS0b == 1 && DS1b == 1 )
							status <= S17;
						else
						begin
//							USER_REb <= (beat_counter != 9'h01) ? 0 : 1;	// seems it does not read last word
							USER_REb <= (beat_counter != 9'h00) ? 0 : 1;
							status <= S13;
						end
					end
			S17:	begin
						DTACK <= 0;
						if( ASb == 1 )
							status <= S00;
					end
			S18:	begin
					end

			S20:	begin	// 2eSST read data phase: TO BE REVISED FOR MULTIBOARD
						USER_REb <= 1;
/*
						if( SLAVE_TERMINATE_2E == 1 )
							status <= S26;	// for slave termination
						else
*/
							if( beat_counter == 0 )
							begin
								status <= S26;	// always slave termination
							end
							else
							begin
								INCR_ADDR_COUNTER <= 1;
								if( rate_code == `d_SST_160 )
									status <= S21;
								else
									if( rate_code == `d_SST_267 )
										status <= S23;
									else
										status <= S24;
							end
					end
			S21:	begin	// 2e160
						INCR_ADDR_COUNTER <= 0;
						status <= S22;
					end
			S22:	begin
						DTACK <= ~even_cycle;
						even_cycle <= ~even_cycle;
						INCR_ADDR_COUNTER <= 0;
						status <= S23;
					end
			S23:	begin	//2e267
						if( rate_code == `d_SST_267 )
						begin
							DTACK <= ~even_cycle;
							even_cycle <= ~even_cycle;
						end
						INCR_ADDR_COUNTER <= 0;
						status <= S24;
					end
			S24:	begin	// 2e320
						decr_beat_counter <= 1;
						INCR_ADDR_COUNTER <= 0;
						if( rate_code == `d_SST_320 )
						begin
							DTACK <= ~even_cycle;
							even_cycle <= ~even_cycle;
						end
						status <= S25;
					end
			S25:	begin
						decr_beat_counter <= 0;
						USER_REb <= (beat_counter != 9'h01) ? 0 : 1;
						if( DS0b == 1 && DS1b == 1 )
							status <= S00;
						else
							status <= S20;
					end

			S26:	begin	// Slave Termination Sequence
						INCR_ADDR_COUNTER <= 0;
						status <= S27;
					end
			S27:	begin
						RETRY <= 1;
						status <= S28;
					end
			S28:	begin
						status <= S29;
					end
			S29:	begin
						status <= S30;
					end
			S30:	begin
						status <= S31;
					end
			S31:	begin
						BERR <= 1;
						if( DS0b == 1 && DS1b == 1 )
							status <= S32;
					end
			S32:	begin
						BERR <= 0;
						RETRY <= 0;
						DTACK <= 0;
						status <= S50;
					end

 			S50:	begin	// wait until end of cycle
						if( DS0b == 1 && DS1b == 1 )
							status <= S51;
					end
 			S51:	begin
						DTACK <= 0;
						if( ASb == 1 )
							status <= S00;
					end

			default: status <= S00;
		endcase
		end
	end
	
endmodule

module TokenHandler(CLK, RESETb, TOKEN_IN, TOKEN_OUT, TOKEN, END_OF_DATA,
	MULTIBOARD_ENABLED, MULTIBOARD_DECODED, MULTIBOARD_FIRST, MULTIBOARD_LAST);
input CLK, RESETb, TOKEN_IN, END_OF_DATA;
output TOKEN_OUT, TOKEN;
input MULTIBOARD_ENABLED, MULTIBOARD_DECODED, MULTIBOARD_FIRST, MULTIBOARD_LAST;

reg TOKEN, local_token_out, TOKEN_OUT;
reg [2:0] tcnt;

	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			local_token_out <= 0;
			TOKEN <= 0;
		end
		else
		begin
			if( local_token_out )
				local_token_out <= 0;
			if( MULTIBOARD_ENABLED & MULTIBOARD_DECODED & (TOKEN == 0) & (MULTIBOARD_FIRST | (MULTIBOARD_FIRST == 0) & TOKEN_IN) )
				TOKEN <= 1;
			if( MULTIBOARD_ENABLED & MULTIBOARD_DECODED & (TOKEN == 1) & END_OF_DATA )
			begin
				TOKEN <= 0;
				if( MULTIBOARD_LAST )
					local_token_out <= 1;
			end
		end
	end

// TOKEN_OUT Stretcher
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			tcnt <= 0;
			TOKEN_OUT <= 0;
		end
		else
		begin
			TOKEN_OUT <= (tcnt != 0) ? 1 : 0;
			if( local_token_out )
				tcnt <= 7;
			else
				if( tcnt != 0 )
					tcnt <= tcnt - 1;
		end
	end

endmodule
