
module Histogrammer(
	LCLK, ADCLK,
	ADC_PDATA0, ADC_PDATA1, ADC_PDATA2, ADC_PDATA3,
	ADC_PDATA4, ADC_PDATA5, ADC_PDATA6, ADC_PDATA7,
	RSTb, CLK, WEb, REb, OEb, CEb, USER_ADDR, DATA_IN, DATA_OUT);

input LCLK, ADCLK;
input [11:0] ADC_PDATA0, ADC_PDATA1, ADC_PDATA2, ADC_PDATA3;
input [11:0] ADC_PDATA4, ADC_PDATA5, ADC_PDATA6, ADC_PDATA7;
input RSTb, CLK, WEb, REb, OEb, CEb;
input [12:0] USER_ADDR;
input [31:0] DATA_IN;
output [31:0] DATA_OUT;

reg [15:0] CtrlRegister;
reg [3:0] FsmStatus;
reg RamWrite, OldAdClk, FsmRunning;
wire [31:0] StatusRegister, RamDataOut;
reg [31:0] RamDataIn;
wire [2:0] AdcSelect;
reg [11:0] RamAddr;
reg HistoEnable, OldHistoEnable, HistoEnableRising, HistoEnableW;
reg UserRamWrite, UserCtrlRegisterWrite, AdcDataValid;
reg [31:0] WriteCounter, DATA_OUT;
reg HistoEnableSlow;


assign AdcSelect = CtrlRegister[2:0];
assign StatusRegister = {FsmRunning, 15'b0, CtrlRegister};


SpRam_4096x32 HistoRam(
	.address( RamAddr ),
	.clock( LCLK ),
	.data( RamDataIn ),
	.wren( RamWrite ),
	.q( RamDataOut ));

// USER_DATA selector
	always @(posedge CLK)
	begin
		casex( {USER_ADDR[12], USER_ADDR[0]} )
			2'b00: DATA_OUT <= RamDataOut;
			2'b01: DATA_OUT <= RamDataOut;
			2'b10: DATA_OUT <= StatusRegister;
			2'b11: DATA_OUT <= WriteCounter;
		endcase
	end

// RamAddr selector
	always @(posedge LCLK)
	begin
		if( HistoEnableW == 0 && HistoEnable == 0 )
			RamAddr <= USER_ADDR[11:0];
		else
			casex( AdcSelect )
				3'd0: RamAddr <= ADC_PDATA0;
				3'd1: RamAddr <= ADC_PDATA1;
				3'd2: RamAddr <= ADC_PDATA2;
				3'd3: RamAddr <= ADC_PDATA3;
				3'd4: RamAddr <= ADC_PDATA4;
				3'd5: RamAddr <= ADC_PDATA5;
				3'd6: RamAddr <= ADC_PDATA6;
				3'd7: RamAddr <= ADC_PDATA7;
			endcase
	end

// Control Register
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			CtrlRegister <= 0;
		end
		else
		begin
			if( UserCtrlRegisterWrite  == 1 )
			begin
				CtrlRegister <= DATA_IN[15:0];
			end
		end
	end

// Sync registers
	always @(posedge LCLK)
	begin
		OldAdClk <= ADCLK;
		UserRamWrite <= (CEb == 0 && WEb == 0 && USER_ADDR[12] == 0) ? 1 : 0;
		UserCtrlRegisterWrite <= (CEb == 0 && WEb == 0 && USER_ADDR[12] == 1) ? 1 : 0;
		AdcDataValid <= (OldAdClk == 0 && ADCLK == 1) ? 1 : 0;
		HistoEnable <= CtrlRegister[7];
		RamDataIn <= (HistoEnable == 0) ? DATA_IN : (RamDataOut + 1);
//			((RamDataOut != 32'hFFFF_FFFF) ? (RamDataOut + 1) : 32'hFFFF_FFFF);
	end

	always @(posedge ADCLK)
	begin
		HistoEnableSlow <= HistoEnable;
		OldHistoEnable <= HistoEnableSlow;
		HistoEnableRising <= (OldHistoEnable == 0 && HistoEnableSlow == 1 ) ? 1 : 0;
		HistoEnableW <= OldHistoEnable | HistoEnableSlow;
	end

// Write pulse counter
	always @(posedge ADCLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			WriteCounter <= 0;
		end
		else
		begin
			if( HistoEnableRising == 1 )
				WriteCounter <= 0;
			else
				if( HistoEnableSlow == 1 && WriteCounter != 32'hFFFF_FFFF )
					WriteCounter <= WriteCounter + 1;
		end
	end


// State machine to handle RAM write
	always @(posedge LCLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			FsmStatus <= 0;
			RamWrite <= 0;
			FsmRunning <= 0;
		end
		else
		begin
			case( FsmStatus )
				0: begin
					FsmRunning <= 0;
					RamWrite <= 0;
					FsmStatus <= 0;
					if( HistoEnable == 0 && UserRamWrite == 1 )
						FsmStatus <= 1;
					else
						if( HistoEnable == 1 && AdcDataValid == 1 )
							FsmStatus <= 4;
				   end

// User Write to Ram
				1: begin
					FsmRunning <= 1;
					FsmStatus <= 2;	// Wait a little bit since we are very fast
				   end
				2: begin
					RamWrite <= 1;	// Issue a write pulse
					FsmStatus <= 3;
				   end
				3: begin
					RamWrite <= 0;
					if( UserRamWrite == 1 )
						FsmStatus <= 3;
					else
						FsmStatus <= 0;
				   end

// Histogrammer
				4: begin
					FsmRunning <= 1;
					FsmStatus <= 5;	// Adder is working...
				   end
				5: begin
					FsmStatus <= 6;
				   end
				6: begin
					FsmStatus <= 7;
				   end
				7: begin
					RamWrite <= HistoEnable;	// Issue a write pulse
					FsmStatus <= 0;
				   end

				default: FsmStatus <= 0;
			endcase
		end
	end

endmodule
