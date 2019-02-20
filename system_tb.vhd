--=================================================
-- Test Bench Lab 7
--=================================================
library ieee;
use ieee.std_logic_1164.all;


entity system_tb is
end entity system_tb;


architecture mixed of system_tb is
    constant tick : time := 10 ns;
    constant RUN_TIME : integer := 100;--30
    signal reset, clock : std_logic;
    signal mem_dump : std_logic := '0';
    signal done : boolean := false;
begin
    uut : entity work.system
        port map(
            reset => reset,
            clock => clock,
            mem_dump => mem_dump
        );

    driver : process is
    begin
        -- reset the system
        reset <= '0';
        wait for tick;
        reset <= '1';

        -- run for RUN_TIME clock cycles
        for i in 1 to RUN_TIME loop
            wait for tick;
        end loop;

        -- Dump the final data memory into a file
        mem_dump <= '1';
        
        -- Stop the clock
        done <= true;
        wait;
    end process driver;

    clock_p : process is
    begin
        while not done loop
            clock <= '0'; wait for tick/2;
            clock <= '1'; wait for tick/2;
        end loop;
        wait;
    end process clock_p;
end architecture mixed;