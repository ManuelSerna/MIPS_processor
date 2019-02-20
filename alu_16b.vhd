---------------------------------------------------------------------------------------------------
-- Computer Org Lab 7: ALU - expanded
-- Manuel Serna-Aguilera
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
---------------------------------------------------------------------------------------------------
-- Description of ALU
---------------------------------------------------------------------------------------------------
entity alu_16b is
    port(
        a           : in std_logic_vector(15 downto 0);
        b           : in std_logic_vector(15 downto 0);
        s           : in std_logic_vector(2 downto 0);
 
        r           : out std_logic_vector(15 downto 0);
		  neq			  : out std_logic;
        cout        : out std_logic;
        overflow    : out std_logic
    );
end entity alu_16b;
---------------------------------------------------------------------------------------------------
-- Behavior of ALU
---------------------------------------------------------------------------------------------------
architecture behavior of alu_16b is
	signal temp : std_logic_vector(15 downto 0);
begin
	process(a, b, s)
	begin
		case s is
			when "000" =>
				temp <= a + b;
				if a /= b then -- **
					neq <= '1'; -- **
				else				-- **
					neq <= '0'; -- **
				end if;			-- **
			when "001" =>
				temp <= a - b;
				if a /= b then -- **
					neq <= '1'; -- **
				else				-- **
					neq <= '0'; -- **
				end if;			-- **
			when "010" =>
				temp <= a and b;
				if a /= b then -- **
					neq <= '1'; -- **
				else				-- **
					neq <= '0'; -- **
				end if;			-- **
			when "011" =>
				temp <= a or b;
				if a /= b then -- **
					neq <= '1'; -- **
				else				-- **
					neq <= '0'; -- **
				end if;			-- **
			when "100" =>
				if a < b then
					temp <= x"0001";
				else
					temp <= x"0000";
				end if;
				if a /= b then -- **
					neq <= '1'; -- **
				else				-- **
					neq <= '0'; -- **
				end if;			-- **
			when others =>
				temp <= a or b;
				if a /= b then -- **
					neq <= '1'; -- **
				else				-- **
					neq <= '0'; -- **
				end if;			-- **
		end case;
	end process;
	
	--neq <= '1' when (a /= b) else '0';

	r <= temp;
	cout <= '1' when (a(15) = '1' and b(15) = '1') 
		else '1' when (a(15) /= b(15) and temp(15) = '0')
		else '0';

	-- getting overflow: when a +/- b is both (+) or both (-), 
	-- but r is the opposite, then you have overflow
	
	overflow <= '1' when (a(15) = b(15) and temp(15) /= a(15) and s = "00") 
			else '1' when (a(15) /= b(15) and temp(15) /= a(15) and s = "01") 
			else '0';
	
end behavior;
