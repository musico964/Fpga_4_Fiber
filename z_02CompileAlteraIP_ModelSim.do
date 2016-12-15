if {[file exists altera_ip]} {
	vdel -lib altera_ip -all
}

vlib altera_ip

vlog -vlog01compat -work altera_ip {./Mpd4/P0CK_Pll.v}
vlog -vlog01compat -work altera_ip {./Mpd4/GlobalPll.v}
vlog -vlog01compat -work altera_ip {./Mpd4/CK40_MUX.v}

vlog -vlog01compat -work altera_ip {./Mpd_Common/ADS5281_Pll.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/ApvDataFifo_1024x12.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/ApvDataFifo_1024x13.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/DdrIn.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/DpRam128x12.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_16x20.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_16x24.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_16x48.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_256x13.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_2048x21.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_2048x24.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_2048x32.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/alt2gxb.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Gxb.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/IntDivide.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Adder12.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Sub13.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/SpRam_4096x32.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/DcFifo_32x12.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/TdcFifo_1024x8.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/Fifo_8192x64.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/z_asmi.v}
vlog -vlog01compat -work altera_ip {./Mpd_Common/z_remote.v}

vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_seq_wrapper.v}
vcom -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_seq.vhd}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_controller_phy.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_reconfig.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_pll.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/Ddr2SdramIf_alt_mem_ddrx_controller_top.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_controller_st_top.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_controller.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_timing_param.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_mm_st_converter.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_input_if.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_cmd_gen.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_tbp.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_arbiter.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_burst_gen.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_addr_cmd_wrap.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_rdwr_data_tmg.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_wdata_path.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_rdata_path.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_sideband.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_rank_timer.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_list.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_burst_tracking.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_dataid_manager.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_fifo.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_addr_cmd.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_odt_gen.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_buffer.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_ecc_encoder.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_ecc_decoder.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_ddr2_odt_gen.v}
vlog -vlog01compat -work altera_ip {./Mpd4/Ddr2SdramIf/alt_mem_ddrx_ddr3_odt_gen.v}
