`ifdef QUESTA_SIMULATION
`include "./Mpd_Common/AddressDefines.v"
`else
`include "./AddressDefines.v"
`endif

module FiberInterface(
		input CLK,		// system
		input RSTb,		// system
		input ENABLE,
		input USE_SDRAM_FIFO,

		output FIBER_RESET,				// to AuroraInterface
		input FIBER_CHANNEL_UP,			// from AuroraInterface

//			-- FIBER_BUS* synchronous to CLK
		input [31:0] FIBER_BUS_ADDR,	// from AuroraInterface decode only [18:2]
		input [31:0] FIBER_BUS_DOUT,	// from AuroraInterface
		output [31:0] FIBER_BUS_DIN,// to AuroraInterface
		input FIBER_BUS_WR,				// from AuroraInterface
		input FIBER_BUS_RD,				// from AuroraInterface
		output reg FIBER_BUS_ACK,		// to AuroraInterface

//			-- EVT_FIFO* synchronous to CLK
		input EVT_FIFO_FULL,			// from AuroraInterface
		output EVT_FIFO_WR,				// to AuroraInterface
		output [31:0] EVT_FIFO_DATA,	// to AuroraInterface
		output EVT_FIFO_END,			// to AuroraInterface
		output EVT_FIFO_RD,				// to Output FIFO Buffer
		input EVT_FIFO_EMPTY,			// from Output FIFO Buffer

// Local Interface syncronous with CLK
		input [31:0] EVB_DATA,
		output reg FIBER_USER_REb,
		output reg FIBER_USER_WEb,
		output FIBER_USER_OEb,
		output [7:0] FIBER_USER_CEb,
		output FIBER_CONFIGREG_CEb,
		output [1:0] FIBER_HISTO_REG,
		output [15:0] FIBER_USER_ADDR,
		input [31:0] FIBER_USER_DATA_IN,
		output [31:0] FIBER_USER_DATA_OUT
	);

	reg old_rd, old_wr;

	assign EVT_FIFO_DATA = EVB_DATA;

	assign FIBER_USER_OEb = ~FIBER_BUS_RD;
	assign FIBER_USER_ADDR = FIBER_BUS_ADDR[15:0];
	
	assign FIBER_USER_DATA_OUT = FIBER_BUS_DOUT;
	assign FIBER_BUS_DIN = FIBER_USER_DATA_IN;

// Generate User RD & WR signals, sample read data and generate ACK
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			FIBER_USER_WEb <= 1;
			FIBER_USER_REb <= 1;
			FIBER_BUS_ACK <= 0;
			old_rd <= 0;
			old_wr <= 0;
		end
		else
		begin
			old_rd <= FIBER_BUS_RD;
			old_wr <= FIBER_BUS_WR;
			if( old_wr == 0 && FIBER_BUS_WR == 1 )
				FIBER_USER_WEb <= 0;
			else
				FIBER_USER_WEb <= 1;
			if( old_rd == 0 && FIBER_BUS_RD == 1 )
				FIBER_USER_REb <= 0;
			else
				FIBER_USER_REb <= 1;
			if( FIBER_USER_WEb == 0 || FIBER_USER_REb == 0 )
				FIBER_BUS_ACK <= 1;
			else
				FIBER_BUS_ACK <= 0;
		end
	end

// Generate Reset pulses to AuroraInterface if channel is not UP		
	aurora_reset_generator FiberRstGen(.CK(CLK), .RSTb(RSTb),
		.ENABLE(FIBER_CHANNEL_UP), .RESET_OUT(FIBER_RESET));

// Decode the address (after sampling them) coming form AuroraInterface
	FiberAddressDecoder AddressDecoder(.ADDR(FIBER_BUS_ADDR[15:0]), .CLK(CLK), .RESETb(RSTb),
		.CROM_CEb(FIBER_CONFIGREG_CEb),
		.OBUF_STATUS_CEb(FIBER_USER_CEb[0]), .ADC_CEb(FIBER_USER_CEb[1]), .I2C_CEb(FIBER_USER_CEb[2]),
		.HISTO0_CEb(FIBER_USER_CEb[3]), .HISTO1_CEb(FIBER_USER_CEb[4]), .HISTO_REG(FIBER_HISTO_REG),
		.CHANNELS_CEb(FIBER_USER_CEb[5]),
		.THR_RAM_CEb(FIBER_USER_CEb[6]), .PED_RAM_CEb(FIBER_USER_CEb[7]));

// Generate signals to transfer event data fron Output FIFO Buffer to AuroraInterface
	EvtHandler EvtSignalGen(.CLK(CLK), .RSTb(RSTb), .ENABLE(FIBER_CHANNEL_UP & ENABLE), .USE_SDRAM_FIFO(USE_SDRAM_FIFO),
		.OUT_FIFO_FULL(EVT_FIFO_FULL),			// from AuroraInterface
		.OUT_FIFO_WR(EVT_FIFO_WR),				// to AuroraInterface
		.EVT_FIFO_END(EVT_FIFO_END),			// to AuroraInterface
		.IN_FIFO_RD(EVT_FIFO_RD),				// to Output FIFO Buffer
		.IN_FIFO_EMPTY(EVT_FIFO_EMPTY),		// from Output FIFO Buffer
		.EVT_FIFO_DATA(EVT_FIFO_DATA));			// from Output FIFO Buffer
endmodule

module aurora_reset_generator(input CK, input RSTb, input ENABLE, output reg RESET_OUT);
//parameter timeout = 125 * 5000;	// 5 ms @125 MHz
//parameter timeout = 125 * 50;	// 50 us @125 MHz (to speedup simulation)
parameter timeout = 110 * 5000;	// 5 ms @110 MHz
//parameter timeout = 110 * 50;	// 50 us @110 MHz (to speedup simulation)

reg [19:0] count;
reg first_time;

	always @(posedge CK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			RESET_OUT <= 1;
			count <= 0;
			first_time <= 0;
		end
		else
		begin
			if( ENABLE == 0 )
			begin
				count <= count + 1;
				if( first_time == 0 && count == 200 )
				begin
						first_time <= 1;
						RESET_OUT <= 1;
						count <= 0;
				end
				else
				begin
					if( count == timeout )
					begin
						RESET_OUT <= 1;
						count <= 0;
					end
					else
						RESET_OUT <= 0;
				end
			end
			else
			begin
				RESET_OUT <= 0;
				count <= 0;
			end
		end
	end

endmodule

module FiberAddressDecoder(ADDR, CLK, RESETb,
	CROM_CEb,
	OBUF_STATUS_CEb, ADC_CEb, I2C_CEb, HISTO0_CEb, HISTO1_CEb, HISTO_REG, CHANNELS_CEb, THR_RAM_CEb,
	PED_RAM_CEb);

	input [15:0] ADDR;
	input CLK, RESETb;
	output CROM_CEb, OBUF_STATUS_CEb, ADC_CEb, I2C_CEb, HISTO0_CEb, HISTO1_CEb, CHANNELS_CEb, THR_RAM_CEb;
	output [1:0] HISTO_REG;
	output PED_RAM_CEb;

	reg CROM_CEb, OBUF_STATUS_CEb, ADC_CEb, I2C_CEb, HISTO0_CEb, HISTO1_CEb, CHANNELS_CEb, THR_RAM_CEb;
	reg PED_RAM_CEb, SDRAM_CEb, OBUF_CEb;
	reg INTERNAL_DETECT;
	reg [1:0] HISTO_REG;

	
	always @(posedge CLK or negedge RESETb)
	begin
		if( RESETb == 0 )
		begin
			OBUF_STATUS_CEb  <= 1;
			ADC_CEb <= 1;
			I2C_CEb <= 1;
			HISTO0_CEb <= 1;
			HISTO1_CEb <= 1;
			CHANNELS_CEb <= 1;
			THR_RAM_CEb <= 1;
			PED_RAM_CEb <= 1;
			CROM_CEb  <= 1;
			HISTO_REG <= 0;
		end
		else
		begin
			CROM_CEb  <= 1;
			OBUF_STATUS_CEb  <= 1;
			ADC_CEb <= 1;
			I2C_CEb <= 1;
			HISTO0_CEb <= 1;
			HISTO1_CEb <= 1;
			HISTO_REG <= 0;
			CHANNELS_CEb <= 1;
			THR_RAM_CEb <= 1;
			PED_RAM_CEb <= 1;
				if( ADDR[15:0] >= `CROM_LO_A && ADDR[15:0] <= `FIR_1415_A )
					CROM_CEb  <= 0;
				if( ADDR[15:0] >= `OBUF_STATUS_LO && ADDR[15:0] < `OBUF_STATUS_HI )
					OBUF_STATUS_CEb  <= 0;
				if( ADDR[15:0] >= `ADC_CONFIG_LO && ADDR[15:0] < `ADC_CONFIG_HI )
					ADC_CEb  <= 0;
				if( ADDR[15:0] >= `I2C_CONFIG_LO && ADDR[15:0] < `I2C_CONFIG_HI )
					I2C_CEb <= 0;
				if( ((ADDR[15:0] >= `HISTO0_LO && ADDR[15:0] < `HISTO0_HI) ||
						(ADDR[15:0] >= `HISTO0_REG_LO && ADDR[15:0] < `HISTO0_REG_HI)) )
					HISTO0_CEb <= 0;
				if( ((ADDR[15:0] >= `HISTO1_LO && ADDR[15:0] < `HISTO1_HI) ||
						(ADDR[15:0] >= `HISTO1_REG_LO && ADDR[15:0] < `HISTO1_REG_HI)) )
					HISTO1_CEb <= 0;
				if( ADDR[15:0] >= `CHANNELS_LO && ADDR[15:0] < `CHANNELS_HI )
					CHANNELS_CEb <= 0;
				if( ADDR[15:0] >= `PED_RAM_LO && ADDR[15:0] < `PED_RAM_HI )
					PED_RAM_CEb <= 0;
				if( ADDR[15:0] >= `THR_RAM_LO && ADDR[15:0] < `THR_RAM_HI )
					THR_RAM_CEb <= 0;
				if( ADDR[15:0] >= `HISTO0_REG_LO && ADDR[15:0] < `HISTO0_REG_HI )
					HISTO_REG[0] <= 1;
				if( ADDR[15:0] >= `HISTO1_REG_LO && ADDR[15:0] < `HISTO1_REG_HI )
					HISTO_REG[1] <= 1;
		end
	end

endmodule

module EvtHandler(input CLK, input RSTb, input ENABLE, input USE_SDRAM_FIFO,
		input OUT_FIFO_FULL,			// from AuroraInterface
		output OUT_FIFO_WR,				// to AuroraInterface
		output reg EVT_FIFO_END,		// to AuroraInterface
		output IN_FIFO_RD,				// to Output FIFO Buffer
		input IN_FIFO_EMPTY,			// from Output FIFO Buffer
		input [31:0] EVT_FIFO_DATA);		// from Output FIFO Buffer

	reg [7:0] fsm_status;
	reg IN_FIFO_RD_int, OUT_FIFO_WR_int, block_trailer_dly;
	wire block_trailer, channel_free;


//`define BLOCK_TRAILER	{1'b1, 4'h1, MODULE_ID, 2'b0, BlockWordCounter}
// Read data up to a BLOCK_TRAILER (or max num of words) if EVT_FIFO_EMPTY is cleared
// How to handle EVT_FIFO_FULL ?

//	assign channel_free = ~IN_FIFO_EMPTY & ~OUT_FIFO_FULL;
	assign channel_free = ~IN_FIFO_EMPTY & ~OUT_FIFO_FULL & ~block_trailer_dly;
	assign IN_FIFO_RD = IN_FIFO_RD_int & channel_free;
	assign OUT_FIFO_WR = (OUT_FIFO_WR_int & channel_free) | (EVT_FIFO_END & ~OUT_FIFO_FULL);
//	assign IN_FIFO_RD = IN_FIFO_RD_int;
//	assign OUT_FIFO_WR = OUT_FIFO_WR_int;
//	assign block_trailer = (EVT_FIFO_DATA[23:19] == {1'b1, 4'h1}) ? ~IN_FIFO_EMPTY : 0;	// 32 bit old format
	assign block_trailer = (EVT_FIFO_DATA[23:20] == {3'h1, 1'b0}) ? ~IN_FIFO_EMPTY : 0;	// 24 bit format
	
	always @(posedge CLK)
		block_trailer_dly <= block_trailer & USE_SDRAM_FIFO;

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			fsm_status <= 0;
			OUT_FIFO_WR_int <= 0;
			IN_FIFO_RD_int <= 0;
			EVT_FIFO_END <= 0;
		end
		else
		begin
			case( fsm_status )
				8'd0:	begin
							OUT_FIFO_WR_int <= 0;
							IN_FIFO_RD_int <= 0;
							EVT_FIFO_END <= 0;
							if( ENABLE & channel_free )
								fsm_status <= 1;
						end
				8'd1:	begin
							OUT_FIFO_WR_int <= channel_free;
							IN_FIFO_RD_int <= channel_free;
							if( block_trailer == 1 && channel_free == 1 )
							begin
//								IN_FIFO_RD_int <= 0;
								fsm_status <= 2;
							end
							else
							begin
								if( OUT_FIFO_FULL )
								begin
									OUT_FIFO_WR_int <= 0;
									IN_FIFO_RD_int <= 0;
									fsm_status <= 3;
								end
								if( IN_FIFO_EMPTY )
								begin
									OUT_FIFO_WR_int <= 0;
									IN_FIFO_RD_int <= 0;
									fsm_status <= 4;
								end
							end
						end
				8'd2:	begin
							IN_FIFO_RD_int <= 0;
							EVT_FIFO_END <= 1;
							if( ~OUT_FIFO_FULL )
								fsm_status <= 5;
						end
				8'd3:	begin
							IN_FIFO_RD_int <= 0;
							OUT_FIFO_WR_int <= 0;
							EVT_FIFO_END <= 0;
							fsm_status <= 0;
						end
				8'd4:	begin
							IN_FIFO_RD_int <= 0;
							OUT_FIFO_WR_int <= 0;
							EVT_FIFO_END <= 0;
							fsm_status <= 0;
						end
				8'd5:	begin
							OUT_FIFO_WR_int <= 0;
							EVT_FIFO_END <= 0;
							fsm_status <= 0;
						end
				8'd6:	begin
						end
				8'd7:	begin
						end
				8'd8:	begin
						end
				default: fsm_status <= 0;
			endcase
		end
	end
	
endmodule
