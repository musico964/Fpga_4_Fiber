`timescale 1ns/100ps

module _a_TestBenchVme;

parameter master_ck_period = 10;
parameter master_ck_half_period = master_ck_period / 2;
parameter master_ck_hold  = 1;	// data hold time

parameter vme_period = 17;

parameter Cr_start = 19'h0, Cr_end = 19'h00100;

integer fout, dump_fout;
reg echo;
reg Master_clock, Master_resetB;
integer i;

tri1 [31:0] vme_data, vme_addr;
reg [31:0] internal_vme_data, rd_data;
reg [31:1] internal_vme_addr;
wire [5:0] vme_ga;
tri1 [7:1] vme_irqB;
reg [5:0] vme_am;
reg [4:0] geog_addr;
reg vme_writeB, vme_ds0B, vme_ds1B, vme_asB, vme_iackB, vme_lwordB;
reg d64_vme_cycle, sst_addr_cycle, Slave_Terminate;
wire vme_iackoutB, vme_adir, vme_aoeB, vme_ddir, vme_doeB, vme_dtack_en, vme_berr_en, vme_retry_en;
tri1 vme_dtackB, vme_berrB, vme_retryB;
wire Vme_user_reB, Vme_user_weB, Vme_user_oeB;
wire [21:0] Vme_user_addr;	// MUST BE 21 bit = 2Mwords (32 bit wide)
wire [7:0] Vme_user_ceB;
wire [31:0] data_from_vme;
reg [63:0] data_to_master;
wire [31:0] Sdram_base, DataReadout_base;

assign vme_ga = {parity(geog_addr), ~geog_addr};
assign vme_addr = (d64_vme_cycle == 0) ? {internal_vme_addr, vme_lwordB} : 32'bz;
assign vme_data = (vme_writeB == 0 || sst_addr_cycle == 1 ) ? internal_vme_data : 32'bz;

assign DataReadout_base = 32'h80_0000;	// Output buffer is mutually exclusive from Sdram direct access (8 MB)
assign Sdram_base = 32'h100_0000;		// Sdram direct access active only if UseSdramFifo = ReadoutConfig[15] = 0


 VmeSlaveIf Dut(

	.VME_D(vme_data), .VME_A(vme_addr[31:1]), .VME_AM(vme_am), .VME_GAb(vme_ga), .VME_LWORDb(vme_addr[0]),
	.VME_WRITEb(vme_writeB), .VME_DS0b(vme_ds0B), .VME_DS1b(vme_ds1B), .VME_ASb(vme_asB),
	.VME_IACKb(vme_iackB), .VME_IackInb(vme_iackB), .VME_IackOutb(vme_iackoutB),
	.VME_DTACK(vme_dtackB), .VME_BERR(vme_berrB), .VME_RETRY(vme_retryB),
	.VME_IRQ(vme_irqB), .VME_ADDR_DIR(vme_adir), .VME_ABUF_OEb(vme_aoeB),
	.VME_DATA_DIR(vme_ddir), .VME_DBUF_OEb(vme_doeB),
	.VME_DTACK_EN(vme_dtack_en), .VME_BERR_EN(vme_berr_en), .VME_RETRY_EN(vme_retry_en),

	.USER_D64(1'b1),	// Permit VME 64 bit data transactions
	.USER_VME64BIT(),	// 64 bit VME data transaction
	.USER_ADDR(Vme_user_addr), // 22 bit
	.USER_DATA_IN(data_to_master), // 64 bit
	.USER_DATA_OUT(data_from_vme), //32 bit
	.USER_WEb(Vme_user_weB), .USER_REb(Vme_user_reB), .USER_OEb(Vme_user_oeB),
	.USER_CEb(Vme_user_ceB), // 8 bit
	.HISTO_REG(),
	.USER_WAITb(1'b1),
	.SLAVE_TERMINATE_2E(Slave_Terminate),

	.RESETb(Master_resetB), .CLK(Master_clock),
	.CONFIG_CEb(Vme_ConfigReg_ceB), .SDRAM_CEb(Vme_Sdram_ceB), .OBUF_CEb(Vme_DataReadout_ceB),
	.ASMI_CEb(), .RUPD_CEb(),
	.TOKEN_IN(1'b0), .END_OF_DATA(), .TOKEN_OUT(), .TOKEN(),
	.GXB_TX_DISABLE(), .GXB_PRESENT(1'b0), .GXB_RX_LOS(1'b0),
	.FIBER_RESET(), .FIBER_DISABLE(), .FIBER_UP(1'b0), .FIBER_HARD_ERR(1'b0), .FIBER_FRAME_ERR(1'b0), .FIBER_ERR_COUNT(7'b0), .SDRAM_BANK()
);

// Time 0 values
initial
begin
	echo = 1;
	Master_clock = 0;
	Master_resetB = 1;
	d64_vme_cycle = 0;
	Slave_Terminate = 0;

	vme_writeB = 1; vme_ds0B = 1; vme_ds1B = 1; vme_asB = 1; vme_iackB = 1; vme_lwordB = 1;
	internal_vme_data <= 32'hFFFF_FFFF;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	geog_addr = 5'h05;
	data_to_master = 0;
	sst_addr_cycle = 0;
	dump_fout = 1;
end

// Main test vectors
initial
begin
	Sleep(2);
	dump_fout = 0;
	if( dump_fout == 1 )
		fout = $fopen("Dump.txt", "w");
	issue_RESET;
	Sleep(100);

	
//	Sleep(5000);

	Sleep(20);
	VME_A24D32_Write(Cr_start+'h190, 1);	// Disable Fiber Interface
// Internal Read Only registers
	VME_A24D32_Read(Cr_start+'h0, rd_data);	// Should Return 0x43524f4d = 'CROM', but registers are not connected!
//	VME_A24D32_Read(Cr_start+'h4, rd_data);	// Should Return 0x00080030 (CERN manufacturer ID), but registers are not connected!
//	VME_A24D32_Read(Cr_start+'h8, rd_data);	// Should Return 0x00030904 (Board ID), but registers are not connected!
//	VME_A24D32_Read(Cr_start+'hC, rd_data);	// Should Return 0x00040004 (Board Revision: HW rev = 4, FW rev = 4), but registers are not connected!
//	VME_A24D32_Read(Cr_start+'h10, rd_data);	// Should Return 0xxxxxxxxx (Compile Time [time_t]), but registers are not connected!
	Sleep(25);
	VME_A24D32_Write(Cr_start+'h194, DataReadout_base>>2);	// Output Buffer Base address
	VME_A24D32_Write(Cr_start+'h198, Sdram_base>>2);		// Sdram Base address
	VME_A24D32_Write(Cr_start+'h19C, 0);					// Sdram Bank 0
	Sleep(25);

	VME_A32D32_BlockRead(DataReadout_base, 16, rd_data);
	Sleep(25); $display(" ");
	VME_A32D64_MbltRead(DataReadout_base, 16, rd_data);
	Sleep(25); $display(" ");
	VME_A32D64_2eVmeRead(DataReadout_base, 16, rd_data);
	Sleep(25); $display(" ");
	VME_A32D64_2eSstRead(DataReadout_base, 16, rd_data, 0);
	Sleep(25); $display(" ");
	VME_A32D64_2eSstRead(DataReadout_base, 16, rd_data, 1);
	Sleep(25); $display(" ");
	VME_A32D64_2eSstRead(DataReadout_base, 16, rd_data, 2);
	Sleep(25); $display(" ");
	VME_A32D64_2eSstRead(DataReadout_base, 16, rd_data, 2);	// this will be interrupted by Slave_Terminate
		
	Sleep(50);
	if( dump_fout == 1 )
		$fclose(fout);

	$stop;
end

  initial	// Interrupts last 2eSST
	#16400   Slave_Terminate = 1;

  // Clock generator: free running
  initial
  begin
    #(master_ck_period-master_ck_hold)	Master_clock <= ~Master_clock;
    forever
      #master_ck_half_period	Master_clock <= ~Master_clock;
  end

always @(negedge Vme_user_reB)
begin
	data_to_master = data_to_master + 1;
end

// Utility tasks
task Sleep;
input [31:0] waittime;
begin
	repeat(waittime)
		#vme_period;
end
endtask // Sleep
 
task issue_RESET;
begin
	if( echo == 1 )
		$display("# Reset @%0t",$stime);
	#vme_period Master_resetB = 0;
	#vme_period;
	#vme_period;
	#vme_period;
	#vme_period Master_resetB = 1;
	#vme_period;
end
endtask // issue_RESET

task VME_CrCsr_Read;
input [18:0] address;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h2F;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	vme_lwordB = 0;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	rd_data = vme_data;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_CrCsr_Read@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask
 
task VME_CrCsr_Write;
input [18:0] address;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_CrCsr_Write@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, wr_data);
	#vme_period;
	vme_am = 6'h2F;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	vme_writeB = 1;
	#vme_period;
end
endtask

task VME_A24D32_Read;
input [18:0] address;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h39;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	vme_lwordB = 0;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	rd_data = vme_data;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A24D32_Read@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask
 
task VME_A24D32_Write;
input [18:0] address;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A24D32_Write@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, wr_data);
	#vme_period;
	vme_am = 6'h39;
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	vme_writeB = 1;
	#vme_period;
end
endtask

task VME_A24D32_BlockRead;
input [31:0] address;
input [31:0] n_read;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h3B;	// Non privileged data space A24 block accesses
	internal_vme_addr = {8'h0, geog_addr, address[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 1;
	repeat( n_read )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		rd_data = vme_data;
		if( dump_fout == 1 )
			$fwrite(fout, "%0x\n", rd_data);
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A24D32_BlockRead@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask

task VME_A24D32_BlockWrite;
input [31:0] addr;
input [31:0] n_write;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A24D32_BlockWrite@%0t: addr=0x%0x, data=0x%0x, N = %0d",$stime, addr, wr_data, n_write);
	#vme_period;
	vme_am = 6'h3B;	// Non privileged data space A24 block accesses
	internal_vme_addr = {8'h0, geog_addr, addr[18:1]};
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	repeat( n_write )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	vme_lwordB = 1;
	#vme_period;
end
endtask

task VME_A32D32_Read;
input [31:0] address;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h09;	// Non privileged data space A32 accesses
	internal_vme_addr = address[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 1;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	rd_data = vme_data;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A32D32_Read@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask

task VME_A32D32_Write;
input [31:0] address;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A32D32_Write@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, wr_data);
	#vme_period;
	vme_am = 6'h09;	// Non privileged data space A32 accesses
	internal_vme_addr = address[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	#vme_period;
	vme_ds0B = 0;
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	vme_writeB = 1;
	#vme_period;
end
endtask

task VME_A32D32_BlockRead;
input [31:0] address;
input [31:0] n_read;
output [31:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h0B;	// Non privileged data space A32 block accesses
	internal_vme_addr = address[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 1;
	repeat( n_read )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		rd_data = vme_data;
		if( dump_fout == 1 )
			$fwrite(fout, "%0x\n", rd_data);
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A32D32_BlockRead@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
end
endtask

task VME_A32D32_BlockWrite;
input [31:0] addr;
input [31:0] n_write;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# VME_A32D32_BlockWrite@%0t: addr=0x%0x, data=0x%0x, N = %0d",$stime, addr, wr_data, n_write);
	#vme_period;
	vme_am = 6'h0B;	// Non privileged data space A32 block accesses
	internal_vme_addr = addr[31:1];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_lwordB = 0;
	vme_writeB = 0;
	internal_vme_data = wr_data;
	repeat( n_write )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	vme_lwordB = 1;
	#vme_period;
end
endtask

task VME_A32D64_MbltRead;
input [31:0] address;
input [31:0] n_read;
output [63:0] rd_data;
begin
	#vme_period;
	vme_am = 6'h08;	// Non privileged data space A32-D64 MBLT
	internal_vme_addr = address[31:1];
	vme_lwordB = address[0];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	vme_ds0B = 0;	// Address Phase
	vme_ds1B = 0;
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	while( vme_dtackB == 0 )
		#vme_period;
	d64_vme_cycle = 1;
	repeat( n_read )
	begin
		#vme_period;
		vme_ds0B = 0;
		vme_ds1B = 0;
		while( vme_dtackB == 1 )
			#vme_period;
		rd_data = {vme_addr, vme_data};
		#vme_period;
		vme_ds0B = 1;
		vme_ds1B = 1;
		while( vme_dtackB == 0 )
			#vme_period;
	end
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_lwordB = 1;
	if( echo == 1 )
		$display("# VME_A32D64_MbltRead@%0t: addr=0x%0x, data=0x%0x",
			$stime, address, rd_data);
	#vme_period;
	d64_vme_cycle = 0;

end
endtask

task VME_A32D64_2eVmeRead;	// Master terminated: no slave termination allowed
input [31:0] address;		// User must be sure that n_words is even
input [7:0] n_words;
output [63:0] rd_data;
integer j;
reg even_cycle;
begin
	#vme_period;
	vme_am = 6'h20;	// 6U A32 2eVME
	internal_vme_addr[7:1] = 0;
	vme_lwordB = 1;	// XAM = 0x01
	internal_vme_addr[31:8] = address[31:8];
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 1
	while( vme_dtackB == 1 )
		#vme_period;
	internal_vme_addr[7:1] = {address[7:4], 3'b0};
	vme_lwordB = 0;
	internal_vme_addr[15:8] = n_words >> 1;
	internal_vme_addr[31:16] = 0;
	#vme_period;
	vme_ds0B = 1;	// Address Phase 2
	while( vme_dtackB == 0 )
		#vme_period;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 3
	internal_vme_addr[31:1] = 0;
	vme_lwordB = 0;
	while( vme_dtackB == 1 )
		#vme_period;

	d64_vme_cycle = 1;
	even_cycle = 0;	// Start with odd cycle
	for(j=0; j<n_words; j=j+1)
	begin
		#vme_period;
		vme_ds1B = even_cycle;
		#vme_period;
		while( vme_dtackB == even_cycle )
			#vme_period;
		rd_data = {vme_addr, vme_data};
		if( dump_fout == 1 )
		begin
			$fwrite(fout, "%0x\n", rd_data[63:32]);
			$fwrite(fout, "%0x\n", rd_data[31:0]);
		end
		#vme_period;
		if( echo == 1 )
			$display("# VME_A32D64_2eVmeRead@%0t: addr=0x%0x, data=0x%0x",
				$stime, address+j, rd_data);
		even_cycle = ~even_cycle;
	end

	#vme_period;
	vme_asB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	vme_lwordB = 1;
	vme_ds0B = 1;
	vme_ds1B = 1;
	d64_vme_cycle = 0;
	#vme_period;
end
endtask

task VME_A32D64_2eSstRead;	// Must be slave terminated
input [31:0] address;		// User must be sure that n_words is even
input [7:0] n_words;
output [63:0] rd_data;
input [3:0] mode;
integer j, dtack_val;
begin
	#vme_period;
	sst_addr_cycle = 1;
	vme_am = 6'h20;	// 6U A32 2eVME
	internal_vme_addr[7:1] = 7'h08;
	vme_lwordB = 1;	// XAM = 0x11
	internal_vme_addr[31:8] = address[31:8];
	case( mode )
		3'h0: internal_vme_data = 32'h0000_0000;	// SST160
		3'h1: internal_vme_data = 32'h0000_0001;	// SST267
		3'h2: internal_vme_data = 32'h0000_0002;	// SST320
		default: internal_vme_data = 32'h0000_0000;	// SST160
	endcase
	#vme_period;
	vme_asB = 0;
	vme_iackB = 1;
	vme_writeB = 1;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 1
	while( vme_dtackB == 1 )
		#vme_period;
	internal_vme_addr[7:1] = address[7:1];
	vme_lwordB = 0;
	internal_vme_addr[15:8] = n_words >> 1;
	internal_vme_addr[31:16] = 0;
	#vme_period;
	vme_ds0B = 1;	// Address Phase 2
	while( vme_dtackB == 0 )
		#vme_period;
	#vme_period;
	vme_ds0B = 0;	// Address Phase 3
	while( vme_dtackB == 1 )
		#vme_period;
	#vme_period;
	sst_addr_cycle = 0;
	vme_ds1B = 0;
	d64_vme_cycle = 1;	// Disable driving ADDR_VME, LWORD

	dtack_val = 0;

	for(j=0; j<=n_words; j=j+1)
	begin
		if( vme_retryB == 0 )
		begin
			$display("#### VME_A32D32_2eSstRead@%0t: got RETRY = 0", $stime);
			while( vme_berrB == 1 )
				#vme_period;
			$display("#### VME_A32D32_2eSstRead@%0t: got BERR = 0", $stime);
			if( j != n_words && echo == 1 )
				$display("# VME_A32D32_2eSstRead@%0t: Slave terminated at %d nwords",
					$stime, j);
			j = n_words+1;
		end
		else
		begin
			while( vme_dtackB == dtack_val && vme_retryB == 1 )
				#vme_period;
			$display("#### VME_A32D32_2eSstRead@%0t: got word %d", $stime, j);
			rd_data = {vme_addr, vme_data};
			if( dtack_val == 0 )
				dtack_val = 1;
			else
				dtack_val = 0;
			if( dump_fout == 1 && vme_retryB == 1 )
			begin
				$fwrite(fout, "%0x\n", rd_data[63:32]);
				$fwrite(fout, "%0x\n", rd_data[31:0]);
			end
			if( echo == 1 )
				$display("# VME_A32D32_2eSstRead@%0t: addr=0x%0x, data=0x%0x",
					$stime, address+j, rd_data);
		end
	end

	#vme_period;
	#vme_period;
	#vme_period;
	vme_ds0B = 1;
	vme_ds1B = 1;
	vme_asB = 1;
	vme_lwordB = 1;
	internal_vme_addr <= 31'h7FFF_FFFF;
	vme_am = 6'h3F;
	vme_writeB = 1;
	d64_vme_cycle = 0;
	#vme_period;
end
endtask


function parity;
input [4:0] x;
begin
	parity = 0;
end
endfunction

endmodule

