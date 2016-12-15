library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity mpd_fiber_reg_slave is
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
end mpd_fiber_reg_slave;

architecture synthesis of mpd_fiber_reg_slave is
	component mpd_fiber_reg_slave_rx_sm is
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
	end component;

	component mpd_fiber_reg_slave_tx_sm is
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
	end component;

	-- REG_WR/REG_RD to REG_ACK timeout cycles (REG_CLK)
	constant TIMER_CNT_TIMEOUT_VAL		: integer := 8;

	signal ACLR									: std_logic;
	signal TIMER_CNT_RST						: std_logic;
	signal TIMER_CNT_DONE					: std_logic;
	signal TIMER_CNT							: std_logic_vector(7 downto 0) := (others=>'0');
	signal DO_ADDRL							: std_logic;
	signal DO_ADDRH							: std_logic;
	signal DO_DATAL							: std_logic;
	signal DO_DATAH							: std_logic;
	signal DO_CMD_READ						: std_logic;
	signal DO_CMD_WRITE						: std_logic;
	signal ACK_WR_REQ							: std_logic;
	signal ACK_DATA							: std_logic_vector(33 downto 0);
	signal ACK_RD_REQ							: std_logic;
	signal ACK_Q								: std_logic_vector(33 downto 0);
	signal ACK_RD_EMPTY						: std_logic;
	signal CMD_WR_REQ							: std_logic;
	signal CMD_DATA							: std_logic_vector(64 downto 0);
	signal CMD_RD_REQ							: std_logic;
	signal CMD_Q								: std_logic_vector(64 downto 0);
	signal CMD_RD_EMPTY						: std_logic;
	signal REG_WR_i							: std_logic;
	signal REG_RD_i							: std_logic;
begin

	-- Note: RESET and CHANNEL_UP are synchronous to CLK, asynchronous to REG_CLK
	ACLR <= RESET or not CHANNEL_UP;

	-- REG_CLK <-> CLK domain crossing

	dcfifo_inst_ack: dcfifo
		generic map(
			intended_device_family	=> "Arria GX",
			lpm_hint						=> "MAXIMIZE_SPEED=5,RAM_BLOCK_TYPE=M4K",
			lpm_numwords				=> 16,
			lpm_showahead				=> "ON",
			lpm_type						=> "dcfifo",
			lpm_width					=> 34,
			lpm_widthu					=> 4,
			overflow_checking			=> "ON",
			rdsync_delaypipe			=> 5,
			underflow_checking		=> "ON",
			use_eab						=> "ON",
			write_aclr_synch			=> "ON",
			wrsync_delaypipe			=> 5
		)
		port map(
			rdclk		=> CLK,
			wrclk		=> REG_CLK,
			wrreq		=> ACK_WR_REQ,
			aclr		=> ACLR,
			data		=> ACK_DATA,
			rdreq		=> ACK_RD_REQ,
			wrfull	=> open,
			q			=> ACK_Q,
			rdempty	=> ACK_RD_EMPTY,
			rdfull	=> open,
			wrusedw	=> open
		);

	dcfifo_inst_cmd: dcfifo
		generic map(
			intended_device_family	=> "Arria GX",
			lpm_hint						=> "MAXIMIZE_SPEED=5,RAM_BLOCK_TYPE=M4K",
			lpm_numwords				=> 16,
			lpm_showahead				=> "ON",
			lpm_type						=> "dcfifo",
			lpm_width					=> 65,
			lpm_widthu					=> 4,
			overflow_checking			=> "ON",
			rdsync_delaypipe			=> 5,
			underflow_checking		=> "ON",
			use_eab						=> "ON",
			write_aclr_synch			=> "ON",
			wrsync_delaypipe			=> 5
		)
		port map(
			rdclk		=> REG_CLK,
			wrclk		=> CLK,
			wrreq		=> CMD_WR_REQ,
			aclr		=> ACLR,
			data		=> CMD_DATA,
			rdreq		=> CMD_RD_REQ,
			wrfull	=> open,
			q			=> CMD_Q,
			rdempty	=> CMD_RD_EMPTY,
			rdfull	=> open,
			wrusedw	=> open
		);

	-- REG_CLK logic
	REG_WR <= REG_WR_i;
	REG_RD <= REG_RD_i;

	TIMER_CNT_DONE <= '1' when TIMER_CNT = conv_std_logic_vector(TIMER_CNT_TIMEOUT_VAL, TIMER_CNT'length) else '0';

	process(REG_CLK)
	begin
		if rising_edge(REG_CLK) then
			if TIMER_CNT_RST = '1' then
				TIMER_CNT <= (others=>'0');
			elsif TIMER_CNT_DONE = '0' then
				TIMER_CNT <= TIMER_CNT + 1;
			end if;
		end if;
	end process;

	TIMER_CNT_RST <= '1' when (REG_RD_i = '0' and REG_WR_i = '0') else '0';

	process(ACLR, REG_CLK)
	begin
		if ACLR = '1' then
			ACK_WR_REQ <= '0';
			REG_RD_i <= '0';
			REG_WR_i <= '0';
			CMD_RD_REQ <= '0';
		elsif rising_edge(REG_CLK) then
			ACK_WR_REQ <= '0';
			CMD_RD_REQ <= '0';
			if (REG_ACK = '1' or TIMER_CNT_DONE = '1') and (REG_RD_i = '1' or REG_WR_i = '1') then
				REG_RD_i <= '0';
				REG_WR_i <= '0';
				ACK_WR_REQ <= '1';
				ACK_DATA(31 downto 0) <= REG_DOUT;
				ACK_DATA(32) <= REG_RD_i;
				ACK_DATA(33) <= REG_ACK;
			elsif (REG_RD_i = '0') and (REG_WR_i = '0') and (CMD_RD_EMPTY = '0') then
				CMD_RD_REQ <= '1';
				REG_DIN <= CMD_Q(31 downto 0);
				REG_ADDR <= CMD_Q(63 downto 32);
				REG_RD_i <= CMD_Q(64);
				REG_WR_i <= not CMD_Q(64);
			end if;
		end if;
	end process;

	-- CLK logic
	mpd_fiber_reg_slave_rx_sm_inst: mpd_fiber_reg_slave_rx_sm
		port map(
			CLK					=> CLK,
			RESET					=> RESET,
			CHANNEL_UP			=> CHANNEL_UP,
			RX_SRC_RDY_N		=> RX_SRC_RDY_N,
			RX_SOF_N				=> RX_SOF_N,
			RX_EOF_N				=> RX_EOF_N,
			RX_D					=> RX_D,
			DO_ADDRL				=> DO_ADDRL,
			DO_ADDRH				=> DO_ADDRH,
			DO_DATAL				=> DO_DATAL,
			DO_DATAH				=> DO_DATAH,
			DO_CMD_READ			=> DO_CMD_READ,
			DO_CMD_WRITE		=> DO_CMD_WRITE
		);

	mpd_fiber_reg_slave_tx_sm_inst: mpd_fiber_reg_slave_tx_sm
		port map(
			CLK				=> CLK,
			RESET				=> RESET,
			CHANNEL_UP		=> CHANNEL_UP,
			TX_DST_RDY_N	=> TX_DST_RDY_N,
			ACK_RD_EMPTY	=> ACK_RD_EMPTY,
			ACK_Q				=> ACK_Q,
			ACK_RD_REQ		=> ACK_RD_REQ,
			TX_SOF_N			=> TX_SOF_N,
			TX_EOF_N			=> TX_EOF_N,
			TX_SRC_RDY_N	=> TX_SRC_RDY_N,
			TX_D				=> TX_D
		);

	process(CLK)
	begin
		if rising_edge(CLK) then
			CMD_WR_REQ <= DO_CMD_READ or DO_CMD_WRITE;

			CMD_DATA(64) <= DO_CMD_READ;

			if DO_DATAL = '1' then
				CMD_DATA(15 downto 0) <= RX_D;
			end if;

			if DO_DATAH = '1' then
				CMD_DATA(31 downto 16) <= RX_D;
			end if;

			if DO_ADDRL = '1' then
				CMD_DATA(47 downto 32) <= RX_D;
			end if;

			if DO_ADDRH = '1' then
				CMD_DATA(63 downto 48) <= RX_D;
			end if;
		end if;
	end process;

end synthesis;
