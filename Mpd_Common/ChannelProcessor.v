// RAM needed:
// 2 x 128x12  DPRAM	= 3072 bit	(Pedestal & Threshold) ALTSYNCRAM
// 1 x 1024x13 DCFIFO	= 13312 bit	(Frame Decoder Data output)
// 1 x 32x12   DCFIFO	= 384 bit	(Frame Decoder Mean output)
// 1 x 2048x21 SCFIFO	= 43008 bit	(Output data buffer)
// --------------------------------
// TOTAL		= 59776 bit

module ChannelProcessor(RSTb, CLK, CLK_APV, CH_ENABLE, ENABLE_BASE_SUB,
	ADC_PDATA, SYNC_PERIOD, COMMON_OFFSET, CH_ID,
	RAM_ADDRESS, RAM_DATA_IN, DATA_OUT, DATA_OUT_EVB, WE_PEDESTAL_RAM, WE_THRESHOLD_RAM, 
	RE_PEDESTAL_RAM, //RE_THRESHOLD_RAM,	// RE_THRESHOLD_RAM not used
	FIFO_RD, 	// FIFO_RD comes from VME (or other user interface) or Event Builder
	FIFO_USED_WORDS,
	EVENT_PRESENT, DECR_EVENT_COUNTER,
	SYNCED, ALL_CLEAR,
	DAQ_MODE, ZERO_VAL, ONE_VAL, NO_MORE_SPACE, FIFO_EMPTY, FIFO_FULL, MODULE_ID, MARKER_CH, SAMPLE_PER_EVENT,
	APV_FIFO_FULL_L, PROC_FIFO_FULL_L
);

input RSTb, CLK, CLK_APV, CH_ENABLE, ENABLE_BASE_SUB;
input [11:0] ADC_PDATA, COMMON_OFFSET;
input [3:0] CH_ID;
input [7:0] SYNC_PERIOD;
input [6:0] RAM_ADDRESS;
input [11:0]  RAM_DATA_IN;
output [20:0] DATA_OUT;
output [20:0] DATA_OUT_EVB;
input WE_PEDESTAL_RAM, WE_THRESHOLD_RAM, RE_PEDESTAL_RAM;//, RE_THRESHOLD_RAM;
input FIFO_RD;
output [11:0] FIFO_USED_WORDS;
output EVENT_PRESENT;
input DECR_EVENT_COUNTER;
output SYNCED;
input ALL_CLEAR;
input [2:0] DAQ_MODE;
input [11:0]  ZERO_VAL, ONE_VAL;
output NO_MORE_SPACE, FIFO_EMPTY, FIFO_FULL;
input [4:0] MODULE_ID;
input [7:0] MARKER_CH;
input [4:0] SAMPLE_PER_EVENT;
output  APV_FIFO_FULL_L, PROC_FIFO_FULL_L;

reg [11:0] FIFO_USED_WORDS;
reg FIFO_EMPTY, FIFO_FULL;

wire [6:0] pedestal_rd_address, threshold_rd_address;
wire [6:0] pedestal_internal_address, threshold_internal_address;
wire [11:0] pedestal_data, threshold_data, baseline;
wire [12:0] decoded_frame_data;
wire [20:0] output_fifo_data;
wire decoded_event_present, end_threshold_processing, decoded_frame_fifo_rd;
wire [11:0] OutputUsedWords, FrameDecoderUsedWords;
wire OutputFifoEmpty, OutputFifoFull, FrameDecoderFifoEmpty, FrameDecoderFifoFull;
//reg DisableMode, SampleMode, ApvReadoutMode_Simple, NoProcessorMode;
reg ApvReadoutMode_Processed;

always @(posedge CLK)
begin
//	DisableMode <= (DAQ_MODE == 3'b000) ? 1 : 0;
//	ApvReadoutMode_Simple <= (DAQ_MODE == 3'b001) ? 1 : 0;
//	SampleMode <= (DAQ_MODE == 3'b010) ? 1 : 0;
	ApvReadoutMode_Processed <= (DAQ_MODE == 3'b011) ? 1 : 0;
//	NoProcessorMode <= ApvReadoutMode_Simple | SampleMode;

	FIFO_USED_WORDS <= ApvReadoutMode_Processed ? OutputUsedWords : FrameDecoderUsedWords;
	FIFO_EMPTY <= ApvReadoutMode_Processed ? OutputFifoEmpty : FrameDecoderFifoEmpty;
	FIFO_FULL <= ApvReadoutMode_Processed ? OutputFifoFull : FrameDecoderFifoFull;
end

assign pedestal_rd_address = CH_ENABLE ? pedestal_internal_address : RAM_ADDRESS;
assign threshold_rd_address = CH_ENABLE ? threshold_internal_address : RAM_ADDRESS;
assign DATA_OUT = CH_ENABLE ? ( ApvReadoutMode_Processed ? output_fifo_data : {8'b0, decoded_frame_data}) :
	(RE_PEDESTAL_RAM ? {9'b0,pedestal_data} : {9'b0,threshold_data});
assign DATA_OUT_EVB = output_fifo_data;

SReg ApvFifoFullReg(.CK(CLK), .RSTb(RSTb), .CLR(ALL_CLEAR), .SET(FrameDecoderFifoFull), .OUT(APV_FIFO_FULL_L));
SReg ProcFifoFullReg(.CK(CLK), .RSTb(RSTb), .CLR(ALL_CLEAR), .SET(OutputFifoFull), .OUT(PROC_FIFO_FULL_L));

DpRam128x12 PedestalRam( .clock(CLK),
	.data(RAM_DATA_IN), .wraddress(RAM_ADDRESS), .wren(WE_PEDESTAL_RAM),
	.rdaddress(pedestal_rd_address), .q(pedestal_data));

DpRam128x12 ThresholdRam( .clock(CLK),
	.data(RAM_DATA_IN), .wraddress(RAM_ADDRESS), .wren(WE_THRESHOLD_RAM),
	.rdaddress(threshold_rd_address), .q(threshold_data));

ApvReadout ApvFrameDecoder(.RSTb(RSTb), .CLK(CLK_APV), .ENABLE(CH_ENABLE), .ADC_PDATA(ADC_PDATA),
	.SYNC_PERIOD(SYNC_PERIOD), .SYNCED(SYNCED), .ERROR(),
	.FIFO_DATA_OUT(decoded_frame_data),
	.FIFO_EMPTY(FrameDecoderFifoEmpty), .FIFO_FULL(FrameDecoderFifoFull),
	.FIFO_RD_CLK(CLK), .FIFO_RD(ApvReadoutMode_Processed ? decoded_frame_fifo_rd : FIFO_RD),
	.HIGH_ONE(ONE_VAL), .LOW_ZERO(ZERO_VAL), .FIFO_CLEAR(ALL_CLEAR),
	.DAQ_MODE(DAQ_MODE),
	.NO_MORE_SPACE_FOR_EVENT(NO_MORE_SPACE),
	.USED_FIFO_WORDS(FrameDecoderUsedWords),
	.ONE_MORE_EVENT(decoded_event_present),
	.PEDESTAL_ADDRESS(pedestal_internal_address), .PEDESTAL_DATA(pedestal_data),
	.OFFSET(COMMON_OFFSET), .MEAN(baseline), .RD_NEXT_MEAN(end_threshold_processing),
	.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT)
	);

BaselineSubtractorAndThresholdCut ThrSub(.RSTb(RSTb & ~ALL_CLEAR), .CLK(CLK),
	.ENABLE_BASE_SUB(ENABLE_BASE_SUB),
	.DATA_IN(decoded_frame_data), .FIFO_DATA_RD(decoded_frame_fifo_rd),
	.EVENT_PRESENT(decoded_event_present), .MEAN(baseline),
	.THRESHOLD_ADDRESS(threshold_internal_address), .THRESHOLD_DATA(threshold_data),
	.CH_ID(CH_ID),
	.FIFO_DATA_OUT(output_fifo_data), .OUT_FIFO_RD(FIFO_RD),
	.FIFO_EMPTY(OutputFifoEmpty), .FIFO_FULL(OutputFifoFull),
	.FIFO_USED_WORDS(OutputUsedWords),
	.END_PROCESSING(end_threshold_processing), .MODULE_ID(MODULE_ID)
	);

FiveBitCounter EvCounter(.RSTb(RSTb & ~ALL_CLEAR), .CLK(CLK), .INC(end_threshold_processing),
	.NON_ZERO(EVENT_PRESENT), .DEC(DECR_EVENT_COUNTER)
	);

endmodule


module BaselineSubtractorAndThresholdCut(RSTb, CLK, ENABLE_BASE_SUB,
	DATA_IN, FIFO_DATA_RD,
	EVENT_PRESENT, MEAN,
	THRESHOLD_ADDRESS, THRESHOLD_DATA, CH_ID,
	FIFO_DATA_OUT, OUT_FIFO_RD, FIFO_EMPTY, FIFO_FULL, FIFO_USED_WORDS,
	END_PROCESSING, MODULE_ID
);
input RSTb, CLK, ENABLE_BASE_SUB;
input [12:0] DATA_IN;
output FIFO_DATA_RD;
input EVENT_PRESENT;
input [11:0] MEAN;
output [6:0] THRESHOLD_ADDRESS;
input [11:0] THRESHOLD_DATA;
input [3:0] CH_ID;
output [20:0] FIFO_DATA_OUT;
input OUT_FIFO_RD;
output FIFO_EMPTY, FIFO_FULL, END_PROCESSING;
output [11:0] FIFO_USED_WORDS;
input [4:0] MODULE_ID;

reg FIFO_DATA_RD;
reg END_PROCESSING;
reg [7:0] ThrAddr;

reg fifo_out_wr, active_channel;
reg [20:0] fifo_data_in;
reg [7:0] word_count;
reg [7:0] fsm_status;

wire [11:0] enabled_mean;
wire [12:0] data_minus_baseline;

assign enabled_mean = ENABLE_BASE_SUB ? MEAN : 12'b0;
assign FIFO_USED_WORDS[11] = FIFO_FULL;
assign THRESHOLD_ADDRESS = ThrAddr[6:0];

Fifo_2048x21 TempFifo21( .aclr(~RSTb), .clock(CLK),
	.data(fifo_data_in), .wrreq(fifo_out_wr),
	.empty(FIFO_EMPTY), .full(FIFO_FULL), .rdreq(OUT_FIFO_RD), .q(FIFO_DATA_OUT),
	.usedw(FIFO_USED_WORDS[10:0]));

Sub13 BaselineSubtractor(.dataa(DATA_IN), .datab({1'b0,enabled_mean}),
	.result(data_minus_baseline));

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			FIFO_DATA_RD <= 0;
			ThrAddr <= 0;
			END_PROCESSING <= 0;
			fifo_out_wr <= 0;
			active_channel <= 0;
			fifo_data_in <= 0;
			word_count <= 0;
			fsm_status <= 0;
		end
		else
		begin
			case( fsm_status )
				0:	begin
						FIFO_DATA_RD <= 0;
						ThrAddr <= 0;
						END_PROCESSING <= 0;
						fifo_out_wr <= 0;
						word_count <= 2;
						if( EVENT_PRESENT == 1 )
						begin
							fifo_data_in <= {1'b0, 1'b0, 1'b0, MEAN[11], DATA_IN, CH_ID};
							FIFO_DATA_RD <= 1;
							fifo_out_wr <= 1;
							fsm_status <= 1;
						end
					end
				1:	begin
						fifo_data_in <= {1'b0, 1'b1, THRESHOLD_ADDRESS, data_minus_baseline[11:0]};
						fifo_out_wr <= 0;
						FIFO_DATA_RD <= 0;
						fsm_status <= 2;
					end
				2:	begin
						fifo_out_wr <= 0;
						FIFO_DATA_RD <= 0;
						if( THRESHOLD_DATA == 12'hFFF )
							active_channel <= 0;
						else
							active_channel <= 1;
						fsm_status <= 3;
					end
				3:	begin
						fifo_data_in <= {1'b0, 1'b1, THRESHOLD_ADDRESS, data_minus_baseline[11:0]};
						ThrAddr <= ThrAddr + 1;
						if( active_channel & (data_minus_baseline > THRESHOLD_DATA) )
						begin
							fifo_out_wr <= 1;
							word_count <= word_count + 1;
						end
						if( ThrAddr != 8'h80 )
						begin
							FIFO_DATA_RD <= 1;
							fsm_status <= 2;
						end
						else
						begin	// Handle trailer coming from preceding stage
							fifo_out_wr <= 1;
							fifo_data_in <= {1'b1, 1'b0, 2'b0, MODULE_ID, DATA_IN[11:0]};
//							fifo_data_in <= {1'b1, 1'b0, 6'b0, DATA_IN};
							FIFO_DATA_RD <= 0;
							fsm_status <= 4;
						end
					end
				4:	begin
						FIFO_DATA_RD <= 0;
						fifo_out_wr <= 0;
						fsm_status <= 5;
						END_PROCESSING <= 1;
					end
				5:	begin
						fifo_out_wr <= 1;
						fifo_data_in <= {1'b1, 1'b1, MEAN[10:0], word_count};	// Write TRAILER
						FIFO_DATA_RD <= 1;
						END_PROCESSING <= 0;
						fsm_status <= 6;
					end
				6:	begin
						FIFO_DATA_RD <= 0;
						fifo_out_wr <= 0;
						fsm_status <= 0;
					end
				default: fsm_status <= 0;
			endcase
		end
	end

endmodule



module FiveBitCounter(RSTb, CLK, INC, NON_ZERO, DEC);
input RSTb, CLK, INC, DEC;
output NON_ZERO;

reg [4:0] cnt;
reg NON_ZERO;

	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			cnt <= 0;
			NON_ZERO <= 0;
		end
		else
		begin
			NON_ZERO <= (cnt != 0) ? 1 : 0;
			if( INC == 1 && cnt != 5'h1F )
				cnt <= cnt + 1;
			else
				if( DEC == 1 && cnt != 5'h00 )
					cnt <= cnt - 1;
		end
	end
endmodule





module EightChannels(RSTb, APV_CLK, PROCESS_CLK, ENABLE, EN_BASELINE_SUBTRACTION,
	ADC_PDATA0, ADC_PDATA1, ADC_PDATA2, ADC_PDATA3,
	ADC_PDATA4, ADC_PDATA5, ADC_PDATA6, ADC_PDATA7,
	SYNC_PERIOD, SYNCED,
	COMMON_OFFSET,
	BANK_ID,
	FIFO_DATA_OUT0, FIFO_DATA_OUT1, FIFO_DATA_OUT2, FIFO_DATA_OUT3,
	FIFO_DATA_OUT4, FIFO_DATA_OUT5, FIFO_DATA_OUT6, FIFO_DATA_OUT7,
	DATA_TO_EVB0, DATA_TO_EVB1, DATA_TO_EVB2, DATA_TO_EVB3,
	DATA_TO_EVB4, DATA_TO_EVB5, DATA_TO_EVB6, DATA_TO_EVB7,
	FIFO_EMPTY, FIFO_FULL, FIFO_RD,
	HIGH_ONE, LOW_ZERO, ALL_CLEAR, DAQ_MODE,
	USED_FIFO_WORDS0, USED_FIFO_WORDS1, USED_FIFO_WORDS2, USED_FIFO_WORDS3,
	USED_FIFO_WORDS4, USED_FIFO_WORDS5, USED_FIFO_WORDS6, USED_FIFO_WORDS7,
	ONE_MORE_EVENT, DECR_EVENT_COUNTER,
	NO_MORE_SPACE, SPACE_AVAILABLE,
	RAM_ADDR, RAM_DIN, WE_PED_RAM, RE_PED_RAM, WE_THR_RAM,// RE_THR_RAM,
	MODULE_ID, MARKER_CH, SAMPLE_PER_EVENT,
	APV_FIFO_FULL_L, PROC_FIFO_FULL_L
	);

input RSTb, APV_CLK, PROCESS_CLK;
input [7:0] ENABLE;
input EN_BASELINE_SUBTRACTION;
input [11:0] ADC_PDATA0, ADC_PDATA1, ADC_PDATA2, ADC_PDATA3;
input [11:0] ADC_PDATA4, ADC_PDATA5, ADC_PDATA6, ADC_PDATA7;
input [7:0] SYNC_PERIOD;
output [7:0] SYNCED;
input [11:0] COMMON_OFFSET;
input BANK_ID;
output [20:0] FIFO_DATA_OUT0, FIFO_DATA_OUT1, FIFO_DATA_OUT2, FIFO_DATA_OUT3;
output [20:0] FIFO_DATA_OUT4, FIFO_DATA_OUT5, FIFO_DATA_OUT6, FIFO_DATA_OUT7;
output [20:0] DATA_TO_EVB0, DATA_TO_EVB1, DATA_TO_EVB2, DATA_TO_EVB3;
output [20:0] DATA_TO_EVB4, DATA_TO_EVB5, DATA_TO_EVB6, DATA_TO_EVB7;
output [7:0] FIFO_EMPTY, FIFO_FULL;
input [7:0] FIFO_RD;
input [11:0] HIGH_ONE, LOW_ZERO;
input ALL_CLEAR;
input [2:0] DAQ_MODE;
output [11:0] USED_FIFO_WORDS0, USED_FIFO_WORDS1, USED_FIFO_WORDS2, USED_FIFO_WORDS3;
output [11:0] USED_FIFO_WORDS4, USED_FIFO_WORDS5, USED_FIFO_WORDS6, USED_FIFO_WORDS7;
output [7:0] ONE_MORE_EVENT;
input DECR_EVENT_COUNTER;
output NO_MORE_SPACE, SPACE_AVAILABLE;
input [6:0] RAM_ADDR;
input [31:0] RAM_DIN;
input [7:0] WE_PED_RAM, RE_PED_RAM, WE_THR_RAM;//, RE_THR_RAM;
input [4:0] MODULE_ID;
input [7:0] MARKER_CH;
input [4:0] SAMPLE_PER_EVENT;
output [7:0] APV_FIFO_FULL_L, PROC_FIFO_FULL_L;

wire [7:0] no_space;

assign NO_MORE_SPACE = |no_space;
assign SPACE_AVAILABLE = &(~no_space);

	ChannelProcessor Ch0(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[0]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA0), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd0}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT0), .DATA_OUT_EVB(DATA_TO_EVB0),
		.WE_PEDESTAL_RAM(WE_PED_RAM[0]), .WE_THRESHOLD_RAM(WE_THR_RAM[0]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[0]), //.RE_THRESHOLD_RAM(RE_THR_RAM[0]),
		.FIFO_RD(FIFO_RD[0]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS0),
		.EVENT_PRESENT(ONE_MORE_EVENT[0]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[0]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[0]),
		.FIFO_EMPTY(FIFO_EMPTY[0]), .FIFO_FULL(FIFO_FULL[0]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[0]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[0])
	);
	ChannelProcessor Ch1(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[1]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA1), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd1}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT1), .DATA_OUT_EVB(DATA_TO_EVB1),
		.WE_PEDESTAL_RAM(WE_PED_RAM[1]), .WE_THRESHOLD_RAM(WE_THR_RAM[1]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[1]), //.RE_THRESHOLD_RAM(RE_THR_RAM[1]),
		.FIFO_RD(FIFO_RD[1]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS1),
		.EVENT_PRESENT(ONE_MORE_EVENT[1]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[1]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[1]),
		.FIFO_EMPTY(FIFO_EMPTY[1]), .FIFO_FULL(FIFO_FULL[1]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[1]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[1])
	);

	ChannelProcessor Ch2(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[2]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA2), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd2}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT2), .DATA_OUT_EVB(DATA_TO_EVB2),
		.WE_PEDESTAL_RAM(WE_PED_RAM[2]), .WE_THRESHOLD_RAM(WE_THR_RAM[2]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[2]), //.RE_THRESHOLD_RAM(RE_THR_RAM[2]),
		.FIFO_RD(FIFO_RD[2]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS2),
		.EVENT_PRESENT(ONE_MORE_EVENT[2]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[2]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[2]),
		.FIFO_EMPTY(FIFO_EMPTY[2]), .FIFO_FULL(FIFO_FULL[2]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[2]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[2])
	);
	ChannelProcessor Ch3(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[3]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA3), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd3}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT3), .DATA_OUT_EVB(DATA_TO_EVB3),
		.WE_PEDESTAL_RAM(WE_PED_RAM[3]), .WE_THRESHOLD_RAM(WE_THR_RAM[3]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[3]), //.RE_THRESHOLD_RAM(RE_THR_RAM[3]),
		.FIFO_RD(FIFO_RD[3]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS3),
		.EVENT_PRESENT(ONE_MORE_EVENT[3]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[3]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[3]),
		.FIFO_EMPTY(FIFO_EMPTY[3]), .FIFO_FULL(FIFO_FULL[3]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[3]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[3])
	);

	ChannelProcessor Ch4(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[4]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA4), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd4}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT4), .DATA_OUT_EVB(DATA_TO_EVB4),
		.WE_PEDESTAL_RAM(WE_PED_RAM[4]), .WE_THRESHOLD_RAM(WE_THR_RAM[4]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[4]), //.RE_THRESHOLD_RAM(RE_THR_RAM[4]),
		.FIFO_RD(FIFO_RD[4]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS4),
		.EVENT_PRESENT(ONE_MORE_EVENT[4]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[4]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[4]),
		.FIFO_EMPTY(FIFO_EMPTY[4]), .FIFO_FULL(FIFO_FULL[4]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[4]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[4])
	);
	ChannelProcessor Ch5(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[5]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA5), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd5}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT5), .DATA_OUT_EVB(DATA_TO_EVB5),
		.WE_PEDESTAL_RAM(WE_PED_RAM[5]), .WE_THRESHOLD_RAM(WE_THR_RAM[5]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[5]), //.RE_THRESHOLD_RAM(RE_THR_RAM[5]),
		.FIFO_RD(FIFO_RD[5]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS5),
		.EVENT_PRESENT(ONE_MORE_EVENT[5]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[5]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[5]),
		.FIFO_EMPTY(FIFO_EMPTY[5]), .FIFO_FULL(FIFO_FULL[5]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[5]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[5])
	);

	ChannelProcessor Ch6(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[6]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA6), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd6}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT6), .DATA_OUT_EVB(DATA_TO_EVB6),
		.WE_PEDESTAL_RAM(WE_PED_RAM[6]), .WE_THRESHOLD_RAM(WE_THR_RAM[6]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[6]), //.RE_THRESHOLD_RAM(RE_THR_RAM[6]),
		.FIFO_RD(FIFO_RD[6]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS6),
		.EVENT_PRESENT(ONE_MORE_EVENT[6]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[6]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[6]),
		.FIFO_EMPTY(FIFO_EMPTY[6]), .FIFO_FULL(FIFO_FULL[6]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[6]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[6])
	);
	ChannelProcessor Ch7(.RSTb(RSTb), .CLK(PROCESS_CLK), .CLK_APV(APV_CLK),
		.CH_ENABLE(ENABLE[7]), .ENABLE_BASE_SUB(EN_BASELINE_SUBTRACTION),
		.ADC_PDATA(ADC_PDATA7), .SYNC_PERIOD(SYNC_PERIOD), .COMMON_OFFSET(COMMON_OFFSET),
		.CH_ID({BANK_ID, 3'd7}),
		.RAM_ADDRESS(RAM_ADDR), .RAM_DATA_IN(RAM_DIN[11:0]), .DATA_OUT(FIFO_DATA_OUT7), .DATA_OUT_EVB(DATA_TO_EVB7),
		.WE_PEDESTAL_RAM(WE_PED_RAM[7]), .WE_THRESHOLD_RAM(WE_THR_RAM[7]), 
		.RE_PEDESTAL_RAM(RE_PED_RAM[7]), //.RE_THRESHOLD_RAM(RE_THR_RAM[7]),
		.FIFO_RD(FIFO_RD[7]),
		.FIFO_USED_WORDS(USED_FIFO_WORDS7),
		.EVENT_PRESENT(ONE_MORE_EVENT[7]), .DECR_EVENT_COUNTER(DECR_EVENT_COUNTER),
		.SYNCED(SYNCED[7]), .ALL_CLEAR(ALL_CLEAR),
		.DAQ_MODE(DAQ_MODE), .ZERO_VAL(LOW_ZERO), .ONE_VAL(HIGH_ONE),
		.NO_MORE_SPACE(no_space[7]),
		.FIFO_EMPTY(FIFO_EMPTY[7]), .FIFO_FULL(FIFO_FULL[7]), .MODULE_ID(MODULE_ID),
		.MARKER_CH(MARKER_CH), .SAMPLE_PER_EVENT(SAMPLE_PER_EVENT),
		.APV_FIFO_FULL_L(APV_FIFO_FULL_L[7]), .PROC_FIFO_FULL_L(PROC_FIFO_FULL_L[7])
	);

endmodule


module FifoIf(FIFO_RD,
	FIFO_DATA_OUT0, FIFO_DATA_OUT1, FIFO_DATA_OUT2, FIFO_DATA_OUT3,
	FIFO_DATA_OUT4, FIFO_DATA_OUT5, FIFO_DATA_OUT6, FIFO_DATA_OUT7,
	FIFO_DATA_OUT8, FIFO_DATA_OUT9, FIFO_DATA_OUT10, FIFO_DATA_OUT11,
	FIFO_DATA_OUT12, FIFO_DATA_OUT13, FIFO_DATA_OUT14, FIFO_DATA_OUT15,
	USED_FIFO_WORDS0, USED_FIFO_WORDS1, USED_FIFO_WORDS2, USED_FIFO_WORDS3,
	USED_FIFO_WORDS4, USED_FIFO_WORDS5, USED_FIFO_WORDS6, USED_FIFO_WORDS7,
	USED_FIFO_WORDS8, USED_FIFO_WORDS9, USED_FIFO_WORDS10, USED_FIFO_WORDS11,
	USED_FIFO_WORDS12, USED_FIFO_WORDS13, USED_FIFO_WORDS14, USED_FIFO_WORDS15,
	FIFO_EMPTY, FIFO_FULL, SYNCED, ERROR,
	RSTb, CLK, WEb, REb, OEb,
	FIFO_CEb, THR_CEb, PED_CEb, OBUF_STATUS_CEb,
	USER_ADDR, DATA_OUT,
	MISSED_TRIGGER, INCOMING_TRIGGER_CNT,
	WE_PED_RAM, RE_PED_RAM, WE_THR_RAM, //RE_THR_RAM,
	EV_BUILDER_DATA_OUT, EV_BUILDER_ENABLE,
	EV_BUILDER_FIFO_EMPTY, EV_BUILDER_FIFO_FULL,
	EV_BUILDER_FIFO_WC, EV_BUILDER_EV_CNT, EV_BUILDER_BLOCK_CNT,
	TRIGGER_COUNTER, SDRAM_INITIALIZED,
	TRIGGER_TIME_FIFO_RD, TRIGGER_TIME_FIFO,
	TRIGGER_TIME_FIFO_FULL, TRIGGER_TIME_FIFO_EMPTY,
	SDRAM_FIFO_WRITE_ADDRESS, SDRAM_FIFO_READ_ADDRESS, SDRAM_FIFO_OVERRUN, SDRAM_FIFO_WORDCOUNT,
	OUTPUT_FIFO_FULL, OUTPUT_FIFO_EMPTY, OUTPUT_FIFO_WC,
	APV_FIFO_FULL_L, PROC_FIFO_FULL_L,
	OUTPUT_FIFO_FULL_L, EVB_FIFO_FULL_L, EVENT_FIFO_FULL_L, TIME_FIFO_FULL_L
);

output [15:0] FIFO_RD;
input [20:0] FIFO_DATA_OUT0, FIFO_DATA_OUT1, FIFO_DATA_OUT2, FIFO_DATA_OUT3;
input [20:0] FIFO_DATA_OUT4, FIFO_DATA_OUT5, FIFO_DATA_OUT6, FIFO_DATA_OUT7;
input [20:0] FIFO_DATA_OUT8, FIFO_DATA_OUT9, FIFO_DATA_OUT10, FIFO_DATA_OUT11;
input [20:0] FIFO_DATA_OUT12, FIFO_DATA_OUT13, FIFO_DATA_OUT14, FIFO_DATA_OUT15;
input [11:0] USED_FIFO_WORDS0, USED_FIFO_WORDS1, USED_FIFO_WORDS2, USED_FIFO_WORDS3;
input [11:0] USED_FIFO_WORDS4, USED_FIFO_WORDS5, USED_FIFO_WORDS6, USED_FIFO_WORDS7;
input [11:0] USED_FIFO_WORDS8, USED_FIFO_WORDS9, USED_FIFO_WORDS10, USED_FIFO_WORDS11;
input [11:0] USED_FIFO_WORDS12, USED_FIFO_WORDS13, USED_FIFO_WORDS14, USED_FIFO_WORDS15;
input [15:0] FIFO_EMPTY, FIFO_FULL, SYNCED, ERROR;
input RSTb, CLK, WEb, REb, OEb, FIFO_CEb, THR_CEb, PED_CEb, OBUF_STATUS_CEb;
input [15:0] USER_ADDR;
output [31:0] DATA_OUT;
input [31:0] MISSED_TRIGGER, INCOMING_TRIGGER_CNT;
output [15:0] WE_PED_RAM, RE_PED_RAM, WE_THR_RAM;//, RE_THR_RAM;
input [23:0] EV_BUILDER_DATA_OUT;
input EV_BUILDER_ENABLE;
input EV_BUILDER_FIFO_EMPTY, EV_BUILDER_FIFO_FULL;
input [15:0] EV_BUILDER_FIFO_WC;
input [23:0] EV_BUILDER_EV_CNT;
input [7:0] EV_BUILDER_BLOCK_CNT;

input [31:0] TRIGGER_COUNTER;
input SDRAM_INITIALIZED;
output TRIGGER_TIME_FIFO_RD;
input [7:0] TRIGGER_TIME_FIFO;
input TRIGGER_TIME_FIFO_FULL, TRIGGER_TIME_FIFO_EMPTY;
input [24:0] SDRAM_FIFO_WRITE_ADDRESS, SDRAM_FIFO_READ_ADDRESS, SDRAM_FIFO_WORDCOUNT;
input SDRAM_FIFO_OVERRUN, OUTPUT_FIFO_FULL, OUTPUT_FIFO_EMPTY;
input [12:0] OUTPUT_FIFO_WC;
input [15:0] APV_FIFO_FULL_L, PROC_FIFO_FULL_L;
input OUTPUT_FIFO_FULL_L, EVB_FIFO_FULL_L, EVENT_FIFO_FULL_L, TIME_FIFO_FULL_L;


reg [15:0] FIFO_RD;
reg [31:0] int_data, int_data_Latched;
reg [15:0] WE_PED_RAM, RE_PED_RAM, WE_THR_RAM;//, RE_THR_RAM;
reg TRIGGER_TIME_FIFO_RD;

assign DATA_OUT = int_data_Latched;

always @(*)
begin
	int_data_Latched <= int_data_Latched;
	if( REb == 0 )
		int_data_Latched <= int_data;
end

always @(*)
begin
	FIFO_RD <= 16'b0;
	casex( USER_ADDR )
		16'b0100_0???_????_????: FIFO_RD[0] <= ~REb & ~FIFO_CEb;	// 0x10000..0x11FFC
		16'b0100_1???_????_????: FIFO_RD[1] <= ~REb & ~FIFO_CEb;	// 0x12000..0x13FFC
		16'b0101_0???_????_????: FIFO_RD[2] <= ~REb & ~FIFO_CEb;	// 0x14000..0x15FFC
		16'b0101_1???_????_????: FIFO_RD[3] <= ~REb & ~FIFO_CEb;	// 0x16000..0x17FFC
		16'b0110_0???_????_????: FIFO_RD[4] <= ~REb & ~FIFO_CEb;	// 0x18000..0x19FFC
		16'b0110_1???_????_????: FIFO_RD[5] <= ~REb & ~FIFO_CEb;	// 0x1A000..0x1BFFC
		16'b0111_0???_????_????: FIFO_RD[6] <= ~REb & ~FIFO_CEb;	// 0x1C000..0x1DFFC
		16'b0111_1???_????_????: FIFO_RD[7] <= ~REb & ~FIFO_CEb;	// 0x1E000..0x1FFFC
		16'b1000_0???_????_????: FIFO_RD[8] <= ~REb & ~FIFO_CEb;	// 0x20000..0x21FFC
		16'b1000_1???_????_????: FIFO_RD[9] <= ~REb & ~FIFO_CEb;	// 0x22000..0x23FFC
		16'b1001_0???_????_????: FIFO_RD[10] <= ~REb & ~FIFO_CEb;	// 0x24000..0x24FFC
		16'b1001_1???_????_????: FIFO_RD[11] <= ~REb & ~FIFO_CEb;	// 0x26000..0x27FFC
		16'b1010_0???_????_????: FIFO_RD[12] <= ~REb & ~FIFO_CEb;	// 0x28000..0x29FFC
		16'b1010_1???_????_????: FIFO_RD[13] <= ~REb & ~FIFO_CEb;	// 0x2A000..0x2BFFC
		16'b1011_0???_????_????: FIFO_RD[14] <= ~REb & ~FIFO_CEb;	// 0x2C000..0x2DFFC
		16'b1011_1???_????_????: FIFO_RD[15] <= ~REb & ~FIFO_CEb;	// 0x2E000..0x2FFFC
		default: FIFO_RD <= 16'b0;
	endcase
end

always @(*)
begin
	RE_PED_RAM <= 16'b0;
	casex( USER_ADDR )
/*
		16'b1101_0000_0???_????: RE_PED_RAM[0] <= ~REb & ~PED_CEb;	// 0x34000..0x341FC
		16'b1101_0000_1???_????: RE_PED_RAM[1] <= ~REb & ~PED_CEb;	// 0x34200..0x343FC
		16'b1101_0001_0???_????: RE_PED_RAM[2] <= ~REb & ~PED_CEb;	// 0x34400..0x345FC
		16'b1101_0001_1???_????: RE_PED_RAM[3] <= ~REb & ~PED_CEb;	// 0x34600..0x347FC
		16'b1101_0010_0???_????: RE_PED_RAM[4] <= ~REb & ~PED_CEb;	// 0x34800..0x349FC
		16'b1101_0010_1???_????: RE_PED_RAM[5] <= ~REb & ~PED_CEb;	// 0x34A00..0x34BFC
		16'b1101_0011_0???_????: RE_PED_RAM[6] <= ~REb & ~PED_CEb;	// 0x34C00..0x34DFC
		16'b1101_0011_1???_????: RE_PED_RAM[7] <= ~REb & ~PED_CEb;	// 0x34E00..0x34FFC
		16'b1101_0100_0???_????: RE_PED_RAM[8] <= ~REb & ~PED_CEb;	// 0x35000..0x351FC
		16'b1101_0100_1???_????: RE_PED_RAM[9] <= ~REb & ~PED_CEb;	// 0x35200..0x353FC
		16'b1101_0101_0???_????: RE_PED_RAM[10] <= ~REb & ~PED_CEb;	// 0x35400..0x355FC
		16'b1101_0101_1???_????: RE_PED_RAM[11] <= ~REb & ~PED_CEb;	// 0x35600..0x357FC
		16'b1101_0110_0???_????: RE_PED_RAM[12] <= ~REb & ~PED_CEb;	// 0x35800..0x359FC
		16'b1101_0110_1???_????: RE_PED_RAM[13] <= ~REb & ~PED_CEb;	// 0x35A00..0x35BFC
		16'b1101_0111_0???_????: RE_PED_RAM[14] <= ~REb & ~PED_CEb;	// 0x35C00..0x35DFC
		16'b1101_0111_1???_????: RE_PED_RAM[15] <= ~REb & ~PED_CEb;	// 0x35E00..0x35FFC
*/
		16'b1101_0000_0???_????: RE_PED_RAM[0] <= ~PED_CEb;		// 0x34000..0x341FC
		16'b1101_0000_1???_????: RE_PED_RAM[1] <= ~PED_CEb;		// 0x34200..0x343FC
		16'b1101_0001_0???_????: RE_PED_RAM[2] <= ~PED_CEb;		// 0x34400..0x345FC
		16'b1101_0001_1???_????: RE_PED_RAM[3] <= ~PED_CEb;		// 0x34600..0x347FC
		16'b1101_0010_0???_????: RE_PED_RAM[4] <= ~PED_CEb;		// 0x34800..0x349FC
		16'b1101_0010_1???_????: RE_PED_RAM[5] <= ~PED_CEb;		// 0x34A00..0x34BFC
		16'b1101_0011_0???_????: RE_PED_RAM[6] <= ~PED_CEb;		// 0x34C00..0x34DFC
		16'b1101_0011_1???_????: RE_PED_RAM[7] <= ~PED_CEb;		// 0x34E00..0x34FFC
		16'b1101_0100_0???_????: RE_PED_RAM[8] <= ~PED_CEb;		// 0x35000..0x351FC
		16'b1101_0100_1???_????: RE_PED_RAM[9] <= ~PED_CEb;		// 0x35200..0x353FC
		16'b1101_0101_0???_????: RE_PED_RAM[10] <= ~PED_CEb;	// 0x35400..0x355FC
		16'b1101_0101_1???_????: RE_PED_RAM[11] <= ~PED_CEb;	// 0x35600..0x357FC
		16'b1101_0110_0???_????: RE_PED_RAM[12] <= ~PED_CEb;	// 0x35800..0x359FC
		16'b1101_0110_1???_????: RE_PED_RAM[13] <= ~PED_CEb;	// 0x35A00..0x35BFC
		16'b1101_0111_0???_????: RE_PED_RAM[14] <= ~PED_CEb;	// 0x35C00..0x35DFC
		16'b1101_0111_1???_????: RE_PED_RAM[15] <= ~PED_CEb;	// 0x35E00..0x35FFC

		default: RE_PED_RAM <= 8'b0;
	endcase
end

/* RE_THR_RAM not used!
always @(*)
begin
	RE_THR_RAM <= 16'b0;
	casex( USER_ADDR )
		16'b1101_1000_0???_????: RE_THR_RAM[0] <= ~REb & ~THR_CEb;	// 0x36000..0x361FC
		16'b1101_1000_1???_????: RE_THR_RAM[1] <= ~REb & ~THR_CEb;	// 0x36200..0x363FC
		16'b1101_1001_0???_????: RE_THR_RAM[2] <= ~REb & ~THR_CEb;	// 0x36400..0x365FC
		16'b1101_1001_1???_????: RE_THR_RAM[3] <= ~REb & ~THR_CEb;	// 0x36600..0x367FC
		16'b1101_1010_0???_????: RE_THR_RAM[4] <= ~REb & ~THR_CEb;	// 0x36800..0x369FC
		16'b1101_1010_1???_????: RE_THR_RAM[5] <= ~REb & ~THR_CEb;	// 0x36A00..0x36BFC
		16'b1101_1011_0???_????: RE_THR_RAM[6] <= ~REb & ~THR_CEb;	// 0x36C00..0x36DFC
		16'b1101_1011_1???_????: RE_THR_RAM[7] <= ~REb & ~THR_CEb;	// 0x36E00..0x36FFC
		16'b1101_1100_0???_????: RE_THR_RAM[8] <= ~REb & ~THR_CEb;	// 0x37000..0x371FC
		16'b1101_1100_1???_????: RE_THR_RAM[9] <= ~REb & ~THR_CEb;	// 0x37200..0x373FC
		16'b1101_1101_0???_????: RE_THR_RAM[10] <= ~REb & ~THR_CEb;	// 0x37400..0x375FC
		16'b1101_1101_1???_????: RE_THR_RAM[11] <= ~REb & ~THR_CEb;	// 0x37600..0x377FC
		16'b1101_1110_0???_????: RE_THR_RAM[12] <= ~REb & ~THR_CEb;	// 0x37800..0x379FC
		16'b1101_1110_1???_????: RE_THR_RAM[13] <= ~REb & ~THR_CEb;	// 0x37A00..0x37BFC
		16'b1101_1111_0???_????: RE_THR_RAM[14] <= ~REb & ~THR_CEb;	// 0x37C00..0x37DFC
		16'b1101_1111_1???_????: RE_THR_RAM[15] <= ~REb & ~THR_CEb;	// 0x37E00..0x37FFC
		default: RE_THR_RAM <= 8'b0;
	endcase
end
*/

always @(*)
begin
	WE_PED_RAM <= 16'b0;
	casex( USER_ADDR )
		16'b1101_0000_0???_????: WE_PED_RAM[0] <= ~WEb & ~PED_CEb;	// 0x34000..0x341FC
		16'b1101_0000_1???_????: WE_PED_RAM[1] <= ~WEb & ~PED_CEb;	// 0x34200..0x343FC
		16'b1101_0001_0???_????: WE_PED_RAM[2] <= ~WEb & ~PED_CEb;	// 0x34400..0x345FC
		16'b1101_0001_1???_????: WE_PED_RAM[3] <= ~WEb & ~PED_CEb;	// 0x34600..0x347FC
		16'b1101_0010_0???_????: WE_PED_RAM[4] <= ~WEb & ~PED_CEb;	// 0x34800..0x349FC
		16'b1101_0010_1???_????: WE_PED_RAM[5] <= ~WEb & ~PED_CEb;	// 0x34A00..0x34BFC
		16'b1101_0011_0???_????: WE_PED_RAM[6] <= ~WEb & ~PED_CEb;	// 0x34C00..0x34DFC
		16'b1101_0011_1???_????: WE_PED_RAM[7] <= ~WEb & ~PED_CEb;	// 0x34E00..0x34FFC
		16'b1101_0100_0???_????: WE_PED_RAM[8] <= ~WEb & ~PED_CEb;	// 0x35000..0x351FC
		16'b1101_0100_1???_????: WE_PED_RAM[9] <= ~WEb & ~PED_CEb;	// 0x35200..0x353FC
		16'b1101_0101_0???_????: WE_PED_RAM[10] <= ~WEb & ~PED_CEb;	// 0x35400..0x355FC
		16'b1101_0101_1???_????: WE_PED_RAM[11] <= ~WEb & ~PED_CEb;	// 0x35600..0x357FC
		16'b1101_0110_0???_????: WE_PED_RAM[12] <= ~WEb & ~PED_CEb;	// 0x35800..0x359FC
		16'b1101_0110_1???_????: WE_PED_RAM[13] <= ~WEb & ~PED_CEb;	// 0x35A00..0x35BFC
		16'b1101_0111_0???_????: WE_PED_RAM[14] <= ~WEb & ~PED_CEb;	// 0x35C00..0x35DFC
		16'b1101_0111_1???_????: WE_PED_RAM[15] <= ~WEb & ~PED_CEb;	// 0x35E00..0x35FFC
		default: WE_PED_RAM <= 8'b0;
	endcase
end

always @(*)
begin
	WE_THR_RAM <= 16'b0;
	casex( USER_ADDR )
		16'b1101_1000_0???_????: WE_THR_RAM[0] <= ~WEb & ~THR_CEb;	// 0x36000..0x361FC
		16'b1101_1000_1???_????: WE_THR_RAM[1] <= ~WEb & ~THR_CEb;	// 0x36200..0x363FC
		16'b1101_1001_0???_????: WE_THR_RAM[2] <= ~WEb & ~THR_CEb;	// 0x36400..0x365FC
		16'b1101_1001_1???_????: WE_THR_RAM[3] <= ~WEb & ~THR_CEb;	// 0x36600..0x367FC
		16'b1101_1010_0???_????: WE_THR_RAM[4] <= ~WEb & ~THR_CEb;	// 0x36800..0x369FC
		16'b1101_1010_1???_????: WE_THR_RAM[5] <= ~WEb & ~THR_CEb;	// 0x36A00..0x36BFC
		16'b1101_1011_0???_????: WE_THR_RAM[6] <= ~WEb & ~THR_CEb;	// 0x36C00..0x36DFC
		16'b1101_1011_1???_????: WE_THR_RAM[7] <= ~WEb & ~THR_CEb;	// 0x36E00..0x36FFC
		16'b1101_1100_0???_????: WE_THR_RAM[8] <= ~WEb & ~THR_CEb;	// 0x37000..0x371FC
		16'b1101_1100_1???_????: WE_THR_RAM[9] <= ~WEb & ~THR_CEb;	// 0x37200..0x373FC
		16'b1101_1101_0???_????: WE_THR_RAM[10] <= ~WEb & ~THR_CEb;	// 0x37400..0x375FC
		16'b1101_1101_1???_????: WE_THR_RAM[11] <= ~WEb & ~THR_CEb;	// 0x37600..0x377FC
		16'b1101_1110_0???_????: WE_THR_RAM[12] <= ~WEb & ~THR_CEb;	// 0x37800..0x379FC
		16'b1101_1110_1???_????: WE_THR_RAM[13] <= ~WEb & ~THR_CEb;	// 0x37A00..0x37BFC
		16'b1101_1111_0???_????: WE_THR_RAM[14] <= ~WEb & ~THR_CEb;	// 0x37C00..0x37DFC
		16'b1101_1111_1???_????: WE_THR_RAM[15] <= ~WEb & ~THR_CEb;	// 0x37E00..0x37FFC
		default: WE_THR_RAM <= 8'b0;
	endcase
end

always @(*)
begin
	casex( USER_ADDR )
		16'b0100_0???_????_????: int_data <= EV_BUILDER_ENABLE ? {8'h0, EV_BUILDER_DATA_OUT} : {11'h0, FIFO_DATA_OUT0};	// 0x10000..0x11FFC APV data Ch0
		16'b0100_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT1};	// 0x12000..0x13FFC APV data Ch1
		16'b0101_0???_????_????: int_data <= {11'h0, FIFO_DATA_OUT2};	// 0x14000..0x15FFC APV data Ch2
		16'b0101_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT3};	// 0x16000..0x17FFC APV data Ch3
		16'b0110_0???_????_????: int_data <= {11'h0, FIFO_DATA_OUT4};	// 0x18000..0x19FFC APV data Ch4
		16'b0110_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT5};	// 0x1A000..0x1BFFC APV data Ch5
		16'b0111_0???_????_????: int_data <= {11'h0, FIFO_DATA_OUT6};	// 0x1C000..0x1DFFC APV data Ch6
		16'b0111_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT7};	// 0x1E000..0x1FFFC APV data Ch7
		16'b1000_0???_????_????: int_data <= {11'h0, FIFO_DATA_OUT8};	// 0x20000..0x21FFC APV data Ch8
		16'b1000_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT9};	// 0x22000..0x23FFC APV data Ch9
		16'b1001_0???_????_????: int_data <= {11'h0, FIFO_DATA_OUT10};	// 0x24000..0x25FFC APV data Ch10
		16'b1001_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT11};	// 0x26000..0x27FFC APV data Ch11
		16'b1010_0???_????_????: int_data <= {11'h0, FIFO_DATA_OUT12};	// 0x28000..0x29FFC APV data Ch12
		16'b1010_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT13} ;	// 0x2A000..0x2BFFC APV data Ch13
		16'b1011_0???_????_????: int_data <= {11'h0, FIFO_DATA_OUT14};	// 0x2C000..0x2DFFC APV data Ch14
		16'b1011_1???_????_????: int_data <= {11'h0, FIFO_DATA_OUT15};	// 0x2E000..0x2FFFC APV data Ch15

		16'b1101_0000_0???_????: int_data <= {11'h0, FIFO_DATA_OUT0};	// 0x34000..0x341FC Ped Ram 0
		16'b1101_0000_1???_????: int_data <= {11'h0, FIFO_DATA_OUT1};	// 0x34200..0x343FC Ped Ram 1
		16'b1101_0001_0???_????: int_data <= {11'h0, FIFO_DATA_OUT2};	// 0x34400..0x345FC Ped Ram 2
		16'b1101_0001_1???_????: int_data <= {11'h0, FIFO_DATA_OUT3};	// 0x34600..0x347FC Ped Ram 3
		16'b1101_0010_0???_????: int_data <= {11'h0, FIFO_DATA_OUT4};	// 0x34800..0x349FC Ped Ram 4
		16'b1101_0010_1???_????: int_data <= {11'h0, FIFO_DATA_OUT5};	// 0x34A00..0x34BFC Ped Ram 5
		16'b1101_0011_0???_????: int_data <= {11'h0, FIFO_DATA_OUT6};	// 0x34C00..0x34DFC Ped Ram 6
		16'b1101_0011_1???_????: int_data <= {11'h0, FIFO_DATA_OUT7};	// 0x34E00..0x34FFC Ped Ram 7
		16'b1101_0100_0???_????: int_data <= {11'h0, FIFO_DATA_OUT8};	// 0x35000..0x351FC Ped Ram 8
		16'b1101_0100_1???_????: int_data <= {11'h0, FIFO_DATA_OUT9};	// 0x35200..0x353FC Ped Ram 9
		16'b1101_0101_0???_????: int_data <= {11'h0, FIFO_DATA_OUT10};	// 0x35400..0x355FC Ped Ram 10
		16'b1101_0101_1???_????: int_data <= {11'h0, FIFO_DATA_OUT11};	// 0x35600..0x357FC Ped Ram 11
		16'b1101_0110_0???_????: int_data <= {11'h0, FIFO_DATA_OUT12};	// 0x35800..0x359FC Ped Ram 12
		16'b1101_0110_1???_????: int_data <= {11'h0, FIFO_DATA_OUT13};	// 0x35A00..0x35BFC Ped Ram 13
		16'b1101_0111_0???_????: int_data <= {11'h0, FIFO_DATA_OUT14};	// 0x35C00..0x35DFC Ped Ram 14
		16'b1101_0111_1???_????: int_data <= {11'h0, FIFO_DATA_OUT15};	// 0x35E00..0x35FFC Ped Ram 15

		16'b1101_1000_0???_????: int_data <= {11'h0, FIFO_DATA_OUT0};	// 0x36000..0x361FC Thr Ram 0
		16'b1101_1000_1???_????: int_data <= {11'h0, FIFO_DATA_OUT1};	// 0x36200..0x363FC Thr Ram 1
		16'b1101_1001_0???_????: int_data <= {11'h0, FIFO_DATA_OUT2};	// 0x36400..0x365FC Thr Ram 2
		16'b1101_1001_1???_????: int_data <= {11'h0, FIFO_DATA_OUT3};	// 0x36600..0x367FC Thr Ram 3
		16'b1101_1010_0???_????: int_data <= {11'h0, FIFO_DATA_OUT4};	// 0x36800..0x369FC Thr Ram 4
		16'b1101_1010_1???_????: int_data <= {11'h0, FIFO_DATA_OUT5};	// 0x36A00..0x36BFC Thr Ram 5
		16'b1101_1011_0???_????: int_data <= {11'h0, FIFO_DATA_OUT6};	// 0x36C00..0x36DFC Thr Ram 6
		16'b1101_1011_1???_????: int_data <= {11'h0, FIFO_DATA_OUT7};	// 0x36E00..0x36FFC Thr Ram 7
		16'b1101_1100_0???_????: int_data <= {11'h0, FIFO_DATA_OUT8};	// 0x37000..0x371FC Thr Ram 8
		16'b1101_1100_1???_????: int_data <= {11'h0, FIFO_DATA_OUT9};	// 0x37200..0x373FC Thr Ram 9
		16'b1101_1101_0???_????: int_data <= {11'h0, FIFO_DATA_OUT10};	// 0x37400..0x375FC Thr Ram 10
		16'b1101_1101_1???_????: int_data <= {11'h0, FIFO_DATA_OUT11};	// 0x37600..0x377FC Thr Ram 11
		16'b1101_1110_0???_????: int_data <= {11'h0, FIFO_DATA_OUT12};	// 0x37800..0x379FC Thr Ram 12
		16'b1101_1110_1???_????: int_data <= {11'h0, FIFO_DATA_OUT13};	// 0x37A00..0x37BFC Thr Ram 13
		16'b1101_1111_0???_????: int_data <= {11'h0, FIFO_DATA_OUT14};	// 0x37C00..0x37DFC Thr Ram 14
		16'b1101_1111_1???_????: int_data <= {11'h0, FIFO_DATA_OUT15};	// 0x37E00..0x37FFC Thr Ram 15

		16'b1100_0000_0000_0000: int_data <= EV_BUILDER_ENABLE ? {EV_BUILDER_EV_CNT[15:0], EV_BUILDER_FIFO_WC} :
							{20'h0, USED_FIFO_WORDS0};	// 0x30000
		16'b1100_0000_0000_0001: int_data <= {20'h0, USED_FIFO_WORDS1};	// 0x30004
		16'b1100_0000_0000_0010: int_data <= {20'h0, USED_FIFO_WORDS2};	// 0x30008
		16'b1100_0000_0000_0011: int_data <= {20'h0, USED_FIFO_WORDS3};	// 0x3000C
		16'b1100_0000_0000_0100: int_data <= {20'h0, USED_FIFO_WORDS4};	// 0x30010
		16'b1100_0000_0000_0101: int_data <= {20'h0, USED_FIFO_WORDS5};	// 0x30014
		16'b1100_0000_0000_0110: int_data <= {20'h0, USED_FIFO_WORDS6};	// 0x30018
		16'b1100_0000_0000_0111: int_data <= {20'h0, USED_FIFO_WORDS7};	// 0x3001C
		16'b1100_0000_0000_1000: int_data <= {20'h0, USED_FIFO_WORDS8};	// 0x30020
		16'b1100_0000_0000_1001: int_data <= {20'h0, USED_FIFO_WORDS9};	// 0x30024
		16'b1100_0000_0000_1010: int_data <= {20'h0, USED_FIFO_WORDS10};	// 0x30028
		16'b1100_0000_0000_1011: int_data <= {20'h0, USED_FIFO_WORDS11};	// 0x3002C
		16'b1100_0000_0000_1100: int_data <= {20'h0, USED_FIFO_WORDS12};	// 0x30030
		16'b1100_0000_0000_1101: int_data <= {20'h0, USED_FIFO_WORDS13};	// 0x30034
		16'b1100_0000_0000_1110: int_data <= {20'h0, USED_FIFO_WORDS14};	// 0x30038
		16'b1100_0000_0000_1111: int_data <= {20'h0, USED_FIFO_WORDS15};	// 0x3003C

		16'b1100_0000_0001_0000: int_data <= EV_BUILDER_ENABLE ? {FIFO_FULL[15:1], EV_BUILDER_FIFO_FULL,
						FIFO_EMPTY[15:1], EV_BUILDER_FIFO_EMPTY} : {FIFO_FULL, FIFO_EMPTY};	// 0x30040
		16'b1100_0000_0001_0001: int_data <= {SYNCED, ERROR};	// 0x30044

		16'b1100_0000_0001_1000: int_data <= {TRIGGER_TIME_FIFO_FULL, TRIGGER_TIME_FIFO_EMPTY, 22'h0, TRIGGER_TIME_FIFO};	// 0x30060

		16'b0000_0000_1000_0000: int_data <= {4'h0, OUTPUT_FIFO_FULL_L, EVB_FIFO_FULL_L, EVENT_FIFO_FULL_L, TIME_FIFO_FULL_L,
												6'h0, EV_BUILDER_FIFO_FULL, EV_BUILDER_FIFO_EMPTY, EV_BUILDER_FIFO_WC};	// 0x200
		16'b0000_0000_1000_0001: int_data <= {8'h0, EV_BUILDER_EV_CNT};	// 0x204
		16'b0000_0000_1000_0010: int_data <= {24'h0, EV_BUILDER_BLOCK_CNT};	// 0x208
		16'b0000_0000_1000_0011: int_data <= TRIGGER_COUNTER;	// 0x20C
		16'b0000_0000_1000_0100: int_data <= MISSED_TRIGGER;	// 0x210
		16'b0000_0000_1000_0101: int_data <= INCOMING_TRIGGER_CNT;	// 0x214
		16'b0000_0000_1000_0110: int_data <= {SDRAM_INITIALIZED, 6'h0, SDRAM_FIFO_WRITE_ADDRESS};	// 0x218
		16'b0000_0000_1000_0111: int_data <= {SDRAM_INITIALIZED, 6'h0, SDRAM_FIFO_READ_ADDRESS};	// 0x21C
		16'b0000_0000_1000_1000: int_data <= {SDRAM_FIFO_OVERRUN, 6'h0, SDRAM_FIFO_WORDCOUNT};	// 0x220
		16'b0000_0000_1000_1001: int_data <= {OUTPUT_FIFO_FULL, OUTPUT_FIFO_EMPTY, 17'h0, OUTPUT_FIFO_WC};	// 0x224
		16'b0000_0000_1000_1010: int_data <= {APV_FIFO_FULL_L, PROC_FIFO_FULL_L};	// 0x228
			
		default: int_data <= 0;
	endcase
end

always @(*)
begin
	TRIGGER_TIME_FIFO_RD <= 0;
	casex( USER_ADDR )
		16'b1100_0000_0001_1000: TRIGGER_TIME_FIFO_RD <= ~REb & ~FIFO_CEb;	// 0x30060
		default: TRIGGER_TIME_FIFO_RD <= 0;
	endcase
end

endmodule


module SReg(CK, RSTb, CLR, SET, OUT);
input CK, RSTb, CLR, SET;
output OUT;
reg OUT;

	always@(posedge CK or negedge RSTb)
	begin
		if( RSTb == 0 )
			OUT <= 0;
		else
		begin
			if( CLR == 1 )
				OUT <= 0;
			else
				if( SET == 1 )
					OUT <= 1;
		end
	end
endmodule


