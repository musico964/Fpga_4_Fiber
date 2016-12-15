## Generated SDC file "Fpga.out.sdc"

## Copyright (C) 1991-2008 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 8.1 Build 163 10/28/2008 SJ Full Version"

## DATE    "Tue Sep 01 13:43:06 2009"

##
## DEVICE  "EP1AGX50DF780C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3
# 100 MHz on MPD 3.0
set master_ck_period 10
#  40 MHz on MPD 4.0
#set master_ck_period 25

set tSU_static 100
set tH_static 100
set tCO_static 100
set tSU_vme 6.0
set tH_vme 1.0
set tCO_vme 9.0

set tSU_DDR_adc 0.67
set tH_DDR_adc 0.85
set bit_period_DDR_adc 4.1
set frame_period_DDR_adc 25.0

#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {Ck_100MHz_virt} -period 10.0
create_clock -name {Ck_40MHz_virt} -period 25.0
create_clock -name {Ck_20MHz_virt} -period 50.0
create_clock -name {Ck_10MHz_virt} -period 100.0

create_clock -name {ADC_LCLK1_virt} -period $bit_period_DDR_adc
create_clock -name {ADC_LCLK2_virt} -period $bit_period_DDR_adc
create_clock -name {ADC_FRAME_CK1_virt} -period $frame_period_DDR_adc
create_clock -name {ADC_FRAME_CK2_virt} -period $frame_period_DDR_adc
create_clock -name {MASTER_CLOCK_virt} -period $master_ck_period
# create_clock -name {MASTER_CLOCK2_virt} -period $master_ck_period
create_clock -name {GXB_CK_virt} -period 15.0
create_clock -name {CLK_IN_P0_virt} -period 7.0

# MASTER_CLOCK (on board) = MASTER_CLOCK2 (front_panel).
# MASTER_CLOCK2 is not used on MPD 3.0
# From GlobalPll are derived:
#		ck_60MHz, ck_40MHz_Adc, ck_40MHz_Apv, MII_25MHZ_CLOCK, ck_10MHz, ck_1MHz


create_clock -period $bit_period_DDR_adc [get_ports ADC_LCLK1]
create_clock -period $bit_period_DDR_adc [get_ports ADC_LCLK2]
create_clock -period $frame_period_DDR_adc [get_ports ADC_FRAME_CK1]
create_clock -period $frame_period_DDR_adc [get_ports ADC_FRAME_CK2]
create_clock -period $master_ck_period [get_ports MASTER_CLOCK]
# create_clock -period $master_ck_period [get_ports MASTER_CLOCK2]
create_clock -period 15.0 [get_ports GXB_CK]
create_clock -period 7.0 [get_ports CLK_IN_P0]

#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks -use_tan_name

derive_clock_uncertainty

set Vme_Ref_Ck Ck_100MHz_virt
set Adc_Ref_Ck Ck_40MHz_virt
set AdcCfg_Ref_Ck Ck_10MHz_virt
set Apv_Ref_Ck Ck_40MHz_virt

# ADC DDR constraints
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

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_A[*]}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_A[*]}]
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_D[*]}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_D[*]}]
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_AM[*]}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_AM[*]}]
# set_input_delay -clock $Vme_Ref_Ck -max $master_ck_period [get_ports {VME_GA[*]}]
# set_input_delay -clock $Vme_Ref_Ck -min $master_ck_period [get_ports {VME_GA[*]}]
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_WRITEb}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_WRITEb}]
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_DS*}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_DS*}]
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_ASb}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_ASb}]
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_IACKb}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_IACKb}]
set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {VME_IACKINb}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {VME_IACKINb}]


set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {USER_IN[*]}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {USER_IN[*]}]

set_input_delay -clock MASTER_CLOCK_virt -max [expr $master_ck_period - $tSU_vme] [get_ports {MASTER_RESETb}]
set_input_delay -clock MASTER_CLOCK_virt -min $tH_vme [get_ports {MASTER_RESETb}]

set_input_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {I2C_SDA_IN}]
set_input_delay -clock $Vme_Ref_Ck -min $tH_vme [get_ports {I2C_SDA_IN}]

set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {SPARE1}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {SPARE1}]
set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {SPARE2}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {SPARE2}]
set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {SPARE3}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {SPARE3}]
set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {SPARE4}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {SPARE4}]

set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {SYNC_IN}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {SYNC_IN}]
set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {TRIG1_IN}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {TRIG1_IN}]
set_input_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tSU_vme] [get_ports {TRIG2_IN}]
set_input_delay -clock $Apv_Ref_Ck -min $tH_vme [get_ports {TRIG2_IN}]

#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_A[*]}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_A[*]}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_D[*]}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_D[*]}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_IACKOUTb}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_IACKOUTb}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_DTACKb}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_DTACKb}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_BERRb}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_BERRb}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_RETRYb}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_RETRYb}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_IRQ[*]}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_IRQ[*]}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_DTACK_EN}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_DTACK_EN}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_BERR_EN}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_BERR_EN}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_RETRY_EN}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_RETRY_EN}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_LIOb}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_LIOb}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_ADIR}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_ADIR}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_DDIR}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_DDIR}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {VME_DOEb}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {VME_DOEb}]


set_output_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {USER_OUT[*]}]
set_output_delay -clock $Apv_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {USER_OUT[*]}]

set_output_delay -clock $AdcCfg_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {ADC_SCLK}]
set_output_delay -clock $AdcCfg_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {ADC_SCLK}]
set_output_delay -clock $AdcCfg_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {ADC_SDA}]
set_output_delay -clock $AdcCfg_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {ADC_SDA}]
set_output_delay -clock $AdcCfg_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {ADC_CS*}]
set_output_delay -clock $AdcCfg_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {ADC_CS*}]
set_output_delay -clock $AdcCfg_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {ADC_RESETb}]
set_output_delay -clock $AdcCfg_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {ADC_RESETb}]

set_output_delay -clock $Adc_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {ADC_CONV_CK*}]
set_output_delay -clock $Adc_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {ADC_CONV_CK*}]

set_output_delay -clock $Apv_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {APV_TRIGGER}]
set_output_delay -clock $Apv_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {APV_TRIGGER}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {APV_RESET}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {APV_RESET}]

set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {I2C_SDA_OUT}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {I2C_SDA_OUT}]
set_output_delay -clock $Vme_Ref_Ck -max [expr $master_ck_period - $tCO_vme] [get_ports {I2C_SCL}]
set_output_delay -clock $Vme_Ref_Ck -min [expr -1 * $tCO_vme] [get_ports {I2C_SCL}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
# set_false_path -setup -from {MASTER_RESETb} -to {*}
# set_false_path -hold -from {MASTER_RESETb} -to {*}
set_false_path -from {*} -to {LED*}
set_false_path -from {VME_GA[*]} -to {*}
set_false_path -from {SWITCH[*]} -to {*}

set_false_path -from {Histogrammer:AdcHisto*|WriteCounter[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]}
set_false_path -from {i2c_master_top:I2C_Controller|*} -to {Histogrammer:AdcHisto*|RamDataIn[*]}
set_false_path -from {Histogrammer:AdcHisto*|IntDataOut[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]}
set_false_path -from {AdcConfigMachine:AdcConfigurator|WrDataRegister[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]}
set_false_path -from {AdcConfigMachine:AdcConfigurator|StartAdc*} -to {Histogrammer:AdcHisto*|RamDataIn[*]}

set_false_path -from {FifoVmeIf:ApvVmeIf|TRIG_GEN_CONFIG[*]} -to *
set_false_path -from {FifoVmeIf:ApvVmeIf|READOUT_CONFIG[*]} -to *
set_false_path -from {FifoVmeIf:ApvVmeIf|ZERO_THR[*]} -to *
set_false_path -from {FifoVmeIf:ApvVmeIf|ONE_THR[*]} -to *
set_false_path -from {FifoVmeIf:ApvVmeIf|MARKER_CH[*]} -to *
set_false_path -from {FifoVmeIf:ApvVmeIf|SYNC_PERIOD[*]} -to *
set_false_path -from {FifoVmeIf:ApvVmeIf|ENABLE[*]} -to *

set_false_path -from {FastSdramFifoIf:SdramFifoHandler|Fifo_8192x64:OutputFifo|scfifo:scfifo_component|scfifo_*:auto_generated|a_dpfifo_*:dpfifo|altsyncram_*:FIFOram|ram_block*} -to {Histogrammer:AdcHisto*|RamDataIn[*]}
set_false_path -from {mem_local_rdata_latched[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]}

#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -from {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|int_PDATA[*]} -to {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|PDATA[*]} -setup -start 2
set_multicycle_path -from {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|int_PDATA[*]} -to {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|PDATA[*]} -hold -start 2
set_multicycle_path -from {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|PDATA[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -setup -start 2
set_multicycle_path -from {AdcDeser:AdcDeser*|AdcOneDeser:Deser*|PDATA[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|SpRam_4096x32:HistoRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_a[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -setup -start 3
set_multicycle_path -from {Histogrammer:AdcHisto*|SpRam_4096x32:HistoRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_a[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -hold -start 3
set_multicycle_path -from {VME_WRITEb} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -setup -start 3
set_multicycle_path -from {VME_WRITEb} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -hold -start 3
set_multicycle_path -from {VME_D[*]} -to {Histogrammer:AdcHisto0|RamDataIn[*]} -setup -end 2
set_multicycle_path -from {VME_D[*]} -to {Histogrammer:AdcHisto1|RamDataIn[*]} -setup -end 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|ControlStatusRegisters:CSR|ADER*[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|ControlStatusRegisters:CSR|ADER*[*]} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|ControlStatusRegisters:CSR|ADER2[*]} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|HistoEnable} -to {Histogrammer:AdcHisto*|HistoEnableSlow} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|HistoEnable} -to {Histogrammer:AdcHisto*|HistoEnableSlow} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|*} -to {Histogrammer:AdcHisto*|*} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|*} -to {Histogrammer:AdcHisto*|*} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]} -hold -start 2
set_multicycle_path -from {VME_D[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -setup -start 2
set_multicycle_path -from {VME_D[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|UserCtrlRegisterWrite} -to {Histogrammer:AdcHisto*|CtrlRegister[*]} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|UserCtrlRegisterWrite} -to {Histogrammer:AdcHisto*|CtrlRegister[*]} -hold -start 2
set_multicycle_path -from {VME_WRITEb} -to {Histogrammer:AdcHisto*|CtrlRegister[*]} -setup -start 2
set_multicycle_path -from {VME_WRITEb} -to {Histogrammer:AdcHisto*|CtrlRegister[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|SpRam_4096x32:HistoRam|altsyncram:altsyncram_component|altsyncram_o2a1:auto_generated|q_a[*]} -to {Histogrammer:AdcHisto*|IntDataOut[*]} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|SpRam_4096x32:HistoRam|altsyncram:altsyncram_component|altsyncram_o2a1:auto_generated|q_a[*]} -to {Histogrammer:AdcHisto*|IntDataOut[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|FsmRunning} -to {Histogrammer:AdcHisto*|IntDataOut[*]} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|FsmRunning} -to {Histogrammer:AdcHisto*|IntDataOut[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|HistoEnableW} -to {Histogrammer:AdcHisto*|RamAddr[*]} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|HistoEnableW} -to {Histogrammer:AdcHisto*|RamAddr[*]} -hold -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to {Histogrammer:AdcHisto*|HistoEnable} -setup -start 2
set_multicycle_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to {Histogrammer:AdcHisto*|HistoEnable} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|USER_CEb[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|USER_CEb[*]} -to {Histogrammer:AdcHisto*|RamDataIn[*]} -hold -start 2

set_multicycle_path -from {VmeSlaveIf:VmeIf|AdCnt:AddressCounter|addr_counter[*]} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|AdCnt:AddressCounter|addr_counter[*]} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|AdCnt:AddressCounter|addr_counter[*]} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|AdCnt:AddressCounter|addr_counter[*]} -to {VME_A[*]} -hold -start 2

set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|FIFO_EMPTY} -to {TrigGen:ApvTriggerHandler|hw_trig_enable} -setup -end 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|FIFO_EMPTY} -to {TrigGen:ApvTriggerHandler|hw_trig_enable} -hold -end 2

set_multicycle_path -from {VME_ASb} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VME_ASb} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VME_ASb} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VME_ASb} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VME_WRITEb} -to * -setup -start 2
set_multicycle_path -from {VME_WRITEb} -to * -hold -start 2
set_multicycle_path -from {VME_A[*]} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VME_A[*]} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VME_D[*]} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VME_D[*]} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VME_D[*]} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VME_D[*]} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VME_ASb} -to {VME_DOEb} -setup -start 2
set_multicycle_path -from {VME_ASb} -to {VME_DOEb} -hold -start 2
set_multicycle_path -from {VME_ASb} -to {VME_ADIR} -setup -start 2
set_multicycle_path -from {VME_ASb} -to {VME_ADIR} -hold -start 2
set_multicycle_path -from {VME_WRITEb} -to {VME_ADIR} -setup -start 2
set_multicycle_path -from {VME_WRITEb} -to {VME_ADIR} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|USER_CEb[*]} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|USER_CEb[*]} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|USER_CEb[*]} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|USER_CEb[*]} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|CR_CSR_SEL} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|CR_CSR_SEL} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|CR_CSR_SEL} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|Decoder:AddressDecoder|CR_CSR_SEL} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_OEb} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_OEb} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_OEb} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_OEb} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_WEb} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_WEb} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_WEb} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|USER_WEb} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|CYCLE_IN_PROGRESS} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|CYCLE_IN_PROGRESS} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|CYCLE_IN_PROGRESS} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|CYCLE_IN_PROGRESS} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|status.S*} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|status.S*} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|status.S*} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|CtrlFsm:DataCycleController|status.S*} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d64_2esst_cycle} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d64_2esst_cycle} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d64_2esst_cycle} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d64_2esst_cycle} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d32_2esst_cycle} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d32_2esst_cycle} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d32_2esst_cycle} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|a32d32_2esst_cycle} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d32_2e_cycle} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d32_2e_cycle} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d32_2e_cycle} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d32_2e_cycle} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d64_2e_cycle} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d64_2e_cycle} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d64_2e_cycle} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|d64_2e_cycle} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|cr_csr_cycle} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|cr_csr_cycle} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|cr_csr_cycle} -to {VME_A[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|cr_csr_cycle} -to {VME_A[*]} -hold -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|ControlStatusRegisters:CSR|IRQ*} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {VmeSlaveIf:VmeIf|ControlStatusRegisters:CSR|IRQ*} -to {VME_D[*]} -hold -start 2
set_multicycle_path -from {i2c_master_top:I2C_Controller|*} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {i2c_master_top:I2C_Controller|*} -to {VME_D[*]} -hold -start 2

set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|n_channel[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|MEAN[*]} -setup -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|n_channel[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|MEAN[*]} -hold -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|accumulator[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|MEAN[*]} -setup -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|accumulator[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|PedestalSubtractor:PedSub|MEAN[*]} -hold -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]} -setup -end 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]} -hold -end 2
set_multicycle_path -from {EightChannels:ApvProcesso*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]} -setup -end 2
set_multicycle_path -from {EightChannels:ApvProcesso*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|computed_mean[*]} -hold -end 2

set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|DpRam128x12:PedestalRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_b[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]} -setup -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|DpRam128x12:PedestalRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_b[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]} -hold -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|DpRam128x12:PedestalRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_b[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]} -setup -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|DpRam128x12:PedestalRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_b[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]} -hold -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|DpRam128x12:PedestalRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_b[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|fifo_data_in[*]} -setup -start 2
set_multicycle_path -from {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|DpRam128x12:PedestalRam|altsyncram:altsyncram_component|altsyncram*:auto_generated|q_b[*]} -to {EightChannels:ApvProcessor*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|fifo_data_in[*]} -hold -start 2

set_multicycle_path -from {FastSdramFifoIf:SdramFifoHandler|Fifo_8192x64:OutputFifo|scfifo:scfifo_component|scfifo*:auto_generated|a_dpfifo*:dpfifo|altsyncram*:FIFOram|ram_block*} -to {VME_D[*]} -setup -start 2
set_multicycle_path -from {FastSdramFifoIf:SdramFifoHandler|Fifo_8192x64:OutputFifo|scfifo:scfifo_component|scfifo*:auto_generated|a_dpfifo*:dpfifo|altsyncram*:FIFOram|ram_block*} -to {VME_D[*]} -hold -start 2

#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from * -to APV_CLOCK 5.0
set_max_delay -from * -to BUSY_OUT 5.0
set_max_delay -from * -to TRIG_OUT 10.0

set_max_delay -from * -to SPARE5 10.0
set_max_delay -from * -to SPARE6 10.0
set_max_delay -from * -to SPARE7 10.0
set_max_delay -from * -to SPARE8 10.0
set_max_delay -from * -to SPARE9 10.0
set_max_delay -from * -to SPARE10 10.0


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -from * -to APV_CLOCK 0
set_min_delay -from * -to BUSY_OUT 0
set_min_delay -from * -to TRIG_OUT 0

set_min_delay -from * -to SPARE5 0
set_min_delay -from * -to SPARE6 0
set_min_delay -from * -to SPARE7 0
set_min_delay -from * -to SPARE8 0
set_min_delay -from * -to SPARE9 0
set_min_delay -from * -to SPARE10 0


#**************************************************************
# Set Input Transition
#**************************************************************

