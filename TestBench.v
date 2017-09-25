`timescale 1ns/100ps

module _a_TestBench;

parameter master_ck_period = 25;
parameter master_ck_half_period = master_ck_period / 2;
parameter master_ck_hold  = 1;	// data hold time

parameter fast_ck_period = 16;
parameter fast_ck_half_period = fast_ck_period / 2;

parameter gxb_ck_period = 16;
parameter gxb_ck_half_period = gxb_ck_period / 2;

//parameter vme_period = 17;
parameter vme_period = 10;

parameter adc_deskew_pattern = 2'b00;
parameter adc_sync_pattern = 2'b01;
parameter adc_ApvSync_pattern = 2'b10;
parameter adc_ApvFrame_pattern = 2'b11;

parameter Cr_start = 19'h0, Cr_end = 19'h00100;


integer fout, dump_fout;
reg echo, use_sdram;
reg Master_clock, Master_resetB;
wire [15:0] adc_data;
reg [11:0] adc_pdata;
integer adc_bit_count, adc_word_count, i;
wire adc_lclk1, adc_lclk2, adc_ck1, adc_ck2, adc_conv_ck;

tri1 i2c_scl, i2c_sda;
tri1 [31:0] vme_data, vme_addr;
wire [31:0] vme_data_x, vme_addr_x;
reg [31:0] internal_vme_data, rd_data;
reg [31:1] internal_vme_addr;
wire [5:0] vme_ga;
tri1 [7:1] vme_irqB;
reg [5:0] vme_am;
reg [4:0] geog_addr;
reg vme_writeB, vme_ds0B, vme_ds1B, vme_asB, vme_iackB, vme_lwordB;
reg d64_vme_cycle, sst_addr_cycle;
wire vme_iackoutB, vme_adir, vme_aoeB, vme_ddir, vme_doeB, vme_dtack_en, vme_berr_en, vme_retry_en;
tri1 vme_dtackB, vme_berrB, vme_retryB;
wire vme_dtackB_x, vme_berrB_x, vme_retryB_x;
wire [17:0] ObufStatus_base, AdcSpi_base, ThrRam_base, PedRam_base;
wire [17:0] Histo_base, Histo0_base, Histo1_base, ApvFifo_base, I2C_base;
wire [31:0] Sdram_base, DataReadout_base, Test_base;
wire Sdram_ck, Sdram_ckB, Sdram_rasB, Sdram_casB, Sdram_weB, Sdram_dm, Sdram_odt;
wire Sdram_csB, Sdram_cke;
wire [2:0] Sdram_ba;
wire [13:0] Sdram_addr;
tri1 [7:0] Sdram_dq;
reg [1:0] adc_pattern;
reg usb_rxfB, usb_txeB;
wire usb_rdB, usb_wr;
reg trig_pulse;
reg fast_clock, gxb_clock;
tri1 Sdram_dqsN;	// same as wire
tri0 Sdram_dqs;		// same as wire
reg [12:0] mean, ch_count;
reg [3:0] MaxTrigOut;	// N of trigger sent to APVs for each incoming TRIGGER
reg apv_SampleMode;	// 0 = 3 samples, 1 = 1 sample
wire [3:0] apv_SamplePerTrigger;
wire [31:0] SamplePerEvent;

assign vme_ga = {parity(geog_addr), ~geog_addr};
assign vme_addr = (d64_vme_cycle == 0) ? {internal_vme_addr, vme_lwordB} : 32'bz;
assign vme_data = (vme_writeB == 0 || sst_addr_cycle == 1 ) ? internal_vme_data : 32'bz;

assign ObufStatus_base = 18'h00200;	// to 18'h002FC;
assign AdcSpi_base = 18'h00300;	// to 18'h00300
assign I2C_base = 18'h00400;	// to 18'h0041C
assign Histo_base = 18'h04000;	// to 18'h0EFFC
assign ApvFifo_base = 18'h10000;	// to 18'h2FFFC
assign Histo0_base = Histo_base;	// from 18'h04000 to 18'h07FFC
assign Histo1_base = Histo_base + 18'h04000;	// from 18'h08000 to 18'h0BFFC
assign PedRam_base = 18'h34000;	// to 18'h35FFC
assign ThrRam_base = 18'h36000;	// to 18'h37FFC

assign DataReadout_base = 32'h80_0000;	// Output buffer is mutually exclusive from Sdram direct access (8 MB)
assign Sdram_base = 32'h100_0000;		// Sdram direct access active only if UseSdramFifo = ReadoutConfig[15] = 0

assign apv_SamplePerTrigger = apv_SampleMode ? 4'h1 : 4'h3;
assign SamplePerEvent = apv_SamplePerTrigger * MaxTrigOut;

BidirBuf #(32) Abuf(.A(vme_addr_x), .B(vme_addr), .OEb(vme_aoeB), .DIR(vme_adir));
BidirBuf #(32) Dbuf(.A(vme_data_x), .B(vme_data), .OEb(vme_doeB), .DIR(vme_ddir));
BidirBuf #(1) Dtack_buf(.A(vme_dtackB_x), .B(vme_dtackB), .OEb(~vme_dtack_en), .DIR(1'b1));
BidirBuf #(1) Berr_buf(.A(vme_berrB_x), .B(vme_berrB), .OEb(~vme_berr_en), .DIR(1'b1));
BidirBuf #(1) Retry_buf(.A(vme_retryB_x), .B(vme_retryB), .OEb(~vme_retry_en), .DIR(1'b1));

Fpga Dut(
	.MASTER_RESETb(Master_resetB), .MASTER_CLOCK(Master_clock), .MASTER_CLOCK2(Master_clock),

	.VME_D(vme_data_x), .VME_A(vme_addr_x), .VME_AM(vme_am), .VME_GA(vme_ga),
	.VME_WRITEb(vme_writeB), .VME_DS0b(vme_ds0B), .VME_DS1b(vme_ds1B), .VME_ASb(vme_asB),
	.VME_IACKb(vme_iackB), .VME_IACKINb(vme_iackB), .VME_IACKOUTb(vme_iackoutB),
	.VME_DTACKb(vme_dtackB_x), .VME_BERRb(vme_berrB_x), .VME_RETRYb(vme_retryB_x),
	.VME_IRQ(vme_irqB), .VME_ADIR(vme_adir), .VME_AOEb(vme_aoeB),
	.VME_DDIR(vme_ddir), .VME_DOEb(vme_doeB),
	.VME_DTACK_EN(vme_dtack_en), .VME_BERR_EN(vme_berr_en), .VME_RETRY_EN(vme_retry_en),
	.VME_LIIb(), .VME_LIOb(),

	.ADC_DATA(adc_data), .ADC_RESETb(adc_resetB),
	.ADC_CS1b(adc_cs1B), .ADC_CS2b(adc_cs2B), .ADC_SCLK(adc_sclk), .ADC_SDA(adc_sda),
	.ADC_LCLK1(adc_lclk1), .ADC_LCLK2(adc_lclk2), .ADC_FRAME_CK1(adc_ck1), .ADC_FRAME_CK2(adc_ck2),
	.ADC_CONV_CK1(adc_conv_ck),

	.APV_CLOCK(apv_clock), .APV_TRIGGER(apv_trigger), .APV_RESET(apv_reset),

	.I2C_SCL(i2c_scl), .I2C_SDA_IN(i2c_sda), .I2C_SDA_OUT(i2c_sda),

	.USER_IN_TTL({1'b0,trig_pulse}), .USER_IN_NIM({1'b0,~trig_pulse}), .USER_OUT(), .SEL_OUT(),

	.MII_25MHZ_CLOCK(), .MII_MDC(), .MII_MDIO(),
	.MII_TX_CLK(), .MII_TX_EN(), .MII_TXD(),
	.MII_RX_CLK(), .MII_RX_DV(), .MII_RX_ER(), .MII_RXD(),
	.MII_CRS(), .MII_COL(), .MII_RESETb(),

	.SDRAM_A(Sdram_addr), .SDRAM_BA(Sdram_ba), .SDRAM_CASb(Sdram_casB), .SDRAM_CKE(Sdram_cke),
	.SDRAM_CSb(Sdram_csB), .SDRAM_DM(Sdram_dm), .SDRAM_RASb(Sdram_rasB), .SDRAM_WEb(Sdram_weB),
	.SDRAM_CK(Sdram_ck), .SDRAM_CKb(Sdram_ckB), .SDRAM_DQ(Sdram_dq), .SDRAM_DQS(Sdram_dqs), .SDRAM_ODT(Sdram_odt),

	.SD_DAT2(), .SD_DAT1(), .SD_DAT0(), .SD_DETECT(), .SD_CD(), .SD_CMD(), .SD_CLK(),
	
	.READ1(), .READ_CLK1(),	.READ2(), .READ_CLK2(),

	.LED(), .SWITCH(4'b1111),

	.GXB_TX(), .GXB_RX(), .GXB_PRESENT(), .GXB_TX_DISABLE(), .GXB_RX_LOS(), .GXB_CK(gxb_clock),

	.TOKEN_OUT_P0(), .TOKEN_OUT_P2(), .TOKEN_IN_P0(1'b0), .TOKEN_IN_P2(1'b0),
	.TRIG_OUT(), .BUSY_OUT(), .SD_LINK_OUT(),
	.TRIG1_IN(1'b0), .TRIG2_IN(1'b0), .SYNC_IN(1'b0), .STATBIT_A_IN(1'b0), .STATBIT_B_IN(1'b0), .CLK_IN_P0(fast_clock),
	.STATBIT_A_OUT(),

	.SPARE1(), .SPARE2(), .SPARE3(),
	
	.SPARE33(),
	.SPARE25(),
	.SPARE_CLK_LVDS(), .SPARE_CLK_TTL()

);
/*
// This is MICRON model
ddr2 Sdram0(.ck(Sdram_ck), .ck_n(Sdram_ckB), .cke(Sdram_cke), .cs_n(Sdram_csB),
	.ras_n(Sdram_rasB), .cas_n(Sdram_casB), .we_n(Sdram_weB), .ba(Sdram_ba), .addr(Sdram_addr),
	.dm_rdqs(Sdram_dm), .dq(Sdram_dq), .dqs(Sdram_dqs), .odt(Sdram_odt), .dqs_n(Sdram_dqsN), .rdqs_n());
*/

// This model is generated by DDR Controller MegaWizard
Ddr2SdramIf_full_mem_model Sdram0(
                                    // inputs:
                                     .mem_addr(Sdram_addr),
                                     .mem_ba(Sdram_ba),
                                     .mem_cas_n(Sdram_casB),
                                     .mem_cke(Sdram_cke),
                                     .mem_clk(Sdram_ck),
                                     .mem_clk_n(Sdram_ckB),
                                     .mem_cs_n(Sdram_csB),
                                     .mem_dm(Sdram_dm),
                                     .mem_odt(Sdram_odt),
                                     .mem_ras_n(Sdram_rasB),
                                     .mem_we_n(Sdram_weB),

                                    // outputs:
                                     .global_reset_n(),
                                     .mem_dq(Sdram_dq),
                                     .mem_dqs(Sdram_dqs),
                                     .mem_dqs_n(Sdram_dqsN)
                                  );
	
ads5281_apv ADC1(.APV_TRIGGER(apv_trigger), .APV_MODE(apv_SampleMode), .CLK(adc_conv_ck),
	.LCLK(adc_lclk1), .ADCLK(adc_ck1), .OUT18(adc_data[7:0]));
ads5281_apv ADC2(.APV_TRIGGER(apv_trigger), .APV_MODE(apv_SampleMode), .CLK(adc_conv_ck),
	.LCLK(adc_lclk2), .ADCLK(adc_ck2), .OUT18(adc_data[15:8]));
defparam ADC1.data_file_prefix = "apv_data0_";
defparam ADC2.data_file_prefix = "apv_data1_";

// Time 0 values
initial
begin
	echo = 1;
	Master_clock = 0;
	Master_resetB = 1;
	d64_vme_cycle = 0;

	vme_writeB = 1; vme_ds0B = 1; vme_ds1B = 1; vme_asB = 1; vme_iackB = 1; vme_lwordB = 1;
	internal_vme_data <= 32'hFFFF_FFFF;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	geog_addr = 5'h05;
	adc_pattern = adc_ApvSync_pattern;
	usb_rxfB = 0;
	usb_txeB = 0;
	trig_pulse = 0;
	fast_clock = 0;
	gxb_clock = 0;
	sst_addr_cycle = 0;
	use_sdram = 1;
	dump_fout = 1;
	MaxTrigOut = 1;
	apv_SampleMode = 0;	// 0 = 3 samples, 1 = 1 sample
end

// Main test vectors
initial
begin
	Sleep(2);
	use_sdram = 1;
	dump_fout = 1;
	MaxTrigOut = 1;
	apv_SampleMode = 0;	// 0 = 3 samples, 1 = 1 sample
	if( dump_fout == 1 )
		fout = $fopen("Dump.txt", "w");
	issue_RESET;
	Sleep(100);

/*	
	VME_A24D32_Write(Cr_start+'h190, 1);	// Disable Fiber Interface
	Sleep(10);
	VME_A24D32_Write(Cr_start+'h194, DataReadout_base>>2);	// Output Buffer Base address
	Sleep(10);
	VME_A32D64_2eSstRead(DataReadout_base, 64, rd_data);
	Sleep(10);
	VME_A24D32_Read(Cr_start+'h224, rd_data);	// Output Buffer Status register
	Sleep(10);
	VME_A24D32_Read(Cr_start+'h224, rd_data);	// Output Buffer Status register
	Sleep(100);
//	$stop;
*/

	if( use_sdram == 1 )
	begin
		@(posedge Dut.SdramInitialized);	// Takes more than 360 us to happen with Quick Calibration and 30 us with Skip Calibration option...
		$display("# Sdram Initialized @%0t",$stime);
	end
	else
	begin
		$display("# Sdram not used in this simulation");
		Sleep(50);
	end
	
//	Sleep(5000);

	Sleep(20);
	VME_A24D32_Write(Cr_start+'h190, 1);	// Disable Fiber Interface
// Internal Read Only registers
	VME_A24D32_Read(Cr_start+'h0, rd_data);	// Should Return 0x43524f4d = 'CROM'
	VME_A24D32_Read(Cr_start+'h4, rd_data);	// Should Return 0x00080030 (CERN manufacturer ID)
	VME_A24D32_Read(Cr_start+'h8, rd_data);	// Should Return 0x00030904 (Board ID)
	VME_A24D32_Read(Cr_start+'hC, rd_data);	// Should Return 0x00040004 (Board Revision: HW rev = 4, FW rev = 4)
	VME_A24D32_Read(Cr_start+'h10, rd_data);	// Should Return 0xxxxxxxxx (Compile Time [time_t])
	Sleep(25);
	VME_A24D32_Write(Cr_start+'h194, DataReadout_base>>2);	// Output Buffer Base address
	VME_A24D32_Write(Cr_start+'h198, Sdram_base>>2);		// Sdram Base address
	VME_A24D32_Write(Cr_start+'h19C, 0);					// Sdram Bank 0
	Sleep(25);
/*
// Internal Read Write registers
	VME_A24D32_Write(Cr_start+'h120, 32'h0A50AFFA);	// RESET register
	VME_A24D32_Write(Cr_start+'h150, 32'h0A50AFFA);	// ZERO Threshold register
	VME_A24D32_Read(Cr_start+'h120, rd_data);
	VME_A24D32_Read(Cr_start+'h150, rd_data);


	Sleep(25);	
	VME_A24D32_Write(PedRam_base, 32'h1234_5678);	// Write Pedestal RAM of channel 0
	VME_A24D32_Write(PedRam_base+4, 32'h1234_5679);
	VME_A24D32_Write(PedRam_base+8, 32'h1234_567A);
	VME_A24D32_Write(PedRam_base+12, 32'h1234_567B);

	VME_A24D32_Read(PedRam_base, rd_data);			// Read back
	VME_A24D32_Read(PedRam_base+4, rd_data);
	VME_A24D32_Read(PedRam_base+8, rd_data);
	VME_A24D32_Read(PedRam_base+12, rd_data);

	Sleep(25);
	VME_A24D32_Write(ThrRam_base, 32'h1234_567C);	// Write Threshold RAM of channel 0
	VME_A24D32_Write(ThrRam_base+4, 32'h1234_567D);
	VME_A24D32_Write(ThrRam_base+8, 32'h1234_567E);
	VME_A24D32_Write(ThrRam_base+12, 32'h1234_567F);

	VME_A24D32_Read(ThrRam_base, rd_data);			// Read back
	VME_A24D32_Read(ThrRam_base+4, rd_data);
	VME_A24D32_Read(ThrRam_base+8, rd_data);
	VME_A24D32_Read(ThrRam_base+12, rd_data);
	Sleep(25);

	VME_A24D32_Read(ObufStatus_base, rd_data);		// Output Buffer Status Registers
	VME_A24D32_Read(ObufStatus_base+4, rd_data);
	VME_A24D32_Read(ObufStatus_base+8, rd_data);
	VME_A24D32_Read(ObufStatus_base+12, rd_data);
	VME_A24D32_Read(ObufStatus_base+16, rd_data);
	VME_A24D32_Read(ObufStatus_base+20, rd_data);
	VME_A24D32_Read(ObufStatus_base+24, rd_data);
	VME_A24D32_Read(ObufStatus_base+28, rd_data);
	VME_A24D32_Read(ObufStatus_base+32, rd_data);
*/
// External
/*
	Sleep(25);
	$display("***   Histogrammer 0 Test");
	Histogrammer0_Test;
	Sleep(25);
	$display("***   Histogrammer 1 Test");
	Histogrammer1_Test;

	Sleep(25);
	$display("***   ADC configurator Test");
	ADC_Config_Test;

	Sleep(25);
	$display("***   I2C Write Test");
	I2C_Byte_Write_Test;
	Sleep(200);
	$display("***   I2C Read Test");
	I2C_Byte_Read_Test;
	Sleep(200);

	Sleep(25);
	HiSpeed_Test;

	Sleep(25);
	$display("***   Software Reset");
	Software_Reset101_Test;
	Sleep(50);
	$display("***   Software Trigger");
	Software_Trigger_Test;
*/
/*	
	if( use_sdram == 1 )
	begin
// Simple SDRAM access
		Sleep(10);
		VME_A32D32_Write(Sdram_base,    32'h0055AAFF);
		VME_A32D32_Write(Sdram_base+4,  32'h55AAFF00);
		VME_A32D32_Write(Sdram_base+8,  32'hAAFF0055);
		VME_A32D32_Write(Sdram_base+12, 32'hFF0055AA);

		Sleep(10);
		VME_A32D32_Read(Sdram_base,     rd_data);
		VME_A32D32_Read(Sdram_base+4,   rd_data);
		VME_A32D32_Read(Sdram_base+8,   rd_data);
		VME_A32D32_Read(Sdram_base+12,  rd_data);
		
		Sleep(10);
		VME_A32D32_BlockRead(Sdram_base, 4, rd_data);
	end
*/	
	Sleep(10);

//	$display("***   DAQ test on channel 8");
//	SingleChannelDAQ_Test(8);

	$display("***   Event Building test on channel 0,1,2,3");
//	SingleChannel_EventBuilding_Test(1, use_sdram, 0);	// check use_sdram
	MultiChannel_EventBuilding_Test_Block(16'h000F, 20, 1);	// use_sdram = fast_readout = 1, 20 trigger, 1 us delay (+3us offset) between APV frames

//	SingleChannelSample_Test(8);
//	SingleChannelSample_Test(8);



//	Sync_Test;

	Sleep(50);
	if( dump_fout == 1 )
		$fclose(fout);

	$stop;
end


  // Clock generator: free running
  initial
  begin
    #(master_ck_period-master_ck_hold)	Master_clock <= ~Master_clock;
    forever
      #master_ck_half_period	Master_clock <= ~Master_clock;
  end

  always
	  #fast_ck_half_period fast_clock = ~fast_clock;

  always
	  #gxb_ck_half_period gxb_clock = ~gxb_clock;


// Utility tasks
task Sleep;
input [31:0] waittime;
begin
	repeat(waittime)
		#vme_period;
end
endtask // Sleep
 
task issue_RESET;
begin
	if( echo == 1 )
		$display("# Reset @%0t",$stime);
	#vme_period Master_resetB = 0;
	#vme_period;
	#vme_period;
	#vme_period;
	#vme_period Master_resetB = 1;
	#vme_period;
end
endtask // issue_RESET

task issue_TRIGGER;
begin
	#vme_period;
	if( echo == 1 )
		$display("# Trigger @%0t",$stime);
	trig_pulse = 1;
	repeat(10)
		#vme_period;
	trig_pulse = 0;
end
endtask // issue_TRIGGER

task VME_CrCsr_Read;
input [18:0] address;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h2F;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	vme_lwordB = 0;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	rd_data = vme_data;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_CrCsr_Read@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask
 
task VME_CrCsr_Write;
input [18:0] address;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_CrCsr_Write@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, wr_data);
	#vme_period;
	vme_am = 6'h2F;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	vme_writeB = 1;
	#vme_period;
end
endtask

task VME_A24D32_Read;
input [18:0] address;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h39;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	vme_lwordB = 0;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	rd_data = vme_data;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A24D32_Read@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask
 
task VME_A24D32_Write;
input [18:0] address;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A24D32_Write@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, wr_data);
	#vme_period;
	vme_am = 6'h39;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	vme_writeB = 1;
	#vme_period;
end
endtask

task VME_A24D32_BlockRead;
input [31:0] address;
input [31:0] n_read;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h3B;	// Non privileged data space A24 block accesses
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 1;
	repeat( n_read )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		rd_data = vme_data;
		if( dump_fout == 1 )
			$fwrite(fout, "%0x\n", rd_data);
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A24D32_BlockRead@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask

task VME_A24D32_BlockWrite;
input [31:0] addr;
input [31:0] n_write;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A24D32_BlockWrite@%0t: addr=0x%0x, data=0x%0x, N = %0d",$stime, addr, wr_data, n_write);
	#vme_period;
	vme_am = 6'h3B;	// Non privileged data space A24 block accesses
	internal_vme_addr = {8'h0, geog_addr, addr[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	repeat( n_write )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	vme_lwordB = 1;
	#vme_period;
end
endtask

task VME_A32D32_Read;
input [31:0] address;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h09;	// Non privileged data space A32 accesses
	internal_vme_addr = address[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 1;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	rd_data = vme_data;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A32D32_Read@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask

task VME_A32D32_Write;
input [31:0] address;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A32D32_Write@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, wr_data);
	#vme_period;
	vme_am = 6'h09;	// Non privileged data space A32 accesses
	internal_vme_addr = address[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	vme_writeB = 1;
	#vme_period;
end
endtask

task VME_A32D32_BlockRead;
input [31:0] address;
input [31:0] n_read;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h0B;	// Non privileged data space A32 block accesses
	internal_vme_addr = address[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 1;
	repeat( n_read )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		rd_data = vme_data;
		if( dump_fout == 1 )
			$fwrite(fout, "%0x\n", rd_data);
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A32D32_BlockRead@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask

task VME_A32D32_BlockWrite;
input [31:0] addr;
input [31:0] n_write;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A32D32_BlockWrite@%0t: addr=0x%0x, data=0x%0x, N = %0d",$stime, addr, wr_data, n_write);
	#vme_period;
	vme_am = 6'h0B;	// Non privileged data space A32 block accesses
	internal_vme_addr = addr[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	repeat( n_write )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	vme_lwordB = 1;
	#vme_period;
end
endtask

task VME_A32D64_MbltRead;
input [31:0] address;
input [31:0] n_read;
output [63:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h08;	// Non privileged data space A32-D64 MBLT
	internal_vme_addr = address[31:1];
	vme_lwordB = address[0];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	vme_ds0B = 0;	// Address Phase
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	while( vme_dtackB == 0 )
		#vme_period;
	d64_vme_cycle = 1;
	repeat( n_read )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		rd_data = {vme_addr, vme_data};
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A32D64_MbltRead@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
	d64_vme_cycle = 0;

end
endtask

task VME_A32D64_2eVmeRead;	// Master terminated: no slave termination allowed
input [31:0] address;		// User must be sure that n_words is even
input [7:0] n_words;
output [63:0] rd_data;
integer j;
reg even_cycle;
begin
	#vme_period;
	vme_am = 6'h20;	// 6U A32 2eVME
	internal_vme_addr[7:1] = 0;
	vme_lwordB = 1;	// XAM = 0x01
	internal_vme_addr[31:8] = address[31:8];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 1
	while( vme_dtackB == 1 )
		#vme_period;
	internal_vme_addr[7:1] = {address[7:4], 3'b0};
	vme_lwordB = 0;
	internal_vme_addr[15:8] = n_words >> 1;
	internal_vme_addr[31:16] = 0;
	#vme_period;
	vme_ds0B = 1;	// Address Phase 2
	while( vme_dtackB == 0 )
		#vme_period;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 3
	internal_vme_addr[31:1] = 0;
	vme_lwordB = 0;
	while( vme_dtackB == 1 )
		#vme_period;

	d64_vme_cycle = 1;
	even_cycle = 0;	// Start with odd cycle
	for(j=0; j<n_words; j=j+1)
	begin
		#vme_period;
		vme_ds1B = even_cycle;
		#vme_period;
		while( vme_dtackB == even_cycle )
			#vme_period;
		rd_data = {vme_addr, vme_data};
		if( dump_fout == 1 )
		begin
			$fwrite(fout, "%0x\n", rd_data[63:32]);
			$fwrite(fout, "%0x\n", rd_data[31:0]);
		end
		#vme_period;
		if( echo == 1 )
			$display("# VME_A32D64_2eVmeRead@%0t: addr=0x%0x, data=0x%0x",
				$stime, address+j, rd_data);
		even_cycle = ~even_cycle;
	end

	#vme_period;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	vme_lwordB = 1;
	vme_ds0B = 1;
	vme_ds1B = 1;
	d64_vme_cycle = 0;
	#vme_period;
end
endtask

task VME_A32D64_2eSstRead;	// Master/slave terminated
input [31:0] address;		// User must be sure that n_words is even
input [7:0] n_words;
output [63:0] rd_data;
integer j, dtack_val;
begin
	$display("@%0t Start 2eSST for %d words", $stime, n_words);
	#vme_period;
	sst_addr_cycle = 1;
	vme_am = 6'h20;	// 6U A32 2eVME
	internal_vme_addr[7:1] = 7'h08;
	vme_lwordB = 1;	// XAM = 0x11
	internal_vme_addr[31:8] = address[31:8];
//	internal_vme_data = 32'h0000_0000;	// SST160
//	internal_vme_data = 32'h0000_0001;	// SST267
	internal_vme_data = 32'h0000_0002;	// SST320
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 1
	while( vme_dtackB == 1 )
		#vme_period;
	internal_vme_addr[7:1] = address[7:1];
	vme_lwordB = 0;
	internal_vme_addr[15:8] = n_words >> 1;
	internal_vme_addr[31:16] = 0;
	#vme_period;
	vme_ds0B = 1;	// Address Phase 2
	while( vme_dtackB == 0 )
		#vme_period;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 3
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	sst_addr_cycle = 0;
	vme_ds1B = 0;
	d64_vme_cycle = 1;	// Disable driving ADDR_VME, LWORD

	dtack_val = 0;
/*
	for(j=0; j<n_words; j=j+1)
	begin
		#vme_period;
		#vme_period;
		rd_data = {vme_addr, vme_data};
		if( dump_fout == 1 )
		begin
			$fwrite(fout, "%0x\n", rd_data[63:32]);
			$fwrite(fout, "%0x\n", rd_data[31:0]);
		end
		#vme_period;
		if( echo == 1 )
			$display("# VME_A32D64_2eSstRead@%0t: addr=0x%0x, data=0x%0x",
				$stime, address+j, rd_data);
	end
*/
	for(j=0; j<n_words; j=j+1)
	begin
		if( vme_retryB == 0 )
		begin
			$display("#### VME_A32D64_2eSstRead@%0t: got RETRY = 0", $stime);
			while( vme_berrB == 1 )
				#vme_period;
			$display("#### VME_A32D64_2eSstRead@%0t: got BERR = 0", $stime);
			if( j != n_words && echo == 1 )
				$display("# VME_A32D64_2eSstRead@%0t: Slave terminated before reaching nwords (%d != %d",
					$stime, j, n_words);
			j = n_words+1;
		end
		else
		begin
			while( vme_dtackB == dtack_val && vme_retryB == 1 )
				#vme_period;
			$display("#### VME_A32D64_2eSstRead@%0t: got word %d", $stime, j);
			rd_data = {vme_addr, vme_data};
			if( dtack_val == 0 )
				dtack_val = 1;
			else
				dtack_val = 0;
			if( dump_fout == 1 && vme_retryB == 1 )	// why check on vme_retryB?
			begin
				$fwrite(fout, "%0x\n", rd_data[63:32]);
				$fwrite(fout, "%0x\n", rd_data[31:0]);
			end
			if( echo == 1 )
				$display("# VME_A32D64_2eSstRead@%0t: addr=0x%0x, data=0x%0x",
					$stime, address+j, rd_data);
		end
	end

	#vme_period;
	#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	vme_lwordB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	d64_vme_cycle = 0;
	#vme_period;
	#vme_period;
	#vme_period;
	#vme_period;
	#vme_period;
	#vme_period;
end
endtask



function parity;
input [4:0] x;
begin
	parity = 0;
end
endfunction

// ADC Configuration Test
task ADC_Config_Test;
begin
	VME_A24D32_Write(AdcSpi_base, 32'h40_8A00F1);	// Start ADC1 configuration
	rd_data[30] = 1;
	while( rd_data[30] == 1 )	// Wait for ADC1 configuration
		VME_A24D32_Read(AdcSpi_base, rd_data);
	Sleep(5);
	VME_A24D32_Write(AdcSpi_base, 32'h80_8F00A1);	// Start ADC2 configuration
	rd_data[31] = 1;
	while( rd_data[31] == 1 )	// Wait for ADC2 configuration
		VME_A24D32_Read(AdcSpi_base, rd_data);
end
endtask


// Histogrammer test for bank 0
task Histogrammer0_Test;
begin
//	repeat(4096)
		VME_A24D32_Write(Histo0_base, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo0_base+4, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo0_base+8, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo0_base+12, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo0_base+2048, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo0_base+10920, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo0_base+11264, 32'h0000_0000);	// Clear Histo SRAM

	VME_A24D32_Write(32'h0000_1000, 32'h0000_0080);	// Start Histogramming on channel 0
	Sleep(100);
	VME_A24D32_Write(32'h0000_1000, 32'h0000_0000);	// Stop Histogramming
//	repeat(4096)
		VME_A24D32_Read(Histo0_base, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo0_base+4, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo0_base+8, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo0_base+12, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo0_base+2048, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo0_base+10920, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo0_base+11264, rd_data);	// Read Histogram
	VME_A24D32_Read(32'h0000_1004, rd_data);	// Read Histo Counter

	VME_A24D32_BlockRead(Histo0_base, 8, rd_data);	// Read Histogram

end
endtask

// Histogrammer test for bank 1
task Histogrammer1_Test;
begin
//	repeat(4096)
		VME_A24D32_Write(Histo1_base, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo1_base+4, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo1_base+8, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo1_base+12, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo1_base+2048, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo1_base+10920, 32'h0000_0000);	// Clear Histo SRAM
		VME_A24D32_Write(Histo1_base+11264, 32'h0000_0000);	// Clear Histo SRAM

	VME_A24D32_Write(32'h0000_1008, 32'h0000_0080);	// Start Histogramming on channel 0
	Sleep(150);
	VME_A24D32_Write(32'h0000_1008, 32'h0000_0000);	// Stop Histogramming
//	repeat(4096)
		VME_A24D32_Read(Histo1_base, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo1_base+4, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo1_base+8, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo1_base+12, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo1_base+2048, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo1_base+10920, rd_data);	// Read Histogram
		VME_A24D32_Read(Histo1_base+11264, rd_data);	// Read Histogram
	VME_A24D32_Read(32'h0000_100C, rd_data);	// Read Histo Counter

	VME_A24D32_BlockRead(Histo1_base, 8, rd_data);	// Read Histogram

end
endtask

// I2C byte write test
task I2C_Byte_Write_Test;
begin
	$display("###   Init I2C_Byte_Write_Test");
	VME_A24D32_Write(I2C_base+8, 32'h0000_0000);	// Disable Core and interrupts
	VME_A24D32_Write(I2C_base+0, 32'h0000_0018);	// Clock Prescaler LSB
	VME_A24D32_Write(I2C_base+4, 32'h0000_0000);	// Clock Prescaler MSB
	VME_A24D32_Write(I2C_base+8, 32'h0000_0080);	// Enable Core and disable interrupts

	VME_A24D32_Write(I2C_base+12, 32'h0000_00AA);	// Write 0xAA (7 bit address + write bit = 0)
	VME_A24D32_Write(I2C_base+16, 32'h0000_0090);	// Generate START + Write command
//	VME_A24D32_Write(I2C_base+16, 32'h0000_0010);	// Write byte command
	rd_data[1] = 1;
	while( rd_data[1] == 1 )			// Poll for completion
		VME_A24D32_Read(I2C_base+16, rd_data);

	VME_A24D32_Write(I2C_base+12, 32'h0000_0055);	// Write 0x55 (8 bit datum)
	VME_A24D32_Write(I2C_base+16, 32'h0000_0010);	// Write byte command
	rd_data[1] = 1;
	while( rd_data[1] == 1 )			// Poll for completion
		VME_A24D32_Read(I2C_base+16, rd_data);

	VME_A24D32_Write(I2C_base+16, 32'h0000_0040);	// Generate STOP
end
endtask

// I2C byte read test
task I2C_Byte_Read_Test;
begin
	$display("###   Init I2C_Byte_Read_Test");
	VME_A24D32_Write(I2C_base+8, 32'h0000_0000);	// Disable Core and interrupts
	VME_A24D32_Write(I2C_base+0, 32'h0000_0018);	// Clock Prescaler LSB
	VME_A24D32_Write(I2C_base+4, 32'h0000_0000);	// Clock Prescaler MSB
	VME_A24D32_Write(I2C_base+8, 32'h0000_0080);	// Enable Core and disable interrupts

	VME_A24D32_Write(I2C_base+12, 32'h0000_00AB);	// Write 0xAA (7 bit address + write bit = 1)
	VME_A24D32_Write(I2C_base+16, 32'h0000_0090);	// Generate START + Write command
//	VME_A24D32_Write(I2C_base+16, 32'h0000_0010);	// Write byte command
	rd_data[1] = 1;
	while( rd_data[1] == 1 )			// Poll for completion
		VME_A24D32_Read(I2C_base+16, rd_data);

//	VME_A24D32_Write(I2C_base+16, 32'h0000_0020);	// Read byte command + NACK
	VME_A24D32_Write(I2C_base+16, 32'h0000_0028);	// Read byte command
	rd_data[1] = 1;
	while( rd_data[1] == 1 )			// Poll for completion
		VME_A24D32_Read(I2C_base+16, rd_data);

	VME_A24D32_Write(I2C_base+16, 32'h0000_0040);	// Generate STOP
	VME_A24D32_Read(I2C_base+12, rd_data);		// Get data
end
endtask

task ClearPedestalRam;
input [3:0] ch;
begin
	$display("@%0t:  Clear PEDESTAL RAM of ch %d", $stime, ch);	
	VME_A24D32_BlockWrite(PedRam_base+(ch<<9), 128, 32'h0000_0000);
end
endtask

task ClearThresholdRam;
input [3:0] ch;
begin
	$display("@%0t:  Clear THRESHOLD RAM of ch %d", $stime, ch);	
	VME_A24D32_BlockWrite(ThrRam_base+(ch<<9), 128, 32'h0000_0000);
end
endtask

task SetDaqMode;
input [2:0] mode;
input en_baseline_sub, en_building, UseSdramFifo, _64bit;
begin
//						DisableMode              = (mode == 3'b000);
//						ApvReadoutMode_Simple    = (mode == 3'b001);
//						SampleMode               = (mode == 3'b010);
//						ApvReadoutMode_Processed = (mode == 3'b011);
	$display("@%0t:  DaqMode set to: ", $stime, mode);	
	VME_A24D32_Write('h00118, {1'b1, en_building, 1'b0, en_baseline_sub, 12'b0,
			UseSdramFifo, _64bit, 11'b0, mode});
									// Daq mode[2:0] = mode
									// Output64Bit[14] = _64bit
									// SdramTestMode[15] = UseSdramFifo
									// Common Offset[27:16] = 12'b0
									// en_baseline_subtract[28] = en_baseline_sub
									// en_event_building[30] = en_building
									// All FIFO Clear[31] = 1
	VME_A24D32_Write('h00118, {1'b0, en_building, 1'b0, en_baseline_sub, 12'b0,
			UseSdramFifo, _64bit, 11'b0, mode});
									// All FIFO Clear[31] = 0
end
endtask

task SetTrigMode;
input [2:0] mode;
begin
//						trig_disable      = (mode == 3'b000);
//						trig_apv_normal   = (mode == 3'b001);
//						trig_apv_multiple = (mode == 3'b010);
//						calib_trig_apv    = (mode == 3'b011);
	$display("@%0t:  TrigMode set to: ", $stime, mode);	
	VME_A24D32_Write('h0011C, {17'h1_0100, mode, MaxTrigOut, 8'd32});	// ResetLatency = 32 (7..0)
									// MaxTrigOut = 3 (11..8)
									// Trig Mode = mode (14..12)
									// Test Mode = 1 (15)
									// ApvClockPhase = 0 (17..16)
									// Sw_Trig = 0 (18)
									// Sw_Reset101 = 0 (19)
									// EnTrig1_P0 = 0 (21)
									// EnTrig2_P0 = 0 (22)
									// EnTrig_Front = 1 (23)
									// CalibLatency = 16 (31..24) ADD 4 TO THIS NUMBER!
end
endtask


// Data Acquisition from single channel FIFO test
// No pedestal subtraction, no offset, no baseline removal, no threshold cut --> Transparent run
task SingleChannelDAQ_Test;
input [3:0] ch;
begin
	ClearPedestalRam(ch);
	ClearThresholdRam(ch);
// ZERO & ONE Thresholds
	VME_A24D32_Write('h00134, 32'h0000_0A80);	// ONE = 0xA80
	VME_A24D32_Write('h00130, 32'h0000_0201);	// ZERO = 0x201
// SYNC & ENABLE
	VME_A24D32_Write('h00124, 32'h0000_0022);	// SyncPeriod = 34
	VME_A24D32_Write('h0012C, (1'b1<<ch));		// EnableMask = 1<<i
	VME_A24D32_Write('h00128, 32'h0000_00FF);	// Marker_channel
											
//	SetDaqMode(1, 0, 0, 0, 0);	// APV_mode_Simple, no pedestal subtraction, no event building, no sdram fifo
	SetDaqMode(3, 0, 0, 0, 0);	// APV_mode_Processed, no pedestal subtraction, no event building, no sdram fifo
	SetTrigMode(3);		// Calib_Trig_Apv

	adc_pattern = adc_ApvSync_pattern;	// One sync period is 35 x 25 ns = 875 ns
	Sleep(100);				// Sleep(1) lasts 17 ns
	issue_TRIGGER;
	adc_pattern = adc_ApvFrame_pattern;	// One frame is 140 x 25 ns = 3.5 us
	Sleep(7*250);				// Fill up the FIFO
	adc_pattern = adc_ApvSync_pattern;

	VME_A24D32_Read(ApvFifo_base+(ch<<13), rd_data);

	issue_TRIGGER;
	Sleep(250);

	repeat(3)
	begin
		VME_A24D32_BlockRead(ApvFifo_base+(ch<<13), 131, rd_data);	// APV_mode_Processed
		Sleep(100);
	end

	Sleep(3*250);

	VME_A24D32_Read(ApvFifo_base+(ch<<13), rd_data);
end
endtask

task MultiChannel_EventBuilding_Test;
input [15:0] ch_mask;
input UseSdramFifo;
input FastReadout;	// Uses 64 bit 2eSST
input [31:0] num_trig;
input [31:0] trig_delay_us;
integer j, xx;
begin
	ch_count = 0;
	for(i = 0; i<16; i=i+1)
	begin
		if( ch_mask[i] == 1 )
		begin
//			ClearPedestalRam(i);
//			ClearThresholdRam(i);
			ch_count = ch_count + 1;
		end
	end
// ZERO & ONE Thresholds
	VME_A24D32_Write('h00134, 32'h0000_0A80);	// ONE = 0xA80
	VME_A24D32_Write('h00130, 32'h0000_0201);	// ZERO = 0x201
// SYNC & ENABLE
	VME_A24D32_Write('h00124, 32'h0000_0022);	// SyncPeriod = 34
	VME_A24D32_Write('h0012C, ch_mask);			// EnableMask
	VME_A24D32_Write('h00128, 32'h0000_00FF);	// Marker_channel
	VME_A24D32_Write('h00108, SamplePerEvent);	// SamplePerEvent: must be the same of MaxTrigOut if APV takes out 1 frame per trigger
	VME_A24D32_Write('h0010C, 32'h0000_0001);	// Event_Per_Block

//	SetDaqMode(1, 0, 0, 0, 0);	// APV_mode_Simple, no pedestal subtraction, no event building, no sdram fifo
	SetDaqMode(3, 1, 1, UseSdramFifo, FastReadout);	// APV_mode_Processed, pedestal subtraction, event building, ...
	SetTrigMode((MaxTrigOut>1) ? 2 : 1);		// trig_apv_multiple or trig_apv_normal

	adc_pattern = adc_ApvSync_pattern;	// One sync period is 35 x 25 ns = 875 ns
	Sleep(100);				// Sleep(1) lasts 10 ns

	for(j=0; j<num_trig; j=j+1)
	begin
		SendTrigger(1, 0);
		$display("@%0t Start reading trg n: %d", $stime, j);
		
		echo = 0;
		if( FastReadout )
		begin
			for(i=0; i<(30 * ch_count); i=i+1)
			begin
//				VME_A24D32_Read('h228, rd_data);	// Read LatchedFull
				rd_data = 0;
				xx = 0;
				while( rd_data[7:0] < 32 && xx < 20 )
				begin
					VME_A24D32_Read('h224, rd_data);	// Read Word Count
					xx = xx + 1;
				end
				if( rd_data[7:0] > 0 )
					VME_A32D64_2eSstRead(DataReadout_base, rd_data[7:0], rd_data);
	//			VME_A32D64_2eVmeRead(DataReadout_base, 64, rd_data);
			end
		end
		else
		begin
			for(i=0; i<(2000 * ch_count); i=i+1)	// (131 * SamplePerEvent * ch_count) + 6 + n_filler
			begin
				if( UseSdramFifo == 0 )
				begin
					rd_data[0] = 1;
					while( rd_data[0] == 1 )	// while( FIFO data is empty )
						VME_A24D32_Read(ApvFifo_base+'h20040, rd_data);
					VME_A24D32_Read(ApvFifo_base, rd_data);
				end
				else
				begin
					rd_data[30] = 1;
					while( rd_data[30] == 1 )	// while( Output FIFO is empty )
						VME_A24D32_Read('h224, rd_data);
					VME_A32D32_Read(DataReadout_base, rd_data);
				end

				if( dump_fout == 1 )
					$fwrite(fout, "%0x\n", rd_data);

				if( rd_data[23:21] == 3'h0 )	// Block Header
					$display("@%0d     Block Header: Module ID = %d EventPerBlock = %d Block_cnt = %d", i,rd_data[20:16], rd_data[15:8],rd_data[7:0]);
				if( rd_data[23:20] == 4'h2 )	// End of Block
					$display("@%0d     Block Trailer: BlockWordCounter = %d", i, rd_data[19:0]);
				if( rd_data[23:20] == 4'h6 )	// Start of Event
					$display("@%0d     Event Header: EventCounter %d", i, rd_data[19:0]);
				if( rd_data[23:20] == 4'hA )	// End of Event
					$display("@%0d     Event Trailer: loop count = %x, Time_fifo = %x", i, rd_data[19:8], rd_data[7:0]);
				if( rd_data[23:20] == 4'h6 )	// Trig Time 0
					$display("@%0d     Trigger Time 0 = 0x%x", i, rd_data[19:0]);
				if( rd_data[23:20] == 4'h7 )	// Trig Time 1
					$display("@%0d     Trigger Time 1 = 0x%x", i, rd_data[19:0]);
				if( rd_data[23:21] == 3'h4 )	// Apv Data
				begin
					if( rd_data[20:19] == 0 )	// Apv Header
					begin
						$display("@%0d    ApvProcessor Header: MeanMSB = %d, ApvHdr = 0x%x, AdcCh = %d", i,
							rd_data[17], rd_data[16:4], rd_data[3:0]);
						mean = rd_data[17] << 11;
					end
		//			if( rd_data[20:19] == 1 )	// Apv Data
					if( rd_data[20:19] == 1 &&  (rd_data[18:12] == 0 || rd_data[18:12] == 127) )	// Apv Data
						$display("@%0d    ApvDataRaw: APV Ch = %d, Data = 0x%x", i,
							rd_data[18:12], rd_data[11:0]);
					if( rd_data[20:19] == 2 )	// Apv Decoder Trailer
						$display("@%0d    ApvDecoder Trailer: ModuleID = %d, Sample Count = %d, Frame Count = %d", i,
							rd_data[16:12], rd_data[11:8], rd_data[7:0]);
					if( rd_data[20:19] == 3 )	// Baseline Subtractor Trailer
					begin
						mean = mean + rd_data[19:8];
						$display("@%0d    ApvProcessor Trailer: MeanLSB = 0x%x, Word Count = %d, Mean = 0x%x", i,
							rd_data[19:8], rd_data[7:0], mean);
					end
				end
				if( rd_data[23:21] == 3'h6 )	// Data Non Valid
					$display("@%0d     Non Valid Data", i);
				if( rd_data[23:21] == 3'h7 )	// Filler
					$display("@%0d     Filler Word", i);
			end
		end
		Sleep(trig_delay_us*100);	// wait delay us
	end
	echo = 1;
end
endtask

task MultiChannel_EventBuilding_Test_Block;
input [15:0] ch_mask;
input [31:0] num_trig;
input [31:0] trig_delay_us;
integer j, xx, nw;
begin
	ch_count = 0;
	for(i = 0; i<16; i=i+1)
	begin
		if( ch_mask[i] == 1 )
		begin
//			ClearPedestalRam(i);
//			ClearThresholdRam(i);
			ch_count = ch_count + 1;
		end
	end
// ZERO & ONE Thresholds
	VME_A24D32_Write('h00134, 32'h0000_0A80);	// ONE = 0xA80
	VME_A24D32_Write('h00130, 32'h0000_0201);	// ZERO = 0x201
// SYNC & ENABLE
	VME_A24D32_Write('h00124, 32'h0000_0022);	// SyncPeriod = 34
	VME_A24D32_Write('h0012C, ch_mask);			// EnableMask
	VME_A24D32_Write('h00128, 32'h0000_00FF);	// Marker_channel
	VME_A24D32_Write('h00108, SamplePerEvent);	// SamplePerEvent: must be the same of MaxTrigOut if APV takes out 1 frame per trigger
	VME_A24D32_Write('h0010C, 32'h0000_0001);	// Event_Per_Block

//	SetDaqMode(1, 0, 0, 0, 0);	// APV_mode_Simple, no pedestal subtraction, no event building, no sdram fifo
//	SetDaqMode(3, 1, 1, 1, 1);	// APV_mode_Processed, pedestal subtraction, event building, use_sdram_fifo, fast_readout
	SetDaqMode(3, 0, 1, 1, 1);	// APV_mode_Processed, no pedestal subtraction, event building, use_sdram_fifo, fast_readout
	SetTrigMode((MaxTrigOut>1) ? 2 : 1);		// trig_apv_multiple or trig_apv_normal

	adc_pattern = adc_ApvSync_pattern;	// One sync period is 35 x 25 ns = 875 ns
	Sleep(100);				// Sleep(1) lasts 10 ns
	echo = 0;

	for(j=0; j<num_trig; j=j+1)
	begin
		SendTrigger(1, 0);
		$display("@%0t Waiting to read trg n: %d", $stime, j);

		rd_data = 0;
		while( rd_data[23:16] < 1 )
		begin
			VME_A24D32_Read('h208, rd_data);	// Read Output Buffer Block Count
			Sleep(100);	
		end

		Sleep(10);	
		VME_A24D32_Read('h224, rd_data);	// Read Word Count (64 bit)
		nw = rd_data[12:0];
		xx =  nw / 64;
		$display("@%0t Start reading trg n: %d, nwords: %d, ntimes: %d", $stime, j, nw, xx);
		for(i=0; i<xx; i=i+1)
		begin
			VME_A32D64_2eSstRead(DataReadout_base, 64, rd_data);
			Sleep(10);	
		end
		xx = nw % 64;
		$display("@%0t Remaining words: %d", $stime, xx);
		if( xx > 0 )
			VME_A32D64_2eSstRead(DataReadout_base, xx, rd_data);

		Sleep(10);	
		VME_A24D32_Read('h224, rd_data);	// Read Word Count (64 bit)
		Sleep(trig_delay_us*100);	// wait delay us
	end
	echo = 1;
end
endtask

task SendTrigger;
input [31:0] ntrg;
input [31:0] us_delay;
begin
	repeat(ntrg)
	begin
		adc_pattern = adc_ApvFrame_pattern;	// One frame is 140 x 25 ns = 3.5 us
		issue_TRIGGER;
		Sleep(SamplePerEvent*320);	// Time for SamplePerEvent complete frames
		adc_pattern = adc_ApvSync_pattern;
		Sleep(400);
//		Sleep(us_delay*100);	// wait delay us
	end
end
endtask


// Sample Acquisition on single channel
task SingleChannelSample_Test;
input [3:0] ch;
begin
// DAQ Config --> ENABLE
	VME_A32D32_Write(ApvFifo_base+32'h0008_0030, 32'h8000_8002);	// All FIFO Clear = 1
									// Daq mode = 2
									// Test mode = 1
	VME_A32D32_Write(ApvFifo_base+32'h0008_0030, 32'h0000_8002);	// All FIFO Clear = 0
// TRIG Config
	VME_A32D32_Write(ApvFifo_base+32'h0008_003C, 32'h0022_0000 + (1'b1<<ch));	// SyncPeriod = 34
									// EnableMask = 1<<i
	VME_A32D32_Write(ApvFifo_base+32'h0008_0034, 32'h0000_8F20);	// ResetLatency = 32 (7..0)
									// MaxTrigOut = 15 (11..8)
									// Trig Mode = 0 (14..12)
									// Test Mode = 1 (15)
									// ApvClockPhase = 0 (17..16)
									// Sw_Trig = 0 (18)
									// Sw_Reset101 = 0 (19)

	VME_A32D32_Write(ApvFifo_base+32'h0008_0038, 32'h0A80_0200);	// ONE = 0xA80, ZERO = 0x200

	rd_data[16+ch] = 0;
	while( rd_data[16+ch] == 0 )			// Poll for FIFO Full
	begin
		Sleep(50);
		VME_A32D32_Read(ApvFifo_base+32'h0008_0020, rd_data);
	end
// Get FIFO nwords
	VME_A32D32_Read(ApvFifo_base+'h80000+((ch/2)<<2), rd_data);

// DAQ Config --> DISABLE
	VME_A32D32_Write(ApvFifo_base+32'h0008_0030, 32'h0000_0000);
	VME_A32D32_Write(ApvFifo_base+32'h0008_003C, 32'h0000_0000);

// Get Data
	repeat(32)
		VME_A32D32_BlockRead(ApvFifo_base+(ch<<14), 64, rd_data);
end
endtask

task Software_Reset101_Test;
begin
	VME_A24D32_Write('h0013C, 32'h0000_1000);	// Set TrigMode == 1 issue a Reset101
//	VME_A24D32_Write('h00138, 32'h0000_0000);
end
endtask

task Software_Trigger_Test;
begin
	VME_A24D32_Write('h0013C, 32'h0004_1000);
	VME_A24D32_Write('h0013C, 32'h0000_0000);
end
endtask

task Sync_Test;
begin
	VME_A32D32_Write(ApvFifo_base+32'h0008_0038, 32'h0A80_0210);	// ONE = 0xA80, ZERO = 0x210
	VME_A32D32_Write(ApvFifo_base+32'h0008_003C, 32'h0022_FFFF);	// Sync period = 34 ck cycles, all channels enabled
	VME_A32D32_Write(ApvFifo_base+32'h0008_0030, 32'h0);			// Readout config = 0
	VME_A32D32_Write(ApvFifo_base+32'h0008_0034, 32'd32);			// Trig config = 32
	
	adc_pattern = adc_ApvSync_pattern;	// One sync period is 35 x 25 ns = 875 ns
	Sleep(850);				// Sleep(1) lasts 17 ns
	VME_A32D32_Read(ApvFifo_base+32'h0008_0024, rd_data);			// Get synced status

	adc_pattern = adc_ApvFrame_pattern;		// Desynchronize...
	Sleep(250);	
	VME_A32D32_Read(ApvFifo_base+32'h0008_0024, rd_data);			// Get synced status

	adc_pattern = adc_ApvSync_pattern;		// Re-synchronize
	Sleep(1000);
	VME_A32D32_Read(ApvFifo_base+32'h0008_0024, rd_data);			// Get synced status

	
end
endtask

/*
task HiSpeed_Test;
begin
//	VME_A24D32_Write('h00154, (Test_base>>2));	// Set Base Address for test module
// Use various block read routines to test the speed
//	VME_A32D32_BlockRead(Test_base, 128, rd_data);
//	VME_A32D64_MbltRead(Test_base, 128, rd_data);
//	VME_A32D64_2eVmeRead(Test_base, 32, rd_data);
	VME_A32D64_2eSstRead(Test_base, 32, rd_data);
end
endtask
*/

endmodule

