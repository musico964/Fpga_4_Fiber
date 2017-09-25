##
##Legal Notice: (C)2007 Altera Corporation. All rights reserved. Your
##use of Altera Corporation's design tools, logic functions and other
##software and tools, and its AMPP partner logic functions, and any
##output files any of the foregoing (including device programming or
##simulation files), and any associated documentation or information are
##expressly subject to the terms and conditions of the Altera Program
##License Subscription Agreement or other applicable license agreement,
##including, without limitation, that your use is for the sole purpose
##of programming logic devices manufactured by Altera and sold by Altera
##or its authorized distributors. Please refer to the applicable
##agreement for further details.

if { ![info exists quartus(nameofexecutable)] || $quartus(nameofexecutable) != "quartus_sta" } {
	puts "Restarting in quartus_sta..."

	set cmd quartus_sta
	if { [info exists quartus(binpath)] } {
		set cmd [file join $quartus(binpath) $cmd]
	}

	set res [catch { exec $cmd -t [info script] batch } output]

	# This procedure is 'clever' in that it will write a message using
	# post_message if available and refert to puts otherwise.
	# if post_message fails, this procedure changes itself into one that
	# uses a simple 'puts' and continues.
	proc out { msg } {
		set type info
		regexp {^\W*(Info|Extra Info|Warning|Critical Warning|Error): (.*)$} $msg x type msg
		regsub " " $type _ type
		if { [catch { post_message -type $type $msg } res] } {
			proc out { msg } {puts $msg}
			out $msg
		}
	}

	foreach line [split $output \n] {
		out $line
	}
	return 0
}

set scriptname [info script]
if { ! [regexp (.*)_report_timing.tcl $scriptname _ corename] } {
	error "Couldn't determine corename from $scriptname"
}

if {[namespace which -variable ::argv] != "" && [lindex $::argv 0] == "batch" } {
	post_message -type info "Running in batch mode"

	set batch_mode_en 1
	set proj_name [glob *.qpf]
	if { ! [is_project_open] } {
		project_open -revision [get_current_revision $proj_name] $proj_name
	}

	catch {delete_timing_netlist }
	create_timing_netlist
	read_sdc

	set opcs [list]
	foreach_in_collection op [get_available_operating_conditions] {
		lappend opcs $op
	}

	update_timing_netlist
} else {
	set batch_mode_en 0
	set opcs [list ""]
}

set fpga_tREAD_CAPTURE_SETUP_ERROR 0
set fpga_tREAD_CAPTURE_HOLD_ERROR 0
set fpga_RESYNC_SETUP_ERROR 0
set fpga_RESYNC_HOLD_ERROR 0
set fpga_PA_DQS_SETUP_ERROR 0
set fpga_PA_DQS_HOLD_ERROR 0
set WR_DQS_DQ_SETUP_ERROR 0
set WR_DQS_DQ_HOLD_ERROR 0
set fpga_tCK_ADDR_CTRL_SETUP_ERROR 0
set fpga_tCK_ADDR_CTRL_HOLD_ERROR 0
set fpga_tDQSS_SETUP_ERROR 0
set fpga_tDQSS_HOLD_ERROR 0
set fpga_tDSSH_SETUP_ERROR 0
set fpga_tDSSH_HOLD_ERROR 0
set write_deskew_mode "none"
set read_deskew_mode "none"
set write_deskew_t10 0
set write_deskew_hc_t10 0
set write_deskew_t9i 0
set write_deskew_hc_t9i 0
set write_deskew_t9ni 0
set write_deskew_hc_t9ni 0
set write_deskew_range 0

set period 5.263

proc ddr_pin {n pin pin_array_name} {
	upvar 1 $pin_array_name pins
	lappend pins($n) $pin
}

load_package report
load_report

if { ! [timing_netlist_exist] } {
	post_message -type error "Timing Netlist has not been created. Run the 'Update Timing Netlist' task first."
	return
}

source "${corename}_ddr_pins.tcl"

set corename [file tail $corename]
set instance_names [get_core_full_instance_list $corename]

for {set inst_index 0} {$inst_index != [llength $instance_names]} {incr inst_index} {
	set full_instance_name [lindex $instance_names $inst_index]
	set instance_name [get_timequest_name $full_instance_name]
	set instname "${instance_name}|${corename}"

	global TimeQuestInfo
	set family $TimeQuestInfo(family)

	set pins(ck_p) [list]
	set pins(ck_n) [list]
	set pins(addrcmd) [list]
	set pins(addrcmd_2t) [list]
	set pins(dqsgroup) [list]
	set pins(dgroup) [list]
	get_ddr_pins $instname pins
	# Find all the DQ pins
	set alldqpins [list]
	set alldqdmpins [list]
	set alldqspins [list]
	foreach dqsgroup $pins(dqsgroup) {
		set alldqpins [concat $alldqpins [lindex $dqsgroup 2]]
		set alldqdmpins [concat $alldqdmpins [lindex $dqsgroup 2] [lindex $dqsgroup 1]]
		lappend alldqspins [lindex $dqsgroup 0]
	}

	set summary [list]
	foreach opc $opcs {
		if {$opc != "" } {
			set_operating_conditions $opc 
			update_timing_netlist
		}

		set opcname [get_operating_conditions_info [get_operating_conditions] -display_name]
		set opcname [string trim $opcname]

# Write
set res_0 [report_timing -detail full_path -to [get_ports $alldqdmpins] -npaths 100 -panel_name "$instname Write \u0028setup\u0029" -setup]
set res_1 [report_timing -detail full_path -to [get_ports $alldqdmpins] -npaths 100 -panel_name "$instname Write \u0028hold\u0029" -hold]
lappend summary [list $opcname 0 "Write ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]

# Address Command
set res_0 [report_timing -detail full_path -to $pins(addrcmd) -npaths 100 -panel_name "$instname Address Command \u0028setup\u0029" -setup]
set res_1 [report_timing -detail full_path -to $pins(addrcmd) -npaths 100 -panel_name "$instname Address Command \u0028hold\u0029" -hold]
lappend summary [list $opcname 0 "Address Command ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]

# Half Rate Address/Command
set res_0 [report_timing -detail full_path -to $pins(addrcmd_2t) -npaths 100 -panel_name "$instname Half Rate Address/Command \u0028setup\u0029" -setup]
set res_1 [report_timing -detail full_path -to $pins(addrcmd_2t) -npaths 100 -panel_name "$instname Half Rate Address/Command \u0028hold\u0029" -hold]
lappend summary [list $opcname 0 "Half Rate Address/Command ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]

# DQS vs CK
set res_0 [report_timing -detail full_path -to [get_ports $alldqspins] -npaths 100 -panel_name "$instname DQS vs CK \u0028setup\u0029" -setup]
set res_1 [report_timing -detail full_path -to [get_ports $alldqspins] -npaths 100 -panel_name "$instname DQS vs CK \u0028hold\u0029" -hold]
lappend summary [list $opcname 0 "DQS vs CK ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]

# Read Capture
set res_0 [report_timing -detail full_path -from [get_ports $alldqpins] -to_clock [get_clocks "${instname}_ddr_dqsin_*"] -npaths 100 -panel_name "$instname Read Capture \u0028setup\u0029" -setup]
set res_1 [report_timing -detail full_path -from [get_ports $alldqpins] -to_clock [get_clocks "${instname}_ddr_dqsin_*"] -npaths 100 -panel_name "$instname Read Capture \u0028hold\u0029" -hold]
lappend summary [list $opcname 0 "Read Capture ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]


################################################################################
# The resynchronization timing analysis concerns transferring read data that
# has been captured with a DQS strobe to a clock domain under the control of
# the ALTMEMPHY. We use a dedicated PLL phase that is calibrated by the
# sequencer, and tracks any movements in the data valid window of the captured
# data. This means that the exact length of the DQS and CK traces don't affect
# the timing analysis, and the calibration will remove any static offset from
# the rest of the path too. With static offset removed, the remaining
# uncertainties with be limited to VT variation, jitter and skew (since one
# clock phase is chosen for the whole interface).
# 
# The implementation of this timing analysis is a little more involved, since
# there is no way to express a skew constraint in SDC scripts. We need to first
# of all make the fitter place the resync registers such that they have a low
# skew between them, and then make sure the timing is checked during sign off.
# Although the requirement is that this bus is low skew and it would be
# possible to route it all the way across the chip as long as all bits were the
# same length, in practice the best way to get a low skew is to place all the
# resync registers as close as possible to the IOE.
# We force the fitter to place the registers as close as possible by applying
# an unachievable timing constraint on them. Because of the nature of the
# fitter's algorithms, this will not harm fitting elsewhere in the chip. The
# timing sign off however needs to have a different set of constraints, since
# there would otherwise be a set of failing paths in the design. It would be
# possible to simply cut the path, but that would have the effect of making the
# paths disappear altogether. We need to be able to find out how long they are
# to measure the skew, so the solution is to replace the unachievable
# constraint with a very loose one.
# 
# Since we don't have a proper constraint for sign off the ALTMEMPHY needs to
# provide its own analysis of this path. The code is generated in <variation_name>_report_timing.tcl,
# and this file is registered to be run automatically from the 'report DDR'
# button in TimeQuest's GUI, or alternatively by simply running:
# 
# source <variation_name>_report_timing.tcl
# 
# This does however mean that these paths are not checked by simply running a
# report of the worst case failing paths.
################################################################################

################################################################################
# The DQS strobe is used as a clock to capture the incoming data, but it is not
# a true clock since the DQS line will go tri-state at the end of a read burst.
# In order to prevent the read data from being corrupted by noise on the DQS
# strobe at the end of a read burst the DQS line is pulled low by special
# purpose postamble protection logic in the DQS block. This logic is held in
# reset until just before the final falling edge of DQS. Once the final edge of
# DQS arrives the logic is activated and the DQS strobe is disabled. The
# important postamble timing path goes to the register that is clocked by the
# falling edge of DQS.
# 
# The series of events during operation of the postamble block are as follows:
#  * The doing-a-read-burst signal is high, and the postamble enable register
# (bottom left) is held in preset
#  * The penultimate falling DQS edge happens. The postamble enable register is
# unaffected, since it is in preset
#  * The preset signal is released
#  * The final falling edge of the DQS burst happens, and the postamble enable
# register is clocked
#  * The input to the enable register is tied to ground, and so the and-gate
# disables the DQS clock.
# The control signal for the postamble is not calibrated specifically. It is
# driven from the inverted resync clock, which is calibrated for the purposes
# of resync only.
# 
# The output of the postamble control register must reach the postamble enable
# register before the last falling edge of DQS in order that the postamble
# protection logic is triggered. This puts a constraint on the sum of the delay
# from the DDIO to resync registers plus the delay from the postamble control
# register to the DQS DDIO.
# There is also a constraint that the postamble control must be released after
# the penultimate falling edge of DQS. Since the DQS clock and the resync clock
# are nominally aligned, there is a possibility of hold timing race conditions.
# In practice this is rarely an issue, since the delay getting into and out of
# the IOE is significant.
# 
# The timing analysis for postamble requires us to use the fact that the resync
# path has been set up by the sequencer. The postamble path needs to be
# statically analyzed, since it is not dynamically calibrated like resync.
# 
# The postamble control register is driven by the resync clock, and we know
# that the clock phase will be shifted by the sequencer to balance the resync
# setup and hold margins.
# 
# Let's assume for a moment that we guessed a resync phase during compilation
# that was exactly the same setting that the dynamic sequencer would pick after
# doing the auto calibration sweep. If we also assume that the resync timing
# analysis give balanced setup and hold times, then the postamble timing path
# would be a simple case for static timing analysis.
# 
# In fact we don't know the resync phase during compilation, but we can find
# out the phase shift that will be applied to the resync clock after compilation
# has finished. Since we can work out what the data valid window at the resync
# registers will be relative to the DQS input pins, and we know that the
# sequencer will put the resync clock in the centre on this window, we can
# apply an offset to the default static timing analysis to account for the
# sequencer's behavior.
################################################################################
# sequencer 0.492
# tDQSCK 0.8
# tDQS_CLK_SKEW_ADDER 0.11
# tDQS_PHASE_JITTER 0.09
set resync_uncertainty 1.492
# sequencer 0.246
# tDQSCK 0.4
# tDQS_CLK_SKEW_ADDER 0.055
# tDQS_PHASE_JITTER 0.045
set postamble_uncertainty 0.746
set offset 100.000
set raw_resync_setup_slack -1000
set raw_resync_hold_slack -1000
set raw_postamble_setup_slack -1000
set raw_postamble_hold_slack -1000
set ideal_resync_phase_offset -1000

# Get worst case paths
set paths [get_timing_paths -npaths 1 -setup -from [get_clocks ${instname}_ddr_dqsin*] -to [get_clocks ${instname}_ddr_resync]]
foreach_in_collection resync_setup_path $paths {
  set slack [get_path_info $resync_setup_path -slack]
  # set raw_resync_setup_slack [expr {$slack-$offset+$period}] (why +period?)
  set raw_resync_setup_slack [expr {$slack-$offset}]
  post_message -type info "Worst case Resync setup path is from [get_node_info -name [get_path_info -from $resync_setup_path]] to [get_node_info -name [get_path_info -to $resync_setup_path]]"
}
set paths [get_timing_paths -npaths 1 -hold -from [get_clocks ${instname}_ddr_dqsin*] -to [get_clocks ${instname}_ddr_resync]]
foreach_in_collection resync_hold_path $paths {
  set slack [get_path_info $resync_hold_path -slack]
  set raw_resync_hold_slack [expr {$slack-$offset}]
  set source_ff [get_node_info -name [get_path_info -from $resync_hold_path]]
  set dest_ff [get_node_info -name [get_path_info -to $resync_hold_path]]
  post_message -type info "Worst case Resync hold path is from $source_ff to $dest_ff"
}
set paths [get_timing_paths -npaths 1 -recovery -from [get_clocks ${instname}_ddr_postamble] -to [get_clocks ${instname}_ddr_dqsin*]]
set raw_postamble_setup_slack ""
foreach_in_collection postamble_setup_path $paths {
  set slack [get_path_info  $postamble_setup_path -slack]
  set raw_postamble_setup_slack [expr {$slack-$offset}]
  post_message -type info "Worst case Read Postamble setup path is from [get_node_info -name [get_path_info -from $postamble_setup_path]] to [get_node_info -name [get_path_info -to $postamble_setup_path]]"
}
set paths [get_timing_paths -npaths 1 -removal -from [get_clocks ${instname}_ddr_postamble] -to [get_clocks ${instname}_ddr_dqsin*]]
foreach_in_collection postamble_hold_path $paths {
  set slack [get_path_info  $postamble_hold_path -slack]
  set raw_postamble_hold_slack [expr {$slack-$offset}]
  post_message -type info "Worst case Read Postamble hold path is from [get_node_info -name [get_path_info -from $postamble_hold_path]] to [get_node_info -name [get_path_info -to $postamble_hold_path]]"
}
set ideal_resync_phase_offset [expr (-$raw_resync_setup_slack + $raw_resync_hold_slack)*0.5]
set resync_slack [expr {$raw_resync_hold_slack + $raw_resync_setup_slack - $resync_uncertainty - $fpga_RESYNC_SETUP_ERROR - $fpga_RESYNC_HOLD_ERROR}]
# Ideal setup slack is (raw_resync_setup_slack + raw_resync_hold_slack) / 2
# Need to adjust phase by (ideal_setup_slack - raw_resync_setup_slack)
#post_message -type info "($opcname)Raw resync setup slack = $raw_resync_setup_slack"
#post_message -type info "($opcname)Raw resync hold slack = $raw_resync_hold_slack"
# post_message -type info "($opcname)Resync skew is [expr $max_raw_resync_setup_slack - $raw_resync_setup_slack] ns"
#post_message -type info "($opcname)Ideal resync phase offset = $ideal_resync_phase_offset"
#post_message -type info "($opcname)Raw Read Postamble Setup Slack = $raw_postamble_setup_slack"
#post_message -type info "($opcname)Raw Read Postamble Hold Slack = $raw_postamble_hold_slack"
set postamble_setup_slack [expr {$raw_postamble_setup_slack - $postamble_uncertainty - $ideal_resync_phase_offset - $fpga_PA_DQS_SETUP_ERROR}]
set postamble_hold_slack [expr {$raw_postamble_hold_slack - $postamble_uncertainty + $ideal_resync_phase_offset - $fpga_PA_DQS_HOLD_ERROR}]
set marginby2 [expr {$resync_slack*0.5}]
lappend summary [list $opcname 0 "Read Resync ($opcname)" $marginby2 $marginby2]
lappend summary [list $opcname 0 "Read Postamble ($opcname)" $postamble_setup_slack $postamble_hold_slack]
# Read postamble enable/disable
set min_postamble_loop_delay 1000
set max_postamble_loop_delay -1000
foreach_in_collection postamble_reg [get_nodes ${full_instance_name}|*|dqs[*].dqs_io~regout] {
  set postamble_reg_name [get_node_info -name $postamble_reg]
  set utco [get_register_info -tco $postamble_reg]
  set max_path_delay [lindex [report_path -from $postamble_reg_name -to $postamble_reg_name] 1]
  if {[expr $max_path_delay + $utco] > $max_postamble_loop_delay} {
    set max_postamble_loop_delay $max_path_delay
    set max_postamble_loop_reg_name $postamble_reg_name
    set max_postamble_loop_reg_utco $utco
  }
  set min_path_delay [lindex [report_path -from $postamble_reg_name -to $postamble_reg_name -min_path] 1]
  if {[expr $min_path_delay + $utco] < $min_postamble_loop_delay} {
    set min_postamble_loop_delay $min_path_delay
    set min_postamble_loop_reg_name $postamble_reg_name
    set min_postamble_loop_reg_utco $utco
  }
}
# tRPST is a memory spec
set tRPST [round_3dp [expr $period * 0.4]]
report_path -from $max_postamble_loop_reg_name -to $max_postamble_loop_reg_name -panel "$instname Postamble Enable/Disable (setup)"
set postamble_enable_setup_formula "$tRPST - $max_postamble_loop_delay - $max_postamble_loop_reg_utco"
set postamble_enable_setup_margin [eval expr $postamble_enable_setup_formula]
report_path -from $min_postamble_loop_reg_name -to $min_postamble_loop_reg_name -min_path -panel "$instname Postamble Enable/Disable (hold)"
set postamble_enable_hold_formula "$min_postamble_loop_delay + $min_postamble_loop_reg_utco"
set postamble_enable_hold_margin [eval expr $postamble_enable_hold_formula]
post_message -type info "$instname Postamble Enable/Disable Setup Margin ($opcname) is $postamble_enable_setup_formula = $postamble_enable_setup_margin"
post_message -type info "$instname Postamble Enable/Disable Hold Margin ($opcname) is $postamble_enable_hold_formula = $postamble_enable_hold_margin"
lappend summary [list $opcname 0 "Read Postamble Enable/Disable ($opcname)" $postamble_enable_setup_margin $postamble_enable_hold_margin]
# Phy
set res_0 [report_timing -detail full_path -to [get_registers  "$full_instance_name|*" ] -npaths 100 -panel_name "$instname Phy \u0028setup\u0029" -setup]
set res_1 [report_timing -detail full_path -to [get_registers  "$full_instance_name|*" ] -npaths 100 -panel_name "$instname Phy \u0028hold\u0029" -hold]
lappend summary [list $opcname 0 "Phy ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]

# Phy Reset
set res_0 [report_timing -detail full_path -to [get_registers  "$full_instance_name|*" ] -npaths 100 -panel_name "$instname Phy Reset \u0028recovery\u0029" -recovery]
set res_1 [report_timing -detail full_path -to [get_registers  "$full_instance_name|*" ] -npaths 100 -panel_name "$instname Phy Reset \u0028removal\u0029" -removal]
lappend summary [list $opcname 0 "Phy Reset ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]

# Mimic
set res_1 [list xxx ""]
set res_0 [report_timing -detail full_path -from $pins(ck_p) -to * -npaths 100 -panel_name "$instname Mimic \u0028setup\u0029" -setup]
lappend summary [list $opcname 0 "Mimic ($opcname)" [lindex $res_0 1] [lindex $res_1 1]]

set full_instname "${full_instance_name}|${corename}"
set all_read_dqs_list [get_all_dqs_pins $pins(dqsgroup)]
set interface_type [get_io_interface_type $all_read_dqs_list]
if {$interface_type == "VHPAD"} {
	set interface_type "HPAD"
}

if {[string compare -nocase $family "Arria II GX"] == 0 || [string compare -nocase $family "Arria II"] == 0} {
	set family "Arria II"
}

}
set opcname "All Conditions"
proc sort_proc {a b} {
	set idxs [list 1 2 0]
	foreach i $idxs {
		set ai [lindex $a $i]
		set bi [lindex $b $i]
		if {$ai > $bi} {
			return 1
		} elseif { $ai < $bi } {
			return -1
		}
	}
	return 0
}

set summary [lsort -command sort_proc $summary]
if {[llength $instance_names] <= 1} {
	set f [open "${corename}_summary.csv" w]
} else {
	set f [open "${corename}${inst_index}_summary.csv" w]
}
puts $f "#Path, Setup Margin, Hold Margin"
post_message -type info "                                                         setup  hold"
set panel_name "$instname"
set root_folder_name [get_current_timequest_report_folder]
if { ! [string match "${root_folder_name}*" $panel_name] } {
	set panel_name "${root_folder_name}||$panel_name"
}
# Create the root if it doesn't yet exist
if {[get_report_panel_id $root_folder_name] == -1} {
	set panel_id [create_report_panel -folder $root_folder_name]
}

# Delete any pre-existing summary panel
set panel_id [get_report_panel_id $panel_name]
if {$panel_id != -1} {
	delete_report_panel -id $panel_id
}

# Create summary panel
set panel_id [create_report_panel -table $panel_name]
add_row_to_table -id $panel_id [list "Path" "Operating Condition" "Setup Slack" "Hold Slack"] 
foreach summary_line $summary {
	foreach {corner order path su hold} $summary_line { }
		if { $su < 0 || ($hold!="" && $hold < 0) } {
			set type warning
			set offset 50
		} else {
			set type info
			set offset 53
		}
		set su [format %.3f $su]
		if {$hold != ""} {
			set hold [format %.3f $hold]
		}
		post_message -type $type [format "%-${offset}s | %6s %6s" $path $su $hold]
		puts $f [format "\"%s\",%s,%s" $path $su $hold]
		set fg_colours [list black black]
		if { $su < 0 } {
			lappend fg_colours red
		} else {
			lappend fg_colours black
		}
		if { $hold != "" && $hold < 0 } {
			lappend fg_colours red
		} else {
			lappend fg_colours black
		}
		add_row_to_table -id $panel_id -fcolors $fg_colours [list $path $corner $su $hold] 
	}
	close $f
}
write_timing_report
if {$batch_mode_en == 1} {
	catch {delete_timing_netlist}
}
