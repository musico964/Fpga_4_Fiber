library ieee;
use ieee.std_logic_1164.all;

entity aurora_8b10b_arria_gxb is
	generic(
		SIM_GTXRESET_SPEEDUP	: integer := 0      
	);
	port(
		USER_CLK			: in std_logic;

		-- Parallel I/O
		TX_OUT_CLK		: out std_logic;

		TX_D				: in std_logic_vector(0 to 15);
		TX_SRC_RDY_N	: in std_logic;
		TX_SOF_N			: in std_logic;
		TX_EOF_N			: in std_logic;
		TX_DST_RDY_N	: out std_logic;

		RX_D				: out std_logic_vector(0 to 15);
		RX_SRC_RDY_N	: out std_logic;
		RX_SOF_N			: out std_logic;
		RX_EOF_N			: out std_logic;

		-- Status/Control
		HARD_ERR			: out std_logic;
		SOFT_ERR			: out std_logic;
		FRAME_ERR		: out std_logic;
		CHANNEL_UP		: out std_logic;
		LANE_UP			: out std_logic;
		RESET				: in std_logic;
		GT_RESET			: in std_logic;
		TX_LOCK			: out std_logic;

		-- Serial/Refclk I/O
		RXP				: in std_logic;
		TXP				: out std_logic;

		REFCLK			: in std_logic
	);
end aurora_8b10b_arria_gxb;

architecture synthesis of aurora_8b10b_arria_gxb is
	component aurora_8b10b_v5_3 is
		generic(
			SIM_GTXRESET_SPEEDUP	:integer := 0      
		);
		port(
			-- LocalLink TX Interface
			TX_D					: in std_logic_vector(0 to 15);
			TX_REM				: in std_logic;
			TX_SRC_RDY_N		: in std_logic;
			TX_SOF_N				: in std_logic;
			TX_EOF_N				: in std_logic;
			TX_DST_RDY_N		: out std_logic;
			-- LocalLink RX Interface
			RX_D					: out std_logic_vector(0 to 15);
			RX_REM				: out std_logic;
			RX_SRC_RDY_N		: out std_logic;
			RX_SOF_N				: out std_logic;
			RX_EOF_N				: out std_logic;
			-- GTX Serial I/O
			RXP					: in std_logic;
			RXN					: in std_logic;
			TXP					: out std_logic;
			TXN					: out std_logic;
			--GTX Reference Clock Interface
			GTXD19				: in std_logic;
			-- Error Detection Interface
			HARD_ERR				: out std_logic;
			SOFT_ERR				: out std_logic;
			FRAME_ERR			: out std_logic;
			-- Status
			CHANNEL_UP			: out std_logic;
			LANE_UP				: out std_logic;
			-- Clock Compensation Control Interface
			WARN_CC				: in std_logic;
			DO_CC					: in std_logic;
			-- System Interface
			USER_CLK				: in std_logic;
			SYNC_CLK				: in std_logic;
			RESET					: in std_logic;
			POWER_DOWN			: in std_logic;
			LOOPBACK				: in std_logic_vector(2 downto 0);
			GT_RESET				: in std_logic;
			TX_OUT_CLK			: out std_logic;
			TX_LOCK				: out std_logic
		);
	end component;

	component aurora_8b10b_v5_3_STANDARD_CC_MODULE
		port(
			-- Clock Compensation Control Interface
			WARN_CC        : out std_logic;
			DO_CC          : out std_logic;
			-- System Interface
			PLL_NOT_LOCKED : in std_logic;
			USER_CLK       : in std_logic;
			RESET          : in std_logic
		);
	end component;

	signal LANE_UP_i			: std_logic;
	signal RST_CC_MODULE		: std_logic;
	signal WARN_CC				: std_logic;
	signal DO_CC				: std_logic;
begin

	LANE_UP <= LANE_UP_i;
	RST_CC_MODULE <= not LANE_UP_i;

	aurora_8b10b_v5_3_STANDARD_CC_MODULE_inst: aurora_8b10b_v5_3_STANDARD_CC_MODULE
		port map(
			WARN_CC        => WARN_CC,
			DO_CC          => DO_CC,
			PLL_NOT_LOCKED => RESET,
			USER_CLK       => USER_CLK,
			RESET          => RST_CC_MODULE
		);

	aurora_8b10b_v5_3_inst: aurora_8b10b_v5_3
		generic map(
			SIM_GTXRESET_SPEEDUP		=> SIM_GTXRESET_SPEEDUP
		)
		port map(
			TX_D				=> TX_D,
			TX_REM			=> '1',
			TX_SRC_RDY_N	=> TX_SRC_RDY_N,
			TX_SOF_N			=> TX_SOF_N,
			TX_EOF_N			=> TX_EOF_N,
			TX_DST_RDY_N	=> TX_DST_RDY_N,
			RX_D				=> RX_D,
			RX_REM			=> open,
			RX_SRC_RDY_N	=> RX_SRC_RDY_N,
			RX_SOF_N			=> RX_SOF_N,
			RX_EOF_N			=> RX_EOF_N,
			RXP				=> RXP,
			RXN				=> '0',
			TXP				=> TXP,
			TXN				=> open,
			GTXD19			=> REFCLK,
			HARD_ERR			=> HARD_ERR,
			SOFT_ERR			=> SOFT_ERR,
			FRAME_ERR		=> FRAME_ERR,
			CHANNEL_UP		=> CHANNEL_UP,
			LANE_UP			=> LANE_UP_i,
			WARN_CC			=> WARN_CC,
			DO_CC				=> DO_CC,
			USER_CLK			=> USER_CLK,
			SYNC_CLK			=> USER_CLK,
			RESET				=> RESET,
			POWER_DOWN		=> '0',
			LOOPBACK			=> "000",
			GT_RESET			=> GT_RESET,
			TX_OUT_CLK		=> TX_OUT_CLK,
			TX_LOCK			=> TX_LOCK
		);

end synthesis;
