if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

if {[file exists arriagx_hssi]} {
	vdel -lib arriagx_hssi -all
}
vlib arriagx_hssi

if {[file exists altera_mf]} {
	vdel -lib altera_mf -all
}

vlib altera_mf

vcom  -work altera_mf  {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/altera_mf_components.vhd}
vcom  -work altera_mf  {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/220pack.vhd}
vcom  -work altera_mf  {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/sgate_pack.vhd}

#vcom  -work arriagx_hssi  {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/sgate.vhd}
vcom  -work arriagx_hssi  {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/arriagx_hssi_components.vhd}
vcom  -work arriagx_hssi {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/arriagx_hssi_atoms.vhd}

vcom -work work {./mpd_fiber/mpd_fiber_interface.vhd}
vcom -work work {./mpd_fiber/mpd_fiber_rx_eventflowcontrol.vhd}
#vcom -work work {./mpd_fiber/mpd_fiber_slave.vhd}
vcom -work work {./mpd_fiber/mpd_fiber_tx_event.vhd}
vcom -work work {./mpd_fiber/mpd_fiber_tx_arbiter.vhd}
vcom -work work {./mpd_fiber/mpd_fiber_reg_slave.vhd}
vcom -work work {./mpd_fiber/mpd_fiber_reg_slave_rx_sm.vhd}
vcom -work work {./mpd_fiber/mpd_fiber_reg_slave_tx_sm.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_8b10b_arria_gxb.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_8b10b_v5_3_transceiver_wrapper.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/FD.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/FDR.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/SRL16.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/gxb_bytealign.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/gxb_clockcompensate.vhd}
vcom -work work {./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/gxb_transceiver.vho}

vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_aurora_lane.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_aurora_pkg.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_channel_err_detect.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_channel_init_sm.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_chbond_count_dec.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_err_detect.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_global_logic.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_idle_and_ver_gen.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_lane_init_sm.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_rx_ll.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_rx_ll_pdu_datapath.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_standard_cc_module.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_sym_dec.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_sym_gen.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_tx_ll.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_tx_ll_control.vhd
vcom -work work ./mpd_fiber/aurora_8b10b_1lane_2_5G_arria_gxb/aurora_src/aurora_8b10b_v5_3_tx_ll_datapath.vhd

