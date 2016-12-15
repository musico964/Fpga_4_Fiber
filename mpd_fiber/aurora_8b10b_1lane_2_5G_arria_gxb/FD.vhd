library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FD is
	generic(
		INIT	: bit := '0'
	);
	port(
		Q		: out std_ulogic;
		C		: in std_ulogic;
		D		: in std_ulogic
	);
end FD;

ARCHITECTURE fd_arch OF FD IS
	SIGNAL Q_I	: std_ulogic := to_x01(INIT);
BEGIN

	Q <= Q_I;

	PROCESS(C)
	BEGIN
		IF rising_edge(C) THEN
			Q_I <= D;
		END IF;
	END PROCESS;
	
END fd_arch;