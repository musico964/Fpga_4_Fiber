/*
 * Revised version: avoid blocking while waiting events from faulty channels
forever
{
	<write Block Header>
	BlockWordCount = 1
	for(k=0; k<EventPerBlock; k++)
	{
		while( <EventCounterFifo is empty> )
			;
		<write Event Header>
		BlockWordCount++
		<write Trigger Time>	// 2 words
		BlockWordCount++
		BlockWordCount++
		EventWordCount = 3
		for(j=0; j<SamplePerEvent; j++)
		{
			<wait at least 1 channel has Event Present>
			<wait N (10-16) clock cycles, so all channels should have Event Present>
			for(i=0; i<16; i++)
			{
				if( ChannelEnabled[i] && EventPresent[i] )	// skip enabled channels that does not have event
				{
					while( ProcessedData[i] != <TRAILER> )	// TRAILER form ChannelProcessor
					{
						<write ProcessedData[i]>
						EventWordCount++
						BlockWordCount++
					}
					<write TRAILER>	// TRAILER form ChannelProcessor
					EventWordCount++
					BlockWordCount++
				}
			}
			Decrement	// to ChannelProcessor: get next available sample
			<write Event Trailer> // including EventWordCount and TriggerTdcTime
			BlockWordCount++
		}
	}
	if( <BlockWordCount is odd> )
	{
		<write filler word>
		BlockWordCount++
	}
	<increment BlockCount>
	<write Block Trailer>
}
*/

/* Data format (24 bit)
BLOCK_HEADER
	EVENT_HEADER
	TRIGGER_TIME1
	TRIGGER_TIME2
		APV_CH_DATA	// Sample 0
		...
		APV_CH_DATA	// Sample 1
		...
		APV_CH_DATA	// Sample N-1
		...
	EVENT_TRAILER

	EVENT_HEADER
	TRIGGER_TIME1
	TRIGGER_TIME2
		APV_CH_DATA
		...
	EVENT_TRAILER

	...

FILLER WORDS (if needed)
BLOCK_TRAILER
*/

/*
	64 bit x 3 = 192 / 24 = 8
	8 (24 bit) output words fill up 3 (64 bit) bus for data transfer
*/

// Max BLOCK_SIZE = 255 events * 16 channels * 131 words = 534480 < 2^20
// BlockWordCounter[19:0], EventWordCounter[11:0], EventCounter[19:0]
// MODULE_ID[4:0], EVENT_PER_BLOCK[7:0]

//`define SIZE_32

`ifdef SIZE_32
// Original 32-bit definition, compliant with Jlab DAQ (hope)
`define BLOCK_HEADER	{1'b1, 4'h0, MODULE_ID, 3'b0, EVENT_PER_BLOCK, BLOCK_CNT[10:0]}
`define BLOCK_TRAILER	{1'b1, 4'h1, MODULE_ID, 2'b0, BlockWordCounter}
`define EVENT_HEADER	{1'b1, 4'h2, 7'b0, EventCounterFifo_Data}
`define TRIGGER_TIME1	{1'b1, 4'h3, 3'b0, TimeCounterFifo_Data[47:24]}
`define TRIGGER_TIME2	{1'b0, 4'h0, 3'b0, TimeCounterFifo_Data[23:0]}	// why {1'b0, 4'h0, ...}? should be {1'b0, 4'h3, ...}!
`define APV_CH_DATA		{1'b1, 4'h4, 3'b0, 3'b000, ChannelData_a}	// ChannelData[23:21] = 3'b000
`define EVENT_TRAILER	{1'b1, 4'h5, 3'b0, EventWordCounter, 4'b0, TRIGGER_TIME_FIFO}
`define DATA_NOT_VALID	{1'b1, 4'hE, 27'b0}
`define FILLER_WORD		{1'b1, 4'hF, 27'b0}
`else
// Tentative 24-bit definition
// assuming TimeCounter[39:0] instead of [47:0]
`define BLOCK_HEADER	{3'h0, MODULE_ID, EVENT_PER_BLOCK, BLOCK_CNT[7:0]}
`define BLOCK_TRAILER	{3'h1, 1'b0, BlockWordCounter}
`define EVENT_HEADER	{3'h2, 1'b0, EventCounterFifo_Data}
`define TRIGGER_TIME1	{3'h3, 1'b0, TimeCounterFifo_Data[39:20]}
`define TRIGGER_TIME2	{3'h3, 1'b1, TimeCounterFifo_Data[19:0]}
`define APV_CH_DATA		{3'h4, ChannelData_a}
`define EVENT_TRAILER	{3'h5, 1'b0, LoopDataCounter[11:0], TRIGGER_TIME_FIFO}
`define DATA_NOT_VALID	{3'h6, 21'b0}
`define FILLER_WORD		{3'h7, 21'b0}
`endif

//`define MAX_LOOP_DATA	2128	// 133 * 16, should be 133 * enabled_channels
`define MAX_LOOP_DATA	35246	// 133 * 16 * 16, should be 133 * enabled_channels * SAMPLE_PER_EVENT


module EventBuilder(RSTb, TIME_CLK, CLK, TRIGGER, ALL_CLEAR, SAMPLE_PER_EVENT, EVENT_PER_BLOCK,
	ENABLE_MASK, ENABLE_EVBUILD,
	TRIGGER_TIME_FIFO, TRIGGER_TIME_FIFO_RD,
	CH_DATA0, CH_DATA1, CH_DATA2, CH_DATA3, CH_DATA4, CH_DATA5, CH_DATA6, CH_DATA7,
	CH_DATA8, CH_DATA9, CH_DATA10, CH_DATA11, CH_DATA12, CH_DATA13, CH_DATA14, CH_DATA15,
	DATA_RD, EVENT_PRESENT, DECREMENT_EVENT_COUNT, MODULE_ID,
	DATA_OUT, EMPTY, FULL, ALMOST_FULL, DATA_OUT_CNT, DATA_OUT_RD, EV_CNT, BLOCK_CNT,
	EVB_FIFO_FULL_L, EVENT_FIFO_FULL_L, TIME_FIFO_FULL_L
);

input RSTb, TIME_CLK, CLK, TRIGGER, ALL_CLEAR;
input [4:0] SAMPLE_PER_EVENT;
input [7:0] EVENT_PER_BLOCK;
input [15:0] ENABLE_MASK;
input ENABLE_EVBUILD;
input [7:0] TRIGGER_TIME_FIFO;
output TRIGGER_TIME_FIFO_RD;
input [20:0] CH_DATA0, CH_DATA1, CH_DATA2, CH_DATA3, CH_DATA4, CH_DATA5, CH_DATA6, CH_DATA7;
input [20:0] CH_DATA8, CH_DATA9, CH_DATA10, CH_DATA11, CH_DATA12, CH_DATA13, CH_DATA14, CH_DATA15;
output [15:0] DATA_RD;
input [15:0] EVENT_PRESENT;
output DECREMENT_EVENT_COUNT;
input [4:0] MODULE_ID;
`ifdef SIZE_32
output [31:0] DATA_OUT;
`else
output [23:0] DATA_OUT;
`endif
output EMPTY, FULL, ALMOST_FULL;
output [11:0] DATA_OUT_CNT;
input DATA_OUT_RD;
output [23:0] EV_CNT;
output [7:0] BLOCK_CNT;
output EVB_FIFO_FULL_L, EVENT_FIFO_FULL_L, TIME_FIFO_FULL_L;

reg [15:0] DATA_RD;
reg DECREMENT_EVENT_COUNT;
reg [7:0] BLOCK_CNT;

reg [19:0] EventCounter;
reg [19:0] BlockWordCounter;
reg [47:0] TimeCounter, AsyncTimeCounter;
reg [4:0] ChCounter;
reg [15:0] LoopDataCounter;
reg [7:0] LoopEventCounter;
reg [4:0] LoopSampleCounter;

reg [7:0] fsm_status;
//reg [31:0] data_bus;
reg [23:0] data_bus;
reg [11:0] DataWordCount;
reg [20:0] ChannelData_a;

wire AllEnabledChannelsHaveEvent;
reg EventCounterFifo_Read, TimeCounterFifo_Read, OutputFifo_Write;
wire EventCounterFifo_Empty, EventCounterFifo_Full, TimeCounterFifo_Empty, TimeCounterFifo_Full;
wire [19:0] EventCounterFifo_Data;
wire [47:0] TimeCounterFifo_Data;
reg trigger_pulse, old_trigger, old_trigger2;
reg clear_time_counter;
reg FifoReset, ClearLoopDataCounter;
reg IncrementBlockCounter, ClearBlockWordCounter;
wire [2:0] NumberFillerWords;
reg [2:0] FillerWordsCounter;
reg OutputFifoAlmostFull;
reg [3:0] ChannelWaitCounter;
wire AtLeastOneChannelHasEvent;


assign NumberFillerWords = BlockWordCounter[2:0];
assign AllEnabledChannelsHaveEvent = ((ENABLE_MASK & EVENT_PRESENT) == ENABLE_MASK) ? 1 : 0;
assign EV_CNT = {4'h0,EventCounter};
assign TRIGGER_TIME_FIFO_RD = DECREMENT_EVENT_COUNT;
assign ALMOST_FULL = OutputFifoAlmostFull;
assign AtLeastOneChannelHasEvent = |(ENABLE_MASK & EVENT_PRESENT);

always @(posedge CLK)
	OutputFifoAlmostFull <= (DATA_OUT_CNT[10:0] > (2048-384) ) ? 1 : 0;

always @(posedge CLK)
	FifoReset <= ~RSTb | ALL_CLEAR;

SReg EvbFifoFullReg(.CK(CLK), .RSTb(RSTb), .CLR(ALL_CLEAR), .SET(FULL), .OUT(EVB_FIFO_FULL_L));
SReg EventFifoFullReg(.CK(CLK), .RSTb(RSTb), .CLR(ALL_CLEAR), .SET(EventCounterFifo_Full), .OUT(EVENT_FIFO_FULL_L));
SReg TimeFifoFullReg(.CK(CLK), .RSTb(RSTb), .CLR(ALL_CLEAR), .SET(TimeCounterFifo_Full), .OUT(TIME_FIFO_FULL_L));

Fifo_16x20 EventCounterFifo(.aclr(FifoReset), .clock(CLK),
	.data(EventCounter), .wrreq(trigger_pulse),
	.q(EventCounterFifo_Data), .rdreq(EventCounterFifo_Read),
	.empty(EventCounterFifo_Empty), .full(EventCounterFifo_Full));

Fifo_16x48 TimeCounterFifo(.aclr(FifoReset), .clock(CLK),
	.data(TimeCounter), .wrreq(trigger_pulse),
	.q(TimeCounterFifo_Data), .rdreq(TimeCounterFifo_Read),
	.empty(TimeCounterFifo_Empty), .full(TimeCounterFifo_Full));

assign DATA_OUT_CNT[11] = FULL;
`ifdef SIZE_32
Fifo_2048x32 OutputFifo(.aclr(FifoReset), .clock(CLK),
	.data(data_bus), .wrreq(OutputFifo_Write),
	.q(DATA_OUT), .rdreq(DATA_OUT_RD),
	.empty(EMPTY), .full(FULL), .usedw(DATA_OUT_CNT[10:0]));
`else
Fifo_2048x24 OutputFifo(.aclr(FifoReset), .clock(CLK),
	.data(data_bus), .wrreq(OutputFifo_Write),
	.q(DATA_OUT), .rdreq(DATA_OUT_RD),
	.empty(EMPTY), .full(FULL), .usedw(DATA_OUT_CNT[10:0]));
`endif

// trigger_pulse
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			trigger_pulse <= 0;
			old_trigger <= 0;
			old_trigger2 <= 0;
		end
		else
		begin
			old_trigger <= TRIGGER;
			old_trigger2 <= old_trigger;
			if( old_trigger2 == 0 && old_trigger == 1 )
				trigger_pulse <= 1;
			else
				trigger_pulse <= 0;
		end
	end

// Data Counter (for loop checking)
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			LoopDataCounter <= 0;
		else
		begin
			if( ClearLoopDataCounter == 1 )
				LoopDataCounter <= 0;
			else
				if( |DATA_RD )
					LoopDataCounter <= LoopDataCounter + 1;
		end
	end

// EVENT Counter
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			EventCounter <= 20'h00001;
		else
		begin
			if( ALL_CLEAR == 1 )
				EventCounter <= 20'h00001;
			else
				if( trigger_pulse == 1 )
					EventCounter <= EventCounter + 1;
		end
	end

// BLOCK Counter
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			BLOCK_CNT <= 8'h0;
		else
		begin
			if( ALL_CLEAR == 1 )
				BLOCK_CNT <= 8'h0;
			else
				if( IncrementBlockCounter == 1 )
					BLOCK_CNT <= BLOCK_CNT + 1;
		end
	end

// BLOCK WORD Counter
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			BlockWordCounter <= 0;
		else
		begin
			if( ALL_CLEAR == 1 || ClearBlockWordCounter == 1 )
				BlockWordCounter <= 0;
			else
				if( OutputFifo_Write == 1 )
					BlockWordCounter <= BlockWordCounter + 1;
		end
	end

// TIME Counter
	always @(posedge TIME_CLK)
		clear_time_counter <= ALL_CLEAR;

	always @(posedge TIME_CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
			AsyncTimeCounter <= 0;
		else
		begin
			if( clear_time_counter == 1 )
				AsyncTimeCounter <= 0;
			else
				AsyncTimeCounter <= AsyncTimeCounter + 1;
		end
	end
// Everything must be synchronous with CLK
	always @(posedge CLK)
		TimeCounter <= AsyncTimeCounter;

// Channel Data Selector
	always @(*)
	begin
		case(ChCounter[3:0])
			4'd0:  ChannelData_a <= CH_DATA0;
			4'd1:  ChannelData_a <= CH_DATA1;
			4'd2:  ChannelData_a <= CH_DATA2;
			4'd3:  ChannelData_a <= CH_DATA3;
			4'd4:  ChannelData_a <= CH_DATA4;
			4'd5:  ChannelData_a <= CH_DATA5;
			4'd6:  ChannelData_a <= CH_DATA6;
			4'd7:  ChannelData_a <= CH_DATA7;
			4'd8:  ChannelData_a <= CH_DATA8;
			4'd9:  ChannelData_a <= CH_DATA9;
			4'd10: ChannelData_a <= CH_DATA10;
			4'd11: ChannelData_a <= CH_DATA11;
			4'd12: ChannelData_a <= CH_DATA12;
			4'd13: ChannelData_a <= CH_DATA13;
			4'd14: ChannelData_a <= CH_DATA14;
			4'd15: ChannelData_a <= CH_DATA15;
		endcase
	end

// Main FSM
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			DATA_RD <= 0;
			DECREMENT_EVENT_COUNT <= 0;
			ChCounter <= 0;
			EventCounterFifo_Read <= 0;
			TimeCounterFifo_Read <= 0;
			OutputFifo_Write <= 0;
			DataWordCount <= 0;
			data_bus <= 0;
			ClearLoopDataCounter <= 0;
			IncrementBlockCounter <= 0;
			ClearBlockWordCounter <= 0;
			LoopEventCounter <= 0;
			LoopSampleCounter <= 0;
			FillerWordsCounter <= 0;
			ChannelWaitCounter <= 0;
			fsm_status <= 0;
		end
		else
		begin
			case( fsm_status )
				0:	begin
/*
if( ALL_CLEAR == 1 )
begin
$display("@%0t EventBuilder SAMPLE_PER_EVENT: 0x%0x", $stime, SAMPLE_PER_EVENT);
$display("@%0t EventBuilder EVENT_PER_BLOCK: 0x%0x", $stime, EVENT_PER_BLOCK);
end
*/
						DATA_RD <= 0;
						DECREMENT_EVENT_COUNT <= 0;
						ChCounter <= 0;
						EventCounterFifo_Read <= 0;
						TimeCounterFifo_Read <= 0;
						OutputFifo_Write <= 0;
						DataWordCount <= 0;
						ClearLoopDataCounter <= 0;
						IncrementBlockCounter <= 0;
						ClearBlockWordCounter <= 1;
						LoopEventCounter <= 0;
						LoopSampleCounter <= 0;
						ChannelWaitCounter <= 0;
						if( ENABLE_EVBUILD == 1 && ALL_CLEAR == 0 )
							fsm_status <= 1;
					end
				1:	begin	// Starting sequence: BLOCK_HEADER
						data_bus <= `BLOCK_HEADER;
						ClearBlockWordCounter <= 0;
						if( ENABLE_EVBUILD == 0 || ALL_CLEAR == 1 )
							fsm_status <= 0;
						else
						begin
							if( ~EventCounterFifo_Empty )
							begin
$display("@%0t EventBuilder BLOCK_HEADER: 0x%0x", $stime, `BLOCK_HEADER);
								OutputFifo_Write <= 1;
								fsm_status <= 2;
							end
						end
					end
				2:	begin	// Start Event: EVENT_HEADER
$display("@%0t EventBuilder EVENT_HEADER: 0x%0x", $stime, `EVENT_HEADER);
						data_bus <= `EVENT_HEADER;
						OutputFifo_Write <= 1;
						EventCounterFifo_Read <= 1;
						fsm_status <= 3;
					end
				3:	begin
$display("@%0t EventBuilder TRIGGER_TIME1: 0x%0x", $stime, `TRIGGER_TIME1);
						data_bus <= `TRIGGER_TIME1;
						EventCounterFifo_Read <= 0;
						fsm_status <= 4;
					end
				4:	begin
$display("@%0t EventBuilder TRIGGER_TIME2: 0x%0x", $stime, `TRIGGER_TIME2);
						data_bus <= `TRIGGER_TIME2;
						TimeCounterFifo_Read <= 1;
						ClearLoopDataCounter <= 1;
						LoopSampleCounter <= 0;
						fsm_status <= 5;
					end
				5:	begin
						ChannelWaitCounter <= 0;
						TimeCounterFifo_Read <= 0;
						ClearLoopDataCounter <= 0;
						OutputFifo_Write <= 0;
						DECREMENT_EVENT_COUNT <= 0;
						if( AtLeastOneChannelHasEvent )		// Revised
							fsm_status <= 20;
//						if( AllEnabledChannelsHaveEvent )	// Original
//							fsm_status <= 6;
						else
						begin
							if( ENABLE_EVBUILD == 0 || ALL_CLEAR == 1 )
								fsm_status <= 0;
						end
						data_bus <= `APV_CH_DATA;
					end
				20: begin	// additional state for revised version
						ChannelWaitCounter <= ChannelWaitCounter + 1;
						if( ChannelWaitCounter == 15 )
							fsm_status <= 6;
					end
				6:	begin
						data_bus <= `APV_CH_DATA;
						DECREMENT_EVENT_COUNT <= 0;
//						if( ChCounter != 5'h10 && ENABLE_MASK[ChCounter[3:0]] == 0 )	// Original
// Revised: skip enabled channels without event (faulty cahnnels)
						if( ChCounter != 5'h10 && (ENABLE_MASK[ChCounter[3:0]] & EVENT_PRESENT[ChCounter[3:0]]) == 0 )
							ChCounter <= ChCounter + 1;
						else
						begin
							if( ChCounter == 5'h10 )
							begin
								LoopSampleCounter <= LoopSampleCounter + 1;
								fsm_status <= 10;
							end
							else
							begin
								fsm_status <= 17;
							end
						end
					end
				17:	begin	// Additional state to get better timing
						data_bus <= `APV_CH_DATA;
						if( OutputFifoAlmostFull == 0 )	// proceed only if there is room to store at least one complete frame
						begin
$display("@%0t EventBuilder LoopSampleCounter = %d, ChCounter = %d", $stime, LoopSampleCounter, ChCounter);
							DATA_RD[ChCounter[3:0]] <= 1;
							fsm_status <= 7;
						end
					end
				7:	begin	// Main copying loop
//$display("@%0t EventBuilder APV Data: 0x%0x", $stime, `APV_CH_DATA);
						data_bus <= `APV_CH_DATA;
						DataWordCount <= DataWordCount + 1;
						OutputFifo_Write <= 1;
						if( ChannelData_a[20:19] == 2'b11 || LoopDataCounter > `MAX_LOOP_DATA ) // Channel Trailer ID
						begin
$display("@%0t EventBuilder Channel Trailer[%d]: 0x%0x", $stime, ChCounter, `APV_CH_DATA);
							DATA_RD[ChCounter[3:0]] <= 0;
							fsm_status <= 8;
						end
						else
						begin
							if( ENABLE_EVBUILD == 0 || ALL_CLEAR == 1 )
								fsm_status <= 0;
						end
					end
				8:	begin
						data_bus <= `APV_CH_DATA;
						DataWordCount <= DataWordCount + 1;
						OutputFifo_Write <= 0;
						fsm_status <= 9;	// Write channel trailer
					end
				9:	begin
						data_bus <= `APV_CH_DATA;
						OutputFifo_Write <= 0;
						if( ChCounter != 5'h10 )
						begin
							ChCounter <= ChCounter + 1;
							fsm_status <= 6;
						end
						else
						begin
							LoopSampleCounter <= LoopSampleCounter + 1;
							fsm_status <= 10;
						end
					end
				10:	begin
						DECREMENT_EVENT_COUNT <= 1;
						ChCounter <= 0;
						if( LoopSampleCounter >= SAMPLE_PER_EVENT )
							fsm_status <= 11;
						else
							fsm_status <= 15;
					end
				11:	begin
						DECREMENT_EVENT_COUNT <= 0;
$display("@%0t EventBuilder Event Trailer: 0x%0x", $stime, `EVENT_TRAILER);
						data_bus <= `EVENT_TRAILER;
						OutputFifo_Write <= 1;
						LoopEventCounter <= LoopEventCounter + 1;
						fsm_status <= 12;
					end
				12:	begin
						OutputFifo_Write <= 0;
						if( LoopEventCounter >= EVENT_PER_BLOCK )
						begin
							data_bus <= `FILLER_WORD;
							FillerWordsCounter <= NumberFillerWords;
							fsm_status <= 13;
						end
						else
							if( ~EventCounterFifo_Empty )
							begin
//								data_bus <= `EVENT_HEADER;
								fsm_status <= 2;
							end
					end
				13:	begin	// Insert filler words if needed: TO BE CHECKED!!!
$display("@%0t EventBuilder Inserting %d filler words", $stime, FillerWordsCounter);
							OutputFifo_Write <= (FillerWordsCounter > 0) ? 1 : 0;
							if( FillerWordsCounter > 0 )
								FillerWordsCounter <= FillerWordsCounter - 1;
							else
							begin
								OutputFifo_Write <= 0;
								data_bus <= `BLOCK_TRAILER;
								fsm_status <= 14;
							end
					end
				14:	begin
$display("@%0t EventBuilder Block Trailer: 0x%0x", $stime, `BLOCK_TRAILER);
						IncrementBlockCounter <= 1;
						data_bus <= `BLOCK_TRAILER;
						OutputFifo_Write <= 1;
						fsm_status <= 0;
					end					
				15:	begin	// wait for AllEnabledChannelsHaveEvent update
						DECREMENT_EVENT_COUNT <= 0;
						fsm_status <= 16;
					end
				16:	begin
						fsm_status <= 5;
					end
				default: fsm_status <= 0;
			endcase
		end
	end

endmodule

