/* QUESTASIM commands:
*  cd C:/Users/musico/Documents/INFN/Jlab12/Fpga_Mpd3_Mpd4/Fpga_4_Fiber/Sort
*  vlog -work work ./Sorter.v
*  vlog -work work ./TestBench.v
*  vsim -novopt work._a_TestBench
*/

module _a_TestBench;
parameter wid = 9;
parameter dep = 11;

reg clk, rst, valid;
reg [wid-1:0] din;
wire [7:0] n_cells;

Sorter #(wid,dep) Dut(.CLK(clk), .RST(rst), .DIN(din), .VALID(valid), .DO(), .N_CELLS(n_cells));


// Time 0 values
initial
begin
	clk = 0;
	rst = 0;
	valid = 0;
	din = 0;
	
end

// Main test vectors
initial
begin
	#60 rst = 1;
	#20 rst = 0;
	    valid = 1;
	    din = 55;
	#20 din = 10;
	#20 din = 77;
	#20 din = 1;
	#20 din = 60;
	#20 din = 10;
		
	#20 din = 255;
	#60	valid = 0;
	
	#60 $stop;
end

// Free running clock generator
initial
begin
	#8
	forever
		#10 clk = ~clk;
end
	
endmodule

