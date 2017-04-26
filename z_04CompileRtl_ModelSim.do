
vlog -vlog01compat -work work {./Mpd4/Fpga_4.v}
#vlog -vlog01compat -work work {./Mpd4/RegisterBank.v}
vlog -vlog01compat -work work {./RegisterBank.v}

vlog -vlog01compat -work work {./Mpd_Common/BidirBuf.v}
vlog -vlog01compat -work work {./Mpd_Common/VmeSlaveIf.v}
vlog -vlog01compat -work work {./Mpd_Common/AdcConfig.v}
vlog -vlog01compat -work work {./Mpd_Common/AdcDeser.v}
vlog -vlog01compat -work work {./Mpd_Common/AdcHisto.v}
vlog -vlog01compat -work work {./Mpd_Common/ApvReadout.v}
vlog -vlog01compat -work work {./Mpd_Common/ChannelProcessor.v}
vlog -vlog01compat -work work {./Mpd_Common/EventBuilder.v}
vlog -vlog01compat -work work {./Mpd_Common/i2c_master_bit_ctrl.v}
vlog -vlog01compat -work work {./Mpd_Common/i2c_master_byte_ctrl.v}
vlog -vlog01compat -work work {./Mpd_Common/i2c_master_top.v}
vlog -vlog01compat -work work {./Mpd_Common/OneShot.v}
vlog -vlog01compat -work work {./Mpd_Common/TrigGen.v}
vlog -vlog01compat -work work {./Mpd_Common/SyncReset.v}
vlog -vlog01compat -work work {./Mpd_Common/TrigMeas.v}
vlog -vlog01compat -work work {./Mpd_Common/Tdc.v}
vlog -vlog01compat -work work {./Mpd_Common/SdramFifoHandler.v}
vlog -vlog01compat -work work {./Mpd_Common/FiberInterface.v}
vlog -vlog01compat -work work {./Fir_Modules/fir_16tap.v}
vlog -vlog01compat -work work {./Fir_Modules/Multadd4.v}
vlog -vlog01compat -work work {./Fir_Modules/add32.v}
vlog -vlog01compat -work work {./Mpd_Common/AsmiRemote.v}
vlog -vlog01compat -work work {./Mpd_Common/AsmiIf.v}
vlog -vlog01compat -work work {./Mpd_Common/RemoteUpdateIf.v}

vlog -vlog01compat -work work {./Mpd_Common/ddr2.v}
vlog -vlog01compat -work work {./Mpd4/Ddr2SdramIf/testbench/Ddr2SdramIf_full_mem_model.v}

vlog -vlog01compat -work work {./Mpd_Common/ADS5281.v}

vlog -vlog01compat -work work {./Mpd_Common/TestModule.v}
vcom -work work {./mpd_fiber/mpd_fiber_slave.vhd}
vlog -vlog01compat -work work {./TestBench.v}

