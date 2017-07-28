`timescale 100ps/1ps
/* Advanced version of ASD5281 to better emulate the APV frames.
 * APV data are stored in text file, 1 hex data per line. The file should have multiple of 128 values,
 * anyway at the end the file is rewinded.
 * For each incoming '100' APV_TRIGGER signal, 1 or 3 frames are generated
 * accordingly to APV_MODE (0 = 3 frames, 1 = 1 frame).
 *
 */

module ads5281_apv(APV_TRIGGER, APV_MODE, CLK, LCLK, ADCLK, OUT18);

input APV_TRIGGER;
input APV_MODE;		// 0 = 3 samples, 1 = 1 sample
input	CLK;
output	LCLK, ADCLK; 
output [7:0] OUT18;

parameter data_file_prefix = "apv_data";
parameter APV_ONE = 12'hB00;
parameter APV_ZERO = 12'h200;
parameter adc_deskew_pattern = 2'b00;
parameter adc_sync_pattern = 2'b01;
parameter adc_ApvSync_pattern = 2'b10;
parameter adc_ApvFrame_pattern = 2'b11;

reg [7:0] outX;
//reg [11:0] OutSr [7:0];	// 8 words, 12 bits each
reg [11:0] OutSr0, OutSr1, OutSr2, OutSr3, OutSr4, OutSr5, OutSr6, OutSr7;
reg [11:0] patcnt, tmpval;
wire clk1, clk6, clk12;
integer i, j, trigcnt;

reg [1:0] pattern;

integer apv_data_file [7:0];
reg file_error;
reg [8*32:1] filename;
reg [7:0] filename_suffix;

assign #8 OUT18 = outX;

assign #20 ADCLK = ~clk1;
assign #10 LCLK = clk6;

ADS5281_Pll Pll(.inclk0(CLK), .c0(clk1), .c1(clk6), .c2(clk12));

initial	// time 0 stuff
begin
	outX <= 0;
	patcnt <= 0;
	pattern <= adc_ApvSync_pattern;
	trigcnt <= 0;
	OutSr0 <= APV_ZERO; OutSr1 <= APV_ZERO; OutSr2 <= APV_ZERO; OutSr3 <= APV_ZERO;
	OutSr4 <= APV_ZERO; OutSr5 <= APV_ZERO; OutSr6 <= APV_ZERO; OutSr7 <= APV_ZERO;
	for(i=0; i<8; i=i+1)
	begin
		filename_suffix = 48+i;	// '0'+i
		filename = {data_file_prefix, filename_suffix, ".txt"};
//		$display("ASD5281_Apv(): opening datafile '%0s'", filename);
		apv_data_file[i] = $fopen(filename, "r");
		if( apv_data_file[i] == 0 )
		begin
			$display("ASD5281_Apv() ERROR: cannot open APV datafile '%s'", filename);
//			$stop;
		end
	end
end

always @(posedge clk12)	// output shift register
begin
	outX <= {OutSr7[0],OutSr6[0],OutSr5[0],OutSr4[0],OutSr3[0],OutSr2[0],OutSr1[0],OutSr0[0]};
	OutSr7 <= {OutSr7[0], OutSr7[11:1]};
	OutSr6 <= {OutSr6[0], OutSr6[11:1]};
	OutSr5 <= {OutSr5[0], OutSr5[11:1]};
	OutSr4 <= {OutSr4[0], OutSr4[11:1]};
	OutSr3 <= {OutSr3[0], OutSr3[11:1]};
	OutSr2 <= {OutSr2[0], OutSr2[11:1]};
	OutSr1 <= {OutSr1[0], OutSr1[11:1]};
	OutSr0 <= {OutSr0[0], OutSr0[11:1]};
end


always @(negedge clk1)	// trigger handling
begin
	if( APV_TRIGGER == 1 )
	begin
		@(negedge clk1)
		if( APV_TRIGGER == 0 )
		begin
			@(negedge clk1)
			if( APV_TRIGGER == 0 )
			begin
				trigcnt = trigcnt + 1;
				$display("ADS5281_Apv(): Trigger received @%0t, trigcnt = %d", $stime, trigcnt);
			end
		end
	end
/*	
	@(negedge clk1)
	if( trigcnt > 0 )
	begin
		if( pattern == adc_ApvSync_pattern )
			$display("ADS5281_Apv(): Switched to APV FRAME MODE @%0t, trigcnt = %d", $stime, trigcnt);
		pattern = adc_ApvFrame_pattern;
	end
	else
	begin
		if( pattern == adc_ApvFrame_pattern )
			$display("ADS5281_Apv(): Switched to APV SYNC MODE @%0t, trigcnt = %d", $stime, trigcnt);
		pattern = adc_ApvSync_pattern;
	end
*/
end

// APV frame and pulses
always @(negedge clk1)
begin
	if( trigcnt > 0 )
	begin
		if( pattern == adc_ApvSync_pattern )
			$display("ADS5281_Apv(): Switched to APV FRAME MODE @%0t, trigcnt = %d", $stime, trigcnt);
		pattern = adc_ApvFrame_pattern;
	end
	else
	begin
		if( pattern == adc_ApvFrame_pattern )
			$display("ADS5281_Apv(): Switched to APV SYNC MODE @%0t, trigcnt = %d", $stime, trigcnt);
		pattern = adc_ApvSync_pattern;
	end

	if( pattern == adc_ApvSync_pattern )
		ApvSync;
	if( pattern == adc_ApvFrame_pattern )
	begin
		ApvFrame;
		if( APV_MODE == 1'b0 )
		begin
			@(negedge clk1)
			ApvFrame;
			@(negedge clk1)
			ApvFrame;
		end
		if( trigcnt > 0 )
			trigcnt = trigcnt - 1;
	end
end

task ApvSync;
begin
//	$display("ASD5281_Apv(): ApvSync ONE = 0x%0x @%0t", OutSr0, $stime);
	#1 OutSr0 <= APV_ONE; OutSr1 <= APV_ONE; OutSr2 <= APV_ONE; OutSr3 <= APV_ONE;
	   OutSr4 <= APV_ONE; OutSr5 <= APV_ONE; OutSr6 <= APV_ONE; OutSr7 <= APV_ONE;
	@(negedge clk1);
//	$display("ASD5281_Apv(): ApvSync ZERO = 0x%0x @%0t", OutSr0, $stime);
	#1 OutSr0 <= APV_ZERO; OutSr1 <= APV_ZERO; OutSr2 <= APV_ZERO; OutSr3 <= APV_ZERO;
	   OutSr4 <= APV_ZERO; OutSr5 <= APV_ZERO; OutSr6 <= APV_ZERO; OutSr7 <= APV_ZERO;
	repeat( 33 )
		@(negedge clk1);
end
endtask // ApvSync

task ApvFrame;
begin
//	$display("ASD5281_Apv(): ApvFrame @%0t",$stime);
	#1 OutSr0 <= APV_ONE; OutSr1 <= APV_ONE; OutSr2 <= APV_ONE; OutSr3 <= APV_ONE;
	   OutSr4 <= APV_ONE; OutSr5 <= APV_ONE; OutSr6 <= APV_ONE; OutSr7 <= APV_ONE;
	repeat(3)
		@(negedge clk1);
	#1 OutSr0 <= APV_ZERO; OutSr1 <= APV_ZERO; OutSr2 <= APV_ZERO; OutSr3 <= APV_ZERO;
	   OutSr4 <= APV_ZERO; OutSr5 <= APV_ZERO; OutSr6 <= APV_ZERO; OutSr7 <= APV_ZERO;
	@(negedge clk1);
	#1 OutSr0 <= APV_ONE; OutSr1 <= APV_ONE; OutSr2 <= APV_ONE; OutSr3 <= APV_ONE;
	   OutSr4 <= APV_ONE; OutSr5 <= APV_ONE; OutSr6 <= APV_ONE; OutSr7 <= APV_ONE;
	@(negedge clk1);
	#1 OutSr0 <= APV_ZERO; OutSr1 <= APV_ZERO; OutSr2 <= APV_ZERO; OutSr3 <= APV_ZERO;
	   OutSr4 <= APV_ZERO; OutSr5 <= APV_ZERO; OutSr6 <= APV_ZERO; OutSr7 <= APV_ZERO;
	@(negedge clk1);
	#1 OutSr0 <= APV_ONE; OutSr1 <= APV_ONE; OutSr2 <= APV_ONE; OutSr3 <= APV_ONE;
	   OutSr4 <= APV_ONE; OutSr5 <= APV_ONE; OutSr6 <= APV_ONE; OutSr7 <= APV_ONE;
	@(negedge clk1);
	#1 OutSr0 <= APV_ZERO; OutSr1 <= APV_ZERO; OutSr2 <= APV_ZERO; OutSr3 <= APV_ZERO;
	   OutSr4 <= APV_ZERO; OutSr5 <= APV_ZERO; OutSr6 <= APV_ZERO; OutSr7 <= APV_ZERO;
	@(negedge clk1);
	#1 OutSr0 <= APV_ONE; OutSr1 <= APV_ONE; OutSr2 <= APV_ONE; OutSr3 <= APV_ONE;
	   OutSr4 <= APV_ONE; OutSr5 <= APV_ONE; OutSr6 <= APV_ONE; OutSr7 <= APV_ONE;
	@(negedge clk1);
	#1 OutSr0 <= APV_ZERO; OutSr1 <= APV_ZERO; OutSr2 <= APV_ZERO; OutSr3 <= APV_ZERO;
	   OutSr4 <= APV_ZERO; OutSr5 <= APV_ZERO; OutSr6 <= APV_ZERO; OutSr7 <= APV_ZERO;
	@(negedge clk1);
	#1 OutSr0 <= APV_ONE; OutSr1 <= APV_ONE; OutSr2 <= APV_ONE; OutSr3 <= APV_ONE;
	   OutSr4 <= APV_ONE; OutSr5 <= APV_ONE; OutSr6 <= APV_ONE; OutSr7 <= APV_ONE;
	@(negedge clk1);
	#1 OutSr0 <= APV_ZERO; OutSr1 <= APV_ZERO; OutSr2 <= APV_ZERO; OutSr3 <= APV_ZERO;
	   OutSr4 <= APV_ZERO; OutSr5 <= APV_ZERO; OutSr6 <= APV_ZERO; OutSr7 <= APV_ZERO;
	for(i=1; i<=128; i=i+1)
	begin
		@(negedge clk1);
		#1 
		for(j=0; j<8; j=j+1)
		begin
			if( apv_data_file[j] != 0 )
			begin
				$fscanf(apv_data_file[j], "%x", tmpval);
				if( $feof(apv_data_file[j]) )
				begin
					$rewind(apv_data_file[j]);	// rewind the file
					$fscanf(apv_data_file[j], "%x", tmpval);
				end
				case(j)
					0: OutSr0 <= tmpval;
					1: OutSr1 <= tmpval;
					2: OutSr2 <= tmpval;
					3: OutSr3 <= tmpval;
					4: OutSr4 <= tmpval;
					5: OutSr5 <= tmpval;
					6: OutSr6 <= tmpval;
					7: OutSr7 <= tmpval;
				endcase
			end
		end
	end
end
endtask // ApvFrame

endmodule

