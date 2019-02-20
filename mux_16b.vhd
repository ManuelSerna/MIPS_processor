--------------------------------------------------------------------------------------------
-- Computer Organization Lab 7: 16 bit mux
-- Manuel Serna-Aguilera
--------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_16b is
	port(
		sel : in std_logic;
		a, b : in std_logic_vector(15 downto 0);
		output : out std_logic_vector(15 downto 0)
	);
end mux_16b;
--------------------------------------------------------------------------------------------
architecture behavior of mux_16b is
begin
	with sel select
	output <=  a when '0', b when '1', a when others;
end behavior;