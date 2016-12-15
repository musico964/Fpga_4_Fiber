library ieee;
use ieee.std_logic_1164.all;

entity mpd_fiber_reg_slave_tx_sm is
	port(
		CLK				: in std_logic;
		RESET				: in std_logic;
		CHANNEL_UP		: in std_logic;

		TX_DST_RDY_N	: in std_logic;
		ACK_RD_EMPTY	: in std_logic;
		ACK_Q				: in std_logic_vector(33 downto 0);

		ACK_RD_REQ		: out std_logic;
		TX_SOF_N			: out std_logic;
		TX_EOF_N			: out std_logic;
		TX_SRC_RDY_N	: out std_logic;
		TX_D				: out std_logic_vector(0 to 15)
	);
end mpd_fiber_reg_slave_tx_sm;

architecture synthesis of mpd_fiber_reg_slave_tx_sm is
	type TX_STATE_TYPE is (TX_RESET, TX_IDLE, TX_READ_DATAL, TX_READ_DATAH, TX_READ_ACK, TX_WRITE_ACK);

	constant SER_TYPE_WRITEACK	: std_logic_vector(15 downto 0) := x"8000";
	constant SER_TYPE_READACK	: std_logic_vector(15 downto 0) := x"8001";

	signal TX_STATE		: TX_STATE_TYPE;
	signal TX_STATE_NEXT	: TX_STATE_TYPE;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RESET = '1') or (CHANNEL_UP = '0') then
				TX_STATE <= TX_RESET;
			else
				TX_STATE <= TX_STATE_NEXT;
			end if;
		end if;
	end process;

	process(TX_STATE, TX_DST_RDY_N, ACK_RD_EMPTY, ACK_Q)
	begin
		TX_STATE_NEXT <= TX_STATE;
		TX_SOF_N <= '1';
		TX_EOF_N <= '1';
		TX_SRC_RDY_N <= '1';
		TX_D <= (others=>'0');
		ACK_RD_REQ <= '0';

		case TX_STATE is
			when TX_RESET =>
				TX_STATE_NEXT <= TX_IDLE;

			when TX_IDLE =>
				TX_SOF_N <= '0';
				if ACK_RD_EMPTY = '0' then
					TX_SRC_RDY_N <= '0';
					if TX_DST_RDY_N = '0' then
						if ACK_Q(32) = '1' then
							-- perform read acknowledgement
							TX_D <= SER_TYPE_READACK;
							TX_STATE_NEXT <= TX_READ_DATAL;
						else
							-- perform write acknowledgement
							TX_D <= SER_TYPE_WRITEACK;
							TX_STATE_NEXT <= TX_WRITE_ACK;
						end if;
					end if;
				end if;

			when TX_READ_DATAL =>
				TX_SRC_RDY_N <= '0';
				TX_D <= ACK_Q(15 downto 0);
				if TX_DST_RDY_N = '0' then
					TX_STATE_NEXT <= TX_READ_DATAH;
				end if;

			when TX_READ_DATAH =>
				TX_SRC_RDY_N <= '0';
				TX_D <= ACK_Q(31 downto 16);
				if TX_DST_RDY_N = '0' then
					TX_STATE_NEXT <= TX_READ_ACK;
				end if;

			when TX_READ_ACK =>
				TX_SRC_RDY_N <= '0';
				TX_EOF_N <= '0';
				if ACK_Q(33) = '1' then
					TX_D <= x"0000";
				else
					TX_D <= x"0001";
				end if;
				if TX_DST_RDY_N = '0' then
					ACK_RD_REQ <= '1';
					TX_STATE_NEXT <= TX_IDLE;
				end if;

			when TX_WRITE_ACK =>
				TX_SRC_RDY_N <= '0';
				TX_EOF_N <= '0';
				if ACK_Q(33) = '1' then
					TX_D <= x"0000";
				else
					TX_D <= x"0001";
				end if;
				if TX_DST_RDY_N = '0' then
					ACK_RD_REQ <= '1';
					TX_STATE_NEXT <= TX_IDLE;
				end if;

			when others =>
				TX_STATE_NEXT <= TX_RESET;

		end case;
	end process;

end synthesis;
