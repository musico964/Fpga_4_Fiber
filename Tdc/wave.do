onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label RSTb /TdcTestBench/Dut/RSTb
add wave -noupdate -label START /TdcTestBench/Dut/START
add wave -noupdate -label STOP /TdcTestBench/Dut/STOP
add wave -noupdate -label TIME -radix hexadecimal /TdcTestBench/Dut/TIME
add wave -noupdate -label VALID /TdcTestBench/Dut/VALID
add wave -noupdate -label clear /TdcTestBench/Dut/clear
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {733978 ps} 0}
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
WaveRestoreZoom {641333 ps} {897333 ps}
