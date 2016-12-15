library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity gxb_clockcompensate is
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
end gxb_clockcompensate;

architecture synthesis of gxb_clockcompensate is
	signal WRREQ		: std_logic;
	signal WRUSEDW		: std_logic_vector(4 downto 0);
	signal RDREQ		: std_logic;
	signal RDUSEDW		: std_logic_vector(4 downto 0);
	signal DATA			: std_logic_vector(23 downto 0);
	signal Q				: std_logic_vector(23 downto 0);
	signal CC_IN		: std_logic;
	signal CC_OUT		: std_logic;
begin

	CC_IN <= '1' when (DATA(15 downto 0) = x"F7F7") and (DATA(17 downto 16) = "11") else '0';
	CC_OUT <= '1' when (Q(15 downto 0) = x"F7F7") and (Q(17 downto 16) = "11") else '0';

	WRREQ <= '0' when (CC_IN = '1') and (WRUSEDW > conv_std_logic_vector(15, WRUSEDW'length)) else '1';
	RDREQ <= '0' when (CC_OUT = '1') and (RDUSEDW < conv_std_logic_vector(15, RDUSEDW'length)) else '1';

	DATA(15 downto 0)		<= RX_DATAIN;
	DATA(17 downto 16)	<= RX_CTRLDETECTIN;
	DATA(19 downto 18)	<= RX_DISPERRIN;
	DATA(21 downto 20)	<= RX_ERRDETECTIN;
	DATA(23 downto 22)	<= RX_PATTERNDETECTIN;

	RX_DATAOUT				<= Q(15 downto 0);
	RX_CTRLDETECTOUT		<= Q(17 downto 16);
	RX_DISPERROUT			<= Q(19 downto 18);
	RX_ERRDETECTOUT		<= Q(21 downto 20);
	RX_PATTERNDETECTOUT	<= Q(23 downto 22);

	dcfifo_inst: dcfifo
		generic map(
			add_ram_output_register	=> "OFF",
			clocks_are_synchronized	=> "FALSE",
			intended_device_family	=> "Arria GX",
			lpm_numwords				=> 32,
			lpm_showahead				=> "ON",
			lpm_type						=> "dcfifo",
			lpm_width					=> 24,
			lpm_widthu					=> 5,
			overflow_checking			=> "ON",
			underflow_checking		=> "ON",
			use_eab						=> "ON"
		)
		port map(
			rdclk		=> TX_CLK,
			wrclk		=> RX_CLK,
			wrreq		=> WRREQ,
			data		=> DATA,
			rdreq		=> RDREQ,
			wrfull	=> open,
			q			=> Q,
			rdempty	=> open,
			wrusedw	=> WRUSEDW,
			rdusedw	=> RDUSEDW
		);

end synthesis;
