`define DUMMY_CONSTANT	32'hF1CA_CAFE

// A24 Read Only Identifiers
`define CROM_LO_A 		(18'h00000 >> 2)
`define CROM_HI_A 		(18'h00100 >> 2)
`define C_STRING		(18'h00000 >> 2)	// "CROM"
`define MANUFACTURER_ID	(18'h00004 >> 2)	// 0x00080030
`define BOARD_ID		(18'h00008 >> 2)	// 0x00030904
`define BOARD_REVISION	(18'h0000C >> 2)	// 0x04000004	// can change with FPGA revision
`define C_TIME			(18'h00010 >> 2)	// time_t		// will change every compilation

// The following registers will be implemented externally to be accessed also from Fiber interface (if enabled)
`define RESET_REG_A				(18'h00100 >> 2)
`define IO_CONFIG_A				(18'h00104 >> 2)
`define SAMPLE_PER_EVENT_A		(18'h00108 >> 2)
`define EVENT_PER_BLOCK_A		(18'h0010C >> 2)
`define BUSY_THRESHOLD_A		(18'h00110 >> 2)
`define BUSY_THRESHOLD_LOCAL_A	(18'h00114 >> 2)	// larger than BUSY_THRESHOLD
//`define USE_APV_ERROR_FOR_BUSY	// 1 bit somewhere...
`define READOUT_CONFIG_A		(18'h00118 >> 2)	// was 0x4000000 up...
`define TRIGGER_CONFIG_A		(18'h0011C >> 2)
`define TRIGGER_DELAY_A			(18'h00120 >> 2)
`define SYNC_PERIOD_A			(18'h00124 >> 2)
`define MARKER_CHANNEL_A		(18'h00128 >> 2)
`define CHANNEL_ENABLE_A		(18'h0012C >> 2)
`define ZERO_THRESHOLD_A		(18'h00130 >> 2)
`define ONE_THRESHOLD_A			(18'h00134 >> 2)
`define FIR_01_A				(18'h00138 >> 2)
`define FIR_23_A				(18'h0013C >> 2)
`define FIR_45_A				(18'h00140 >> 2)
`define FIR_67_A				(18'h00144 >> 2)
`define FIR_89_A				(18'h00148 >> 2)
`define FIR_1011_A				(18'h0014C >> 2)
`define FIR_1213_A				(18'h00150 >> 2)
`define FIR_1415_A				(18'h00154 >> 2)
// A24 Internal Registers (R/W) VME access only
`define A24_BAR_A				(18'h00180 >> 2)	// to remap A24 space
`define MULTIBOARD_CONFIG_A		(18'h00184 >> 2)	// Enable, first, last, token on P0 or P2
`define MULTIBOARD_ADD_LOW_A	(18'h00188 >> 2)
`define MULTIBOARD_ADD_HIGH_A	(18'h0018C >> 2)
`define FIBER_STCTRL_A			(18'h00190 >> 2)
`define OBUF_BASE_ADDRESS_A		(18'h00194 >> 2)
`define SDRAM_BASE_ADDRESS_A	(18'h00198 >> 2)	// for debug only
`define SDRAM_BANK_A			(18'h0019C >> 2)	// for debug only

`define INTERNAL_LO_A `A24_BAR_A
`define INTERNAL_HI_A (`SDRAM_BANK_A+1)

// A24 External access
`define OBUF_STATUS_LO	(18'h00200 >> 2)	// up to 64 registers
`define OBUF_STATUS_HI	(18'h00300 >> 2)
`define ADC_CONFIG_LO	(18'h00300 >> 2)	// 1 register
`define ADC_CONFIG_HI	(18'h00304 >> 2)
`define ASMI_A_LO		(18'h00380 >> 2)
`define ASMI_A_HI		(18'h00390 >> 2)
`define RUPD_A_LO		(18'h003A0 >> 2)
`define RUPD_A_HI		(18'h003B0 >> 2)
`define I2C_CONFIG_LO	(18'h00400 >> 2)	// 8 registers
`define I2C_CONFIG_HI	(18'h00424 >> 2)
`define HISTO0_REG_LO	(18'h01000 >> 2)	// 2 registers
`define HISTO0_REG_HI	(18'h01008 >> 2)
`define HISTO1_REG_LO	(18'h01008 >> 2)	// 2 registers
`define HISTO1_REG_HI	(18'h01010 >> 2)
`define HISTO0_LO		(18'h04000 >> 2)		// 4K RAM
`define HISTO0_HI		(18'h08000 >> 2)
`define HISTO1_LO		(18'h08000 >> 2)		// 4K RAM
`define HISTO1_HI		(18'h0C000 >> 2)
`define CHANNELS_LO		(18'h10000 >> 2)	// 16 x 2K RAM locations + Registers and trigger time fifo
`define CHANNELS_HI		(18'h34000 >> 2)
`define PED_RAM_LO		(18'h34000 >> 2)	// 16 x 128 RAM locations
`define PED_RAM_HI		(18'h36000 >> 2)
`define THR_RAM_LO		(18'h36000 >> 2)	// 16 x 128 RAM locations
`define THR_RAM_HI		(18'h38000 >> 2)

`define EXTERNAL_LO_A `OBUF_STATUS_LO
`define EXTERNAL_HI_A (`THR_RAM_HI+1)
