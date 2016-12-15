//
// Test modules to exercise fiber event data interface
//
module time_base(input CK, input RSTb, input [7:0] PERIOD, input ENABLE, output reg SYNC);
//parameter period = 110 / 2;	// 500 ns
//parameter period = 110 * 1;	// 1 us
//parameter period = 110 * 5;	// 5 us

	wire [9:0] period_int;
	reg [9:0] count;
	
	assign period_int = {1'b0, PERIOD, 1'b0};
	
	always @(posedge CK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			count <= 0;
			SYNC <= 0;
		end
		else
		begin
			if( ENABLE == 1 )
			begin
				count <= count + 1;
				if( count == period_int )
				begin
					count <= 0;
					SYNC <= 1;
				end
				else
					SYNC <= 0;
			end
			else
			begin
				count <= 0;
				SYNC <= 0;
			end
		end
	end
	
endmodule

module frame_generator(input CK, input RSTb, input [7:0] PERIOD, input FULL, input ENABLE,
	output reg WR, output reg [31:0] DATA, output reg EOF);

	reg [4:0] addr;
	reg [31:0] frame_count;
	reg frame_gen_enable;
	wire start_frame_gen;
		
	time_base TimeBase(.CK(CK), .RSTb(RSTb), .PERIOD(PERIOD), .ENABLE(ENABLE), .SYNC(start_frame_gen));

	always @(posedge CK)
	begin
		case( addr[3:0] )
			 0: DATA <= 32'h12345678;
			 1: DATA <= 32'h23456789;
			 2: DATA <= 32'h3456789a;
			 3: DATA <= 32'h456789ab;
			 4: DATA <= 32'h56789abc;
			 5: DATA <= 32'h6789abcd;
			 6: DATA <= 32'h789abcde;
			 7: DATA <= 32'h89abcdef;
			 8: DATA <= 32'h9abcdef0;
			 9: DATA <= 32'habcdef01;
			10: DATA <= 32'hbcdef012;
			11: DATA <= 32'hcdef0123;
			12: DATA <= 32'hdef01234;
			13: DATA <= 32'hef012345;
			14: DATA <= 32'hf0123456;
			15: DATA <= frame_count;
		endcase
	end
	
	always @(posedge CK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			frame_count <= 0;
		end
		else
		begin
			if( EOF )
				frame_count <= frame_count + 1;
		end
	end
	
	always @(posedge CK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			frame_gen_enable <= 0;
		end
		else
		begin
			if( ENABLE == 0 )
				frame_gen_enable <= 0;
			else
			begin
				if( start_frame_gen == 1 )
					frame_gen_enable <= 1;
				if( addr == 16 )
					frame_gen_enable <= 0;
			end
		end
	end

	always @(posedge CK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			addr <= 0;
			EOF <= 0;
		end
		else
		begin
			if( frame_gen_enable == 1 )
			begin
				if( FULL == 0 && EOF == 0 && addr < 17 )
					addr <= addr + 1;
				else
					addr <= 0;
				if( addr == 15 )
				begin
					EOF <= 1;
				end
				else
					EOF <= 0;
			end
			else
				addr <= 0;
		end
	end

	always @(posedge CK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			WR <= 0;
		end
		else
		begin
			if( addr >= 0 && addr <= 15 && FULL == 0 && frame_gen_enable == 1 )
				WR <= 1;
			else
				WR <= 0;
		end
	end
	
endmodule
