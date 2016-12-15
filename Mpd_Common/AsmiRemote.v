module AsmiRemote(
	input VME_CLK, input RESETb,
	input [1:0] USER_ADDR,
	input [31:0] USER_DATA_IN, output [31:0] USER_DATA_OUT,
	input ASMI_CEb, input RUPD_CEb,
	input USER_WEb, input USER_REb, input USER_OEb,
	input PERIPH_CK
);
	wire [23:0] asmi_addr;
	wire [7:0] asmi_datain, asmi_dataout, asmi_rdidout, asmi_status;
	wire asmi_rden, asmi_read, asmi_rdstatus, asmi_reset, asmi_sec_erase, asmi_write, asmi_busy, asmi_data_valid, asmi_illegal_erase, asmi_illegal_write;
	wire [11:0] rupd_datain, rupd_dataout;
	wire [2:0] rupd_param;
	wire rupd_read, rupd_reconfig, rupd_t_reset, rupd_write, rupd_busy;
	wire [31:0] Asmi_dout, Rupd_dout;
	
	assign USER_DATA_OUT = (ASMI_CEb == 0) ?  Asmi_dout : Rupd_dout;

	AsmiIf Asmi_Interface(
		.CLK(VME_CLK), .RESETb(RESETb),
		.USER_ADDR(USER_ADDR[0]),
		.USER_DATA_IN(USER_DATA_IN), .USER_DATA_OUT(Asmi_dout), .USER_CEb(ASMI_CEb),
		.USER_WEb(USER_WEb), .USER_REb(USER_REb), .USER_OEb(USER_OEb),
		.ASMI_ADDR(asmi_addr),
		.ASMI_CK(PERIPH_CK),
		.ASMI_DATAIN(asmi_datain),
		.ASMI_RDEN(asmi_rden),
		.ASMI_RD(asmi_read),
		.ASMI_RDID(asmi_rdid),
		.ASMI_RDSTATUS(asmi_rdstatus),
		.ASMI_RESET(asmi_reset),
		.ASMI_SECTOR_ERASE(asmi_sec_erase),
		.ASMI_WR(asmi_write),
		.ASMI_BUSY(asmi_busy),
		.ASMI_DV(asmi_data_valid),
		.ASMI_DATAOUT(asmi_dataout),
		.ASMI_ILL_ERASE(asmi_illegal_erase),
		.ASMI_ILL_WR(asmi_illegal_write),
		.ASMI_RDID_OUT(asmi_rdidout),
		.ASMI_STATUS(asmi_status)
		);

	z_asmi	z_asmi_inst (
		.addr(asmi_addr),		// input [23:0]
		.clkin(PERIPH_CK),		// input
		.datain(asmi_datain),	// input [7:0]
		.rden(asmi_rden),		// input
		.read(asmi_read),		// input
		.read_rdid(asmi_rdid),	// input
		.read_status(asmi_rdstatus),
		.reset(asmi_reset),		// input
		.sector_erase(asmi_sec_erase),	// input
		.write(asmi_write),		// input
		.busy(asmi_busy),		// output
		.data_valid(asmi_data_valid),		// output
		.dataout(asmi_dataout),			// output [7:0]
		.illegal_erase(asmi_illegal_erase),		// output
		.illegal_write(asmi_illegal_write),		// output
		.rdid_out(asmi_rdidout),			// output [7:0]
		.status_out(asmi_status)			// output [7:0]
		);

		
	RemoteUpdateIf RemoteUpdate_Interface(
		.CLK(VME_CLK), .RESETb(RESETb),
		.USER_ADDR(USER_ADDR[1:0]),
		.USER_DATA_IN(USER_DATA_IN), .USER_DATA_OUT(Rupd_dout), .USER_CEb(RUPD_CEb),
		.USER_WEb(USER_WEb), .USER_REb(USER_REb), .USER_OEb(USER_OEb),
		.RUPD_PARAM(rupd_param),
		.RUPD_CK(PERIPH_CK),
		.RUPD_DATAIN(rupd_datain),
		.RUPD_RD(rupd_read),
		.RUPD_TRESET(rupd_t_reset),
		.RUPD_WR(rupd_write),
		.RUPD_BUSY(rupd_busy),
		.RUPD_RECONFIG(rupd_reconfig),
		.RUPD_DATAOUT(rupd_dataout));

	z_remote	z_remote_inst (
		.clock(PERIPH_CK),			// input
		.data_in(rupd_datain),		// input [11:0]
		.param(rupd_param),			// input [2:0]
		.read_param(rupd_read),		// input
		.reconfig(rupd_reconfig),	// input
		.reset(~RESETb),			// input
		.reset_timer(rupd_t_reset),	// input
		.write_param(rupd_write),	// input
		.busy(rupd_busy),			// output
		.data_out(rupd_dataout)		// output [11:0]
		);
endmodule
