
#vsim -t 1ps -L altera_lib -L altera_ip -L rtl_work -L work -novopt _a_TestBench -voptargs="+acc"
#vsim -t 1ps -L altera_mf -L altera_lib -L altera_ip -L arriagx_hssi -L rtl_work -L work -novopt _a_TestBench
vsim -t 1ps -L altera_mf -L altera_lib -L altera_ip -L arriagx_hssi -L rtl_work -L work -voptargs="+acc" _a_TestBench

do wave.do

view structure
view signals
run -all
