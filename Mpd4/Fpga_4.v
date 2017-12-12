/* This is the implementation for MPD v4 hosting a EP1AGX60DF780C6
 * and 1 x MT47H128CF-3:H (128 MB DDR2 SDRAM)
 *
 */
module Fpga(
	MASTER_RESETb,
	MASTER_CLOCK,	// 40 MHz local oxillatror
	MASTER_CLOCK2,	// 40 MHz from front panel

	VME_D, VME_A, VME_AM, VME_GA, VME_WRITEb, VME_DS0b, VME_DS1b, VME_ASb,
	VME_IACKb, VME_IACKINb, VME_IACKOUTb, VME_DTACKb, VME_BERRb, VME_RETRYb,
	VME_IRQ, VME_ADIR, VME_AOEb, VME_DDIR, VME_DOEb,
	VME_DTACK_EN, VME_BERR_EN, VME_RETRY_EN,
	VME_LIIb, VME_LIOb,

	ADC_DATA, ADC_RESETb, ADC_CS1b, ADC_CS2b, ADC_SCLK, ADC_SDA,
	ADC_LCLK1, ADC_LCLK2, ADC_FRAME_CK1, ADC_FRAME_CK2, ADC_CONV_CK1, //ADC_CONV_CK2,

	APV_CLOCK, APV_TRIGGER, APV_RESET,

	I2C_SCL, I2C_SDA_IN, I2C_SDA_OUT,

	USER_IN_TTL, USER_IN_NIM, USER_OUT, SEL_OUT,

	MII_25MHZ_CLOCK, MII_MDC, MII_MDIO,
	MII_TX_CLK, MII_TX_EN, MII_TXD,
	MII_RX_CLK, MII_RX_DV, MII_RX_ER, MII_RXD,
	MII_CRS, MII_COL, MII_RESETb,

	SDRAM_A, SDRAM_BA, SDRAM_CASb, SDRAM_CKE, SDRAM_CSb, SDRAM_DM, SDRAM_ODT,
	SDRAM_RASb, SDRAM_WEb, SDRAM_CK, SDRAM_CKb, SDRAM_DQ, SDRAM_DQS,

	SD_DAT2, SD_DAT1, SD_DAT0, SD_DETECT, SD_CD, SD_CMD, SD_CLK,

	READ1, READ_CLK1,
	READ2, READ_CLK2,

	LED, SWITCH,

	GXB_TX, GXB_RX, GXB_PRESENT, GXB_TX_DISABLE, GXB_RX_LOS, GXB_CK,

	TOKEN_OUT_P0, TOKEN_OUT_P2, TOKEN_IN_P0, TOKEN_IN_P2,
	TRIG_OUT, BUSY_OUT, SD_LINK_OUT,
	TRIG1_IN, TRIG2_IN, SYNC_IN, STATBIT_A_IN, STATBIT_B_IN,
	CLK_IN_P0,	// 62.5 MHz LVDS from backplane P0 connector
	STATBIT_A_OUT,

	SPARE1, SPARE2, SPARE3,
	
	SPARE33,
	SPARE25,
	SPARE_CLK_LVDS, SPARE_CLK_TTL
);
// Port interface definition
input MASTER_RESETb, MASTER_CLOCK, MASTER_CLOCK2;

inout [31:0] VME_D, VME_A;	// VME_A[0] = LWORD
input [5:0] VME_AM;
input [5:0] VME_GA;	// GA[5] = GAP
input VME_WRITEb, VME_DS0b, VME_DS1b, VME_ASb, VME_IACKb, VME_IACKINb;
output VME_IACKOUTb, VME_DTACKb, VME_BERRb, VME_RETRYb;
output [7:1] VME_IRQ;
output VME_ADIR, VME_AOEb, VME_DDIR, VME_DOEb;
output VME_DTACK_EN, VME_BERR_EN, VME_RETRY_EN;
input VME_LIIb;
output VME_LIOb;

input [15:0] ADC_DATA;	// 480 Mb/s data streams (LVDS)
output ADC_RESETb, ADC_CS1b, ADC_CS2b, ADC_SCLK, ADC_SDA;
input ADC_LCLK1, ADC_LCLK2;	// 240 MHz DDR clock from ADC (LVDS)
input ADC_FRAME_CK1, ADC_FRAME_CK2;		// Word clock from ADC
output ADC_CONV_CK1; // 40 MHz clock (LVDS)
//output ADC_CONV_CK2; // 40 MHz clock (LVDS)

output 	APV_CLOCK, APV_TRIGGER;	// (2.5V LVTTL)
output 	APV_RESET;

output I2C_SCL;
input I2C_SDA_IN;
output I2C_SDA_OUT;

input [1:0] USER_IN_TTL, USER_IN_NIM;
output [1:0] USER_OUT, SEL_OUT;

output MII_25MHZ_CLOCK, MII_MDC;
inout MII_MDIO;
input MII_TX_CLK;
output MII_TX_EN;
output [3:0] MII_TXD;
input MII_RX_CLK, MII_RX_DV, MII_RX_ER;
input [3:0] MII_RXD;
input MII_CRS, MII_COL;
output MII_RESETb;

output [13:0] SDRAM_A;	// was [12:0]
output [2:0] SDRAM_BA;	// was [1:0]
output SDRAM_CASb;
output SDRAM_CKE, SDRAM_CSb;	// was [1:0]
output SDRAM_DM, SDRAM_RASb, SDRAM_WEb;
output SDRAM_ODT;
inout SDRAM_CK, SDRAM_CKb;
inout [7:0] SDRAM_DQ;
inout SDRAM_DQS;

inout SD_DAT2, SD_DAT1, SD_DAT0;
input SD_DETECT, SD_CD;
output SD_CMD, SD_CLK;

output READ_CLK1, READ1, READ_CLK2, READ2;

output [3:0] LED;
input [3:0] SWITCH;

output GXB_TX, GXB_TX_DISABLE;
input GXB_RX, GXB_PRESENT, GXB_RX_LOS, GXB_CK;

output TOKEN_OUT_P0, TOKEN_OUT_P2;
input TOKEN_IN_P0, TOKEN_IN_P2;
output TRIG_OUT, BUSY_OUT, SD_LINK_OUT;
input TRIG1_IN, TRIG2_IN, SYNC_IN, STATBIT_A_IN, STATBIT_B_IN, CLK_IN_P0;
output STATBIT_A_OUT;

// To Test & PMC connectors
inout SPARE1, SPARE2, SPARE3;

// To PMC connectors
inout [16:0] SPARE33;	// 3.3 V I/O
inout [25:0] SPARE25;	// 2.5 V I/O

output SPARE_CLK_LVDS;	// LVDS clock
output SPARE_CLK_TTL;	// 2.5 V clock

// End of port interface definition

	reg BUSY_OUT;

	wire [11:0] adc0, adc1, adc2, adc3, adc4, adc5, adc6, adc7;
	wire [11:0] adc8, adc9, adc10, adc11, adc12, adc13, adc14, adc15;
	wire [11:0] adcx0, adcx1, adcx2, adcx3, adcx4, adcx5, adcx6, adcx7;
	wire [11:0] adcx8, adcx9, adcx10, adcx11, adcx12, adcx13, adcx14, adcx15;
	wire [63:0] Sdram_Fifo_Output_Data;

	wire [1:0] internal_user_in;

	wire ck_40MHz, ck_1MHz, time_clock, Vme_clock;
	wire ck_10MHz;
	wire Vme_DataReadout_ceB;
	wire ObufStatus_ceB, AdcConfig_ceB, I2C_Controller_ceB, Vme_Sdram_ceB, Vme_ConfigReg_ceB;
	wire Histogrammer0_ceB, Histogrammer1_ceB, ApvFifo_ceB, ThrRam_ceB, PedRam_ceB;
	wire [31:0] missing_trigger_count, apv_trigger_count, incoming_trigger_count;
	wire [15:0] ApvSynced, ApvFifoEmpty, ApvFifoFull, ApvError, ApvEnable, ApvFifo_read, ApvFifoRd_EVB,
		OneMoreEvent, ApvEndFrame, ApvFrameGate, ApvFifoFullLatched, ProcFifoFullLatched;
	wire [31:0] IoConfig, TrigGenConfig, ReadoutConfig;
	wire [2:0] TrigMode, ReadoutMode;
	wire [7:0] ApvSyncPeriod;
	wire [20:0] ApvFifoData0, ApvFifoData1, ApvFifoData2, ApvFifoData3,
		ApvFifoData4, ApvFifoData5, ApvFifoData6, ApvFifoData7,
		ApvFifoData8, ApvFifoData9, ApvFifoData10, ApvFifoData11,
		ApvFifoData12, ApvFifoData13, ApvFifoData14, ApvFifoData15;
	wire [20:0] EvbData0, EvbData1, EvbData2, EvbData3, EvbData4, EvbData5, EvbData6, EvbData7,
		EvbData8, EvbData9, EvbData10, EvbData11, EvbData12, EvbData13, EvbData14, EvbData15;
	wire [11:0] one_threshold, zero_threshold;

	wire apv_reset101;
	wire HeaderSeen07, HeaderSeen815;

	wire DataReadout_ceB, Sdram_ceB, ConfigReg_ceB;

	wire user_reB, user_weB, user_oeB;
	wire [21:0] user_addr;	// MUST BE 21 bit = 2Mwords (32 bit wide)
	wire [7:0] user_ceB;
	wire Vme_user_reB, Vme_user_weB, Vme_user_oeB;
	wire [21:0] Vme_user_addr;	// MUST BE 21 bit = 2Mwords (32 bit wide)
	wire [7:0] Vme_user_ceB;

	wire scl_oeB, sda_oeB, i2c_ApvReset;
	wire internal_trigger_disabled;
	wire Pack24BitData, UseSdramFifo, Data64Bit, AllFifoClear, TrigTestMode, sw_apv_trig, sw_apv_reset;
	wire [7:0] ResetLatency, CalibLatency;
	wire [7:0] TriggerDelay;
	wire [3:0] MaxTrigOut;
	wire EnTrig1P0, EnTrig2P0, EnTrigFront, EnSyncP0, EnSyncFront, incoming_trigger, apv_trigger_pulse, sync;


	wire no_more_space07, no_more_space815, space_available07, space_available815;
	wire fwd07, fwd815;
	wire DecrEventCounter;
	wire [11:0] used_fifo_words0, used_fifo_words1, used_fifo_words2, used_fifo_words3,
		used_fifo_words4, used_fifo_words5, used_fifo_words6, used_fifo_words7,
		used_fifo_words8, used_fifo_words9, used_fifo_words10, used_fifo_words11,
		used_fifo_words12, used_fifo_words13, used_fifo_words14, used_fifo_words15;

	wire [15:0] we_ped_ram, re_ped_ram, we_thr_ram; //, re_thr_ram;
	wire [11:0] common_offset;
	wire en_baseline_subtraction;
	wire Enable_EventBuilder, EventBuilder_Read;
	wire [23:0] EvBuilderDataOut;
	wire EventBuilder_Empty, EventBuilder_Full;
	wire [11:0] EventBuilder_Wc;
	wire [23:0] EventBuilder_EvCnt;
	wire RSTb_sync;
	wire [7:0] MarkerCh;
	wire [4:0] SamplePerEvent;
	wire [7:0] EventPerBlock;

	wire mem_local_read_req, mem_local_write_req;
	wire [24:0] mem_local_addr;
	wire [31:0] mem_local_wdata;
	wire [31:0] mem_local_rdata;
	wire [2:0] mem_local_size;
	wire [3:0]  mem_local_be;
	wire local_burstbegin, SdramInitialized;
	wire mem_local_ready, mem_local_rdata_valid;
	reg Vme_user_waitB;
	reg [31:0] mem_local_rdata_latched;
	wire mem_aux_full_rate_clk, mem_aux_half_rate_clk, dll_reference_clk;
	wire [5:0] dqs_delay_ctrl_export;

	wire Sdram_Fifo_read_req, Sdram_Fifo_write_req, Sdram_Fifo_Evb_rd, Sdram_Fifo_Re;
	wire Sdram_Fifo_Overrun;
	wire [24:0] Sdram_Fifo_addr, Sdram_Fifo_Write_Address, Sdram_Fifo_Read_Address, Sdram_Fifo_WordCount;
	wire [31:0] Sdram_Fifo_wdata;
	wire [3:0] Sdram_Bank;
	wire Output_Fifo_Empty, Output_Fifo_Full;
	wire [12:0] Output_Fifo_Wc;

	wire trigger_time_fifo_rd, trigger_time_fifo_rd_evb, trigger_time_fifo_full, trigger_time_fifo_empty, tdc_select;
	wire [7:0] trigger_time_fifo_data, EventBuilder_BlockCnt, Obuf_BlockCnt;

	wire ck_40MHz_from_Bkplane, P0CkPll_Locked, ck_40MHz_Main;
	wire pll_clock_switch0, pll_clock_switch1;
	wire [31:0] BusyThreshold, BusyThresholdLocal;
	wire FifoLevel1, FifoLevel2, EvbFifoAlmostFull;
	wire [1:0] Vme_histo_reg, Fiber_histo_reg, histo_reg;

	wire FIR_enable, sel_time_clk;
	wire ck_125MHz_out, Fiber_reset, Fiber_up, Fiber_hard_err, Fiber_frame_err;
	wire Vme_Fiber_disable, Vme_Fiber_reset;
	wire [7:0] Fiber_err_count;
	wire AuroraFifoFull, AuroraFifoWrite, AuroraEndOfFrame;
	wire Fiber_enabled;
	wire Fiber_user_reB, Fiber_user_weB, Fiber_user_oeB, Fiber_Sdram_ceB, Fiber_ConfigReg_ceB, Fiber_DataReadout_ceB;
	wire [7:0] Fiber_user_ceB;
	wire [15:0] Fiber_user_addr;
	wire [31:0] Fiber_addr_bus;	//	??? [15:0] ???
	wire [31:0] Fiber_dout_bus, Fiber_din_bus, AuroraEventData;
	wire Fiber_wr_bus, Fiber_rd_bus, Fiber_ack_bus, Fiber_data_re, Fiber_activity; // Fiber_nack_bus;
	reg APV_RESET, AllClear;
	wire [15:0] fir_coeff0, fir_coeff1, fir_coeff2, fir_coeff3, fir_coeff4, fir_coeff5, fir_coeff6, fir_coeff7;
	wire [15:0] fir_coeff8, fir_coeff9, fir_coeff10, fir_coeff11, fir_coeff12, fir_coeff13, fir_coeff14, fir_coeff15;
	wire EvbFifoFullLatched, EventFifoFullLatched, TimeFifoFullLatched,OutputFifoFullLatched;
	wire Enable_Slave_Terminate;
	wire User_Reset;

wire [31:0] data_from_vme, data_from_fiber, data_from_master, data_to_fiber;
reg [63:0] data_to_master;
wire [31:0] dout_reg, dout_adc, dout_histo0, dout_histo1, Channel_Direct_Data, asmi_rupd_dout;
wire [7:0] dout_i2c;
wire Dtack_Rd, Berr_Rd, Retry_Rd;
wire asmi_ceB, rupd_ceB;

wire OutputFifoBlockWordCount_Rd, OutputFifoBlockWordCount_Empty, OutputFifoBlockWordCount_Full;
wire [19:0] OutputFifoBlockWordCount_Q;

assign SPARE33 = 0;
assign SPARE25 = 0;
assign SPARE_CLK_TTL = 0;
assign SPARE_CLK_LVDS = SPARE_CLK_TTL;
	
assign VME_LIOb = 1;
assign MII_RESETb = RSTb_sync;
assign MII_MDC = 0;
assign MII_TX_EN = 0;
assign MII_TXD = 4'b0;
assign MII_25MHZ_CLOCK = 0;

assign TOKEN_OUT_P0 = TOKEN_IN_P0;
assign TOKEN_OUT_P2 = TOKEN_IN_P2;
assign TRIG_OUT = 0;
assign STATBIT_A_OUT = 0;
assign SD_LINK_OUT = 0;

assign SD_CMD = 0;
assign SD_CLK = 0;

assign ADC_RESETb = RSTb_sync;
assign ADC_CONV_CK1 = ck_40MHz;


assign I2C_SDA_OUT = (sda_oeB == 0) ? 0 : 1'bz;
assign I2C_SCL = (scl_oeB == 0) ? 0 : 1'bz;
//assign I2C_SCL = scl_oeB;


assign internal_user_in[0] = ~IoConfig[0] ? USER_IN_TTL[0] : ~USER_IN_NIM[0];	// LVTTL default
assign internal_user_in[1] = ~IoConfig[1] ? USER_IN_TTL[1] : ~USER_IN_NIM[1];	// LVTTL default

assign SEL_OUT[0] = IoConfig[2];	// LVTTL default
assign SEL_OUT[1] = IoConfig[3];	// LVTTL default
assign USER_OUT[0] = SEL_OUT[0] ? ~BUSY_OUT : BUSY_OUT;	// BUSY signal
assign USER_OUT[1] = SEL_OUT[1] ? ~ck_40MHz : ck_40MHz;

// Control signals selector switches from VME to Fiber interface
assign user_reB  = Fiber_enabled ? Fiber_user_reB : Vme_user_reB;
assign user_weB  = Fiber_enabled ? Fiber_user_weB : Vme_user_weB;
assign user_oeB  = Fiber_enabled ? Fiber_user_oeB : Vme_user_oeB;
assign user_addr = Fiber_enabled ? {6'h0, Fiber_user_addr} : {6'h0,Vme_user_addr[15:0]};
assign user_ceB  = Fiber_enabled ? Fiber_user_ceB : Vme_user_ceB;	// 8 bit
assign ConfigReg_ceB =  Fiber_enabled ? Fiber_ConfigReg_ceB : Vme_ConfigReg_ceB;
assign histo_reg =  Fiber_enabled ? Fiber_histo_reg : Vme_histo_reg;
assign Sdram_ceB =  Vme_Sdram_ceB;	// VME access only
assign DataReadout_ceB = Vme_DataReadout_ceB;	// VME access only

assign ObufStatus_ceB = user_ceB[0];
assign AdcConfig_ceB = user_ceB[1];
assign I2C_Controller_ceB = user_ceB[2];
assign Histogrammer0_ceB = user_ceB[3];
assign Histogrammer1_ceB = user_ceB[4];
assign ApvFifo_ceB = user_ceB[5];
assign ThrRam_ceB = user_ceB[6];
assign PedRam_ceB = user_ceB[7];

assign ReadoutMode = ReadoutConfig[2:0];
//						DisableMode              = (DAQ_MODE == 3'b000);
//						ApvReadoutMode_Simple    = (DAQ_MODE == 3'b001);
//						SampleMode               = (DAQ_MODE == 3'b010);
//						ApvReadoutMode_Processed = (DAQ_MODE == 3'b011);
assign FIR_enable = ReadoutConfig[4];
assign sel_time_clk = ReadoutConfig[5];
assign Enable_Slave_Terminate = ReadoutConfig[8];
assign Pack24BitData = ReadoutConfig[13];
assign Data64Bit = ReadoutConfig[14];	// Must be 0 (32 bit) if Fiber interface is enabled
assign UseSdramFifo = ReadoutConfig[15];
assign common_offset = ReadoutConfig[27:16];
assign en_baseline_subtraction = ReadoutConfig[28];
assign Enable_EventBuilder = ReadoutConfig[30];
assign AllFifoClear = ReadoutConfig[31];

assign ResetLatency = TrigGenConfig[7:0];
assign MaxTrigOut = TrigGenConfig[11:8];
assign TrigMode = TrigGenConfig[14:12];
//						trig_disable      = (TRIG_MODE == 3'b000);
//						trig_apv_normal   = (TRIG_MODE == 3'b001);
//						trig_apv_multiple = (TRIG_MODE == 3'b010);
//						calib_trig_apv    = (TRIG_MODE == 3'b011);
assign TrigTestMode = TrigGenConfig[15];	// NOT USED
assign EnSyncP0 = TrigGenConfig[16];
assign EnSyncFront = TrigGenConfig[17];
assign sw_apv_trig = TrigGenConfig[18];
assign sw_apv_reset = TrigGenConfig[19];
assign tdc_select = TrigGenConfig[20];
assign EnTrig1P0 = TrigGenConfig[21];
assign EnTrig2P0 = TrigGenConfig[22];
assign EnTrigFront = TrigGenConfig[23];
assign CalibLatency = TrigGenConfig[31:24];	// effective latency = CalibLatency + 4

/* J49 Test connector pinout
 *	1: READ_CLK1
 *	2: READ1
 *	3: READ_CLK2
 *	4: READ2
 *	5: SPARE1
 *	6: SPARE2
 *	7: SPARE3
 *	8: GND
 */
assign READ_CLK1 = 0;
assign READ1 = 0;
assign READ_CLK2 = 0;
assign READ2 = 0;
//assign SPARE1 = mem_local_write_req;
//assign SPARE2 = mem_local_read_req;
//assign SPARE3 = mem_local_rdata_valid;
assign Dtack_Rd = SPARE1;
assign Berr_Rd  = SPARE2;
assign Retry_Rd = SPARE3;

// TBD: CHECK THAT BOTH trigger AND sync SIGNALS WIDTH MUST BE AT LEAST 25 ns
// TBD: NEED TO SYNCHRONIZE THEM ???
assign incoming_trigger = (EnTrig1P0 & TRIG1_IN) |
		 (EnTrig2P0 & TRIG2_IN) |
		 (EnTrigFront & internal_user_in[0]) |
		 sw_apv_trig;

assign sync = (EnSyncP0 & SYNC_IN) | (EnSyncFront & internal_user_in[1]) | sw_apv_reset;


assign data_from_master  = Fiber_enabled ?  data_from_fiber : data_from_vme;

// MASTER_RESETb synchronizer
SyncReset ResetSynchronizer(.CK(MASTER_CLOCK), .ASYNC_RSTb(MASTER_RESETb & ~User_Reset),
	.SYNC_RSTb(RSTb_sync));

assign APV_CLOCK = ck_40MHz;
assign time_clock = sel_time_clk ? CLK_IN_P0 : APV_CLOCK;

	always @(posedge APV_CLOCK)
	begin
		APV_RESET <= RSTb_sync & ~i2c_ApvReset;
		BUSY_OUT <= internal_trigger_disabled | (FifoLevel1&UseSdramFifo) | (EvbFifoAlmostFull&~UseSdramFifo);
	end

	OneShot TurnOnLed0(.OUT(LED[0]), .START(VME_DTACK_EN | Fiber_activity), .CK(ck_1MHz), .RSTb(RSTb_sync));
	OneShot TurnOnLed1(.OUT(LED[1]), .START(APV_TRIGGER),  .CK(ck_1MHz), .RSTb(RSTb_sync));
	OneShot TurnOnLed2(.OUT(LED[2]), .START(~I2C_SCL),     .CK(ck_1MHz), .RSTb(RSTb_sync));
//	OneShot TurnOnLed3(.OUT(LED[3]), .START(1'b0),         .CK(ck_1MHz), .RSTb(RSTb_sync));
	assign LED[3] = Fiber_up;

// Clocking devices
// CLK_IN_P0 = 62.5 MHz = 250 MHz / 4
// A PLL is used to generate 40 MHz from CLK_IN_P0 
// A MUX is implemented to choose between P0 generated and FrontPanel clock
// A PLL is used to generate every neede clock, choosing between local oscillator and the output of the MUX
P0CK_Pll P0Clk_Pll_Inst(
	.inclk0(CLK_IN_P0),	// 62.5 MHz
	.c0(ck_40MHz_from_Bkplane),	// 40 MHz
	.locked(P0CkPll_Locked));

assign pll_clock_switch0 = SWITCH[0];	// default = OPEN = OFF = 1
assign pll_clock_switch1 = SWITCH[1];	// default = OPEN = OFF = 1
/* pll_clock_switch1 pll_clock_switch2 Main clock source
 *       0 (ON)            0 (ON)          CLK_IN_P0 (40 MHz, PLL generated from 62.5 MHz)
 *       0 (ON)            1 (OFF)         MASTER_CLOCK2 (40 MHz, front panel clock)
 *       1 (OFF)           0 (ON)          MASTER_CLOCK (40 MHz, local oscillator)
 *       1 (OFF) *         1 (OFF) *       MASTER_CLOCK (40 MHz, local oscillator)
 *
 * Switch default: *
 */
// Connection for CK40_MUX are very crytical for P&R: do not modify them
CK40_MUX Ck40Mux_Inst(
	.clkselect(pll_clock_switch0),
	.inclk0x(ck_40MHz_from_Bkplane),
	.inclk1x(MASTER_CLOCK2),
	.outclk(ck_40MHz_Main));

GlobalPll ClockGenerator(
	.clkswitch(pll_clock_switch1),
	.inclk0(ck_40MHz_Main),
	.inclk1(MASTER_CLOCK),
	.c0(ck_40MHz),
	.c1(ck_10MHz),
	.c2(ck_1MHz));	// 1.2 MHz
// End of Clocking devices

assign Sdram_Fifo_Re = Fiber_enabled ? Fiber_data_re : (~Vme_user_reB & ~DataReadout_ceB);

assign mem_local_addr      = ~UseSdramFifo ? {Sdram_Bank[3:0], Vme_user_addr[20:0]} : Sdram_Fifo_addr;
assign mem_local_wdata     = ~UseSdramFifo ? data_from_vme : Sdram_Fifo_wdata;
assign mem_local_write_req = ~UseSdramFifo ? (~Vme_user_weB & ~Sdram_ceB) : Sdram_Fifo_write_req;
assign mem_local_read_req  = ~UseSdramFifo ? (~Vme_user_reB & ~Sdram_ceB) : Sdram_Fifo_read_req;

assign mem_local_be = 4'b1111;
assign mem_local_size = 3'b001;
assign local_burstbegin = 1'b1;

//assign EventBuilder_Read = ~UseSdramFifo ? (Enable_EventBuilder & (ApvFifo_read[0] | Fiber_data_re)) :
assign EventBuilder_Read = ~UseSdramFifo ? (Fiber_enabled ? Fiber_data_re : ApvFifo_read[0]) :
	Sdram_Fifo_Evb_rd;

assign Fiber_enabled = ~Vme_Fiber_disable;
assign Fiber_activity = Fiber_enabled & (Fiber_wr_bus | Fiber_rd_bus | AuroraEndOfFrame);

// For SDRAM Vme accesses: TEST ONLY
	always @(posedge Vme_clock or negedge RSTb_sync)
	begin
		if( RSTb_sync == 0 )
			Vme_user_waitB <= 1;
		else
		begin
			if( mem_local_read_req == 1 && UseSdramFifo == 0 )
				Vme_user_waitB <= 0;
			if( mem_local_rdata_valid == 1 )
				Vme_user_waitB <= 1;
		end
	end

	always @(posedge Vme_clock)
		AllClear <= AllFifoClear | apv_reset101;

// Data register
	always @(posedge Vme_clock or negedge RSTb_sync)
	begin
		if( RSTb_sync == 0 )
			mem_local_rdata_latched <= 0;
		else
		begin
		if( mem_local_rdata_valid == 1 )
			mem_local_rdata_latched <= mem_local_rdata;
		end
	end

	always @(*)
	begin
		case({(ObufStatus_ceB & ApvFifo_ceB & ThrRam_ceB & PedRam_ceB), DataReadout_ceB, Sdram_ceB, Histogrammer1_ceB,
				Histogrammer0_ceB, I2C_Controller_ceB, AdcConfig_ceB, ConfigReg_ceB, asmi_ceB&rupd_ceB})
			9'b111111110: data_to_master <= {32'b0, asmi_rupd_dout};
			9'b111111101: data_to_master <= {32'b0, dout_reg};
			9'b111111011: data_to_master <= {32'b0, dout_adc};
			9'b111110111: data_to_master <= {56'b0, dout_i2c};
			9'b111101111: data_to_master <= {32'b0, dout_histo0};
			9'b111011111: data_to_master <= {32'b0, dout_histo1};
			9'b110111111: data_to_master <= {32'b0, mem_local_rdata_latched};
			9'b101111111: data_to_master <= Sdram_Fifo_Output_Data;
			9'b011111111: data_to_master <= {32'b0, Channel_Direct_Data};
			default: data_to_master <= 64'b0;
		endcase
	end
	
FastSdramFifoIf SdramFifoHandler(.RSTb(RSTb_sync), .CLK(Vme_clock),
	.ENABLE(UseSdramFifo), .CLEAR_ADDR(AllClear),
	.SDRAM_WRITE_REQ(Sdram_Fifo_write_req), .SDRAM_READY(mem_local_ready),
	.SDRAM_READ_REQ(Sdram_Fifo_read_req), .SDRAM_DATA_VALID(mem_local_rdata_valid),
	.SDRAM_INPUT_DATA(Sdram_Fifo_wdata), .SDRAM_ADDR(Sdram_Fifo_addr), .SDRAM_RDATA(mem_local_rdata),
	.SDRAM_WRITE_ADDRESS(Sdram_Fifo_Write_Address), .SDRAM_READ_ADDRESS(Sdram_Fifo_Read_Address),
	.SDRAM_WORD_COUNT(Sdram_Fifo_WordCount), .SDRAM_OVERRUN(Sdram_Fifo_Overrun),
	.USER_RE(Sdram_Fifo_Re), .USER_DATA(Sdram_Fifo_Output_Data),
	.USER_64BIT(Data64Bit), .PACK_DATA(Pack24BitData),
	.RD_EVB(Sdram_Fifo_Evb_rd), .WC_EVB(EventBuilder_Wc),.DATA_EVB(EvBuilderDataOut),
	.EMPTY_EVB(EventBuilder_Empty), .FULL_EVB(EventBuilder_Full),
	.OUTPUT_FIFO_EMPTY(Output_Fifo_Empty), .OUTPUT_FIFO_FULL(Output_Fifo_Full),
	.OUTPUT_FIFO_WC(Output_Fifo_Wc),
	.LEVEL1_THRESHOLD(BusyThreshold), .LEVEL2_THRESHOLD(BusyThresholdLocal),
	.FIFO_LEVEL1(FifoLevel1), .FIFO_LEVEL2(FifoLevel2), .OUTPUT_FIFO_FULL_L(OutputFifoFullLatched),
	.DATA_TO_FIBER(data_to_fiber),  .FIFO_BLOCK_CNT(Obuf_BlockCnt),
	.OFIFO_BLOCKWORDCOUNT_RD(OutputFifoBlockWordCount_Rd), .OFIFO_BLOCKWORDCOUNT_EMPTY(OutputFifoBlockWordCount_Empty),
	.OFIFO_BLOCKWORDCOUNT_FULL(OutputFifoBlockWordCount_Full), .OFIFO_BLOCKWORDCOUNT_Q(OutputFifoBlockWordCount_Q)
	);

Ddr2SdramIf Ddr2SdramIf_inst(
	.aux_full_rate_clk (mem_aux_full_rate_clk),	// output
	.aux_half_rate_clk (mem_aux_half_rate_clk),	// output
	.dll_reference_clk (dll_reference_clk),		// output
	.dqs_delay_ctrl_export (dqs_delay_ctrl_export),	// output
	.global_reset_n (RSTb_sync),

	.local_init_done (SdramInitialized),	// output
	.local_refresh_ack (),		// output
	.local_burstbegin (local_burstbegin),
	.local_be (mem_local_be),			// [3:0]
	.local_size (mem_local_size),

	.local_address (mem_local_addr),	// [24:0]

	.local_rdata (mem_local_rdata),
	.local_read_req (mem_local_read_req),
	.local_rdata_valid (mem_local_rdata_valid),

	.local_wdata (mem_local_wdata),
	.local_write_req (mem_local_write_req),
	.local_ready (mem_local_ready),

	.mem_addr (SDRAM_A),
	.mem_ba (SDRAM_BA),
	.mem_cas_n (SDRAM_CASb),
	.mem_cke (SDRAM_CKE),
	.mem_clk (SDRAM_CK),
	.mem_clk_n (SDRAM_CKb),
	.mem_cs_n (SDRAM_CSb),
	.mem_dm (SDRAM_DM),
	.mem_dq (SDRAM_DQ),
	.mem_dqs (SDRAM_DQS),
	.mem_ras_n (SDRAM_RASb),
	.mem_we_n (SDRAM_WEb),
	.mem_odt (SDRAM_ODT),

	.phy_clk (Vme_clock),		// output 100 MHz

	.pll_ref_clk (MASTER_CLOCK),// input 40 MHz
	.reset_phy_clk_n (),		// output
	.reset_request_n (),		// output
	.soft_reset_n (1'b1)		// 200-300 us are needed before initialization
    );

	mpd_fiber_interface AuroraInterface(
			.FIBER_USER_CLK(ck_125MHz_out),		// output

//			-- Fiber link status/control
`ifdef QUESTA_SIMULATION	// Don't know why...
			.FIBER_GT_RESET(~MASTER_RESETb),		// input, Active high reset
			.FIBER_RESET(~MASTER_RESETb),		// input, Active high reset
`else
			.FIBER_GT_RESET(~RSTb_sync | Fiber_reset | Vme_Fiber_reset),		// input, Active high reset
			.FIBER_RESET(~RSTb_sync | Fiber_reset | Vme_Fiber_reset),		// input, Active high reset
`endif
			.FIBER_CHANNEL_UP(Fiber_up),		// output
			.FIBER_HARD_ERR(Fiber_hard_err),	// output
			.FIBER_FRAME_ERR(Fiber_frame_err),	// output
			.FIBER_ERR_CNT(Fiber_err_count),	// output

//			-- REG_* synchronous to REG_CLK
			.REG_CLK(Vme_clock),		//  : in std_logic
			.REG_ADDR(Fiber_addr_bus),	//	: out std_logic_vector(31 downto 0);
			.REG_DOUT(Fiber_din_bus),	//	: out std_logic_vector(31 downto 0);
			.REG_DIN(Fiber_dout_bus),	//	: in std_logic_vector(31 downto 0);
			.REG_WR(Fiber_wr_bus),		//	: out std_logic;
			.REG_RD(Fiber_rd_bus),		//	: out std_logic;
			.REG_ACK(Fiber_ack_bus),	//	: in std_logic;

//			-- EVT_FIFO* synchronous to EVT_FIFO_CLK
//			-- Interface to event FIFO that must be in FWFT mode
//			-- EVT_FIFO_END must be '0' for valid event data (EVT_FIFO_DATA)
//			-- EVT_FIFO_END must be '1' written along with a dummy event data
//			--              word (EVT_FIFO_DATA) to mark the end of an event

			.EVT_FIFO_CLK(Vme_clock),		// input
			.EVT_FIFO_FULL(AuroraFifoFull),	// output
			.EVT_FIFO_WR(AuroraFifoWrite),	// input
			.EVT_FIFO_DATA(AuroraEventData),		// input [31:0]
			.EVT_FIFO_END(AuroraEndOfFrame),		// input

//			-- Serial(2.5Gbps)/Refclk(62.5MHz) I/O
			.RXP(GXB_RX), .TXP(GXB_TX), .REFCLK(GXB_CK));

	FiberInterface FiberInterface_Instance(
		.CLK(Vme_clock),		// input, system
		.RSTb(RSTb_sync),		// input, system
		.ENABLE(Fiber_enabled),
		
		.FIBER_RESET(Fiber_reset),			// output, to AuroraInterface
		.FIBER_CHANNEL_UP(Fiber_up),		// input, from AuroraInterface

//			-- FIBER_BUS* synchronous to FIBER_USER_CLK
		.FIBER_BUS_ADDR(Fiber_addr_bus),	// input, from AuroraInterface
		.FIBER_BUS_DOUT(Fiber_dout_bus),	// input, from AuroraInterface
		.FIBER_BUS_DIN(Fiber_din_bus),		// output, to AuroraInterface
		.FIBER_BUS_WR(Fiber_wr_bus),		// input, from AuroraInterface
		.FIBER_BUS_RD(Fiber_rd_bus),		// input, from AuroraInterface
		.FIBER_BUS_ACK(Fiber_ack_bus),		// output, to AuroraInterface

//			-- EVT_FIFO* synchronous to CLK
		.EVT_FIFO_FULL(AuroraFifoFull),		// input, from AuroraInterface
		.EVT_FIFO_WR(AuroraFifoWrite),		// output, to AuroraInterface
		.EVT_FIFO_DATA(AuroraEventData),	// output, to AuroraInterface
		.EVT_FIFO_END(AuroraEndOfFrame),	// output, to AuroraInterface
		.EVT_FIFO_RD(Fiber_data_re),		// output, to Output FIFO Buffer
		.EVT_FIFO_EMPTY(EventBuilder_Empty),	// input, form Output FIFO Buffer

// Local Interface syncronous with CLK
		.EVB_DATA({8'h0,EvBuilderDataOut}),	// input
		.FIBER_USER_REb(Fiber_user_reB),	// output
		.FIBER_USER_WEb(Fiber_user_weB),	// output
		.FIBER_USER_OEb(Fiber_user_oeB),	// output
		.FIBER_USER_CEb(Fiber_user_ceB),	// output
		.FIBER_CONFIGREG_CEb(Fiber_ConfigReg_ceB),	// output
		.FIBER_HISTO_REG(Fiber_histo_reg),	// output
		.FIBER_USER_ADDR(Fiber_user_addr),	// output
		.FIBER_USER_DATA_IN(data_to_master[31:0]),	// input
		.FIBER_USER_DATA_OUT(data_from_fiber)		// output
	);

VmeSlaveIf VmeIf(
	.VME_A(VME_A[31:1]), .VME_AM(VME_AM), .VME_D(VME_D),
	.VME_ASb(VME_ASb), .VME_DS1b(VME_DS1b), .VME_DS0b(VME_DS0b),
	.VME_WRITEb(VME_WRITEb), .VME_LWORDb(VME_A[0]), .VME_IACKb(VME_IACKb),
	.VME_IackInb(VME_IACKINb), .VME_IackOutb(VME_IACKOUTb),
	.VME_IRQ(VME_IRQ), .VME_DTACK(VME_DTACKb), .VME_BERR(VME_BERRb),
	.VME_DTACK_EN(VME_DTACK_EN), .VME_BERR_EN(VME_BERR_EN),
	.VME_RETRY(VME_RETRYb), .VME_RETRY_EN(VME_RETRY_EN),
	.VME_GAb(VME_GA[4:0]), .VME_GAPb(VME_GA[5]),
	.VME_DATA_DIR(VME_DDIR), .VME_DBUF_OEb(VME_DOEb),
	.VME_ADDR_DIR(VME_ADIR), .VME_ABUF_OEb(VME_AOEb),
	.USER_D64(1'b1),	// Permit VME 64 bit data transactions
	.USER_ADDR(Vme_user_addr), // 22 bit
	.USER_DATA_IN(data_to_master), // 64 bit
	.USER_DATA_OUT(data_from_vme), //32 bit
	.USER_WEb(Vme_user_weB), .USER_REb(Vme_user_reB), .USER_OEb(Vme_user_oeB),
	.USER_CEb(Vme_user_ceB), // 8 bit
	.HISTO_REG(Vme_histo_reg),
	.USER_WAITb(Vme_user_waitB),
	.SLAVE_TERMINATE_2E(Output_Fifo_Empty & Enable_Slave_Terminate),
	.RESETb(RSTb_sync),
	.CLK(Vme_clock),
	.CONFIG_CEb(Vme_ConfigReg_ceB), .SDRAM_CEb(Vme_Sdram_ceB), .OBUF_CEb(Vme_DataReadout_ceB),
	.ASMI_CEb(asmi_ceB), .RUPD_CEb(rupd_ceB),
	.TOKEN_IN(), .END_OF_DATA(), .TOKEN_OUT(), .TOKEN(),
	.GXB_TX_DISABLE(GXB_TX_DISABLE), .GXB_PRESENT(GXB_PRESENT), .GXB_RX_LOS(GXB_RX_LOS),
	.FIBER_RESET(Vme_Fiber_reset), .FIBER_DISABLE(Vme_Fiber_disable),
	.FIBER_UP(Fiber_up), .FIBER_HARD_ERR(Fiber_hard_err), .FIBER_FRAME_ERR(Fiber_frame_err),
	.FIBER_ERR_COUNT(Fiber_err_count), .SDRAM_BANK(Sdram_Bank)
	);

AsmiRemote RemoteUpdate_AsmiIf(
	.VME_CLK(Vme_clock), .RESETb(RSTb_sync),
	.USER_ADDR(Vme_user_addr[1:0]),
	.USER_DATA_IN(data_from_vme), .USER_DATA_OUT(asmi_rupd_dout), .ASMI_CEb(asmi_ceB), .RUPD_CEb(rupd_ceB),
	.USER_WEb(Vme_user_weB), .USER_REb(Vme_user_reB), .USER_OEb(Vme_user_oeB),
	.PERIPH_CK(ck_10MHz)
);

RegisterBank ConfigRegisters_and_Rom(
	.RSTb(RSTb_sync), .CLK(Vme_clock), .ADDR(user_addr[17:0]),
	.DATA_IN(data_from_master), .DATA_OUT(dout_reg),
	.WEb(user_weB), .REb(user_reB), .OEb(user_oeB), .CEb(ConfigReg_ceB),
	.USER_RESET(User_Reset), //.RESET_REG(),
	.SAMPLE_PER_EVENT(SamplePerEvent), .EVENT_PER_BLOCK(EventPerBlock),
	.BUSY_THRESHOLD(BusyThreshold), .BUSY_THRESHOLD_LOCAL(BusyThresholdLocal),
	.IO_CONFIG(IoConfig), .READOUT_CONFIG(ReadoutConfig), .TRIGGER_CONFIG(TrigGenConfig),
	.TRIGGER_DELAY(TriggerDelay), .SYNC_PERIOD(ApvSyncPeriod), .MARKER_CHANNEL(MarkerCh),
	.CHANNEL_ENABLE(ApvEnable),
	.ZERO_THRESHOLD(zero_threshold), .ONE_THRESHOLD(one_threshold),
	.FIR0_COEFF(fir_coeff0), .FIR1_COEFF(fir_coeff1), .FIR2_COEFF(fir_coeff2), .FIR3_COEFF(fir_coeff3),
	.FIR4_COEFF(fir_coeff4), .FIR5_COEFF(fir_coeff5), .FIR6_COEFF(fir_coeff6), .FIR7_COEFF(fir_coeff7),
	.FIR8_COEFF(fir_coeff8), .FIR9_COEFF(fir_coeff9), .FIR10_COEFF(fir_coeff10), .FIR11_COEFF(fir_coeff11),
	.FIR12_COEFF(fir_coeff12), .FIR13_COEFF(fir_coeff13), .FIR14_COEFF(fir_coeff14), .FIR15_COEFF(fir_coeff15)
	);

AdcConfigMachine AdcConfigurator(
	.RSTb(RSTb_sync), .CLK(Vme_clock),
	.WEb(user_weB), .REb(user_reB), .OEb(user_oeB), .CEb(AdcConfig_ceB),
	.DATA_IN(data_from_master), .DATA_OUT(dout_adc),
	.AdcConfigClk(ck_10MHz),
	.ADC_CS1b(ADC_CS1b), .ADC_CS2b(ADC_CS2b), .ADC_SCLK(ADC_SCLK), .ADC_SDA(ADC_SDA));

i2c_master_top I2C_Controller(
	.wb_clk_i(Vme_clock), .wb_rst_i(1'b0), .arst_i(RSTb_sync), .wb_adr_i(user_addr[2:0]),
	.wb_dat_i(data_from_master[7:0]), .wb_dat_o(dout_i2c),
	.weB(user_weB), .reB(user_reB), .oeB(user_oeB), .ceB(I2C_Controller_ceB),
	.scl_pad_i(I2C_SCL), .scl_pad_o(), .scl_padoen_o(scl_oeB),
	.sda_pad_i(I2C_SDA_IN), .sda_pad_o(), .sda_padoen_o(sda_oeB),
	.ApvReset(i2c_ApvReset) );





AdcDeser AdcDeser0(.ADC_SDATA(ADC_DATA[7:0]), .LCLK(ADC_LCLK1), .ADCLK(ADC_FRAME_CK1),
	.ADC_PDATA0(adc0), .ADC_PDATA1(adc1), .ADC_PDATA2(adc2), .ADC_PDATA3(adc3),
	.ADC_PDATA4(adc4), .ADC_PDATA5(adc5), .ADC_PDATA6(adc6), .ADC_PDATA7(adc7));

AdcDeser AdcDeser1(.ADC_SDATA(ADC_DATA[15:8]), .LCLK(ADC_LCLK2), .ADCLK(ADC_FRAME_CK2),
	.ADC_PDATA0(adc8), .ADC_PDATA1(adc9), .ADC_PDATA2(adc10), .ADC_PDATA3(adc11),
	.ADC_PDATA4(adc12), .ADC_PDATA5(adc13), .ADC_PDATA6(adc14), .ADC_PDATA7(adc15));

fir_16tap fir0(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc0), .DATA_OUT(adcx0),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir1(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc1), .DATA_OUT(adcx1),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir2(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc2), .DATA_OUT(adcx2),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir3(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc3), .DATA_OUT(adcx3),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir4(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc4), .DATA_OUT(adcx4),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir5(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc5), .DATA_OUT(adcx5),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir6(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc6), .DATA_OUT(adcx6),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir7(.CLK(ADC_FRAME_CK1), .ENABLE_FIR(FIR_enable), .DATA_IN(adc7), .DATA_OUT(adcx7),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir8(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc8), .DATA_OUT(adcx8),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir9(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc9), .DATA_OUT(adcx9),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir10(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc10), .DATA_OUT(adcx10),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir11(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc11), .DATA_OUT(adcx11),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir12(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc12), .DATA_OUT(adcx12),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir13(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc13), .DATA_OUT(adcx13),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir14(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc14), .DATA_OUT(adcx14),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));

fir_16tap fir15(.CLK(ADC_FRAME_CK2), .ENABLE_FIR(FIR_enable), .DATA_IN(adc15), .DATA_OUT(adcx15),
	.COEFF_0(fir_coeff0), .COEFF_1(fir_coeff1), .COEFF_2(fir_coeff2), .COEFF_3(fir_coeff3),
	.COEFF_4(fir_coeff4), .COEFF_5(fir_coeff5), .COEFF_6(fir_coeff6), .COEFF_7(fir_coeff7),
	.COEFF_8(fir_coeff8), .COEFF_9(fir_coeff9), .COEFF_10(fir_coeff10), .COEFF_11(fir_coeff11),
	.COEFF_12(fir_coeff12), .COEFF_13(fir_coeff13), .COEFF_14(fir_coeff14), .COEFF_15(fir_coeff15));


Histogrammer AdcHisto0(.LCLK(ADC_LCLK1), .ADCLK(ADC_FRAME_CK1),
	.ADC_PDATA0(adcx0), .ADC_PDATA1(adcx1), .ADC_PDATA2(adcx2), .ADC_PDATA3(adcx3),
	.ADC_PDATA4(adcx4), .ADC_PDATA5(adcx5), .ADC_PDATA6(adcx6), .ADC_PDATA7(adcx7),
	.RSTb(RSTb_sync), .CLK(Vme_clock),
	.WEb(user_weB), .REb(user_reB), .OEb(user_oeB), .CEb(Histogrammer0_ceB),
	.USER_ADDR({histo_reg[0], user_addr[11:0]}),
	.DATA_IN(data_from_master), .DATA_OUT(dout_histo0));

Histogrammer AdcHisto1(.LCLK(ADC_LCLK2), .ADCLK(ADC_FRAME_CK2),
	.ADC_PDATA0(adcx8), .ADC_PDATA1(adcx9), .ADC_PDATA2(adcx10), .ADC_PDATA3(adcx11),
	.ADC_PDATA4(adcx12), .ADC_PDATA5(adcx13), .ADC_PDATA6(adcx14), .ADC_PDATA7(adcx15),
	.RSTb(RSTb_sync), .CLK(Vme_clock),
	.WEb(user_weB), .REb(user_reB), .OEb(user_oeB), .CEb(Histogrammer1_ceB),
	.USER_ADDR({histo_reg[1], user_addr[11:0]}),
	.DATA_IN(data_from_master), .DATA_OUT(dout_histo1));


TrigGen ApvTriggerHandler(.APV_TRG(APV_TRIGGER), .RESET101(apv_reset101), .RSTb(RSTb_sync),
	.CLK(APV_CLOCK), .MAX_TRIG_OUT(MaxTrigOut), .TRIG_PULSE(apv_trigger_pulse),
	.TRIG_MODE(TrigMode),
	.TRIG_CMD(incoming_trigger), .RESET_CMD(sync),
	.MISSING_TRIGGER_CNT(missing_trigger_count), .APV_TRIGGER_CNT(apv_trigger_count),
	.INCOMING_TRIGGER_CNT(incoming_trigger_count),
	.MAX_RESET_LATENCY(ResetLatency), .CALIB_LATENCY(CalibLatency),
	.NO_MORE_SPACE(no_more_space07 | no_more_space815),
//	.SPACE_AVAILABLE(space_available07 & space_available815),
	.SPACE_AVAILABLE( &ApvFifoEmpty ), .OUTPUT_FIFO_ALMOST_FULL(FifoLevel2&UseSdramFifo),
	.TRIGGER_DISABLED(internal_trigger_disabled), .TRIGGER_DELAY(TriggerDelay));	// BUSY signal

TrigMeas TriggerMeasurements(.FAST_CK(ADC_LCLK1), .RSTb(RSTb_sync),
	.START_TDC(APV_CLOCK), .STOP_TDC(incoming_trigger),
	.ALL_CLEAR(AllClear), .TDC_SELECT(tdc_select),
	.TRIGGER_TIME_FIFO_RD(trigger_time_fifo_rd|trigger_time_fifo_rd_evb),  .TRIGGER_TIME_FIFO_CK(Vme_clock),
	.TRIGGER_TIME_FIFO(trigger_time_fifo_data),
	.TRIGGER_TIME_FIFO_FULL(trigger_time_fifo_full), .TRIGGER_TIME_FIFO_EMPTY(trigger_time_fifo_empty));



EightChannels ApvProcessor_0_7(.RSTb(RSTb_sync), .APV_CLK(ADC_FRAME_CK1), .PROCESS_CLK(Vme_clock),
	.ENABLE(ApvEnable[7:0]),
	.EN_BASELINE_SUBTRACTION(en_baseline_subtraction),
	.ADC_PDATA0(adcx0), .ADC_PDATA1(adcx1), .ADC_PDATA2(adcx2), .ADC_PDATA3(adcx3),
	.ADC_PDATA4(adcx4), .ADC_PDATA5(adcx5), .ADC_PDATA6(adcx6), .ADC_PDATA7(adcx7),
	.SYNC_PERIOD(ApvSyncPeriod), .SYNCED(ApvSynced[7:0]),
	.COMMON_OFFSET(common_offset), .BANK_ID(1'b0),
	.FIFO_DATA_OUT0(ApvFifoData0), .FIFO_DATA_OUT1(ApvFifoData1),
	.FIFO_DATA_OUT2(ApvFifoData2), .FIFO_DATA_OUT3(ApvFifoData3),
	.FIFO_DATA_OUT4(ApvFifoData4), .FIFO_DATA_OUT5(ApvFifoData5),
	.FIFO_DATA_OUT6(ApvFifoData6), .FIFO_DATA_OUT7(ApvFifoData7),
	.DATA_TO_EVB0(EvbData0), .DATA_TO_EVB1(EvbData1),
	.DATA_TO_EVB2(EvbData2), .DATA_TO_EVB3(EvbData3),
	.DATA_TO_EVB4(EvbData4), .DATA_TO_EVB5(EvbData5),
	.DATA_TO_EVB6(EvbData6), .DATA_TO_EVB7(EvbData7),
	.FIFO_EMPTY(ApvFifoEmpty[7:0]), .FIFO_FULL(ApvFifoFull[7:0]),
	.FIFO_RD(Enable_EventBuilder ? ApvFifoRd_EVB[7:0] : ApvFifo_read[7:0]),
	.HIGH_ONE(one_threshold), .LOW_ZERO(zero_threshold),
	.ALL_CLEAR(AllClear), .DAQ_MODE(ReadoutMode),
	.USED_FIFO_WORDS0(used_fifo_words0), .USED_FIFO_WORDS1(used_fifo_words1),
	.USED_FIFO_WORDS2(used_fifo_words2), .USED_FIFO_WORDS3(used_fifo_words3),
	.USED_FIFO_WORDS4(used_fifo_words4), .USED_FIFO_WORDS5(used_fifo_words5),
	.USED_FIFO_WORDS6(used_fifo_words6), .USED_FIFO_WORDS7(used_fifo_words7),
	.ONE_MORE_EVENT(OneMoreEvent[7:0]), .DECR_EVENT_COUNTER(DecrEventCounter),
	.NO_MORE_SPACE(no_more_space07), .SPACE_AVAILABLE(space_available07),
	.RAM_ADDR(user_addr[6:0]), .RAM_DIN(data_from_master),
	.WE_PED_RAM(we_ped_ram[7:0]), .RE_PED_RAM(re_ped_ram[7:0]),
	.WE_THR_RAM(we_thr_ram[7:0]), //.RE_THR_RAM(re_thr_ram[7:0]),
	.MODULE_ID(~VME_GA[4:0]), .MARKER_CH(MarkerCh), .SAMPLE_PER_EVENT(SamplePerEvent),
	.APV_FIFO_FULL_L(ApvFifoFullLatched[7:0]), .PROC_FIFO_FULL_L(ProcFifoFullLatched[7:0])
	);

EightChannels ApvProcessor_8_15(.RSTb(RSTb_sync), .APV_CLK(ADC_FRAME_CK2), .PROCESS_CLK(Vme_clock),
	.ENABLE(ApvEnable[15:8]),
	.EN_BASELINE_SUBTRACTION(en_baseline_subtraction),
	.ADC_PDATA0(adcx8), .ADC_PDATA1(adcx9), .ADC_PDATA2(adcx10), .ADC_PDATA3(adcx11),
	.ADC_PDATA4(adcx12), .ADC_PDATA5(adcx13), .ADC_PDATA6(adcx14), .ADC_PDATA7(adcx15),
	.SYNC_PERIOD(ApvSyncPeriod), .SYNCED(ApvSynced[15:8]),
	.COMMON_OFFSET(common_offset), .BANK_ID(1'b1),
	.FIFO_DATA_OUT0(ApvFifoData8), .FIFO_DATA_OUT1(ApvFifoData9),
	.FIFO_DATA_OUT2(ApvFifoData10), .FIFO_DATA_OUT3(ApvFifoData11),
	.FIFO_DATA_OUT4(ApvFifoData12), .FIFO_DATA_OUT5(ApvFifoData13),
	.FIFO_DATA_OUT6(ApvFifoData14), .FIFO_DATA_OUT7(ApvFifoData15),
	.DATA_TO_EVB0(EvbData8), .DATA_TO_EVB1(EvbData9),
	.DATA_TO_EVB2(EvbData10), .DATA_TO_EVB3(EvbData11),
	.DATA_TO_EVB4(EvbData12), .DATA_TO_EVB5(EvbData13),
	.DATA_TO_EVB6(EvbData14), .DATA_TO_EVB7(EvbData15),
	.FIFO_EMPTY(ApvFifoEmpty[15:8]), .FIFO_FULL(ApvFifoFull[15:8]),
	.FIFO_RD(Enable_EventBuilder ? ApvFifoRd_EVB[15:8] : ApvFifo_read[15:8]),
	.HIGH_ONE(one_threshold), .LOW_ZERO(zero_threshold),
	.ALL_CLEAR(AllClear), .DAQ_MODE(ReadoutMode),
	.USED_FIFO_WORDS0(used_fifo_words8), .USED_FIFO_WORDS1(used_fifo_words9),
	.USED_FIFO_WORDS2(used_fifo_words10), .USED_FIFO_WORDS3(used_fifo_words11),
	.USED_FIFO_WORDS4(used_fifo_words12), .USED_FIFO_WORDS5(used_fifo_words13),
	.USED_FIFO_WORDS6(used_fifo_words14), .USED_FIFO_WORDS7(used_fifo_words15),
	.ONE_MORE_EVENT(OneMoreEvent[15:8]), .DECR_EVENT_COUNTER(DecrEventCounter),
	.NO_MORE_SPACE(no_more_space815), .SPACE_AVAILABLE(space_available815),
	.RAM_ADDR(user_addr[6:0]), .RAM_DIN(data_from_master),
	.WE_PED_RAM(we_ped_ram[15:8]), .RE_PED_RAM(re_ped_ram[15:8]),
	.WE_THR_RAM(we_thr_ram[15:8]), //.RE_THR_RAM(re_thr_ram[15:8]),
	.MODULE_ID(~VME_GA[4:0]), .MARKER_CH(MarkerCh), .SAMPLE_PER_EVENT(SamplePerEvent),
	.APV_FIFO_FULL_L(ApvFifoFullLatched[15:8]), .PROC_FIFO_FULL_L(ProcFifoFullLatched[15:8])
	);

FifoIf DebugFifoIf(.FIFO_RD(ApvFifo_read),
	.FIFO_DATA_OUT0(ApvFifoData0), .FIFO_DATA_OUT1(ApvFifoData1),
	.FIFO_DATA_OUT2(ApvFifoData2), .FIFO_DATA_OUT3(ApvFifoData3),
	.FIFO_DATA_OUT4(ApvFifoData4), .FIFO_DATA_OUT5(ApvFifoData5),
	.FIFO_DATA_OUT6(ApvFifoData6), .FIFO_DATA_OUT7(ApvFifoData7),
	.FIFO_DATA_OUT8(ApvFifoData8), .FIFO_DATA_OUT9(ApvFifoData9),
	.FIFO_DATA_OUT10(ApvFifoData10), .FIFO_DATA_OUT11(ApvFifoData11),
	.FIFO_DATA_OUT12(ApvFifoData12), .FIFO_DATA_OUT13(ApvFifoData13),
	.FIFO_DATA_OUT14(ApvFifoData14), .FIFO_DATA_OUT15(ApvFifoData15),
	.USED_FIFO_WORDS0(used_fifo_words0), .USED_FIFO_WORDS1(used_fifo_words1),
	.USED_FIFO_WORDS2(used_fifo_words2), .USED_FIFO_WORDS3(used_fifo_words3),
	.USED_FIFO_WORDS4(used_fifo_words4), .USED_FIFO_WORDS5(used_fifo_words5),
	.USED_FIFO_WORDS6(used_fifo_words6), .USED_FIFO_WORDS7(used_fifo_words7),
	.USED_FIFO_WORDS8(used_fifo_words8), .USED_FIFO_WORDS9(used_fifo_words9),
	.USED_FIFO_WORDS10(used_fifo_words10), .USED_FIFO_WORDS11(used_fifo_words11),
	.USED_FIFO_WORDS12(used_fifo_words12), .USED_FIFO_WORDS13(used_fifo_words13),
	.USED_FIFO_WORDS14(used_fifo_words14), .USED_FIFO_WORDS15(used_fifo_words15),
	.FIFO_EMPTY(ApvFifoEmpty), .FIFO_FULL(ApvFifoFull),
	.SYNCED(ApvSynced), .ERROR(ApvError),
	.RSTb(RSTb_sync), .CLK(Vme_clock),
	.WEb(user_weB), .REb(user_reB), .OEb(user_oeB),
	.FIFO_CEb(ApvFifo_ceB), .THR_CEb(ThrRam_ceB), .PED_CEb(PedRam_ceB), .OBUF_STATUS_CEb(ObufStatus_ceB),
	.USER_ADDR(user_addr[15:0]),
	.DATA_OUT(Channel_Direct_Data),
	.MISSED_TRIGGER(missing_trigger_count), .INCOMING_TRIGGER_CNT(incoming_trigger_count),
	.WE_PED_RAM(we_ped_ram), .RE_PED_RAM(re_ped_ram),
	.WE_THR_RAM(we_thr_ram), //.RE_THR_RAM(re_thr_ram),
	.EV_BUILDER_DATA_OUT(EvBuilderDataOut), .EV_BUILDER_ENABLE(Enable_EventBuilder),
	.EV_BUILDER_FIFO_EMPTY(EventBuilder_Empty), .EV_BUILDER_FIFO_FULL(EventBuilder_Full),
	.EV_BUILDER_FIFO_WC({4'h0,EventBuilder_Wc}),
	.EV_BUILDER_EV_CNT(EventBuilder_EvCnt), .EV_BUILDER_BLOCK_CNT(EventBuilder_BlockCnt), .OBUF_BLOCK_CNT(Obuf_BlockCnt),
	.TRIGGER_COUNTER(apv_trigger_count), .SDRAM_INITIALIZED(SdramInitialized),
	.TRIGGER_TIME_FIFO_RD(trigger_time_fifo_rd), .TRIGGER_TIME_FIFO(trigger_time_fifo_data),
	.TRIGGER_TIME_FIFO_FULL(trigger_time_fifo_full), .TRIGGER_TIME_FIFO_EMPTY(trigger_time_fifo_empty),
	.SDRAM_FIFO_WRITE_ADDRESS(Sdram_Fifo_Write_Address), .SDRAM_FIFO_READ_ADDRESS(Sdram_Fifo_Read_Address),
	.SDRAM_FIFO_OVERRUN(Sdram_Fifo_Overrun), .SDRAM_FIFO_WORDCOUNT(Sdram_Fifo_WordCount),
	.OUTPUT_FIFO_FULL(Output_Fifo_Full), .OUTPUT_FIFO_EMPTY(Output_Fifo_Empty), .OUTPUT_FIFO_WC(Output_Fifo_Wc),
	.APV_FIFO_FULL_L(ApvFifoFullLatched), .PROC_FIFO_FULL_L(ProcFifoFullLatched), .OUTPUT_FIFO_FULL_L(OutputFifoFullLatched),
	.EVB_FIFO_FULL_L(EvbFifoFullLatched), .EVENT_FIFO_FULL_L(EventFifoFullLatched), .TIME_FIFO_FULL_L(TimeFifoFullLatched),
	.OFIFO_BLOCKWORDCOUNT_RD(OutputFifoBlockWordCount_Rd), .OFIFO_BLOCKWORDCOUNT_EMPTY(OutputFifoBlockWordCount_Empty),
	.OFIFO_BLOCKWORDCOUNT_FULL(OutputFifoBlockWordCount_Full), .OFIFO_BLOCKWORDCOUNT_Q(OutputFifoBlockWordCount_Q)
	);

	
EventBuilder TheBuilder(.RSTb(RSTb_sync), .TIME_CLK(time_clock), .CLK(Vme_clock),
//	.TRIGGER(incoming_trigger),	// Incoming trigger pulse
	.TRIGGER(apv_trigger_pulse),	// Pulse sent to APVs
	.ALL_CLEAR(AllClear),
	.SAMPLE_PER_EVENT(SamplePerEvent), .EVENT_PER_BLOCK(EventPerBlock),
	.ENABLE_MASK(ApvEnable), .ENABLE_EVBUILD(Enable_EventBuilder),
	.TRIGGER_TIME_FIFO(trigger_time_fifo_data), .TRIGGER_TIME_FIFO_RD(trigger_time_fifo_rd_evb),
	.CH_DATA0(EvbData0), .CH_DATA1(EvbData1),
	.CH_DATA2(EvbData2), .CH_DATA3(EvbData3),
	.CH_DATA4(EvbData4), .CH_DATA5(EvbData5),
	.CH_DATA6(EvbData6), .CH_DATA7(EvbData7),
	.CH_DATA8(EvbData8), .CH_DATA9(EvbData9),
	.CH_DATA10(EvbData10), .CH_DATA11(EvbData11),
	.CH_DATA12(EvbData12), .CH_DATA13(EvbData13),
	.CH_DATA14(EvbData14), .CH_DATA15(EvbData15),
	.DATA_RD(ApvFifoRd_EVB), .EVENT_PRESENT(OneMoreEvent),
	.DECREMENT_EVENT_COUNT(DecrEventCounter), .MODULE_ID(~VME_GA[4:0]),
	.DATA_OUT(EvBuilderDataOut), .EMPTY(EventBuilder_Empty), .FULL(EventBuilder_Full),
	.ALMOST_FULL(EvbFifoAlmostFull),
	.DATA_OUT_CNT(EventBuilder_Wc), .DATA_OUT_RD(EventBuilder_Read),
	.EV_CNT(EventBuilder_EvCnt), .BLOCK_CNT(EventBuilder_BlockCnt),
	.EVB_FIFO_FULL_L(EvbFifoFullLatched), .EVENT_FIFO_FULL_L(EventFifoFullLatched), .TIME_FIFO_FULL_L(TimeFifoFullLatched)
	);


endmodule

