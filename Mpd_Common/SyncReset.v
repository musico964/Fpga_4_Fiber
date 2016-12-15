module SyncReset(CK, ASYNC_RSTb, SYNC_RSTb);
input CK, ASYNC_RSTb;
output SYNC_RSTb;

reg SYNC_RSTb;
reg x1, x2, x3, x4;

always @(posedge CK or negedge ASYNC_RSTb)
begin
	if( ASYNC_RSTb == 0 )
	begin
		x1 <= 0; x2 <= 0; x3 <= 0; x4 <= 0;
		SYNC_RSTb <= 0;
	end
	else
	begin
		x1 <= 1'b1;
		x2 <= x1;
		x3 <= x2;
		x4 <= x3;
		SYNC_RSTb <= x4;
	end
end

endmodule

