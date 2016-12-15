// A24 Address space offset from 0 to 0x37FFF = 256 KB organized in 32 bit longword.
// Single access and block transfer (BLT) are permitted
// All the following constants are address offsets that must be added to:
// BASE_ADDRESS = {A24_BAR[7:2], 18'b0}
// A24_BAR = {GA[4:0], 3'b0} by default
// Note that only 6 MSB of A24_BAR are used
// By default: BASE_ADDRESS = {GA[4:0], 19'b0}

// 	Board Identification (Read Only)
#define CONSTANT_STRING		0x00000	// always returns "CROM"
#define MANUFACTURER_ID		0x00004	// always returns 0x00080030	// CERN manufacturer ID
#define BOARD_ID		0x00008	// always returns 0x00030904	// MPD device ID
#define BOARD_REVISION		0x0000C	// always returns 0x04000004	// can change with FPGA revision
#define COMPILE_TIME		0x00010	// always returns FPGA compilation time in time_t

// 	Configuration registers (Read/Write) FPGA Internals
#define A24_BAR			0x00100	// to remap A24 space
#define MULTIBOARD_CONFIG	0x00104	// Enable, first, last, token on P0 or P2
#define MULTIBOARD_ADD_LOW	0x00108
#define MULTIBOARD_ADD_HIGH	0x0010C
#define FIBER_STCTRL_A		0x00110
#define OBUF_BASE_ADDRESS	0x00114	// 8 Mbytes = 2 Mword space from here
#define SDRAM_BASE_ADDRESS	0x00118	// for debug only	// 8 Mbytes = 2 Mword space from here
#define SDRAM_BANK		0x0011C	// for debug only	// 16 banks x 8 Mbytes = 128 Mbytes
#define RESET_REG		0x00120
#define IO_CONFIG		0x00124
#define SAMPLE_PER_EVENT	0x00128
#define EVENT_PER_BLOCK		0x0012C
#define BUSY_THRESHOLD		0x00130
#define BUSY_THRESHOLD_LOCAL	0x00134	// bigger than BUSY_THRESHOLD
#define USE_APV_ERROR_FOR_BUSY	// 1 bit somewhere...
#define READOUT_CONFIG		0x00138	// was 0x4000000 up...
#define TRIGGER_CONFIG		0x0013C
#define TRIGGER_DELAY		0x00140
#define SYNC_PERIOD		0x00144
#define MARKER_CHANNEL		0x00148
#define CHANNEL_ENABLE		0x0014C
#define ZERO_THRESHOLD		0x00150
#define ONE_THRESHOLD		0x00154
#define FIR_COEFF_10		0x00158
#define FIR_COEFF_32		0x0015C
#define FIR_COEFF_54		0x00160
#define FIR_COEFF_76		0x00164
#define FIR_COEFF_98		0x00168
#define FIR_COEFF_1110		0x0016C

//	Output buffers Status registers (Read Only) FPGA externals
#define EVB_FIFO_WORD_COUNT	0x00200
#define EVB_EVENT_COUNT		0x00204
#define EVB_BLOCK_COUNT		0x00208
#define TRIGGER_COUNT		0x0020C
#define MISSED_TRIGGER		0x00210
#define INCOMING_TRIGGER	0x00214
#define SDRAM_FIFO_WR_ADDR	0x00218
#define SDRAM_FIFO_RD_ADDR	0x0021C
#define SDRAM_FIFO_FLAG_WC	0x00220
#define OUTPUT_BUFFER_FLAG_WC	0x00224

//	Pheripheral Control and Status registers FPGA Externals
#define ADC_CONFIG		0x00300	// was 0x1000000
#define I2C_REGISTERS		0x00400	// 8	// was 0x2000000 .. 0x200001C 
#define HISTO_RAM_0		0x04000	// 4096	// was 0x3000000 .. 0x3003FFC 
#define HISTO_STCTRL_0		0x01000	// was 0x3004000
#define HISTO_COUNT_0		0x01004	// was 0x3004004
#define HISTO_RAM_1		0x08000	// 4096	// was 0x3008000 .. 0x300BFFC 
#define HISTO_STCTRL_1		0x01008	// was 0x300C000
#define HISTO_COUNT_1		0x0100C	// was 0x300C004

//	Channel data (Read Only): for debug only
#define CH_FIFO_0		0x10000
#define CH_FIFO_1		0x12000
#define CH_FIFO_2		0x14000
#define CH_FIFO_3		0x16000
#define CH_FIFO_4		0x18000
#define CH_FIFO_5		0x1A000
#define CH_FIFO_6		0x1C000
#define CH_FIFO_7		0x1E000
#define CH_FIFO_8		0x20000
#define CH_FIFO_0		0x22000
#define CH_FIFO_10		0x24000
#define CH_FIFO_11		0x26000
#define CH_FIFO_12		0x28000
#define CH_FIFO_13		0x2A000
#define CH_FIFO_14		0x2C000
#define CH_FIFO_15		0x2E000

#define CH_USED_WORDS_0		0x30000
#define CH_USED_WORDS_1		0x30004
#define CH_USED_WORDS_2		0x30008
#define CH_USED_WORDS_3		0x3000C
#define CH_USED_WORDS_4		0x30010
#define CH_USED_WORDS_5		0x30014
#define CH_USED_WORDS_6		0x30018
#define CH_USED_WORDS_7		0x3001C
#define CH_USED_WORDS_8		0x30020
#define CH_USED_WORDS_0		0x30024
#define CH_USED_WORDS_10	0x30028
#define CH_USED_WORDS_11	0x3002C
#define CH_USED_WORDS_12	0x30030
#define CH_USED_WORDS_13	0x30034
#define CH_USED_WORDS_14	0x30038
#define CH_USED_WORDS_15	0x3003C
#define CH_FIFO_FLAG		0x30040	// {FIFO_FULL, FIFO_EMPTY}
#define CH_SYNCED_ERROR		0x30044	// {SYNCED, ERROR}

#define TRIGGER_TIME_FIFO	0x30060	// {TRIGGER_TIME_FIFO_FULL, TRIGGER_TIME_FIFO_EMPTY, 22'h0, TRIGGER_TIME_FIFO}


//	Pedestal RAMs (Read/Write)
#define PED_RAM_0	0x34000// 128
#define PED_RAM_1	0x34200
#define PED_RAM_2	0x34400
#define PED_RAM_3	0x34600
#define PED_RAM_4	0x34800
#define PED_RAM_5	0x34A00
#define PED_RAM_6	0x34C00
#define PED_RAM_7	0x34E00
#define PED_RAM_8	0x35000
#define PED_RAM_0	0x35200
#define PED_RAM_10	0x35400
#define PED_RAM_11	0x35600
#define PED_RAM_12	0x35800
#define PED_RAM_13	0x35A00
#define PED_RAM_14	0x35C00
#define PED_RAM_15	0x35E00
//	Threshold RAMs (Read/Write)
#define THR_RAM_0	0x36000// 128
#define THR_RAM_1	0x36200
#define THR_RAM_2	0x36400
#define THR_RAM_3	0x36600
#define THR_RAM_4	0x36800
#define THR_RAM_5	0x36A00
#define THR_RAM_6	0x36C00
#define THR_RAM_7	0x36E00
#define THR_RAM_8	0x37000
#define THR_RAM_0	0x37200
#define THR_RAM_10	0x37400
#define THR_RAM_11	0x37600
#define THR_RAM_12	0x37800
#define THR_RAM_13	0x37A00
#define THR_RAM_14	0x37C00
#define THR_RAM_15	0x37E00
