library ieee;
use ieee.std_logic_1164.all;

entity mpd_fiber_reg_slave_rx_sm is
	port(
		CLK					: in std_logic;

		RESET					: in std_logic;
		CHANNEL_UP			: in std_logic;
		RX_SRC_RDY_N		: in std_logic;
		RX_SOF_N				: in std_logic;
		RX_EOF_N				: in std_logic;
		RX_D					: in std_logic_vector(0 to 15);

		DO_ADDRL				: out std_logic;
		DO_ADDRH				: out std_logic;
		DO_DATAL				: out std_logic;
		DO_DATAH				: out std_logic;
		DO_CMD_READ			: out std_logic;
		DO_CMD_WRITE		: out std_logic
	);
end mpd_fiber_reg_slave_rx_sm;

architecture synthesis of mpd_fiber_reg_slave_rx_sm is
	type RX_STATE_TYPE is (RX_RESET, RX_IDLE, RX_WRITE_ADDRL, RX_WRITE_ADDRH, RX_WRITE_DATAL, RX_WRITE_DATAH, RX_READ_ADDRL, RX_READ_ADDRH);

	constant SER_TYPE_WRITEREG	: std_logic_vector(15 downto 0) := x"0000";
	constant SER_TYPE_READREG	: std_logic_vector(15 downto 0) := x"0001";

	signal RX_STATE		: RX_STATE_TYPE;
	signal RX_STATE_NEXT	: RX_STATE_TYPE;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RESET = '1') or (CHANNEL_UP = '0') then
				RX_STATE <= RX_RESET;
			else
				RX_STATE <= RX_STATE_NEXT;
			end if;
		end if;
	end process;

	process(RX_STATE, RX_SRC_RDY_N, RX_SOF_N, RX_EOF_N, RX_D)
	begin
		RX_STATE_NEXT <= RX_STATE;
		DO_ADDRL <= '0';
		DO_ADDRH <= '0';
		DO_DATAL <= '0';
		DO_DATAH <= '0';
		DO_CMD_READ <= '0';
		DO_CMD_WRITE <= '0';

		case RX_STATE is
			when RX_RESET =>
				RX_STATE_NEXT <= RX_IDLE;

			when RX_IDLE =>
				if (RX_SRC_RDY_N = '0') and (RX_SOF_N = '0') then
					if (RX_D = SER_TYPE_WRITEREG) then
						RX_STATE_NEXT <= RX_WRITE_ADDRL;
					elsif (RX_D = SER_TYPE_READREG) then
						RX_STATE_NEXT <= RX_READ_ADDRL;
					end if;
				end if;

			when RX_WRITE_ADDRL =>
				DO_ADDRL <= '1';
				if (RX_SRC_RDY_N = '0') then
					RX_STATE_NEXT <= RX_WRITE_ADDRH;
				end if;

			when RX_WRITE_ADDRH =>
				DO_ADDRH <= '1';
				if (RX_SRC_RDY_N = '0') then
					RX_STATE_NEXT <= RX_WRITE_DATAL;
				end if;

			when RX_WRITE_DATAL =>
				DO_DATAL <= '1';
				if (RX_SRC_RDY_N = '0') then
					RX_STATE_NEXT <= RX_WRITE_DATAH;
				end if;

			when RX_WRITE_DATAH =>
				DO_DATAH <= '1';
				if (RX_SRC_RDY_N = '0') then
					DO_CMD_WRITE <= '1';
					RX_STATE_NEXT <= RX_IDLE;
				end if;

			when RX_READ_ADDRL =>
				DO_ADDRL <= '1';
				if (RX_SRC_RDY_N = '0') then
					RX_STATE_NEXT <= RX_READ_ADDRH;
				end if;

			when RX_READ_ADDRH =>
				DO_ADDRH <= '1';
				if (RX_SRC_RDY_N = '0') then
					DO_CMD_READ <= '1';
					RX_STATE_NEXT <= RX_IDLE;
				end if;

			when others =>
				RX_STATE_NEXT <= RX_IDLE;

		end case;

		if (RX_SRC_RDY_N = '0') and (RX_EOF_N = '0') then
			RX_STATE_NEXT <= RX_IDLE;
		end if;

	end process;

end synthesis;
