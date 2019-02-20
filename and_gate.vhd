---------------------------------------------------------------------------------------------------
-- Computer Org Lab 7: AND gate
-- Manuel Serna-Aguilera
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity and_gate is
	port(
		a : in std_logic;
		b : in std_logic;
		r : out std_logic
	);
end and_gate;

architecture behavior of and_gate is
begin
	r <= a and b;
end behavior;