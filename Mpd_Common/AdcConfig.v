module AdcConfigMachine(
	RSTb, CLK,
	WEb, REb, OEb, CEb, DATA_IN, DATA_OUT,	// VME interface user side signals
	AdcConfigClk,
	ADC_CS1b, ADC_CS2b, ADC_SCLK, ADC_SDA);

input  RSTb, CLK;
input  WEb, REb, OEb, CEb;
input  [31:0] DATA_IN;
output  [31:0] DATA_OUT;
input  AdcConfigClk;
output ADC_CS1b, ADC_CS2b, ADC_SCLK, ADC_SDA;

// ControlRegister[23:0] = Data stream to be serialized to ADC x
// ControlRegister[31] = Start serialization of data stream on ADC 2
// ControlRegister[30] = Start serialization of data stream on ADC 1
// StatusRegister[23:0]: read back of ControlRegister
// StatusRegister[30]: 1 --> Serialization in progress, 0 --> Serialization done
// StatusRegister[31]: 1 --> Serialization in progress, 0 --> Serialization done

reg ADC_CS1b, ADC_CS2b, ADC_SDA;
reg StartAdc1, StartAdc2, EnableAdcClk;
reg OldStartAdc1, OldStartAdc2, EndSerialization;
reg [23:0] WrDataRegister, Shreg;
reg [4:0] BitCnt;
wire [31:0] StatusRegister;
wire RisingStartAdc1, RisingStartAdc2;

assign ADC_SCLK = ~EnableAdcClk | AdcConfigClk;
assign StatusRegister = {StartAdc2, StartAdc1, 6'b0, WrDataRegister};
assign DATA_OUT = StatusRegister;

assign RisingStartAdc1 = (OldStartAdc1 == 0 && StartAdc1 == 1 ) ? 1 : 0;
assign RisingStartAdc2 = (OldStartAdc2 == 0 && StartAdc2 == 1 ) ? 1 : 0;

// Control Register
	always @(posedge CLK or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			WrDataRegister <= 0;
			StartAdc1 <= 0; StartAdc2 <= 0;
		end
		else
		begin
			if( CEb == 0 && WEb == 0 )
			begin
				WrDataRegister <= DATA_IN[23:0];
				StartAdc1 <= DATA_IN[30];
				StartAdc2 <= DATA_IN[31];
			end
			if( EndSerialization == 1 )
			begin
				StartAdc1 <= 0; StartAdc2 <= 0;
			end
		end
	end

// Signals generator.
	always @(negedge AdcConfigClk)
	begin
		ADC_SDA <= Shreg[23];
	end

	always @(posedge AdcConfigClk or negedge RSTb)
	begin
		if( RSTb == 0 )
		begin
			EndSerialization <= 0; EnableAdcClk <= 0;
			ADC_CS1b <= 1; ADC_CS2b <= 1;
			OldStartAdc1 <= 0; OldStartAdc2 <= 0;
			BitCnt <= 0;
			Shreg <= 0;
		end
		else
		begin
			OldStartAdc1 <= StartAdc1; OldStartAdc2 <= StartAdc2;
			EndSerialization <= 0;

			if( RisingStartAdc1 == 1 || RisingStartAdc2 == 1 )
			begin
				ADC_CS1b <= ~StartAdc1; ADC_CS2b <= ~StartAdc2;
				EnableAdcClk <= 1;
				BitCnt <= 24;
				Shreg <= WrDataRegister;
			end
			if( BitCnt > 0 )
			begin
				BitCnt <= BitCnt - 1;
				Shreg <= Shreg << 1;
			end
			if( BitCnt == 1 )
			begin
				ADC_CS1b <= 1; ADC_CS2b <= 1;
				EnableAdcClk <= 0;
				EndSerialization <= 1;
			end
		end
	end

endmodule

