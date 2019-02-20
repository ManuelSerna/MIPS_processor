--------------------------------------------------------------------------------------------
-- Computer Organization Lab 7: Control
-- Manuel Serna-Aguilera
--------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control is
    port(
        opcode  : in std_logic_vector(3 downto 0);
        alu_src : out std_logic;-- 0: reg value, 1: signed imm val
        alu_op  : out std_logic_vector(2 downto 0);-- opcode for mux
		  reg_src	: out std_logic;-- 0: memory, 1: alu result
		  mem_write	: out std_logic;-- 0: do not store data, 1: data mem stores on input line
		  mem_read	: out std_logic;-- 0: do not update data, 1: update data
		  reg_load	: out std_logic;-- drives load input of reg file
		  reg_dest	: out std_logic;
		  branch		: out std_logic;-- used for branch instr
		  jump		: out std_logic-- used to jump instructions
    );
end entity control;
--------------------------------------------------------------------------------------------
architecture behavior of control is
	begin
		process(opcode)
			begin
			case opcode is
				--add: 0000 - 0
				when x"0" =>
					alu_op 	<= "000";-- add: 00
					alu_src 	<= '0';
					reg_src	<= '1';-- grab alu result
					mem_write<= '0';-- dont send out a signal
					mem_read	<= '0';-- dont take in data
					reg_load	<= '1';-- load value
					reg_dest	<= '0';-- take in bits 11:8
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				--addi: 0100 - 4
				when x"4" =>
					alu_op 	<= "000";
					alu_src 	<= '1';-- working w/ imm
					reg_src	<= '1';-- grab alu result
					mem_write<= '0';-- dont send out a signal
					mem_read	<= '0';-- dont take in data
					reg_load	<= '1';-- load value
					reg_dest	<= '0';-- take in bits 11:8 
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				--sub: 0001 - 1
				when x"1" =>
					alu_op 	<= "001";-- sub: 01
					alu_src 	<= '0';
					reg_src	<= '1';-- grab alu result
					mem_write<= '0';-- dont send out a signal
					mem_read	<= '0';-- dont take in data
					reg_load	<= '1';-- load value
					reg_dest	<= '0';-- take in bits 11:8
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				--subi: 0101 - 5
				when x"5" =>
					alu_op 	<= "001";
					alu_src 	<= '1';-- working w/ imm
					reg_src	<= '1';-- grab alu result
					mem_write<= '0';-- dont send out a signal
					mem_read	<= '0';-- dont take in data
					reg_load	<= '1';-- load value
					reg_dest	<= '0';-- take in bits 11:8
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				--and: 0010 - 2
				when x"2" =>
					alu_op 	<= "010";
					alu_src 	<= '0';
					reg_src	<= '1';-- grab alu result
					mem_write<= '0';-- dont send out a signal
					mem_read	<= '0';-- dont take in data
					reg_load	<= '1';-- load value
					reg_dest	<= '0';-- take in bits 11:8
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				--or: 0011 - 3
				when x"3" =>
					alu_op 	<= "011";
					alu_src 	<= '0';
					reg_src	<= '1';-- grab alu result
					mem_write<= '0';-- dont send out a signal
					mem_read	<= '0';-- dont take in data
					reg_load	<= '1';-- load value
					reg_dest	<= '0';-- take in bits 11:8
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				-- lw: 8
				when x"8" =>
					alu_op 	<= "000";-- add reg with imm/offset
					alu_src 	<= '1';-- DC
					reg_src	<= '0';-- pull from memory on mux
					mem_write<= '0';-- do not store data on input line
					mem_read	<= '1';-- update output line
					reg_load	<= '1';-- transfer data from reg file to mem
					reg_dest	<= '0';
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				-- sw: c
				when x"C" =>
					alu_op 	<= "000";-- add reg with imm/offest
					alu_src 	<= '1';-- DC
					reg_src	<= '0';
					mem_write<= '1';-- take in data from input line
					mem_read	<= '0';-- dont update output line
					reg_load	<= '0';
					reg_dest	<= '1';--store a word
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				-- slt: 7
				when x"7" =>
					alu_op 	<= "100";
					alu_src 	<= '0';
					reg_src	<= '1';-- grab alu result from comparison
					mem_write<= '0';-- dont send out a signal
					mem_read	<= '0';-- dont take in data
					reg_load	<= '1';-- load value to reg file
					reg_dest	<= '0';-- take in bits 11:8
					branch	<= '0';-- no branch instr
					jump		<= '0';-- no jump
				-- bne: 9
				when x"9" =>
					alu_op 	<= "100";-- slt
					alu_src 	<= '0';-- want to pick reg
					reg_src	<= '1';-- want result of alu to pass
					mem_write<= '0';-- do not mess with mem
					mem_read	<= '0';
					reg_load	<= '0';-- get reg values and compare in alu
					reg_dest <= '0';-- no store word
					branch	<= '1';-- perform branch instr
					jump		<= '0';-- no jump
				-- jump address: b
				when x"B" =>
					alu_op 	<= "000";-- DC
					alu_src 	<= '0';-- want to pick offset -- CHANGED!!!!!!! TO 0 <-
					reg_src	<= '1';-- do not want result of alu to pass
					mem_write<= '0';-- do not mess with mem
					mem_read	<= '0';
					reg_load	<= '0';-- DC
					reg_dest <= '0';-- no store word
					branch	<= '0';-- no branch instr
					jump		<= '1';-- jump opcode received
				when others => -- add will be default case
					alu_op 	<= "000";
					alu_src 	<= '0';
					reg_src	<= '0';
					mem_write<= '0';
					mem_read	<= '0';
					reg_load	<= '0';
					reg_dest	<= '0';
					jump		<= '0';
			end case;
		end process;
end behavior;
