---------------------------------------------------------------------------------------------------
-- Computer Org Lab 7: Shift Left 1
-- Manuel Serna-Aguilera
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_left_16b is
	port(
		input : in std_logic_vector(15 downto 0);
		output: out std_logic_vector(15 downto 0)
	);
end shift_left_16b;

architecture behavior of shift_left_16b is
begin
	output <= input(14 downto 0) & '0';
end behavior;