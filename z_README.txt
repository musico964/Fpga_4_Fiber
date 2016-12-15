Compilation steps for MODELSIM simulation of FPGA revision 4.0, for MPD 4.0:

In ModelSim console run the following:

cd C:/Users/musico/Documents/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4_Fiber
# cd /home/musico/Documents/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4_Fiber

do z_01CompileAlteraLibs_ModelSim.do	# Creates altera_lib with all needed atoms
do z_02CompileAlteraIP_ModelSim.do	# Creates altera_ip with all used IP blocks
do z_03CompileRtl_ModelSim.do		# Creates rtl_work wuth all user code

do z_04Run_ModelSim.do			# Run the simulation


