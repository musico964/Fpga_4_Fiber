if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work



##### Top level Example
vlog  -work rtl_work D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/testbench/Ddr2SdramIf_mem_model.v
# vlog  -work rtl_work D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/testbench/Ddr2SdramIf_full_mem_model.v
# vlog  -work rtl_work D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd_Common/ddr2.v
vlog  -work rtl_work D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_ex_lfsr8.v
vlog  -work rtl_work D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_example_driver.v
vlog  -work rtl_work D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_example_top.v

##### Test Bench
vlog  -work rtl_work D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/testbench/Ddr2SdramIf_example_top_tb.v


##### Library stuff
vlog  -work rtl_work {c:/programs/altera/12.1sp1/quartus/eda/sim_lib/altera_mf.v}
vlog  -work rtl_work {c:/programs/altera/12.1sp1/quartus/eda/sim_lib/220model.v}
vlog  -work rtl_work {c:/programs/altera/12.1sp1/quartus/eda/sim_lib/sgate.v}
vlog  -work rtl_work {c:/programs/altera/12.1sp1/quartus/eda/sim_lib/arriagx_hssi_atoms.v}
vlog  -work rtl_work {c:/programs/altera/12.1sp1/quartus/eda/sim_lib/stratixii_atoms.v}
vlog  -work rtl_work {c:/programs/altera/12.1sp1/quartus/eda/sim_lib/stratixiigx_hssi_atoms.v}


##### DDR2 Interface stuff
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_seq_wrapper.v}
vcom  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_seq.vhd}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_controller_phy.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_reconfig.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy_pll.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_phy_alt_mem_phy.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/Ddr2SdramIf_alt_mem_ddrx_controller_top.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_controller_st_top.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_controller.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_timing_param.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_mm_st_converter.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_input_if.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_cmd_gen.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_tbp.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_arbiter.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_burst_gen.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_addr_cmd_wrap.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_rdwr_data_tmg.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_wdata_path.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_rdata_path.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_sideband.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_rank_timer.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_list.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_burst_tracking.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_dataid_manager.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_fifo.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_addr_cmd.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_odt_gen.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_buffer.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_ecc_encoder.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_ecc_decoder.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_ddr2_odt_gen.v}
vlog  -work rtl_work {D:/Users/musico/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4/Mpd4/Ddr2SdramIf/alt_mem_ddrx_ddr3_odt_gen.v}


##### Simulate
vsim -t 1ps -L rtl_work -L work -novopt  Ddr2SdramIf_example_top_tb

do wave_ex.do

run 225us
