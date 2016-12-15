library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity aurora_8b10b_v5_3_GTX_WRAPPER is
generic(
SIM_GTXRESET_SPEEDUP   :integer :=   0      --Set to 1 to speed up sim reset
);
port
(
---------------------- Loopback and Powerdown Ports ----------------------
LOOPBACK_IN                               : in    std_logic_vector (2 downto 0);
--------------------- Receive Ports - 8b10b Decoder ----------------------

RXCHARISCOMMA_OUT : out   std_logic_vector (1 downto 0); 
RXCHARISK_OUT     : out   std_logic_vector (1 downto 0);
RXDISPERR_OUT     : out   std_logic_vector (1 downto 0);
RXNOTINTABLE_OUT  : out   std_logic_vector (1 downto 0);
----------------- Receive Ports - Channel Bonding Ports -----------------

ENCHANSYNC_IN     : in    std_logic;

CHBONDDONE_OUT    : out   std_logic;

----------------- Receive Ports - Clock Correction Ports -----------------

RXBUFERR_OUT      : out   std_logic;

------------- Receive Ports - Comma Detection and Alignment --------------

RXREALIGN_OUT     : out   std_logic;

ENMCOMMAALIGN_IN  : in    std_logic;

ENPCOMMAALIGN_IN  : in    std_logic;

----------------- Receive Ports - RX Data Path interface -----------------
RXDATA_OUT        : out   std_logic_vector (15 downto 0);

RXRECCLK1_OUT     : out   std_logic;

RXRECCLK2_OUT     : out   std_logic;

RXRESET_IN        : in    std_logic;
RXUSRCLK_IN                               : in    std_logic;
RXUSRCLK2_IN                              : in    std_logic;
----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
RX1N_IN           : in    std_logic;
RX1P_IN           : in    std_logic;

--------------- Receive Ports - RX Polarity Control Ports ----------------
RXPOLARITY_IN     : in    std_logic;

------------------- Shared Ports - Tile and PLL Ports --------------------

REFCLK                                    : in    std_logic;

GTXRESET_IN                               : in    std_logic;
PLLLKDET_OUT      : out   std_logic;
REFCLKOUT_OUT     : out   std_logic;

-------------- Transmit Ports - 8b10b Encoder Control Ports --------------

TXCHARISK_IN      : in    std_logic_vector (1 downto 0);

---------------- Transmit Ports - TX Data Path interface -----------------

TXDATA_IN         : in    std_logic_vector (15 downto 0);

TXOUTCLK1_OUT     : out   std_logic;

TXOUTCLK2_OUT     : out   std_logic;

TXRESET_IN        : in    std_logic;
 
TXUSRCLK_IN                               : in    std_logic;       
TXUSRCLK2_IN                              : in    std_logic;
TXBUFERR_OUT      : out   std_logic;

------------- Transmit Ports - TX Driver and OOB signalling --------------

TX1N_OUT          : out   std_logic;
TX1P_OUT          : out   std_logic;

RXCHARISCOMMA_OUT_unused : out   std_logic_vector (1 downto 0);
RXCHARISK_OUT_unused     : out   std_logic_vector (1 downto 0);
RXDISPERR_OUT_unused     : out   std_logic_vector (1 downto 0);
RXNOTINTABLE_OUT_unused  : out   std_logic_vector (1 downto 0);
------------------- Receive Ports - Channel Bonding Ports -----------------
RXREALIGN_OUT_unused     : out   std_logic;
RXDATA_OUT_unused        : out   std_logic_vector (15 downto 0);
RX1N_IN_unused           : in    std_logic;
RX1P_IN_unused           : in    std_logic;
RXBUFERR_OUT_unused      : out   std_logic_vector(2 downto 0);
TXBUFERR_OUT_unused      : out   std_logic_vector(1 downto 0);
CHBONDDONE_OUT_unused    : out   std_logic;
TX1N_OUT_unused          : out   std_logic;
TX1P_OUT_unused          : out   std_logic;

POWERDOWN_IN                                       : in    std_logic
);
end aurora_8b10b_v5_3_GTX_WRAPPER;

architecture BEHAVIORAL of aurora_8b10b_v5_3_GTX_WRAPPER is
	component gxb_transceiver is
		port(
			cal_blk_clk				: in std_logic;
			pll_inclk				: in std_logic;
			rx_analogreset			: in std_logic_vector (0 downto 0);
			rx_datain				: in std_logic_vector (0 downto 0);
			rx_digitalreset		: in std_logic_vector (0 downto 0);
			rx_enapatternalign	: in std_logic_vector (0 downto 0);
			tx_ctrlenable			: in std_logic_vector (1 downto 0);
			tx_datain				: in std_logic_vector (15 downto 0);
			tx_digitalreset		: in std_logic_vector (0 downto 0);
			pll_locked				: out std_logic_vector (0 downto 0);
			rx_clkout				: out std_logic_vector (0 downto 0);
			rx_ctrldetect			: out std_logic_vector (1 downto 0);
			rx_dataout				: out std_logic_vector (15 downto 0);
			rx_disperr				: out std_logic_vector (1 downto 0);
			rx_errdetect			: out std_logic_vector (1 downto 0);
			rx_freqlocked			: out std_logic_vector (0 downto 0);
			rx_patterndetect		: out std_logic_vector (1 downto 0);
			rx_syncstatus			: out std_logic_vector (1 downto 0);
			tx_clkout				: out std_logic_vector (0 downto 0);
			tx_dataout				: out std_logic_vector (0 downto 0)
		);
	end component;

	component gxb_bytealign is
		port(
			RX_CLK					: in std_logic;

			RX_ENAPATTERNALIGN	: in std_logic;

			RX_DATAIN				: in std_logic_vector(15 downto 0);
			RX_CTRLDETECTIN		: in std_logic_vector(1 downto 0);
			RX_DISPERRIN			: in std_logic_vector(1 downto 0);
			RX_ERRDETECTIN			: in std_logic_vector(1 downto 0);
			RX_PATTERNDETECTIN	: in std_logic_vector(1 downto 0);

			RX_DATAOUT				: out std_logic_vector(15 downto 0);
			RX_CTRLDETECTOUT		: out std_logic_vector(1 downto 0);
			RX_DISPERROUT			: out std_logic_vector(1 downto 0);
			RX_ERRDETECTOUT		: out std_logic_vector(1 downto 0);
			RX_PATTERNDETECTOUT	: out std_logic_vector(1 downto 0)
		);
	end component;

	component gxb_clockcompensate is
		port(
			RX_CLK					: in std_logic;

			RX_DATAIN				: in std_logic_vector(15 downto 0);
			RX_CTRLDETECTIN		: in std_logic_vector(1 downto 0);
			RX_DISPERRIN			: in std_logic_vector(1 downto 0);
			RX_ERRDETECTIN			: in std_logic_vector(1 downto 0);
			RX_PATTERNDETECTIN	: in std_logic_vector(1 downto 0);

			TX_CLK					: in std_logic;
			
			RX_DATAOUT				: out std_logic_vector(15 downto 0);
			RX_CTRLDETECTOUT		: out std_logic_vector(1 downto 0);
			RX_DISPERROUT			: out std_logic_vector(1 downto 0);
			RX_ERRDETECTOUT		: out std_logic_vector(1 downto 0);
			RX_PATTERNDETECTOUT	: out std_logic_vector(1 downto 0)
		);
	end component;

	signal RX_CLK								: std_logic;
	signal TX_CLKOUT							: std_logic;
	signal RX_SYNCSTATUS						: std_logic_vector(1 downto 0);
	signal RX_SYNCSTATUS_Q					: std_logic_vector(1 downto 0);
	signal RX_ANALOGRESET					: std_logic;
	signal RX_DIGITALRESET					: std_logic;
	signal TX_DIGITALRESET					: std_logic;
	signal PLL_LOCKED							: std_logic;
	signal RX_FREQLOCK_CNT					: std_logic_vector(8 downto 0);
	signal RX_FREQLOCK_CNT_DONE			: std_logic;
	signal RX_FREQLOCKED						: std_logic;
	signal RX_CTRLDETECT						: std_logic_vector(1 downto 0);
	signal RX_DATAOUT							: std_logic_vector(15 downto 0);
	signal RX_DISPERR							: std_logic_vector(1 downto 0);
	signal RX_ERRDETECT						: std_logic_vector(1 downto 0);
	signal RX_PATTERNDETECT					: std_logic_vector(1 downto 0);
	signal RX_CTRLDETECT_Q					: std_logic_vector(1 downto 0);
	signal RX_DATAOUT_Q						: std_logic_vector(15 downto 0);
	signal RX_DISPERR_Q						: std_logic_vector(1 downto 0);
	signal RX_ERRDETECT_Q					: std_logic_vector(1 downto 0);
	signal RX_PATTERNDETECT_Q				: std_logic_vector(1 downto 0);

	signal RX_DATA_BYTEALIGN				: std_logic_vector(15 downto 0);
	signal RX_CTRLDETECT_BYTEALIGN		: std_logic_vector(1 downto 0);
	signal RX_DISPERR_BYTEALIGN			: std_logic_vector(1 downto 0);
	signal RX_ERRDETECT_BYTEALIGN			: std_logic_vector(1 downto 0);
	signal RX_PATTERNDETECT_BYTEALIGN	: std_logic_vector(1 downto 0);
	signal RX_DATA_CC							: std_logic_vector(15 downto 0);
	signal RX_CTRLDETECT_CC					: std_logic_vector(1 downto 0);
	signal RX_DISPERR_CC						: std_logic_vector(1 downto 0);
	signal RX_ERRDETECT_CC					: std_logic_vector(1 downto 0);
	signal RX_PATTERNDETECT_CC				: std_logic_vector(1 downto 0);
begin

	RX_FREQLOCK_CNT_DONE <= '1' when RX_FREQLOCK_CNT = conv_std_logic_vector(2**RX_FREQLOCK_CNT'length-1, RX_FREQLOCK_CNT'length) else '0';

-- TX_DIGITALRESET <= GTXRESET_IN;

	process(GTXRESET_IN, TXUSRCLK_IN)
	begin
		if GTXRESET_IN = '1' then
			RX_ANALOGRESET <= '1';
			RX_DIGITALRESET <= '1';
			TX_DIGITALRESET <= '1';
			RX_FREQLOCK_CNT <= (others=>'0');
		elsif rising_edge(TXUSRCLK_IN) then
			if PLL_LOCKED = '1' then
				TX_DIGITALRESET <= '0';
				RX_ANALOGRESET <= '0';
			else
				RX_ANALOGRESET <= '1';
				RX_DIGITALRESET <= '1';
				TX_DIGITALRESET <= TXRESET_IN;
			end if;

			if (RX_FREQLOCKED = '0') or (PLL_LOCKED = '0')  then
				RX_FREQLOCK_CNT <= (others=>'0');
			elsif RX_FREQLOCK_CNT_DONE = '0' then
				RX_FREQLOCK_CNT <= RX_FREQLOCK_CNT + 1;
			end if;

			if RX_FREQLOCK_CNT_DONE = '1' then
				RX_DIGITALRESET <= RXRESET_IN;
			else
				RX_DIGITALRESET <= '1';
			end if;
		end if;
	end process;

	gxb_transceiver_inst: gxb_transceiver
		port map(
			cal_blk_clk					=> TXUSRCLK_IN,
			pll_inclk					=> REFCLK,
			rx_analogreset(0)			=> RX_ANALOGRESET,
			rx_datain(0)				=> RX1P_IN,
			rx_digitalreset(0)		=> RX_DIGITALRESET,
			rx_enapatternalign(0)	=> ENMCOMMAALIGN_IN,
			tx_ctrlenable				=> TXCHARISK_IN,
			tx_datain					=> TXDATA_IN,
			tx_digitalreset(0)		=> TX_DIGITALRESET,
			pll_locked(0)				=> PLL_LOCKED,
			rx_clkout(0)				=> RX_CLK,
			rx_ctrldetect				=> RX_CTRLDETECT_BYTEALIGN,
			rx_dataout					=> RX_DATA_BYTEALIGN,
			rx_disperr					=> RX_DISPERR_BYTEALIGN,
			rx_errdetect				=> RX_ERRDETECT_BYTEALIGN,
			rx_freqlocked(0)			=> RX_FREQLOCKED,
			rx_patterndetect			=> RX_PATTERNDETECT_BYTEALIGN,
			rx_syncstatus				=> RX_SYNCSTATUS,
			tx_clkout(0)				=> TX_CLKOUT,
			tx_dataout(0)				=> TX1P_OUT
		);

	gxb_bytealign_inst: gxb_bytealign
		port map(
			RX_CLK					=> RX_CLK,
			RX_ENAPATTERNALIGN	=> ENMCOMMAALIGN_IN,
			RX_DATAIN				=> RX_DATA_BYTEALIGN,
			RX_CTRLDETECTIN		=> RX_CTRLDETECT_BYTEALIGN,
			RX_DISPERRIN			=> RX_DISPERR_BYTEALIGN,
			RX_ERRDETECTIN			=> RX_ERRDETECT_BYTEALIGN,
			RX_PATTERNDETECTIN	=> RX_PATTERNDETECT_BYTEALIGN,
			RX_DATAOUT				=> RX_DATA_CC,
			RX_CTRLDETECTOUT		=> RX_CTRLDETECT_CC,
			RX_DISPERROUT			=> RX_DISPERR_CC,
			RX_ERRDETECTOUT		=> RX_ERRDETECT_CC,
			RX_PATTERNDETECTOUT	=> RX_PATTERNDETECT_CC
		);

	gxb_clockcompensate_inst: gxb_clockcompensate
		port map(
			RX_CLK					=> RX_CLK,
			RX_DATAIN				=> RX_DATA_CC,
			RX_CTRLDETECTIN		=> RX_CTRLDETECT_CC,
			RX_DISPERRIN			=> RX_DISPERR_CC,
			RX_ERRDETECTIN			=> RX_ERRDETECT_CC,
			RX_PATTERNDETECTIN	=> RX_PATTERNDETECT_CC,
			TX_CLK					=> TX_CLKOUT,
			RX_DATAOUT				=> RXDATA_OUT,
			RX_CTRLDETECTOUT		=> RXCHARISK_OUT,
			RX_DISPERROUT			=> RXDISPERR_OUT,
			RX_ERRDETECTOUT		=> RXNOTINTABLE_OUT,
			RX_PATTERNDETECTOUT	=> RXCHARISCOMMA_OUT
		);

	RXREALIGN_OUT <= (RX_SYNCSTATUS(0) and not RX_SYNCSTATUS_Q(0)) or (RX_SYNCSTATUS(1) and not RX_SYNCSTATUS_Q(1));

	process(TXUSRCLK_IN)
	begin
		if rising_edge(TXUSRCLK_IN) then
			RX_SYNCSTATUS_Q <= RX_SYNCSTATUS;
		end if;
	end process;

	PLLLKDET_OUT <= PLL_LOCKED;
	TXOUTCLK1_OUT <= TX_CLKOUT;
	TXOUTCLK2_OUT <= TX_CLKOUT;

	CHBONDDONE_OUT <= '0';
	RXBUFERR_OUT <= '0';
	RXRECCLK1_OUT <= '0';
	RXRECCLK2_OUT <= '0';
	REFCLKOUT_OUT <= '0';
	TXBUFERR_OUT <= '0';
	TX1N_OUT <= '0';

	RXCHARISCOMMA_OUT_unused <= (others=>'0');
	RXCHARISK_OUT_unused <= (others=>'0');
	RXDISPERR_OUT_unused <= (others=>'0');
	RXNOTINTABLE_OUT_unused <= (others=>'0');
	RXREALIGN_OUT_unused <= '0';
	RXDATA_OUT_unused <= (others=>'0');
	RXBUFERR_OUT_unused <= (others=>'0');
	TXBUFERR_OUT_unused <= (others=>'0');
	CHBONDDONE_OUT_unused <= '0';
	TX1N_OUT_unused <= '0';
	TX1P_OUT_unused <= '0';

end BEHAVIORAL;