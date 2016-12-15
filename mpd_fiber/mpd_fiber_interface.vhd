library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity mpd_fiber_interface is
	port(
			FIBER_USER_CLK			: out std_logic;

			-- Fiber link status/control
			FIBER_GT_RESET			: in std_logic;
			FIBER_RESET				: in std_logic;
			FIBER_CHANNEL_UP		: out std_logic;
			FIBER_HARD_ERR			: out std_logic;
			FIBER_FRAME_ERR		: out std_logic;
			FIBER_ERR_CNT			: out std_logic_vector(7 downto 0);

			-- Register Access Master->Slave Interface
			REG_CLK					: in std_logic;
			REG_RD					: out std_logic;
			REG_WR					: out std_logic;
			REG_ADDR					: out std_logic_vector(31 downto 0);
			REG_DIN					: out std_logic_vector(31 downto 0);
			REG_DOUT					: in std_logic_vector(31 downto 0);
			REG_ACK					: in std_logic;

			-- EVT_FIFO* synchronous to EVT_FIFO_CLK
			-- Interface to event FIFO that must be in FWFT mode
			-- EVT_FIFO_END must be '0' for valid event data (EVT_FIFO_DATA)
			-- EVT_FIFO_END must be '1' written along with a dummy event data
			--              word (EVT_FIFO_DATA) to mark the end of an event

			EVT_FIFO_CLK			: in std_logic;
			EVT_FIFO_FULL			: out std_logic;
			EVT_FIFO_WR				: in std_logic;
			EVT_FIFO_DATA			: in std_logic_vector(31 downto 0);
			EVT_FIFO_END			: in std_logic;

			-- Serial(2.5Gbps)/Refclk(62.5MHz) I/O
			RXP						: in std_logic;
			TXP						: out std_logic;

			REFCLK					: in std_logic
	);
end mpd_fiber_interface;

architecture synthesis of mpd_fiber_interface is
	component aurora_8b10b_arria_gxb is
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
	end component;

	component mpd_fiber_slave is
		port(
			-- Transceiver Parallel Interface
			CLK						: in std_logic;
			RESET						: in std_logic;

			CHANNEL_UP				: in std_logic;

			TX_D						: out std_logic_vector(0 to 15);
			TX_SRC_RDY_N			: out std_logic;
			TX_SOF_N					: out std_logic;
			TX_EOF_N					: out std_logic;
			TX_DST_RDY_N			: in std_logic;

			RX_D						: in std_logic_vector(0 to 15);
			RX_SRC_RDY_N			: in std_logic;
			RX_SOF_N					: in std_logic;
			RX_EOF_N					: in std_logic;

			-- Register Access Master->Slave Interface
			REG_CLK					: in std_logic;
			REG_RD					: out std_logic;
			REG_WR					: out std_logic;
			REG_ADDR					: out std_logic_vector(31 downto 0);
			REG_DIN					: out std_logic_vector(31 downto 0);
			REG_DOUT					: in std_logic_vector(31 downto 0);
			REG_ACK					: in std_logic;

			-- Event builder output
			EVT_FIFO_CLK			: in std_logic;
			EVT_FIFO_FULL			: out std_logic;
			EVT_FIFO_WR				: in std_logic;
			EVT_FIFO_DATA			: in std_logic_vector(31 downto 0);
			EVT_FIFO_END			: in std_logic
		);
	end component;

	signal USER_CLK_i			: std_logic;
	signal SOFT_ERR			: std_logic;
	signal SOFT_ERR_CNT		: std_logic_vector(7 downto 0);
	signal SOFT_ERR_CNT_OVF	: std_logic;
	signal RESET				: std_logic := '1';
	signal CHANNEL_UP			: std_logic;
	signal FRAME_ERR			: std_logic;
	signal TX_LOCK				: std_logic;
	signal TX_D					: std_logic_vector(0 to 15);
	signal TX_SRC_RDY_N		: std_logic;
	signal TX_DST_RDY_N		: std_logic;
	signal TX_SOF_N			: std_logic;
	signal TX_EOF_N			: std_logic;
	signal RX_D					: std_logic_vector(0 to 15);
	signal RX_SRC_RDY_N		: std_logic;
	signal RX_SOF_N			: std_logic;
	signal RX_EOF_N			: std_logic;
begin

	------------------------------------------
	-- Fiber interface status/control
	------------------------------------------

	FIBER_USER_CLK <= USER_CLK_i;
	FIBER_ERR_CNT <= SOFT_ERR_CNT;
	FIBER_CHANNEL_UP <= CHANNEL_UP;

	process(USER_CLK_i)
	begin
		if rising_edge(USER_CLK_i) then
			RESET <= not TX_LOCK;
		end if;
	end process;

	SOFT_ERR_CNT_OVF <= '1' when SOFT_ERR_CNT = conv_std_logic_vector(2**SOFT_ERR_CNT'length-1, SOFT_ERR_CNT'length) else '0';

	process(USER_CLK_i)
	begin
		if rising_edge(USER_CLK_i) then
			if FIBER_RESET = '1' then
				SOFT_ERR_CNT <= (others=>'0');
			elsif (SOFT_ERR = '1') and (SOFT_ERR_CNT_OVF = '0') then
				SOFT_ERR_CNT <= SOFT_ERR_CNT + 1;
			end if;
		end if;
	end process;

	process(USER_CLK_i)
	begin
		if rising_edge(USER_CLK_i) then
			if FIBER_RESET = '1' then
				FIBER_FRAME_ERR <= '0';
			elsif FRAME_ERR = '1' then
				FIBER_FRAME_ERR <= '1';
			end if;
		end if;
	end process;

	------------------------------------------
	-- Fiber data interface
	------------------------------------------

	mpd_fiber_slave_inst: mpd_fiber_slave
		port map(
			CLK						=> USER_CLK_i,
			RESET						=> RESET,
			CHANNEL_UP				=> CHANNEL_UP,
			TX_D						=> TX_D,
			TX_SRC_RDY_N			=> TX_SRC_RDY_N,
			TX_SOF_N					=> TX_SOF_N,
			TX_EOF_N					=> TX_EOF_N,
			TX_DST_RDY_N			=> TX_DST_RDY_N,
			RX_D						=> RX_D,
			RX_SRC_RDY_N			=> RX_SRC_RDY_N,
			RX_SOF_N					=> RX_SOF_N,
			RX_EOF_N					=> RX_EOF_N,
			REG_CLK					=> REG_CLK,
			REG_RD					=> REG_RD,
			REG_WR					=> REG_WR,
			REG_ADDR					=> REG_ADDR,
			REG_DIN					=> REG_DIN,
			REG_DOUT					=> REG_DOUT,
			REG_ACK					=> REG_ACK,
			EVT_FIFO_CLK			=> EVT_FIFO_CLK,
			EVT_FIFO_FULL			=> EVT_FIFO_FULL,
			EVT_FIFO_WR				=> EVT_FIFO_WR,
			EVT_FIFO_DATA			=> EVT_FIFO_DATA,
			EVT_FIFO_END			=> EVT_FIFO_END
		);

	------------------------------------------
	-- Transceiver
	------------------------------------------

	aurora_8b10b_arria_gxb_inst: aurora_8b10b_arria_gxb
		generic map(
			SIM_GTXRESET_SPEEDUP	=> 0
		)
		port map(
			USER_CLK			=> USER_CLK_i,
			TX_OUT_CLK		=> USER_CLK_i,
			TX_D				=> TX_D,
			TX_SRC_RDY_N	=> TX_SRC_RDY_N,
			TX_SOF_N			=> TX_SOF_N,
			TX_EOF_N			=> TX_EOF_N,
			TX_DST_RDY_N	=> TX_DST_RDY_N,
			RX_D				=> RX_D,
			RX_SRC_RDY_N	=> RX_SRC_RDY_N,
			RX_SOF_N			=> RX_SOF_N,
			RX_EOF_N			=> RX_EOF_N,
			HARD_ERR			=> FIBER_HARD_ERR,
			SOFT_ERR			=> SOFT_ERR,
			FRAME_ERR		=> FRAME_ERR,
			CHANNEL_UP		=> CHANNEL_UP,
			LANE_UP			=> open,
			RESET				=> FIBER_RESET,
			GT_RESET			=> FIBER_GT_RESET,
			TX_LOCK			=> TX_LOCK,
			RXP				=> RXP,
			TXP				=> TXP,
			REFCLK			=> REFCLK
		);

end synthesis;
