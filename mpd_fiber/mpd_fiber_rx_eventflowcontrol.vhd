library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mpd_fiber_rx_eventflowcontrol is
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
end mpd_fiber_rx_eventflowcontrol;

architecture synthesis of mpd_fiber_rx_eventflowcontrol is
	constant SER_TYPE_EVENTFLOW			: std_logic_vector(15 downto 0) := x"0003";

	type RX_STATE_TYPE is (RX_IDLE, RX_EVENTFLOW);

	signal RX_STATE				: RX_STATE_TYPE;
	signal RX_STATE_NEXT			: RX_STATE_TYPE;

	signal RX_TYPE_EVENTFLOW	: std_logic;
	signal DO_EVENTFLOW			: std_logic;
begin

	RX_TYPE_EVENTFLOW <= '1' when RX_D = SER_TYPE_EVENTFLOW else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if CHANNEL_UP = '0' then
				EVT_FIFO_BUSY <= '1';
			elsif DO_EVENTFLOW = '1' then
				EVT_FIFO_BUSY <= RX_D(15);
			end if;
		end if;
	end process;

	----------------------------------------
	-- Event Receiver State Machine
	----------------------------------------
	process(CLK)
	begin
		if rising_edge(CLK) then
			if CHANNEL_UP = '0' then
				RX_STATE <= RX_IDLE;
			else
				RX_STATE <= RX_STATE_NEXT;
			end if;
		end if;
	end process;

	process(RX_STATE, RX_SRC_RDY_N, RX_SOF_N, RX_EOF_N, RX_TYPE_EVENTFLOW)
	begin
		RX_STATE_NEXT <= RX_STATE;
		DO_EVENTFLOW <= '0';

		case RX_STATE is
			when RX_IDLE =>
				if (RX_SRC_RDY_N = '0') and (RX_SOF_N = '0') and (RX_TYPE_EVENTFLOW = '1') then
					RX_STATE_NEXT <= RX_EVENTFLOW;
				end if;

			when RX_EVENTFLOW =>
				if (RX_SRC_RDY_N = '0') and (RX_SOF_N = '0') then
					RX_STATE_NEXT <= RX_IDLE;
				elsif RX_SRC_RDY_N = '0' then
					DO_EVENTFLOW <= '1';
					RX_STATE_NEXT <= RX_IDLE;
				end if;

			when others =>
				RX_STATE_NEXT <= RX_IDLE;

		end case;
	end process;

end synthesis;
