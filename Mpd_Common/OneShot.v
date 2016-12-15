//	OneShot TurnOnLed1(.OUT(LED_1), .START(~ceB), .CK(ck_div8), .RSTb(RSTb));

// 13 bit ripple down counter with async preset and reset
module OneShot(OUT, START, CK, RSTb);
output OUT;
input START, CK, RSTb;

reg [12:0] count;
assign OUT = (count != 0) ? 1 : 0;

always @(posedge CK or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[0] <= 0;
	else
		if( START == 1 )
			count[0] <= 1;
		else
			if( count != 0 )
				count[0] <= ~count[0];
end

always @(posedge count[0] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[1] <= 0;
	else
		if( START == 1 )
			count[1] <= 1;
		else
			if( count != 0 )
				count[1] <= ~count[1];
end

always @(posedge count[1] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[2] <= 0;
	else
		if( START == 1 )
			count[2] <= 1;
		else
			if( count != 0 )
				count[2] <= ~count[2];
end

always @(posedge count[2] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[3] <= 0;
	else
		if( START == 1 )
			count[3] <= 1;
		else
			if( count != 0 )
				count[3] <= ~count[3];
end

always @(posedge count[3] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[4] <= 0;
	else
		if( START == 1 )
			count[4] <= 1;
		else
			if( count != 0 )
				count[4] <= ~count[4];
end

always @(posedge count[4] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[5] <= 0;
	else
		if( START == 1 )
			count[5] <= 1;
		else
			if( count != 0 )
				count[5] <= ~count[5];
end

always @(posedge count[5] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[6] <= 0;
	else
		if( START == 1 )
			count[6] <= 1;
		else
			if( count != 0 )
				count[6] <= ~count[6];
end

always @(posedge count[6] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[7] <= 0;
	else
		if( START == 1 )
			count[7] <= 1;
		else
			if( count != 0 )
				count[7] <= ~count[7];
end

always @(posedge count[7] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[8] <= 0;
	else
		if( START == 1 )
			count[8] <= 1;
		else
			if( count != 0 )
				count[8] <= ~count[8];
end

always @(posedge count[8] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[9] <= 0;
	else
		if( START == 1 )
			count[9] <= 1;
		else
			if( count != 0 )
				count[9] <= ~count[9];
end

always @(posedge count[9] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[10] <= 0;
	else
		if( START == 1 )
			count[10] <= 1;
		else
			if( count != 0 )
				count[10] <= ~count[10];
end

always @(posedge count[10] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[11] <= 0;
	else
		if( START == 1 )
			count[11] <= 1;
		else
			if( count != 0 )
				count[11] <= ~count[11];
end

always @(posedge count[11] or posedge START or negedge RSTb)
begin
	if( RSTb == 0 )
		count[12] <= 0;
	else
		if( START == 1 )
			count[12] <= 1;
		else
			if( count != 0 )
				count[12] <= ~count[12];
end

endmodule

