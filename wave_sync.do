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
add wave -noupdate -divider {User Signals}
add wave -noupdate -label user_addr -radix hexadecimal /_a_TestBench/Dut/user_addr
add wave -noupdate -label user_data -radix hexadecimal /_a_TestBench/Dut/user_d
add wave -noupdate -label user_ceB -radix hexadecimal /_a_TestBench/Dut/user_ceB
add wave -noupdate -label user_weB /_a_TestBench/Dut/user_weB
add wave -noupdate -label user_oeB /_a_TestBench/Dut/user_oeB
add wave -noupdate -label user_reB /_a_TestBench/Dut/user_reB
add wave -noupdate -label user_waitB /_a_TestBench/Dut/Vme_user_waitB
add wave -noupdate -divider ADC
add wave -noupdate -label CONV_CK1 /_a_TestBench/Dut/ADC_CONV_CK1
add wave -noupdate -label ADC_DATA -radix hexadecimal /_a_TestBench/Dut/ADC_DATA
add wave -noupdate -label LCLK1 /_a_TestBench/Dut/ADC_LCLK1
add wave -noupdate -label ADC_FRAME_CK1 /_a_TestBench/Dut/ADC_FRAME_CK1
add wave -noupdate -label {Pdata 0} -radix hexadecimal /_a_TestBench/Dut/AdcDeser0/Deser0/PDATA
add wave -noupdate -divider {SYNC 8}
add wave -noupdate -label PeriodCounter -radix hexadecimal /_a_TestBench/Dut/ApvProcessor_8_15/Ch0/ApvFrameDecoder/SyncDetector/period_cnt
add wave -noupdate -label SyncCounter -radix hexadecimal /_a_TestBench/Dut/ApvProcessor_8_15/Ch0/ApvFrameDecoder/SyncDetector/sync_cnt
add wave -noupdate -label Synced /_a_TestBench/Dut/ApvProcessor_8_15/Ch0/ApvFrameDecoder/SyncDetector/SYNCED
add wave -noupdate -label Period -radix hexadecimal /_a_TestBench/Dut/ApvProcessor_8_15/Ch0/ApvFrameDecoder/SyncDetector/PERIOD
add wave -noupdate -label Zero /_a_TestBench/Dut/ApvProcessor_8_15/Ch0/ApvFrameDecoder/SyncDetector/ZERO
add wave -noupdate -label One /_a_TestBench/Dut/ApvProcessor_8_15/Ch0/ApvFrameDecoder/SyncDetector/ONE
add wave -noupdate -label Enable /_a_TestBench/Dut/ApvProcessor_8_15/Ch0/ApvFrameDecoder/SyncDetector/ENABLE
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51940800 ps} 0} {{Cursor 2} {737334 ps} 0}
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
WaveRestoreZoom {50333014 ps} {52878470 ps}
