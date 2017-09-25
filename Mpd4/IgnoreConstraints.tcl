
  ## TO TEST
set_false_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|DpRam128x12:*Ram|altsyncram:altsyncram_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|fifo_data_in[*]}
set_false_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|DpRam128x12:*Ram|altsyncram:altsyncram_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|accumulator[*]}
set_false_path -from {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|DpRam128x12:*Ram|altsyncram:altsyncram_component|*} -to {EightChannels:ApvProcessor_*|ChannelProcessor:Ch*|ApvReadout:ApvFrameDecoder|n_channel[*]}
set_false_path -from {Histogrammer:AdcHisto*|CtrlRegister[*]} -to *
set_false_path -from {Histogrammer:AdcHisto*|HistoEnable} -to {Histogrammer:AdcHisto*|HistoEnableSlow}
set_false_path -from {OneShot:TurnOnLed*|*} -to {*}
set_false_path -from {EventBuilder:TheBuilder|AsyncTimeCounter[*]} -to {EventBuilder:TheBuilder|AsyncTimeCounter[*]}
set_false_path -from {EventBuilder:TheBuilder|clear_time_counter} -to {EventBuilder:TheBuilder|AsyncTimeCounter[*]}
set_false_path -from {VmeSlaveIf:VmeIf|AdCnt:AddressCounter|addr_counter[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]}
set_false_path -from {mpd_fiber_interface:AuroraInterface|mpd_fiber_slave:mpd_fiber_slave_inst|mpd_fiber_reg_slave:mpd_fiber_reg_slave_inst|REG_ADDR[*]} -to {Histogrammer:AdcHisto*|RamAddr[*]}

set_multicycle_path -from {SyncReset:ResetSynchronizer|SYNC_RSTb} -to {mpd_fiber_interface:AuroraInterface|*} -setup -end 2
set_multicycle_path -from {FiberInterface:FiberInterface_Instance|aurora_reset_generator:FiberRstGen|RESET_OUT} -to {mpd_fiber_interface:AuroraInterface|*} -setup -end 2
set_multicycle_path -from {Histogrammer:AdcHisto*|HistoEnableW} -to {Histogrammer:AdcHisto*|RamAddr*} -setup -end 2
set_multicycle_path -from {mpd_fiber_interface:AuroraInterface|RESET} -to {mpd_fiber_interface:AuroraInterface|mpd_fiber_slave:mpd_fiber_slave_inst|*} -setup -end 2
set_false_path -from {EventBuilder:TheBuilder|AsyncTimeCounter[*]} -to {EventBuilder:TheBuilder|TimeCounter[*]}
set_false_path -from {USER_IN_*} -to {TrigMeas:TriggerMeasurements|*}
set_false_path -from {TRIG*_IN} -to {TrigMeas:TriggerMeasurements|*}
set_multicycle_path -from * -to {VME_*} -setup -end 3
set_false_path -from [get_clocks {ADC_FRAME_CK1}] -to [get_clocks {ClockGenerator|altpll_component|pll|clk[0]}]
set_false_path -from [get_clocks {ADC_FRAME_CK2}] -to [get_clocks {ClockGenerator|altpll_component|pll|clk[0]}]

set_false_path -from {TrigMeas:TriggerMeasurements|*} -to {*}

set_false_path -from {AdcConfigMachine:AdcConfigurator|StartAdc*} -to {AdcConfigMachine:AdcConfigurator|Shreg*}
set_false_path -from {AdcConfigMachine:AdcConfigurator|BitCnt*} -to {AdcConfigMachine:AdcConfigurator|Shreg*}
