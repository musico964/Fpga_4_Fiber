set f [open "CompileTime.v" "w"]
set t [clock seconds]
puts $f [format "`define COMPILE_TIME 32'h%08X" $t]
close $f
