--------------------------------------------------------------------------------------------
-- Computer Organization Lab 6: 16-bit Register
-- Manuel Serna-Aguilera
--------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_16b is
	port(
		d 					: in std_logic_vector(15 downto 0);
		reset, clock 	: in std_logic;
		q 					: out std_logic_vector(15 downto 0)
	);
end reg_16b;

architecture behavior of reg_16b is
begin
	process(reset, clock)
	begin
		if reset = '0' then
			q <= x"0000";
		elsif clock'event and clock = '1' then
			q <= d;
		end if;
	end process;
end behavior;