transcript on

if {[file exists altera_lib]} {
	vdel -lib altera_lib -all
}

vlib altera_lib

vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/altera_mf.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/220model.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/sgate.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/arriagx_atoms.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/arriagx_hssi_atoms.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/altera_primitives.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/stratixgx_mf.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/stratixii_atoms.v}
vlog -vlog01compat -work altera_lib {c:/programs/altera/13.0sp1/quartus/eda/sim_lib/stratixiigx_hssi_atoms.v}

