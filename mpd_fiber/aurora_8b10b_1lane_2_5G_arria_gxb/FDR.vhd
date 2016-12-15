LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity FDR is
	generic(
		INIT	: bit := '0'
	);
	port(
		Q		: out std_ulogic;
		C		: in std_ulogic;
		D		: in std_ulogic;
		R		: in std_ulogic
	);
end FDR;


ARCHITECTURE fdr_arch OF FDR IS
  signal Q_I    : std_ulogic := to_x01(INIT);
BEGIN

  Q <= Q_I;

	PROCESS(C)
	BEGIN
		IF rising_edge(C) THEN
			IF R = '1' THEN
				Q_I <= '0';
			ELSE
				Q_I <= D;
			END IF;
		END IF;
	END PROCESS;
	
END fdr_arch;