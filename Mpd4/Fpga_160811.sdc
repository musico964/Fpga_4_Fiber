set_time_format -unit ns -decimal_places 3

# 100 MHz on MPD 3.0
#set master_ck_period 10
#  40 MHz on MPD 4.0
set master_ck_period 24.3
#set master_ck_period 25.0

set tSU_static 100
set tH_static 100
set tCO_static 100
set tSU_vme 6.5
set tH_vme 1.0
set tCO_vme 8.5

set tSU_DDR_adc 0.67
set tH_DDR_adc 0.85
set bit_period_DDR_adc 4.1
set frame_period_DDR_adc 25.0

# Virtual clocks
create_clock -name {Ck_110MHz_virt} -period 9.09
create_clock -name {Ck_100MHz_virt} -period 10.0
create_clock -name {ADC_LCLK1_virt} -period $bit_period_DDR_adc
create_clock -name {ADC_LCLK2_virt} -period $bit_period_DDR_adc
create_clock -name {ADC_FRAME_CK1_virt} -period $frame_period_DDR_adc
create_clock -name {ADC_FRAME_CK2_virt} -period $frame_period_DDR_adc
create_clock -name {Ck_40MHz_virt} -period 25.0
create_clock -name {Ck_10MHz_virt} -period 100.0
#create_clock -name {MASTER_CLOCK_virt} -period $master_ck_period
#create_clock -name {MASTER_CLOCK2_virt} -period $master_ck_period
#create_clock -name {GXB_CK_virt} -period 16.0
#create_clock -name {CLK_IN_P0_virt} -period 16.0
#create_clock -name {Ck_50MHz_virt} -period 20.0
#create_clock -name {Ck_20MHz_virt} -period 50.0

# Real clocks
create_clock -name ADC_LCLK1 -period $bit_period_DDR_adc [get_ports ADC_LCLK1]
create_clock -name ADC_LCLK2 -period $bit_period_DDR_adc [get_ports ADC_LCLK2]
create_clock -name ADC_FRAME_CK1 -period $frame_period_DDR_adc [get_ports ADC_FRAME_CK1]
create_clock -name ADC_FRAME_CK2 -period $frame_period_DDR_adc [get_ports ADC_FRAME_CK2]
#create_clock -name MASTER_CLOCK -period $master_ck_period [get_ports MASTER_CLOCK]
create_clock -name MASTER_CLOCK2 -period $master_ck_period [get_ports MASTER_CLOCK2]
create_clock -name GXB_CK -period 16.0 [get_ports GXB_CK]
#create_clock -name CLK_IN_P0 -period 16.0 [get_ports CLK_IN_P0]

create_generated_clock -source [get_ports {MASTER_CLOCK2}] -divide_by 1 -multiply_by 1 -duty_cycle 50 -phase 0 -offset 0 \
	[get_nets {Ck40Mux_Inst|CK40_MUX_altclkctrl_hfe_component|wire_clkctrl1_outclk}]

#create_generated_clock -source [get_ports {MASTER_CLOCK2}] -divide_by 1 -multiply_by 1 -duty_cycle 28 -phase 0 -offset 0 \	
#	[get_nets {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_REb}]
	
#derive_pll_clocks -use_tan_name
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

set Vme_Ref_Ck Ck_100MHz_virt
set Adc_Ref_Ck Ck_40MHz_virt
set AdcCfg_Ref_Ck Ck_10MHz_virt
set Apv_Ref_Ck Ck_40MHz_virt

set_clock_groups -asynchronous -group { \
	MASTER_CLOCK \
	GlobalPll:ClockGenerator|altpll:altpll_component|_clk1 \
	GlobalPll:ClockGenerator|altpll:altpll_component|_clk2 \
	GlobalPll:ClockGenerator|altpll:altpll_component|_clk3 \
Ddr2SdramIf:Ddr2SdramIf_inst|Ddr2SdramIf_controller_phy:Ddr2SdramIf_controller_phy_inst|Ddr2SdramIf_phy:Ddr2SdramIf_phy_inst|Ddr2SdramIf_phy_alt_mem_phy:Ddr2SdramIf_phy_alt_mem_phy_inst|Ddr2SdramIf_phy_alt_mem_phy_clk_reset:clk|Ddr2SdramIf_phy_alt_mem_phy_pll:pll|altpll:altpll_component|_clk5 \
Ddr2SdramIf:Ddr2SdramIf_inst|Ddr2SdramIf_controller_phy:Ddr2SdramIf_controller_phy_inst|Ddr2SdramIf_phy:Ddr2SdramIf_phy_inst|Ddr2SdramIf_phy_alt_mem_phy:Ddr2SdramIf_phy_alt_mem_phy_inst|Ddr2SdramIf_phy_alt_mem_phy_clk_reset:clk|Ddr2SdramIf_phy_alt_mem_phy_pll:pll|altpll:altpll_component|_clk0 \
Ddr2SdramIf:Ddr2SdramIf_inst|Ddr2SdramIf_controller_phy:Ddr2SdramIf_controller_phy_inst|Ddr2SdramIf_phy:Ddr2SdramIf_phy_inst|Ddr2SdramIf_phy_alt_mem_phy:Ddr2SdramIf_phy_alt_mem_phy_inst|Ddr2SdramIf_phy_alt_mem_phy_clk_reset:clk|Ddr2SdramIf_phy_alt_mem_phy_pll:pll|altpll:altpll_component|_clk1 \
Ddr2SdramIf:Ddr2SdramIf_inst|Ddr2SdramIf_controller_phy:Ddr2SdramIf_controller_phy_inst|Ddr2SdramIf_phy:Ddr2SdramIf_phy_inst|Ddr2SdramIf_phy_alt_mem_phy:Ddr2SdramIf_phy_alt_mem_phy_inst|Ddr2SdramIf_phy_alt_mem_phy_clk_reset:clk|Ddr2SdramIf_phy_alt_mem_phy_pll:pll|altpll:altpll_component|_clk2 \
Ddr2SdramIf:Ddr2SdramIf_inst|Ddr2SdramIf_controller_phy:Ddr2SdramIf_controller_phy_inst|Ddr2SdramIf_phy:Ddr2SdramIf_phy_inst|Ddr2SdramIf_phy_alt_mem_phy:Ddr2SdramIf_phy_alt_mem_phy_inst|Ddr2SdramIf_phy_alt_mem_phy_clk_reset:clk|Ddr2SdramIf_phy_alt_mem_phy_pll:pll|altpll:altpll_component|_clk4 \
	ADC_FRAME_CK1 ADC_LCLK1 \
	ADC_FRAME_CK2 ADC_LCLK2 \
	} \
	-group { \
	MASTER_CLOCK2 \
	} \
	-group { \
	CLK_IN_P0 \
	} \
	-group { \
	GXB_CK \
	}

# new 08 Jul 2016
#set_false_path -from [get_clocks #{Ddr2SdramIf_inst|Ddr2SdramIf_controller_phy_inst|Ddr2SdramIf_phy_inst|Ddr2SdramIf_phy_alt_mem_phy_inst|clk|pll|altpll_component|pll|clk[0]}] -to #[get_clocks {ADC_LCLK*}]

	
# ADC DDR constraints START
set_input_delay -clock { ADC_LCLK1_virt } -max [expr $bit_period_DDR_adc / 2.0 - $tSU_DDR_adc] \
	[get_ports {ADC_DATA[0] ADC_DATA[1] ADC_DATA[2] ADC_DATA[3] \
	ADC_DATA[4] ADC_DATA[5] ADC_DATA[6] ADC_DATA[7]}]
set_input_delay -clock ADC_LCLK1_virt -min $tH_DDR_adc \
	[get_ports {ADC_DATA[0] ADC_DATA[1] ADC_DATA[2] ADC_DATA[3] \
	ADC_DATA[4] ADC_DATA[5] ADC_DATA[6] ADC_DATA[7]}]

set_input_delay -clock ADC_LCLK1_virt -max [expr $bit_period_DDR_adc / 2.0 - $tSU_DDR_adc] \
	[get_ports {ADC_DATA[0] ADC_DATA[1] ADC_DATA[2] ADC_DATA[3] \
	ADC_DATA[4] ADC_DATA[5] ADC_DATA[6] ADC_DATA[7]}] -clock_fall -add_delay
set_input_delay -clock ADC_LCLK1_virt -min $tH_DDR_adc \
	[get_ports {ADC_DATA[0] ADC_DATA[1] ADC_DATA[2] ADC_DATA[3] \
	ADC_DATA[4] ADC_DATA[5] ADC_DATA[6] ADC_DATA[7]}] -clock_fall -add_delay

set_input_delay -clock { ADC_FRAME_CK1_virt } -max [expr $bit_period_DDR_adc / 2.0 - $tSU_DDR_adc] \
	[get_ports {ADC_DATA[0] ADC_DATA[1] ADC_DATA[2] ADC_DATA[3] \
	ADC_DATA[4] ADC_DATA[5] ADC_DATA[6] ADC_DATA[7]}] -add_delay
set_input_delay -clock ADC_FRAME_CK1_virt -min $tH_DDR_adc \
	[get_ports {ADC_DATA[0] ADC_DATA[1] ADC_DATA[2] ADC_DATA[3] \
	ADC_DATA[4] ADC_DATA[5] ADC_DATA[6] ADC_DATA[7]}] -add_delay

set_false_path -setup -rise_from ADC_LCLK1_virt -fall_to ADC_LCLK1
set_false_path -setup -fall_from ADC_LCLK1_virt -rise_to ADC_LCLK1
set_false_path -hold -rise_from ADC_LCLK1_virt -fall_to ADC_LCLK1
set_false_path -hold -fall_from ADC_LCLK1_virt -rise_to ADC_LCLK1

set_false_path -from [get_clocks {ADC_FRAME_CK1}] -to [get_clocks {ADC_LCLK2}]
set_false_path -from [get_clocks {ADC_FRAME_CK2}] -to [get_clocks {ADC_LCLK1}]

set_input_delay -clock { ADC_LCLK2_virt } -max [expr $bit_period_DDR_adc / 2.0 - $tSU_DDR_adc] \
	[get_ports {ADC_DATA[8] ADC_DATA[9] ADC_DATA[10] ADC_DATA[11] \
	ADC_DATA[12] ADC_DATA[13] ADC_DATA[14] ADC_DATA[15]}]
set_input_delay -clock ADC_LCLK2_virt -min $tH_DDR_adc \
	[get_ports {ADC_DATA[8] ADC_DATA[9] ADC_DATA[10] ADC_DATA[11] \
	ADC_DATA[12] ADC_DATA[13] ADC_DATA[14] ADC_DATA[15]}]

set_input_delay -clock ADC_LCLK2_virt -max [expr $bit_period_DDR_adc / 2.0 - $tSU_DDR_adc] \
	[get_ports {ADC_DATA[8] ADC_DATA[9] ADC_DATA[10] ADC_DATA[11] \
	ADC_DATA[12] ADC_DATA[13] ADC_DATA[14] ADC_DATA[15]}] -clock_fall -add_delay
set_input_delay -clock ADC_LCLK2_virt -min $tH_DDR_adc \
	[get_ports {ADC_DATA[8] ADC_DATA[9] ADC_DATA[10] ADC_DATA[11] \
	ADC_DATA[12] ADC_DATA[13] ADC_DATA[14] ADC_DATA[15]}] -clock_fall -add_delay

set_input_delay -clock { ADC_FRAME_CK2_virt } -max [expr $bit_period_DDR_adc / 2.0 - $tSU_DDR_adc] \
	[get_ports {ADC_DATA[8] ADC_DATA[9] ADC_DATA[10] ADC_DATA[11] \
	ADC_DATA[12] ADC_DATA[13] ADC_DATA[14] ADC_DATA[15]}] -add_delay
set_input_delay -clock ADC_FRAME_CK2_virt -min $tH_DDR_adc \
	[get_ports {ADC_DATA[8] ADC_DATA[9] ADC_DATA[10] ADC_DATA[11] \
	ADC_DATA[12] ADC_DATA[13] ADC_DATA[14] ADC_DATA[15]}] -add_delay

set_false_path -setup -rise_from ADC_LCLK2_virt -fall_to ADC_LCLK2
set_false_path -setup -fall_from ADC_LCLK2_virt -rise_to ADC_LCLK2
set_false_path -hold -rise_from ADC_LCLK2_virt -fall_to ADC_LCLK2
set_false_path -hold -fall_from ADC_LCLK2_virt -rise_to ADC_LCLK2

set_false_path -setup -rise_from ADC_LCLK2 -fall_to ADC_FRAME_CK2
set_false_path -setup -fall_from ADC_LCLK2 -rise_to ADC_FRAME_CK2
set_false_path -hold -rise_from ADC_LCLK2 -fall_to ADC_FRAME_CK2
set_false_path -hold -fall_from ADC_LCLK2 -rise_to ADC_FRAME_CK2
set_false_path -setup -rise_from ADC_FRAME_CK2 -fall_to ADC_LCLK2
set_false_path -setup -fall_from ADC_FRAME_CK2 -rise_to ADC_LCLK2
set_false_path -hold -rise_from ADC_FRAME_CK2 -fall_to ADC_LCLK2
set_false_path -hold -fall_from ADC_FRAME_CK2 -rise_to ADC_LCLK2
# ADC DDR constraints END

# Input delays
set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_A[*]}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_A[*]}]
set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_D[*]}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_D[*]}]
set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_AM[*]}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_AM[*]}]
set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_WRITEb}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_WRITEb}]
set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_DS*}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_DS*}]
set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_ASb}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_ASb}]
set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_IACKb}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_IACKb}]
#set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {VME_IACKINb}]
#set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {VME_IACKINb}]

set_input_delay -clock $Vme_Ref_Ck -max 6.0 [get_ports {I2C_SDA_IN}]
set_input_delay -clock $Vme_Ref_Ck -min 1.0 [get_ports {I2C_SDA_IN}]
set_input_delay -clock $Apv_Ref_Ck -max 6.0 [get_ports {USER_IN_TTL[*]}]
set_input_delay -clock $Apv_Ref_Ck -min 1.0 [get_ports {USER_IN_TTL[*]}]
set_input_delay -clock $Apv_Ref_Ck -max 6.0 [get_ports {USER_IN_NIM[*]}]
set_input_delay -clock $Apv_Ref_Ck -min 1.0 [get_ports {USER_IN_NIM[*]}]
set_input_delay -clock $Apv_Ref_Ck -max 6.0 [get_ports {SYNC_IN}]
set_input_delay -clock $Apv_Ref_Ck -min 1.0 [get_ports {SYNC_IN}]
set_input_delay -clock $Apv_Ref_Ck -max 6.0 [get_ports {TRIG1_IN}]
set_input_delay -clock $Apv_Ref_Ck -min 1.0 [get_ports {TRIG1_IN}]
set_input_delay -clock $Apv_Ref_Ck -max 6.0 [get_ports {TRIG2_IN}]
set_input_delay -clock $Apv_Ref_Ck -min 1.0 [get_ports {TRIG2_IN}]

# Output delays
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_A[*]}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_A[*]}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_D[*]}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_D[*]}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_IACKOUTb}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_IACKOUTb}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_DTACKb}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_DTACKb}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_BERRb}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_BERRb}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_RETRYb}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_RETRYb}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_IRQ[*]}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_IRQ[*]}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_DTACK_EN}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_DTACK_EN}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_BERR_EN}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_BERR_EN}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_RETRY_EN}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_RETRY_EN}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_LIOb}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_LIOb}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_ADIR}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_ADIR}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_DDIR}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_DDIR}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {VME_DOEb}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {VME_DOEb}]

set_output_delay -clock $Apv_Ref_Ck -max 0.0 [get_ports {USER_OUT[*]}]
set_output_delay -clock $Apv_Ref_Ck -min -1.0 [get_ports {USER_OUT[*]}]

set_output_delay -clock $AdcCfg_Ref_Ck -max 0.0 [get_ports {ADC_SCLK}]
set_output_delay -clock $AdcCfg_Ref_Ck -min -2.0 [get_ports {ADC_SCLK}]
set_output_delay -clock $AdcCfg_Ref_Ck -max 0.0 [get_ports {ADC_SDA}]
set_output_delay -clock $AdcCfg_Ref_Ck -min -2.0 [get_ports {ADC_SDA}]
set_output_delay -clock $AdcCfg_Ref_Ck -max 0.0 [get_ports {ADC_CS*}]
set_output_delay -clock $AdcCfg_Ref_Ck -min -2.0 [get_ports {ADC_CS*}]
set_output_delay -clock $AdcCfg_Ref_Ck -max 0.0 [get_ports {ADC_RESETb}]
set_output_delay -clock $AdcCfg_Ref_Ck -min -2.0 [get_ports {ADC_RESETb}]

set_output_delay -clock $Adc_Ref_Ck -max 0.0 [get_ports {ADC_CONV_CK*}]
set_output_delay -clock $Adc_Ref_Ck -min -1.0 [get_ports {ADC_CONV_CK*}]
set_output_delay -clock $Apv_Ref_Ck -max 0.0 [get_ports {APV_TRIGGER}]
set_output_delay -clock $Apv_Ref_Ck -min -1.0 [get_ports {APV_TRIGGER}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {APV_RESET}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {APV_RESET}]

set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {READ1}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {READ1}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {READ2}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {READ2}]

set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {I2C_SDA_OUT}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {I2C_SDA_OUT}]
set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {I2C_SCL}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {I2C_SCL}]

set_output_delay -clock $Vme_Ref_Ck -max 0.0 [get_ports {SPARE*}]
set_output_delay -clock $Vme_Ref_Ck -min -1.0 [get_ports {SPARE*}]

# False paths
set_false_path -from MASTER_RESETb -to {*}
set_false_path -from {*} -to {LED*}
set_false_path -from {*} -to {SEL_OUT[*]}
set_false_path -from {*} -to GXB_TX_DISABLE
set_false_path -from {*} -to MII_RESETb
set_false_path -from {VME_GA[*]} -to {*}
set_false_path -from {SWITCH[*]} -to {*}
set_false_path -from GXB_PRESENT -to {*}
set_false_path -from GXB_RX_LOS -to {*}
set_false_path -from {TOKEN_IN*} -to {*}

# config register outputs are static
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|RESET_REG[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|SAMPLE_PER_EVENT[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|EVENT_PER_BLOCK[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|BUSY_THRESHOLD[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|BUSY_THRESHOLD_LOCAL[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|IO_CONFIG[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|READOUT_CONFIG[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|TRIGGER_CONFIG[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|TRIGGER_DELAY[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|SYNC_PERIOD[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|MARKER_CHANNEL[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|CHANNEL_ENABLE[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|ZERO_THRESHOLD[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|ONE_THRESHOLD[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR0_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR1_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR2_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR3_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR4_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR5_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR6_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR7_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR8_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR9_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR10_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR11_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR12_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR13_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR14_COEFF[*]}  -to {*}
set_false_path -from {RegisterBank:ConfigRegisters_and_Rom|FIR15_COEFF[*]}  -to {*}
set_false_path -from {VmeSlaveIf:VmeIf|ConfigRegisters:CFG|SDRAM_BANK[*]}  -to {*}
set_false_path -from {VmeSlaveIf:VmeIf|ConfigRegisters:CFG|SDRAM_BASE_ADDRESS[*]}  -to {*}
set_false_path -from {VmeSlaveIf:VmeIf|ConfigRegisters:CFG|OUTPUT_BUFFER_BASE_ADDRESS[*]}  -to {*}
set_false_path -from {VmeSlaveIf:VmeIf|ConfigRegisters:CFG|FIBER_CTRL[*]}  -to {*}
set_false_path -from {VmeSlaveIf:VmeIf|ConfigRegisters:CFG|MULTIBOARD*}  -to {*}

# Set Maximum Delay
set_max_delay -from * -to APV_CLOCK 5.0
set_max_delay -from * -to BUSY_OUT 5.0
set_max_delay -from * -to TRIG_OUT 10.0

set_max_delay -from * -to SPARE_CLK_LVDS 5.0
set_max_delay -from * -to SPARE_CLK_TTL 5.0
set_max_delay -from * -to READ_CLK1 5.0
set_max_delay -from * -to READ_CLK2 5.0

# Set Minimum Delay
set_min_delay -from * -to APV_CLOCK 0.0
set_min_delay -from * -to BUSY_OUT 0.0
set_min_delay -from * -to TRIG_OUT 0.0

set_min_delay -from * -to SPARE_CLK_LVDS 0.0
set_min_delay -from * -to SPARE_CLK_TTL 0.0
set_min_delay -from * -to READ_CLK1 0.0
set_min_delay -from * -to READ_CLK2 0.0
set_min_delay -from * -to MII_25MHZ_CLOCK 0.0

# Multicycles
set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]} -to \
    {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]*} -setup -end 3
set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]} -to \
    {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]*} -hold -end 3
set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]} -to \
    {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]*} -setup -end 3
set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]} -to \
    {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]*} -hold -end 3
set_multicycle_path -from {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|int_PDATA[*]} -to \
    {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|PDATA[*]} -setup -end 2
set_multicycle_path -from {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|int_PDATA[*]} -to \
    {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|PDATA[*]} -hold -end 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|USER_DATA_OUT[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -setup -end 3
set_multicycle_path -from {VmeSlaveIf:VmeIf|USER_DATA_OUT[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -hold -end 3
set_multicycle_path -from {fir_16tap:fir*|DATA_OUT[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -setup -end 2
set_multicycle_path -from {fir_16tap:fir*|DATA_OUT[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -hold -end 2
set_multicycle_path -from {VME_*} -to {VME_D*} -setup -end 3
set_multicycle_path -from {VME_*} -to {VME_D*} -hold -end 3
set_multicycle_path -from {VME_*} -to {VME_A*} -setup -end 3
set_multicycle_path -from {VME_*} -to {VME_A*} -hold -end 3
set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|FIFO_EMPTY} -to \
   {TrigGen:ApvTriggerHandler|hw_trig_enable} -setup -end 2
set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|FIFO_EMPTY} -to \
   {TrigGen:ApvTriggerHandler|hw_trig_enable} -hold -end 2
  
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|ApvDataFifo_1024x13:DataFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|word_count[*]} -setup -end 2
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|ApvDataFifo_1024x13:DataFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|word_count[*]} -hold -end 2
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|ApvDataFifo_1024x13:DataFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|fifo_out_wr} -setup -end 2
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|ApvDataFifo_1024x13:DataFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|fifo_out_wr	} -hold -end 2
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|DcFifo_32x12:MeanFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|word_count[*]} -setup -end 2
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|DcFifo_32x12:MeanFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|word_count[*]} -hold -end 2
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|DcFifo_32x12:MeanFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|fifo_out_wr} -setup -end 2
  set_multicycle_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|DcFifo_32x12:MeanFifo|dcfifo:dcfifo_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|BaselineSubtractorAndThresholdCut:ThrSub|fifo_out_wr} -hold -end 2
  
  
  
  
  ## TO TEST
  ## set_false_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|DpRam128x12:*Ram|altsyncram:altsyncram_component|altsyncram_sso1:auto_generated|ram*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|fifo_data_in[*]}
  ## set_false_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|DpRam128x12:*Ram|altsyncram:altsyncram_component|altsyncram_sso1:auto_generated|ram*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]}
  ## set_false_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|DpRam128x12:*Ram|altsyncram:altsyncram_component|altsyncram_sso1:auto_generated|ram_*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]}
  ## set_false_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]}
  