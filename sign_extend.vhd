--------------------------------------------------------------------------------------------
-- Computer Organization Lab 7: New sign extend
-- Manuel Serna-Aguilera
--------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_extend is
    port(
			unsigned: in std_logic;
			input  : in std_logic_vector(3 downto 0);
			output : out std_logic_vector(15 downto 0)
    );
end entity sign_extend;
--------------------------------------------------------------------------------------------
architecture behavior of sign_extend is
	signal out_temp : std_logic_vector(15 downto 0);
	begin
	-- PROCESS: take in "unsigned" input, if it's 0, then no branch in system occurs
	-- and thus sign-extend as usual. If signal is 1, then zero-extend to increase
	-- the numbers of jumps necessary for the machine code given.
	-- Max jump signed: 7.
	-- Max jump with this description: 15.
		process(input, unsigned)
		begin
			case unsigned is
				when '0' =>
					output <= std_logic_vector(resize(signed(input), out_temp'length));-- signed
				when '1' =>
					output <= "000000000000" & input;-- signed;
				when others =>
					output <= std_logic_vector(resize(signed(input), out_temp'length));-- signed
			end case;
		end process;
end behavior;