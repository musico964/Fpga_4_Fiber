onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {VME BUS}
add wave -noupdate -label VME_A -radix hexadecimal /_a_TestBench/Dut/VME_A
add wave -noupdate -label VME_D -radix hexadecimal /_a_TestBench/Dut/VME_D
add wave -noupdate -label WRITEb /_a_TestBench/Dut/VME_WRITEb
add wave -noupdate -label DS0b /_a_TestBench/Dut/VME_DS0b
add wave -noupdate -label ASb /_a_TestBench/Dut/VME_ASb
add wave -noupdate -label DTACKb /_a_TestBench/Dut/VME_DTACKb
add wave -noupdate -label BERRb /_a_TestBench/Dut/VME_BERRb
add wave -noupdate -label Vme_clock /_a_TestBench/Dut/Vme_clock
add wave -noupdate -label MASTER_CLOCK /_a_TestBench/Dut/MASTER_CLOCK
add wave -noupdate -label MASTER_CLOCK2 /_a_TestBench/Dut/MASTER_CLOCK2
add wave -noupdate -divider {User Signals}
add wave -noupdate -label user_addr -radix hexadecimal /_a_TestBench/Dut/user_addr
add wave -noupdate -label user_data -radix hexadecimal /_a_TestBench/Dut/user_d
add wave -noupdate -label user_ceB -radix hexadecimal /_a_TestBench/Dut/user_ceB
add wave -noupdate -label user_weB /_a_TestBench/Dut/user_weB
add wave -noupdate -label user_oeB /_a_TestBench/Dut/user_oeB
add wave -noupdate -label user_reB /_a_TestBench/Dut/user_reB
add wave -noupdate -label user_waitB /_a_TestBench/Dut/Vme_user_waitB
add wave -noupdate -divider Sdram
add wave -noupdate -label SdramInitialized /_a_TestBench/Sdram_Initialized
add wave -noupdate -label SdramCk /_a_TestBench/Sdram_ck
add wave -noupdate -label SdramRasB /_a_TestBench/Sdram_rasB
add wave -noupdate -label SdramCasB /_a_TestBench/Sdram_casB
add wave -noupdate -label SdramWeB /_a_TestBench/Sdram_weB
add wave -noupdate -label SdramDqs /_a_TestBench/Sdram_dqs
add wave -noupdate -label SdramDm /_a_TestBench/Sdram_dm
add wave -noupdate -label SdramOdt /_a_TestBench/Sdram_odt
add wave -noupdate -label SdramCsB /_a_TestBench/Sdram_csB
add wave -noupdate -label SdramCke /_a_TestBench/Sdram_cke
add wave -noupdate -label SdramBa -radix hexadecimal /_a_TestBench/Sdram_ba
add wave -noupdate -label SdramAddr -radix hexadecimal /_a_TestBench/Sdram_addr
add wave -noupdate -label SdramDq -radix hexadecimal /_a_TestBench/Sdram_dq
add wave -noupdate -label LocalWrReq /_a_TestBench/Dut/mem_local_write_req
add wave -noupdate -label LocalRdReq /_a_TestBench/Dut/mem_local_read_req
add wave -noupdate -label LocalReady /_a_TestBench/Dut/mem_local_ready
add wave -noupdate -label SdramLocWdata -radix hexadecimal -childformat {{{/_a_TestBench/Dut/mem_local_wdata[31]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[30]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[29]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[28]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[27]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[26]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[25]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[24]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[23]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[22]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[21]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[20]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[19]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[18]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[17]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[16]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[15]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[14]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[13]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[12]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[11]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[10]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[9]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[8]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[7]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[6]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[5]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[4]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[3]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[2]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[1]} -radix hexadecimal} {{/_a_TestBench/Dut/mem_local_wdata[0]} -radix hexadecimal}} -subitemconfig {{/_a_TestBench/Dut/mem_local_wdata[31]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[30]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[29]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[28]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[27]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[26]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[25]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[24]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[23]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[22]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[21]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[20]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[19]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[18]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[17]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[16]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[15]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[14]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[13]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[12]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[11]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[10]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[9]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[8]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[7]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[6]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[5]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[4]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[3]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[2]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[1]} {-radix hexadecimal} {/_a_TestBench/Dut/mem_local_wdata[0]} {-radix hexadecimal}} /_a_TestBench/Dut/mem_local_wdata
add wave -noupdate -label SdarmUserData -radix hexadecimal /_a_TestBench/Dut/Sdram_User_Data
add wave -noupdate -label LocRdataLatched -radix hexadecimal /_a_TestBench/Dut/mem_local_rdata_latched
add wave -noupdate -label Sdram_ceB /_a_TestBench/Dut/Sdram_ceB
add wave -noupdate -label DataReadout_ceB /_a_TestBench/Dut/DataReadout_ceB
add wave -noupdate -label Vme_user_oeB /_a_TestBench/Dut/Vme_user_oeB
add wave -noupdate -label SdramLocAddr -radix hexadecimal /_a_TestBench/Dut/mem_local_addr
add wave -noupdate -label LocalRdataValid /_a_TestBench/Dut/mem_local_rdata_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {557286546 ps} 0} {{Cursor 2} {216000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 69
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {556998198 ps} {557359652 ps}
