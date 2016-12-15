library ieee;
use ieee.std_logic_1164.all;

entity gxb_bytealign is
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
end gxb_bytealign;

architecture synthesis of gxb_bytealign is
	signal RX_DATAIN_Q				: std_logic_vector(15 downto 0);
	signal RX_CTRLDETECTIN_Q		: std_logic_vector(1 downto 0);
	signal RX_DISPERRIN_Q			: std_logic_vector(1 downto 0);
	signal RX_ERRDETECTIN_Q			: std_logic_vector(1 downto 0);
	signal RX_PATTERNDETECTIN_Q	: std_logic_vector(1 downto 0);

	signal RX_ALIGN_SEL				: std_logic := '1';
begin

	process(RX_CLK)
	begin
		if rising_edge(RX_CLK) then
			RX_DATAIN_Q <= RX_DATAIN;
			RX_CTRLDETECTIN_Q <= RX_CTRLDETECTIN;
			RX_DISPERRIN_Q <= RX_DISPERRIN;
			RX_ERRDETECTIN_Q <= RX_ERRDETECTIN;
			RX_PATTERNDETECTIN_Q <= RX_PATTERNDETECTIN;

			if RX_ENAPATTERNALIGN = '1' then
				if RX_CTRLDETECTIN(0) = '1' then
					RX_ALIGN_SEL <= '0';
				elsif RX_CTRLDETECTIN_Q(1) = '1' then
					RX_ALIGN_SEL <= '1';
				end if;
			end if;

			if RX_ALIGN_SEL = '0' then
				RX_DATAOUT <= RX_DATAIN;
				RX_CTRLDETECTOUT <= RX_CTRLDETECTIN;
				RX_DISPERROUT <= RX_DISPERRIN;
				RX_ERRDETECTOUT <= RX_ERRDETECTIN;
				RX_PATTERNDETECTOUT <= RX_PATTERNDETECTIN;
			else
				RX_DATAOUT <= RX_DATAIN_Q(7 downto 0) & RX_DATAIN(15 downto 8);
				RX_CTRLDETECTOUT <= RX_CTRLDETECTIN_Q(0) & RX_CTRLDETECTIN(1);
				RX_DISPERROUT <= RX_DISPERRIN_Q(0) & RX_DISPERRIN(1);
				RX_ERRDETECTOUT <= RX_ERRDETECTIN_Q(0) & RX_ERRDETECTIN(1);
				RX_PATTERNDETECTOUT <= RX_PATTERNDETECTIN_Q(0) & RX_PATTERNDETECTIN(1);
			end if;

		end if;
	end process;
	
end synthesis;
