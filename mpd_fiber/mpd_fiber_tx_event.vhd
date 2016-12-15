library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity mpd_fiber_tx_event is
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
end mpd_fiber_tx_event;

architecture synthesis of mpd_fiber_tx_event is
	constant SER_TYPE_EVENT	: std_logic_vector(15 downto 0) := x"0002";

	type TX_STATE_TYPE is (TX_RESET, TX_IDLE, TX_EVENT);

	signal TX_STATE				: TX_STATE_TYPE;
	signal TX_STATE_NEXT			: TX_STATE_TYPE;

	signal ACLR						: std_logic;
	signal EVT_FIFO_RD			: std_logic;
	signal EVT_FIFO_EMPTY		: std_logic;
	signal EVT_FIFO_DOUT			: std_logic_vector(16 downto 0);
	signal EVT_FIFO_DOUT_END	: std_logic;
	signal TX_SOF_N_i				: std_logic;
begin

	TX_SOF_N <= TX_SOF_N_i;
	TX_D <= SER_TYPE_EVENT when TX_SOF_N_i = '0' else
	        EVT_FIFO_DOUT(15 downto 0);

	EVT_FIFO_DOUT_END <= EVT_FIFO_DOUT(16);

	ACLR <= not CHANNEL_UP;

	----------------------------------------
	-- Event Data Buffer
	----------------------------------------
	dcfifo_mixed_widths_inst: dcfifo_mixed_widths
		generic map(
			intended_device_family	=> "Arria GX",
			lpm_hint						=> "MAXIMIZE_SPEED=5,RAM_BLOCK_TYPE=M4K",
			lpm_numwords				=> 128,
			lpm_showahead				=> "ON",
			lpm_type						=> "dcfifo_mixed_widths",
			lpm_width					=> 34,
			lpm_widthu					=> 7,
			lpm_widthu_r				=> 8,
			lpm_width_r					=> 17,
			overflow_checking			=> "ON",
			rdsync_delaypipe			=> 5,
			underflow_checking		=> "ON",
			use_eab						=> "ON",
			write_aclr_synch			=> "ON",
			wrsync_delaypipe			=> 5
		)
		port map(
			rdclk						=> CLK,
			wrclk						=> EVT_FIFO_CLK,
			wrreq						=> EVT_FIFO_WR,
			aclr						=> ACLR,
			data(15 downto 0)		=> EVT_FIFO_DATA(15 downto 0),
			data(16)					=> '0',
			data(32 downto 17)	=> EVT_FIFO_DATA(31 downto 16),
			data(33)					=> EVT_FIFO_END,
			rdreq						=> EVT_FIFO_RD,
			wrfull					=> EVT_FIFO_FULL,
			q							=> EVT_FIFO_DOUT,
			rdempty					=> EVT_FIFO_EMPTY
		);

	----------------------------------------
	-- Event Transmitter State Machine
	----------------------------------------
	process(CLK)
	begin
		if rising_edge(CLK) then
			if CHANNEL_UP = '0' then
				TX_STATE <= TX_RESET;
			else
				TX_STATE <= TX_STATE_NEXT;
			end if;
		end if;
	end process;

	process(TX_STATE, EVT_FIFO_EMPTY, TX_DST_RDY_N, EVT_FIFO_DOUT_END, EVT_FIFO_BUSY)
	begin
		TX_STATE_NEXT <= TX_STATE;
		TX_SRC_RDY_N <= '1';
		TX_SOF_N_i <= '1';
		TX_EOF_N <= '1';
		EVT_FIFO_RD <= '0';

		case TX_STATE is
			when TX_RESET =>
				TX_STATE_NEXT <= TX_IDLE;

			when TX_IDLE =>
				if (EVT_FIFO_EMPTY = '0') and (EVT_FIFO_BUSY = '0') then
					TX_SRC_RDY_N <= '0';
					TX_SOF_N_i <= '0';
					if TX_DST_RDY_N = '0' then
						TX_STATE_NEXT <= TX_EVENT;
					end if;
				end if;

			when TX_EVENT =>
				if (EVT_FIFO_EMPTY = '0') and (EVT_FIFO_DOUT_END = '0') then
					TX_SRC_RDY_N <= '0';
					if TX_DST_RDY_N = '0' then
						TX_STATE_NEXT <= TX_EVENT;
						EVT_FIFO_RD <= '1';
					end if;
				elsif (EVT_FIFO_EMPTY = '0') and (EVT_FIFO_DOUT_END = '1') then
					TX_SRC_RDY_N <= '0';
					TX_EOF_N <= '0';
					if TX_DST_RDY_N = '0' then
						TX_STATE_NEXT <= TX_IDLE;
						EVT_FIFO_RD <= '1';
					end if;
				end if;

			when others =>
				TX_STATE_NEXT <= TX_IDLE;
		end case;
	end process;

end synthesis;
