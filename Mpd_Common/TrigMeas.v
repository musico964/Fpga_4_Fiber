
module TrigMeas(FAST_CK, RSTb,
	START_TDC, STOP_TDC, ALL_CLEAR,
	TDC_SELECT,
	TRIGGER_TIME_FIFO_RD, TRIGGER_TIME_FIFO_CK, TRIGGER_TIME_FIFO,
	TRIGGER_TIME_FIFO_FULL, TRIGGER_TIME_FIFO_EMPTY
	);
input FAST_CK, RSTb, START_TDC, STOP_TDC, ALL_CLEAR;
input TDC_SELECT, TRIGGER_TIME_FIFO_RD, TRIGGER_TIME_FIFO_CK;
output [7:0] TRIGGER_TIME_FIFO;
output TRIGGER_TIME_FIFO_FULL, TRIGGER_TIME_FIFO_EMPTY;

wire [7:0] trig_time_lo, trig_time_hi;
wire time_valid_lo, time_valid_hi;

LoResTdc ATrgTdc(.CLK(FAST_CK), .RSTb(RSTb), .START(START_TDC), .STOP(STOP_TDC), .TIME(trig_time_lo), .VALID(time_valid_lo));
HiResTdc BTrgTdc(.CLK(FAST_CK), .RSTb(RSTb), .START(START_TDC), .STOP(STOP_TDC), .TIME(trig_time_hi), .VALID(time_valid_hi));

TdcFifo_1024x8 TrigTimeFifo(
	.data(TDC_SELECT ? trig_time_hi : trig_time_lo),
	.wrclk(FAST_CK),
	.wrreq(TDC_SELECT ? time_valid_hi : time_valid_lo),
	.q(TRIGGER_TIME_FIFO),
	.rdclk(TRIGGER_TIME_FIFO_CK),
	.rdreq(TRIGGER_TIME_FIFO_RD),
	.rdempty(TRIGGER_TIME_FIFO_EMPTY),
	.rdfull(TRIGGER_TIME_FIFO_FULL));

endmodule

