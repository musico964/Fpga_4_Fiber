onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {VME SIDE}
add wave -noupdate -label A -radix hexadecimal /_a_TestBenchVme/Dut/VME_A
add wave -noupdate -label AM -radix hexadecimal /_a_TestBenchVme/Dut/VME_AM
add wave -noupdate -label D -radix hexadecimal /_a_TestBenchVme/Dut/VME_D
add wave -noupdate -label ASb /_a_TestBenchVme/Dut/VME_ASb
add wave -noupdate -label DS1b /_a_TestBenchVme/Dut/VME_DS1b
add wave -noupdate -label DS0b /_a_TestBenchVme/Dut/VME_DS0b
add wave -noupdate -label WRITEb /_a_TestBenchVme/Dut/VME_WRITEb
add wave -noupdate -label LWORDb /_a_TestBenchVme/Dut/VME_LWORDb
add wave -noupdate -label DTACK /_a_TestBenchVme/Dut/VME_DTACK
add wave -noupdate -label BERR /_a_TestBenchVme/Dut/VME_BERR
add wave -noupdate -label RETRY /_a_TestBenchVme/Dut/VME_RETRY
add wave -noupdate -divider {USER SIDE}
add wave -noupdate -label USER_ADDR -radix hexadecimal /_a_TestBenchVme/Dut/USER_ADDR
add wave -noupdate -label USER_DIN -radix hexadecimal /_a_TestBenchVme/Dut/USER_DATA_IN
add wave -noupdate -label USER_DOUT -radix hexadecimal /_a_TestBenchVme/Dut/USER_DATA_OUT
add wave -noupdate -label USER_WEb /_a_TestBenchVme/Dut/USER_WEb
add wave -noupdate -label USER_REb /_a_TestBenchVme/Dut/USER_REb
add wave -noupdate -label USER_OEb /_a_TestBenchVme/Dut/USER_OEb
add wave -noupdate -label USER_CEb -radix hexadecimal /_a_TestBenchVme/Dut/USER_CEb
add wave -noupdate -divider CycleController
add wave -noupdate -label internal_detect /_a_TestBenchVme/Dut/internal_detect
add wave -noupdate -label IncrAddrCounter /_a_TestBenchVme/Dut/DataCycleController/INCR_ADDR_COUNTER
add wave -noupdate -color Magenta -label fsm_status -radix unsigned /_a_TestBenchVme/Dut/DataCycleController/status
add wave -noupdate -label LdBeatCounter /_a_TestBenchVme/Dut/DataCycleController/ld_beat_counter
add wave -noupdate -label DecrBeatCounter /_a_TestBenchVme/Dut/DataCycleController/decr_beat_counter
add wave -noupdate -label BeatCounter -radix hexadecimal /_a_TestBenchVme/Dut/DataCycleController/beat_counter
add wave -noupdate -label RateCode -radix hexadecimal /_a_TestBenchVme/Dut/DataCycleController/rate_code
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3902950 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {15496230 ps} {15844158 ps}
