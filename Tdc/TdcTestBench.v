`timescale 1ns/100ps

module TdcTestBench;

parameter master_ck_period = 25;
parameter master_ck_half_period = master_ck_period / 2;
parameter master_ck_hold  = 1;	// data hold time

parameter fast_ck_period = 4;
parameter fast_ck_half_period = fast_ck_period / 2;
parameter fast_ck_hold  = 0.5;	// data hold time

reg Master_clock, Fast_clock, Master_resetB;
reg trig_pulse;
reg fast_clock;
wire [7:0] trig_time;
wire time_valid;

//	LoResTdc Dut(.CLK(Fast_clock), .RSTb(Master_resetB), .START(Master_clock), .STOP(trig_pulse), .TIME(trig_time), .VALID(time_valid));
	HiResTdc Dut(.CLK(Fast_clock), .RSTb(Master_resetB), .START(Master_clock), .STOP(trig_pulse), .TIME(trig_time), .VALID(time_valid));
	

	// Time 0 values
initial
begin
	Master_clock = 0;
	Fast_clock = 0;
	Master_resetB = 1;
	trig_pulse = 0;
	fast_clock = 0;
end

// Main test vectors
initial
begin
	Sleep(2);
	issue_RESET;
	Sleep(20);

	trig_pulse = 1;
	Sleep(1);
	trig_pulse = 0;
	
	#(master_ck_period + 5);
	trig_pulse = 1;
	Sleep(1);
	trig_pulse = 0;
	#(master_ck_period - 5);

	#(master_ck_period + 9);
	trig_pulse = 1;
	Sleep(1);
	trig_pulse = 0;
	#(master_ck_period - 9);

	#(master_ck_period + 13);
	trig_pulse = 1;
	Sleep(1);
	trig_pulse = 0;
	#(master_ck_period - 13);
	
end




  // Clock generator: free running
  initial
  begin
    #(master_ck_period-master_ck_hold)	Master_clock <= ~Master_clock;
    forever
      #master_ck_half_period	Master_clock <= ~Master_clock;
  end

  initial
  begin
    #(fast_ck_period-fast_ck_hold)	Fast_clock <= ~Fast_clock;
    forever
      #fast_ck_half_period	Fast_clock <= ~Fast_clock;
  end




// User tasks
task Sleep;
input [31:0] waittime;
begin
	repeat(waittime)
		#master_ck_period;
end
endtask // Sleep
 
task issue_RESET;
begin
	#master_ck_period Master_resetB = 0;
	#master_ck_period;
	#master_ck_period;
	#master_ck_period;
	#master_ck_period Master_resetB = 1;
	#master_ck_period;
end
endtask // issue_RESET


endmodule
