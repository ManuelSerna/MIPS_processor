--------------------------------------------------------------------------------------------
-- Computer Organization Lab 6: PC adder (add 2 to PC)
-- Manuel Serna-Aguilera
--------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;

entity PC_adder is
	port(
		a : in std_logic_vector(15 downto 0);
		b : in std_logic_vector(15 downto 0);
		r : out std_logic_vector(15 downto 0)
	);
end PC_adder;

architecture behavior of PC_adder is
begin
	-- add 2 bytes to the old PC instr to go
	-- to next instr in instr mem
	r <= a + b;
end behavior;