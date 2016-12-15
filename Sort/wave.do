onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /_a_TestBench/clk
add wave -noupdate -label rst /_a_TestBench/rst
add wave -noupdate -label din -radix unsigned /_a_TestBench/din
add wave -noupdate -label valid /_a_TestBench/valid
add wave -noupdate -label n_cells -radix unsigned /_a_TestBench/n_cells
add wave -noupdate -label status /_a_TestBench/Dut/s
add wave -noupdate -label push /_a_TestBench/Dut/p
add wave -noupdate -label {dout[5]} -radix unsigned {/_a_TestBench/Dut/dout[5]}
add wave -noupdate -label {dout[4]} -radix unsigned {/_a_TestBench/Dut/dout[4]}
add wave -noupdate -label {dout[3]} -radix unsigned {/_a_TestBench/Dut/dout[3]}
add wave -noupdate -label {dout[2]} -radix unsigned {/_a_TestBench/Dut/dout[2]}
add wave -noupdate -label {dout[1]} -radix unsigned {/_a_TestBench/Dut/dout[1]}
add wave -noupdate -label {dout[0]} -radix unsigned {/_a_TestBench/Dut/dout[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50 ns} 0}
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
WaveRestoreZoom {124 ns} {310 ns}
