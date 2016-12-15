library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mpd_fiber_slave is
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
end mpd_fiber_slave;

architecture synthesis of mpd_fiber_slave is
	component mpd_fiber_tx_event is
		port(
			CLK						: in std_logic;

			-- Transceiver Interface
			CHANNEL_UP				: in std_logic;
			TX_D						: out std_logic_vector(0 to 15);
			TX_SRC_RDY_N			: out std_logic;
			TX_SOF_N					: out std_logic;
			TX_EOF_N					: out std_logic;
			TX_DST_RDY_N			: in std_logic;

			-- Event builder output
			EVT_FIFO_CLK			: in std_logic;
			EVT_FIFO_FULL			: out std_logic;
			EVT_FIFO_WR				: in std_logic;
			EVT_FIFO_DATA			: in std_logic_vector(31 downto 0);
			EVT_FIFO_END			: in std_logic;

			-- Event flow control
			EVT_FIFO_BUSY			: in std_logic
		);
	end component;

	component mpd_fiber_rx_eventflowcontrol is
		port(
			CLK						: in std_logic;

			-- Transceiver Interface
			CHANNEL_UP				: in std_logic;
			RX_D						: in std_logic_vector(0 to 15);
			RX_SRC_RDY_N			: in std_logic;
			RX_SOF_N					: in std_logic;
			RX_EOF_N					: in std_logic;

			-- Event flow control
			EVT_FIFO_BUSY			: out std_logic
		);
	end component;

	component mpd_fiber_tx_arbiter is
		port(
			CLK					: in std_logic;
			RESET					: in std_logic;
			CHANNEL_UP			: in std_logic;
			TX_D					: out std_logic_vector(0 to 15);
			TX_SRC_RDY_N		: out std_logic;
			TX_DST_RDY_N		: in std_logic;
			TX_SOF_N				: out std_logic;
			TX_EOF_N				: out std_logic;
			TX_D_0				: in std_logic_vector(0 to 15);
			TX_SRC_RDY_N_0		: in std_logic;
			TX_DST_RDY_N_0		: out std_logic;
			TX_SOF_N_0			: in std_logic;
			TX_EOF_N_0			: in std_logic;
			TX_D_1				: in std_logic_vector(0 to 15);
			TX_SRC_RDY_N_1		: in std_logic;
			TX_DST_RDY_N_1		: out std_logic;
			TX_SOF_N_1			: in std_logic;
			TX_EOF_N_1			: in std_logic
		);
	end component;

	component mpd_fiber_reg_slave is
		port(
			-- Register Interface
			REG_CLK					: in std_logic;
			REG_RD					: out std_logic;
			REG_WR					: out std_logic;
			REG_ADDR					: out std_logic_vector(31 downto 0);
			REG_DIN					: out std_logic_vector(31 downto 0);
			REG_DOUT					: in std_logic_vector(31 downto 0);
			REG_ACK					: in std_logic;

			-- Transceiver Parallel Interface
			CLK						: in std_logic;
			RESET						: in std_logic;

			CHANNEL_UP				: in std_logic;
			RX_D						: in std_logic_vector(0 to 15);
			RX_SRC_RDY_N			: in std_logic;
			RX_SOF_N					: in std_logic;
			RX_EOF_N					: in std_logic;
			TX_D						: out std_logic_vector(0 to 15);
			TX_SRC_RDY_N			: out std_logic;
			TX_SOF_N					: out std_logic;
			TX_EOF_N					: out std_logic;
			TX_DST_RDY_N			: in std_logic
		);
	end component;


	signal EVT_FIFO_BUSY			: std_logic;

	signal TX_D_0					: std_logic_vector(0 to 15);
	signal TX_SRC_RDY_N_0		: std_logic;
	signal TX_DST_RDY_N_0		: std_logic;
	signal TX_SOF_N_0				: std_logic;
	signal TX_EOF_N_0				: std_logic;
	signal TX_D_1					: std_logic_vector(0 to 15);
	signal TX_SRC_RDY_N_1		: std_logic;
	signal TX_DST_RDY_N_1		: std_logic;
	signal TX_SOF_N_1				: std_logic;
	signal TX_EOF_N_1				: std_logic;
begin

	mpd_fiber_tx_arbiter_inst: mpd_fiber_tx_arbiter
		port map(
			CLK					=> CLK,
			RESET					=> RESET,
			CHANNEL_UP			=> CHANNEL_UP,
			TX_D					=> TX_D,
			TX_SRC_RDY_N		=> TX_SRC_RDY_N,
			TX_DST_RDY_N		=> TX_DST_RDY_N,
			TX_SOF_N				=> TX_SOF_N,
			TX_EOF_N				=> TX_EOF_N,
			TX_D_0				=> TX_D_0,
			TX_SRC_RDY_N_0		=> TX_SRC_RDY_N_0,
			TX_DST_RDY_N_0		=> TX_DST_RDY_N_0,
			TX_SOF_N_0			=> TX_SOF_N_0,
			TX_EOF_N_0			=> TX_EOF_N_0,
			TX_D_1				=> TX_D_1,
			TX_SRC_RDY_N_1		=> TX_SRC_RDY_N_1,
			TX_DST_RDY_N_1		=> TX_DST_RDY_N_1,
			TX_SOF_N_1			=> TX_SOF_N_1,
			TX_EOF_N_1			=> TX_EOF_N_1
		);

	mpd_fiber_tx_event_inst: mpd_fiber_tx_event
		port map(
			CLK					=> CLK,
			CHANNEL_UP			=> CHANNEL_UP,
			TX_D					=> TX_D_1,
			TX_SRC_RDY_N		=> TX_SRC_RDY_N_1,
			TX_SOF_N				=> TX_SOF_N_1,
			TX_EOF_N				=> TX_EOF_N_1,
			TX_DST_RDY_N		=> TX_DST_RDY_N_1,
			EVT_FIFO_CLK		=> EVT_FIFO_CLK,
			EVT_FIFO_FULL		=> EVT_FIFO_FULL,
			EVT_FIFO_WR			=> EVT_FIFO_WR,
			EVT_FIFO_DATA		=> EVT_FIFO_DATA,
			EVT_FIFO_END		=> EVT_FIFO_END,
			EVT_FIFO_BUSY		=> EVT_FIFO_BUSY
		);

	mpd_fiber_rx_eventflowcontrol_inst: mpd_fiber_rx_eventflowcontrol
		port map(
			CLK					=> CLK,
			CHANNEL_UP			=> CHANNEL_UP,
			RX_D					=> RX_D,
			RX_SRC_RDY_N		=> RX_SRC_RDY_N,
			RX_SOF_N				=> RX_SOF_N,
			RX_EOF_N				=> RX_EOF_N,
			EVT_FIFO_BUSY		=> EVT_FIFO_BUSY
		);

	mpd_fiber_reg_slave_inst: mpd_fiber_reg_slave
		port map(
			REG_CLK					=> REG_CLK,
			REG_RD					=> REG_RD,
			REG_WR					=> REG_WR,
			REG_ADDR					=> REG_ADDR,
			REG_DIN					=> REG_DIN,
			REG_DOUT					=> REG_DOUT,
			REG_ACK					=> REG_ACK,
			CLK						=> CLK,
			RESET						=> RESET,
			CHANNEL_UP				=> CHANNEL_UP,
			RX_D						=> RX_D,
			RX_SRC_RDY_N			=> RX_SRC_RDY_N,
			RX_SOF_N					=> RX_SOF_N,
			RX_EOF_N					=> RX_EOF_N,
			TX_D						=> TX_D_0,
			TX_SRC_RDY_N			=> TX_SRC_RDY_N_0,
			TX_SOF_N					=> TX_SOF_N_0,
			TX_EOF_N					=> TX_EOF_N_0,
			TX_DST_RDY_N			=> TX_DST_RDY_N_0
		);

end synthesis;
