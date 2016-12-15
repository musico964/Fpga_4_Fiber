library ieee;
use ieee.std_logic_1164.all;

entity mpd_fiber_tx_arbiter is
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
end mpd_fiber_tx_arbiter;

architecture synthesis of mpd_fiber_tx_arbiter is
	signal ACTIVE_0		: std_logic;
	signal ACTIVE_1		: std_logic;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RESET = '1') or (CHANNEL_UP = '0') then
				ACTIVE_0 <= '0';
				ACTIVE_1 <= '0';
			elsif (ACTIVE_0 = '0') and (ACTIVE_1 = '0') then
				if TX_SRC_RDY_N_0 = '0' then
					ACTIVE_0 <= '1';
				elsif TX_SRC_RDY_N_1 = '0' then
					ACTIVE_1 <= '1';
				end if;
			elsif (ACTIVE_0 = '1') and (TX_SRC_RDY_N_0 = '0') and (TX_EOF_N_0 = '0') then
				ACTIVE_0 <= '0';
			elsif (ACTIVE_1 = '1') and (TX_SRC_RDY_N_1 = '0') and (TX_EOF_N_1 = '0') then
				ACTIVE_1 <= '0';
			end if;
		end if;
	end process;

	process(ACTIVE_0, ACTIVE_1, TX_D_0, TX_D_1, TX_SRC_RDY_N_0, TX_SRC_RDY_N_1, TX_SOF_N_0, TX_SOF_N_1, TX_EOF_N_0, TX_EOF_N_1, TX_DST_RDY_N)
	begin
		if ACTIVE_0 = '1' then
			TX_D <= TX_D_0;
			TX_SRC_RDY_N <= TX_SRC_RDY_N_0;
			TX_SOF_N <= TX_SOF_N_0;
			TX_EOF_N <= TX_EOF_N_0;
			TX_DST_RDY_N_0 <= TX_DST_RDY_N;
			TX_DST_RDY_N_1 <= '1';
		elsif ACTIVE_1 = '1' then
			TX_D <= TX_D_1;
			TX_SRC_RDY_N <= TX_SRC_RDY_N_1;
			TX_SOF_N <= TX_SOF_N_1;
			TX_EOF_N <= TX_EOF_N_1;
			TX_DST_RDY_N_0 <= '1';
			TX_DST_RDY_N_1 <= TX_DST_RDY_N;
		else
			TX_D <= (others=>'0');
			TX_SRC_RDY_N <= '1';
			TX_SOF_N <= '1';
			TX_EOF_N <= '1';
			TX_DST_RDY_N_0 <= '1';
			TX_DST_RDY_N_1 <= '1';
		end if;
	end process;

end synthesis;
