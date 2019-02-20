----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:58:14 04/23/2018 
-- Design Name: 
-- Module Name:    reg_n_bit - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_n_bit is
	 generic (WIDTH : positive);

    port (
        d : in std_logic_vector(0 to WIDTH-1);
        q : out std_logic_vector(0 to WIDTH-1);
        en : in std_logic;
        clock : in std_logic;
        reset : in std_logic -- asynch active low
    );
end reg_n_bit;

architecture behavior of reg_n_bit is
begin
    process(d, en, clock, reset) is
    begin
        if reset = '0' then
            q <= (others => '0');
        elsif rising_edge(clock) and en = '1' then
            q <= d;
        end if;
    end process;
end behavior;

