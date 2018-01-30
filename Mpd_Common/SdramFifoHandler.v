/* First version of 24 to 32 bit formatter: it loads the upper 8 bit with 0
 *
 * A better version is MANDATORY.
 */
/*
module Sdram2432Formatter(RSTb, CLK, ENABLE,
	SDRAM_WDATA, EMPTY_WDATA, NEXT_WDATA, 
	RD_EVB, WC_EVB, DATA_EVB, PACK_DATA
	);
input RSTb, CLK, ENABLE;
output [31:0] SDRAM_WDATA;
output EMPTY_WDATA;
input NEXT_WDATA;
output RD_EVB;
input [11:0] WC_EVB;
input [23:0] DATA_EVB;
input PACK_DATA;

reg [31:0] SDRAM_WDATA;
reg EMPTY_WDATA;
reg RD_EVB;
reg [7:0] fsm_status;


	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			SDRAM_WDATA <= 0;
			EMPTY_WDATA <= 1;
			RD_EVB <= 0;
			fsm_status <= 0;
		end
		else
		begin
			case( fsm_status )
			0:	begin
					EMPTY_WDATA <= 1;
					RD_EVB <= 0;
					SDRAM_WDATA <= {8'b0, DATA_EVB};
					if( ENABLE == 1 && WC_EVB[10:0] >  16 )
						fsm_status <= 1;
				end
			1:	begin
//$display("Sdram2432FormatterSimple RD: 0x%0x", SDRAM_WDATA);
					RD_EVB <= 1;
					EMPTY_WDATA <= 0;
					fsm_status <= 2;
				end
			2:	begin
					RD_EVB <= 0;
					if( NEXT_WDATA == 1 || ENABLE == 0 )
						fsm_status <= 0;
					else
						fsm_status <= 2;
				end
			3:	begin
				end
			default: fsm_status <= 0;
			endcase
		end
	end

endmodule
*/

module SdramWriteMachine(RSTb, CLK, ENABLE, CLEAR_ADDR,
	SDRAM_WRITE_REQ, SDRAM_READY,
	CAN_WRITE,	// From SdramReadMachine
	FSM_IDLE,	// To SdramReadMachine
	DATA_AVAILABLE,	// From EventBuilder (was Sdram2432Formatter)
	GET_NEXT_DATA,	// To EventBuilder (was Sdram2432Formatter)
	SDRAM_WRITE_ADDRESS
	);
input RSTb, CLK, ENABLE, CLEAR_ADDR;
output SDRAM_WRITE_REQ;
input SDRAM_READY;
input CAN_WRITE;
output FSM_IDLE;
input DATA_AVAILABLE;
output GET_NEXT_DATA;
output [24:0] SDRAM_WRITE_ADDRESS;

reg [24:0] SDRAM_WRITE_ADDRESS;
reg SDRAM_WRITE_REQ_x, FSM_IDLE, GET_NEXT_DATA_x;
reg increment_write_address;
reg [7:0] fsm_status;

//assign SDRAM_WRITE_REQ = SDRAM_WRITE_REQ_x & SDRAM_READY;
//assign GET_NEXT_DATA = GET_NEXT_DATA_x & SDRAM_READY;
assign SDRAM_WRITE_REQ = SDRAM_WRITE_REQ_x & DATA_AVAILABLE & SDRAM_READY;
assign GET_NEXT_DATA = GET_NEXT_DATA_x & DATA_AVAILABLE & SDRAM_READY;

// Write Address counter
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			SDRAM_WRITE_ADDRESS <= 0;
		else
		begin
			if( CLEAR_ADDR == 1 )
				SDRAM_WRITE_ADDRESS <= 0;
			else
				if( increment_write_address == 1 && SDRAM_READY == 1 && DATA_AVAILABLE == 1 )
					SDRAM_WRITE_ADDRESS <= SDRAM_WRITE_ADDRESS + 1;
		end
	end

// Write state machine
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			fsm_status <= 0;
			SDRAM_WRITE_REQ_x <= 0;
			FSM_IDLE <= 1;
			GET_NEXT_DATA_x <= 0;
			increment_write_address <= 0;
		end
		else
		begin
			case( fsm_status )
			0:	begin
					if( ENABLE == 1 && CAN_WRITE == 1 && DATA_AVAILABLE ==  1 && SDRAM_READY == 1 )
					begin
						FSM_IDLE <= 0;
						GET_NEXT_DATA_x <= 1;
						increment_write_address <= 1;
						SDRAM_WRITE_REQ_x <= 1;
						fsm_status <= 1;
					end
					else
					begin
						FSM_IDLE <= 1;
						GET_NEXT_DATA_x <= 0;
						SDRAM_WRITE_REQ_x <= 0;
						increment_write_address <= 0;
					end
				end
			1:	begin
					if( ENABLE == 1 && CAN_WRITE == 1 && DATA_AVAILABLE ==  1 && SDRAM_READY == 1 )
						fsm_status <= 1;
					else
					begin
						GET_NEXT_DATA_x <= 0;
						SDRAM_WRITE_REQ_x <= 0;
						increment_write_address <= 0;
						fsm_status <= 0;
					end
				end
			default: fsm_status <= 0;
			endcase
		end
	end

endmodule


module ComputeWordCount(RSTb, CLK, CLEAR, SDRAM_WRITE_ADDRESS, SDRAM_READ_ADDRESS, WORD_COUNT, OVERRUN);
input RSTb, CLK, CLEAR;
input [24:0] SDRAM_WRITE_ADDRESS, SDRAM_READ_ADDRESS;
output [24:0] WORD_COUNT;
output OVERRUN;

reg [24:0] WORD_COUNT;
reg OVERRUN;

parameter SdramSize = 26'h2000000;

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			WORD_COUNT <= 0;
			OVERRUN <= 0;
		end
		else
		begin
			if( CLEAR == 1 )
			begin
				WORD_COUNT <= 0;
				OVERRUN <= 0;
			end
			else
			begin
				if( OVERRUN == 0 )
				begin
					if( SDRAM_WRITE_ADDRESS >= SDRAM_READ_ADDRESS )
						WORD_COUNT <= SDRAM_WRITE_ADDRESS - SDRAM_READ_ADDRESS;
					else
						WORD_COUNT <= SdramSize - SDRAM_READ_ADDRESS + SDRAM_WRITE_ADDRESS;

					if( WORD_COUNT == (SdramSize-1) )	// This should lock everithing and must be reset
						OVERRUN <= 1;
				end
			end
		end
	end

endmodule


// From here faster machinery...

module Reg32(RSTb, CLK, LOAD, D, Q);
input RSTb, CLK, LOAD;
input [31:0] D;
output [31:0] Q;

reg [31:0] Q;

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			Q <= 0;
		else
		begin
			if( LOAD == 1 )
				Q <= D;
		end
	end

endmodule

module SdramBlockReadMachine(RSTb, CLK, ENABLE, CLEAR_ADDR,
	SDRAM_READ_REQ, SDRAM_READY, SDRAM_DATA_VALID,
	SDRAM_READ_ADDRESS, SDRAM_FIFO_WC, 
	CAN_READ,	// From SdramWriteMachine
	FSM_IDLE,	// To SdramWriteMachine
	LOAD_LSB, LOAD_MSB, USER_64BIT,
	OUTPUT_FIFO_WR, OUTPUT_FIFO_WC,
	OUTPUT_FIFO_EMPTY, OUTPUT_FIFO_FULL, EMPTY_EVB, OUTPUT_FIFO_EOB
	);
input RSTb, CLK, ENABLE, CLEAR_ADDR;
output SDRAM_READ_REQ;
input SDRAM_READY, SDRAM_DATA_VALID;
output [24:0] SDRAM_READ_ADDRESS;
input [24:0] SDRAM_FIFO_WC;
input CAN_READ;
output FSM_IDLE, LOAD_LSB, LOAD_MSB;
input USER_64BIT;
output OUTPUT_FIFO_WR;
input [12:0] OUTPUT_FIFO_WC;
input OUTPUT_FIFO_EMPTY, OUTPUT_FIFO_FULL;
input EMPTY_EVB;
input OUTPUT_FIFO_EOB;

reg SDRAM_READ_REQ_x, OUTPUT_FIFO_WR;
reg [24:0] SDRAM_READ_ADDRESS;
reg req_fsm_idle, odd_data;
reg LoadSdramBurstCount, Flushing, DataInside;
reg [7:0] SdramBurstCount;
reg [7:0] fsm_req_status, fsm_rd_status;
wire [7:0] OutBurstSize;
wire [7:0] BurstSize;

parameter BurstSize_max = 8'd64;
parameter OutFifoSize = 8192;

assign BurstSize = Flushing ? 8'h2 : BurstSize_max;
assign SDRAM_READ_REQ = ( SdramBurstCount > 0 && SDRAM_FIFO_WC > 0 ) ? SDRAM_READ_REQ_x : 0; 
assign OutBurstSize = USER_64BIT ? BurstSize_max >> 1 : BurstSize_max;
assign LOAD_LSB = USER_64BIT ? (SDRAM_DATA_VALID & ~odd_data) : SDRAM_DATA_VALID;
assign LOAD_MSB = USER_64BIT ? (SDRAM_DATA_VALID & odd_data) : SDRAM_DATA_VALID;
assign FSM_IDLE = req_fsm_idle;

	always @(posedge CLK)
//		OUTPUT_FIFO_WR <= USER_64BIT ? (SDRAM_DATA_VALID & odd_data) : SDRAM_DATA_VALID;
		OUTPUT_FIFO_WR <= LOAD_MSB;
			
// Read Address counter
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			SDRAM_READ_ADDRESS <= 0;
		else
		begin
			if( CLEAR_ADDR == 1 )
				SDRAM_READ_ADDRESS <= 0;
			else
				if( SDRAM_READ_REQ == 1 && SDRAM_READY == 1 )
					SDRAM_READ_ADDRESS <= SDRAM_READ_ADDRESS + 1;
		end
	end

// Sdram Burst counter
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			SdramBurstCount <= 0;
		else
		begin
			if( CLEAR_ADDR == 1 )
				SdramBurstCount <= 0;
			else
			begin
				if( LoadSdramBurstCount == 1 )
					SdramBurstCount <= BurstSize;
				else
					if( SDRAM_READ_REQ == 1 && SDRAM_READY == 1 && SdramBurstCount > 0 )
						SdramBurstCount <= SdramBurstCount - 1;
			end
		end
	end

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			DataInside <= 0;
		end
		else
		begin
			if( SDRAM_FIFO_WC > 16 )	// Always > 4
				DataInside <= 1;
			else
				DataInside <= 0;
				
		end
	end

// Block Read state machine: generate SDRAM_READ_REQ
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			req_fsm_idle <= 1;
			SDRAM_READ_REQ_x <= 0;
			LoadSdramBurstCount <= 0;
			Flushing <= 0;
			fsm_req_status <= 0;
		end
		else
		begin
			case( fsm_req_status )
			0:	begin
					SDRAM_READ_REQ_x <= 0;
					LoadSdramBurstCount <= 0;
					Flushing <= 0;
					if( ENABLE == 1 && SDRAM_READY == 1  &&
						(SDRAM_FIFO_WC > (BurstSize<<1)) && ((OutFifoSize - OUTPUT_FIFO_WC) > OutBurstSize) )
						begin
							fsm_req_status <= 1;
							req_fsm_idle <= 0;
						end
					else
						if( ENABLE == 1 && SDRAM_READY == 1  &&
							EMPTY_EVB == 1 && SDRAM_FIFO_WC > 0 && DataInside == 1 )	// New version
							begin
								fsm_req_status <= 5;
								req_fsm_idle <= 0;
							end
							else	
								req_fsm_idle <= 1;
				end
			1:	begin
					LoadSdramBurstCount <= 1;
					fsm_req_status <= 2;
				end
			2:	begin
					LoadSdramBurstCount <= 0;
					fsm_req_status <= 3;
				end
			3:	begin
					if( SDRAM_READY == 1 && SdramBurstCount > 0 && CAN_READ == 1 )
					begin
						SDRAM_READ_REQ_x <= 1;
					end
					else
						fsm_req_status <= 4;
				end
			4:	begin
					SDRAM_READ_REQ_x <= 0;
					if( SdramBurstCount == 0 )
						fsm_req_status <= 0;
					else
						fsm_req_status <= 3;
				end

				5:	begin // Handle SDRAM FIFO flushing if EVB FIFO is empty
					Flushing <= 1;
					if( SDRAM_READY == 1 && ((OutFifoSize - OUTPUT_FIFO_WC) > 1) )
						fsm_req_status <= 6;
				end
			6:	begin
					LoadSdramBurstCount <= 1;
					fsm_req_status <= 7;
				end
			7:	begin
					LoadSdramBurstCount <= 0;
					fsm_req_status <= 8;
				end
			8:	begin
					if( SDRAM_READY == 1 && SdramBurstCount > 0 && CAN_READ == 1 )
					begin
						SDRAM_READ_REQ_x <= 1;
					end
					else
					begin
//						if( SdramBurstCount == 0 && SDRAM_FIFO_WC == 0)
//							fsm_req_status <= 0;
//						else
							fsm_req_status <= 9;
					end
				end
			9:	begin
					SDRAM_READ_REQ_x <= 0;
					if( SdramBurstCount == 0 && SDRAM_FIFO_WC == 0)
						fsm_req_status <= 0;
					else
						fsm_req_status <= 5;
				end
				
			default: fsm_req_status <= 0;
			endcase
		end
	end

// Block Read state machine: generate odd_data
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			odd_data <= 0;
			fsm_rd_status <= 0;
		end
		else
		begin
			case( fsm_rd_status )
			0:	begin
					odd_data <= 0;
					if( ENABLE == 1 )
						fsm_rd_status <= 1;
				end
			1:	begin
					if( ENABLE == 0 || CLEAR_ADDR == 1 || (OUTPUT_FIFO_WR & OUTPUT_FIFO_EOB) )
						fsm_rd_status <= 0;
					if( SDRAM_DATA_VALID == 1 )
						odd_data <= ~odd_data;
				end
			default: fsm_rd_status <= 0;
			endcase
		end
	end

endmodule

module FastSdramFifoIf(RSTb, CLK, ENABLE, CLEAR_ADDR,
	SDRAM_WRITE_REQ, SDRAM_READY, SDRAM_READ_REQ, SDRAM_DATA_VALID,
	SDRAM_INPUT_DATA,
	SDRAM_ADDR, SDRAM_RDATA,
	SDRAM_WRITE_ADDRESS, SDRAM_READ_ADDRESS,
	SDRAM_WORD_COUNT, SDRAM_OVERRUN,
	USER_RE, USER_DATA, USER_64BIT, PACK_DATA,
	RD_EVB, WC_EVB, DATA_EVB, EMPTY_EVB, FULL_EVB,
	OUTPUT_FIFO_EMPTY, OUTPUT_FIFO_FULL, OUTPUT_FIFO_WC,
	LEVEL1_THRESHOLD, LEVEL2_THRESHOLD, FIFO_LEVEL1, FIFO_LEVEL2, OUTPUT_FIFO_FULL_L, DATA_TO_FIBER, FIFO_BLOCK_CNT,
	OFIFO_BLOCKWORDCOUNT_RD, OFIFO_BLOCKWORDCOUNT_EMPTY, OFIFO_BLOCKWORDCOUNT_FULL, OFIFO_BLOCKWORDCOUNT_Q
	);
input RSTb, CLK, ENABLE, CLEAR_ADDR;
output SDRAM_WRITE_REQ, SDRAM_READ_REQ;
input SDRAM_READY, SDRAM_DATA_VALID;
output [31:0] SDRAM_INPUT_DATA;
output [24:0] SDRAM_ADDR, SDRAM_WRITE_ADDRESS, SDRAM_READ_ADDRESS, SDRAM_WORD_COUNT;
input [31:0] SDRAM_RDATA;
output SDRAM_OVERRUN;
input USER_RE, USER_64BIT, PACK_DATA;
output RD_EVB;
output [63:0] USER_DATA;
input [11:0] WC_EVB;
input [23:0] DATA_EVB;
input EMPTY_EVB, FULL_EVB;
output OUTPUT_FIFO_EMPTY, OUTPUT_FIFO_FULL;
output [12:0] OUTPUT_FIFO_WC;
input [31:0] LEVEL1_THRESHOLD, LEVEL2_THRESHOLD;
output FIFO_LEVEL1, FIFO_LEVEL2, OUTPUT_FIFO_FULL_L;
output [31:0] DATA_TO_FIBER;
output [7:0] FIFO_BLOCK_CNT;
input OFIFO_BLOCKWORDCOUNT_RD;
output OFIFO_BLOCKWORDCOUNT_EMPTY;
output OFIFO_BLOCKWORDCOUNT_FULL;
output [19:0] OFIFO_BLOCKWORDCOUNT_Q;

reg [63:0] USER_DATA;
reg FIFO_LEVEL1, FIFO_LEVEL2, IncrBlockCounter, DecrBlockCounter, OutputFifoRdDly;
reg [7:0] FIFO_BLOCK_CNT;
reg BlockWordCountWrite;

wire WriteFsmIdle, ReadFsmIdle;
//wire GetFormattedData, FormattedDataNotAvailable, FormattedDataAvailable;
wire LoadMsb, LoadLsb, OutputFifoWr;
wire OutputFifoEndOfBlockIn, OutputFifoEndOfBlockOut;

wire [63:0] Data64Bit, DataOut64bit;
wire [31:0] SdramWordCount32;

assign DATA_TO_FIBER = {DataOut64bit[15:0], DataOut64bit[31:16]};	// Fiber interface does not need output register; why word swapping ???
//assign DATA_TO_FIBER = DataOut64bit[31:0];	// Fiber interface does not need output register

assign SdramWordCount32 = {7'h0, SDRAM_WORD_COUNT};

//assign FormattedDataAvailable = ~FormattedDataNotAvailable;


assign SDRAM_ADDR = WriteFsmIdle ? SDRAM_READ_ADDRESS : SDRAM_WRITE_ADDRESS;
//assign OutputFifoEndOfBlockIn = (Data64Bit[55:52] == 4'b0010 || Data64Bit[23:20] == 4'b0010) ? 1 : 0;	// 4'b0010 = {3'h1, 1'b0}
//assign OutputFifoEndOfBlockOut = (DataOut64bit[55:52] == 4'b0010 || DataOut64bit[23:20] == 4'b0010) ? 1 : 0;	// 4'b0010 = {3'h1, 1'b0}
assign OutputFifoEndOfBlockIn = (Data64Bit[23:20] == 4'b0010) ? 1 : 0;	// 4'b0010 = {3'h1, 1'b0}
assign OutputFifoEndOfBlockOut = (DataOut64bit[23:20] == 4'b0010) ? 1 : 0;	// 4'b0010 = {3'h1, 1'b0}

/*
Sdram2432Formatter EvbFormatter(.RSTb(RSTb), .CLK(CLK), .ENABLE(ENABLE),
	.SDRAM_WDATA(SDRAM_INPUT_DATA), .EMPTY_WDATA(FormattedDataNotAvailable), .NEXT_WDATA(GetFormattedData), 
	.RD_EVB(RD_EVB), .WC_EVB(WC_EVB), .DATA_EVB(DATA_EVB), .PACK_DATA(PACK_DATA)
	);
*/

assign SDRAM_INPUT_DATA = {8'h0, DATA_EVB};

SdramWriteMachine WriteHandler(.RSTb(RSTb), .CLK(CLK), .ENABLE(ENABLE), .CLEAR_ADDR(CLEAR_ADDR),
	.SDRAM_WRITE_REQ(SDRAM_WRITE_REQ), .SDRAM_READY(SDRAM_READY),
	.CAN_WRITE(ReadFsmIdle),	// From SdramReadMachine
	.FSM_IDLE(WriteFsmIdle),	// To SdramReadMachine
	.DATA_AVAILABLE(~EMPTY_EVB),// From EventBuilder
	.GET_NEXT_DATA(RD_EVB),		// To EventBuilder
//	.DATA_AVAILABLE(FormattedDataAvailable),	// From Sdram2432Formatter
//	.GET_NEXT_DATA(GetFormattedData),	// To Sdram2432Formatter
	.SDRAM_WRITE_ADDRESS(SDRAM_WRITE_ADDRESS)
	);

SdramBlockReadMachine ReadHandler(.RSTb(RSTb), .CLK(CLK), .ENABLE(ENABLE), .CLEAR_ADDR(CLEAR_ADDR),
	.SDRAM_READ_REQ(SDRAM_READ_REQ), .SDRAM_READY(SDRAM_READY), .SDRAM_DATA_VALID(SDRAM_DATA_VALID),
	.SDRAM_READ_ADDRESS(SDRAM_READ_ADDRESS), .SDRAM_FIFO_WC(SDRAM_WORD_COUNT),
	.CAN_READ(WriteFsmIdle),	// From SdramWriteMachine
	.FSM_IDLE(ReadFsmIdle),	// To SdramWriteMachine
	.LOAD_LSB(LoadLsb), .LOAD_MSB(LoadMsb), .USER_64BIT(USER_64BIT),
	.OUTPUT_FIFO_WR(OutputFifoWr), .OUTPUT_FIFO_WC(OUTPUT_FIFO_WC),
	.OUTPUT_FIFO_EMPTY(OUTPUT_FIFO_EMPTY), .OUTPUT_FIFO_FULL(OUTPUT_FIFO_FULL),
	.EMPTY_EVB(EMPTY_EVB), .OUTPUT_FIFO_EOB(OutputFifoEndOfBlockIn)
	);
	
Reg32 LsbDataReg(.RSTb(RSTb), .CLK(CLK), .LOAD(LoadLsb), .D(SDRAM_RDATA), .Q(Data64Bit[63:32]));
Reg32 MsbDataReg(.RSTb(RSTb), .CLK(CLK), .LOAD(LoadMsb), .D(SDRAM_RDATA), .Q(Data64Bit[31:0]));

ComputeWordCount WordCountCalculator(.RSTb(RSTb), .CLK(CLK), .CLEAR(CLEAR_ADDR),
	.SDRAM_WRITE_ADDRESS(SDRAM_WRITE_ADDRESS), .SDRAM_READ_ADDRESS(SDRAM_READ_ADDRESS),
	.WORD_COUNT(SDRAM_WORD_COUNT), .OVERRUN(SDRAM_OVERRUN));

Fifo_8192x64 OutputFifo(.aclr(~RSTb|CLEAR_ADDR), .clock(CLK),
	.data(Data64Bit), .wrreq(OutputFifoWr),
	.q(DataOut64bit), .rdreq(USER_RE),
	.empty(OUTPUT_FIFO_EMPTY), .full(OUTPUT_FIFO_FULL), .usedw(OUTPUT_FIFO_WC));

Fifo_16x20 OutputFifo_BlockWordCount(.aclr(~RSTb|CLEAR_ADDR), .clock(CLK),
	.data(Data64Bit[19:0]), .wrreq(BlockWordCountWrite),
	.empty(OFIFO_BLOCKWORDCOUNT_EMPTY), .full(OFIFO_BLOCKWORDCOUNT_FULL),
	.q(OFIFO_BLOCKWORDCOUNT_Q), .rdreq(OFIFO_BLOCKWORDCOUNT_RD));
	
SReg OutputFifoFullReg(.CK(CLK), .RSTb(RSTb), .CLR(CLEAR_ADDR), .SET(OUTPUT_FIFO_FULL), .OUT(OUTPUT_FIFO_FULL_L));

always @(posedge CLK)
	if( USER_RE )
		USER_DATA <= DataOut64bit;

always @(posedge CLK)
	if( (SdramWordCount32 > LEVEL1_THRESHOLD) && (LEVEL1_THRESHOLD > 0) )
		FIFO_LEVEL1 <= 1;
	else
		FIFO_LEVEL1 <= 0;

always @(posedge CLK)
	if( (SdramWordCount32 > LEVEL2_THRESHOLD) && (LEVEL2_THRESHOLD > 0) )
		FIFO_LEVEL2 <= 1;
	else
		FIFO_LEVEL2 <= 0;


always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		IncrBlockCounter <= 0;
		DecrBlockCounter <= 0;
		OutputFifoRdDly <= 0;
	end
	else
	begin
		OutputFifoRdDly <= USER_RE;
		case( {OutputFifoEndOfBlockIn, OutputFifoEndOfBlockOut, OutputFifoRdDly, OutputFifoWr} )
			4'b0000: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b0001: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b0010: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b0011: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			
			4'b0100: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b0101: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b0110: begin IncrBlockCounter <= 0; DecrBlockCounter <= 1; end
			4'b0111: begin IncrBlockCounter <= 0; DecrBlockCounter <= 1; end
			
			4'b1000: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b1001: begin IncrBlockCounter <= 1; DecrBlockCounter <= 0; end
			4'b1010: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b1011: begin IncrBlockCounter <= 1; DecrBlockCounter <= 0; end
			
			4'b1100: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
			4'b1101: begin IncrBlockCounter <= 1; DecrBlockCounter <= 0; end
			4'b1110: begin IncrBlockCounter <= 0; DecrBlockCounter <= 1; end
			4'b1111: begin IncrBlockCounter <= 0; DecrBlockCounter <= 0; end
		endcase
	end
end

always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
		BlockWordCountWrite <= 0;
	else
	begin
		if( OutputFifoEndOfBlockIn & OutputFifoWr )
			BlockWordCountWrite <= 1;
		else
			BlockWordCountWrite <= 0;
	end
end

// BLOCK Counter
always @(posedge CLK or negedge RSTb)
begin
	if( RSTb == 0 )
		FIFO_BLOCK_CNT <= 8'h0;
	else
	begin
		if( CLEAR_ADDR == 1 )
			FIFO_BLOCK_CNT <= 8'h0;
		else
		begin
			if( IncrBlockCounter == 1 && FIFO_BLOCK_CNT < 8'hFF )
				FIFO_BLOCK_CNT <= FIFO_BLOCK_CNT + 1;
			if( DecrBlockCounter == 1 && FIFO_BLOCK_CNT > 0 )
				FIFO_BLOCK_CNT <= FIFO_BLOCK_CNT - 1;
		end
	end
end

endmodule
