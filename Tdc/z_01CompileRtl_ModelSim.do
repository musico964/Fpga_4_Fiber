cd D:/Users/musico/INFN/Jlab12/Vme_Rev4/Fpga_4/Tdc

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work {D:/Users/musico/INFN/Jlab12/Vme_Rev4/Fpga_4/Tdc/Tdc.v}

vlog -vlog01compat -work work {D:/Users/musico/INFN/Jlab12/Vme_Rev4/Fpga_4/Tdc/TdcTestBench.v}

vsim -L altera_ver -novopt work.TdcTestBench
