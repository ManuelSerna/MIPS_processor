--------------------------------------------------------------------------------------------
-- Computer Organization Lab 6: 16-bit Register File
-- Manuel Serna-Aguilera
--------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;-- addresses will need to be unsigned
use ieee.numeric_std.all;

--------------------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------------------
-- *Note: addresses will be 4 bits wide to distinguish among the 2^4=16 registers
entity reg_file is
    port (
        a_data : in std_logic_vector(15 downto 0); -- input data port
        a_addr : in std_logic_vector(3 downto 0); -- register select for input a
        load   : in std_logic; -- load enable
 
        b_data : out std_logic_vector(15 downto 0); -- first output data port
        b_addr : in std_logic_vector(3 downto 0); -- register select for output b
 
        c_data : out std_logic_vector(15 downto 0); -- second output data port
        c_addr : in std_logic_vector(3 downto 0); -- register select for output c
 
        clear  : in std_logic; -- asynchronous reset, negative logic
        clk    : in std_logic -- sys clock, positive edge-triggered
    );
end entity reg_file;
--------------------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------------------
architecture behavior of reg_file is
	-- make register file, which will have 16 regs and each reg will be 16 bits wide
	type regfile is array(0 to 15) of std_logic_vector(15 downto 0);
	signal registers: regfile;

begin	
	-- Set b_data to reflect b_addr, c_data to reflect c_addr
	b_data <= registers(to_integer(unsigned(b_addr)));-- pass value in register to data
	c_data <= registers(to_integer(unsigned(c_addr)));

	-- process if and when async clear, clock, and load on rising change
	reg: process(clear, clk, load)-- label process reg
	variable i: integer;-- make index i of integer type
	begin
		-- clear the register file when clear changes to '0'
		if(clear = '0') then
			for i in 2 to 15 loop
				registers(i) <= "0000000000000000";
			end loop;

		-- if load changes, load into register file
		elsif(rising_edge(clk) and load = '1') then
			registers(to_integer(unsigned(a_addr))) <= a_data;
		end if;
		
		-- Set registers 0 and 1 to values 0 and 1 respectively
		registers(0) <= "0000000000000000";
		registers(1) <= "0000000000000001";
	end process;

end behavior;
