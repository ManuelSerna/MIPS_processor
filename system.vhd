--******************************************************************************************
-- COMPUTER ORGANIZATION LAB 7: Pipelined System
-- Manuel Serna-Aguilera
--******************************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--==========================================================================================
-- ENTITY
--==========================================================================================
entity system is
	port(
		clock 		: in std_logic;
		reset 		: in std_logic;
		mem_dump 	: in std_logic := '0'
	);
end system;

--==========================================================================================
-- ARCHITECTURE - COMPONENTS
--==========================================================================================
architecture behavior of system is
--------------------------------------------------------------------------------------------
-- REGISTER FILE component
--------------------------------------------------------------------------------------------
component reg_file is
    port(
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
end component;
--------------------------------------------------------------------------------------------
-- MEMORY component
--------------------------------------------------------------------------------------------
component memory is
   generic (
       INPUT 	: string := "";
       OUTPUT 	: string := ""
   );
	port(
        clk 		: in std_logic;
        read_en 	: in std_logic;
        write_en 	: in std_logic;
        addr 		: in std_logic_vector(15 downto 0);
        data_in 	: in std_logic_vector(15 downto 0);
        data_out 	: out std_logic_vector(15 downto 0);
        mem_dump 	: in std_logic := '0'
	);
end component;
--------------------------------------------------------------------------------------------
-- ALU component
--------------------------------------------------------------------------------------------
component alu_16b is
    port(
        a			: in std_logic_vector(15 downto 0);-- operand 1
        b			: in std_logic_vector(15 downto 0);-- operand 2
        s			: in std_logic_vector(2 downto 0);-- select 
        r			: out std_logic_vector(15 downto 0);-- result
		  neq, cout	: out std_logic;
        overflow	: out std_logic
    );
end component;
--------------------------------------------------------------------------------------------
-- 16 BIT MUX component
--------------------------------------------------------------------------------------------
component mux_16b is
	port(
		sel    : in std_logic;-- select
		a, b   : in std_logic_vector(15 downto 0);-- reg and imm values
		output : out std_logic_vector(15 downto 0)
	);
end component;
--------------------------------------------------------------------------------------------
-- MUX 4B component
--------------------------------------------------------------------------------------------
component mux_4b is
	port(
		sel 		: in std_logic;
		a, b		: in std_logic_vector(3 downto 0);
		output 	: out std_logic_vector(3 downto 0)
	);
end component;
--------------------------------------------------------------------------------------------
-- CONTROL component
--------------------------------------------------------------------------------------------
component control is
    port(
			opcode  	: in std_logic_vector(3 downto 0);-- instruction opcode (bits 15:12)
			alu_src 	: out std_logic;-- 0: reg value, 1: signed imm val
			alu_op  	: out std_logic_vector(2 downto 0);-- opcode for mux
			reg_src	: out std_logic;-- 0: memory, 1: alu result
			mem_write: out std_logic;-- 0: do not store data, 1: data mem stores on input line
			mem_read	: out std_logic;-- 0: do not update data, 1: update data
			reg_load	: out std_logic;-- drives load input of reg file
			reg_dest	: out std_logic;-- asserted if storing a word
			branch	: out std_logic;
			jump		: out std_logic
    );
end component;
--------------------------------------------------------------------------------------------
-- SIGN-EXTEND component
--------------------------------------------------------------------------------------------
component sign_extend is
    port(
			unsigned	: in std_logic;-- increase branch range width 
			input		: in std_logic_vector(3 downto 0);
			output	: out std_logic_vector(15 downto 0)-- input but extended to 16b
    );
end component;
--------------------------------------------------------------------------------------------
-- 16b REGISTER component
--------------------------------------------------------------------------------------------
component reg_16b is
	port(
		d 					: in std_logic_vector(15 downto 0);
		reset, clock 	: in std_logic;
		q 					: out std_logic_vector(15 downto 0)
	);
end component;
--------------------------------------------------------------------------------------------
-- PC ADDER component
--------------------------------------------------------------------------------------------
component PC_adder is
	port(
		a : in std_logic_vector(15 downto 0);
		b : in std_logic_vector(15 downto 0);
		r : out std_logic_vector(15 downto 0)
	);
end component;
--------------------------------------------------------------------------------------------
-- SHIFT LEFT 1 component
--------------------------------------------------------------------------------------------
component shift_left_16b is
	port(
		input 	: in std_logic_vector(15 downto 0);
		output	: out std_logic_vector(15 downto 0)
	);
end component;
--------------------------------------------------------------------------------------------
-- AND GATE component
--------------------------------------------------------------------------------------------
component and_gate is
	port(
		a : in std_logic;
		b : in std_logic;
		r : out std_logic
	);
end component;
--------------------------------------------------------------------------------------------
-- BUFFER REGISTER component
--------------------------------------------------------------------------------------------
component reg_n_bit is
	generic (WIDTH : positive);
	port(
		d : in std_logic_vector(0 to WIDTH-1);
      q : out std_logic_vector(0 to WIDTH-1);
      en : in std_logic;
      clock : in std_logic;
      reset : in std_logic
	);
end component;
--==========================================================================================
-- INTERNAL SIGNALS
--==========================================================================================
signal instruction	: std_logic_vector(15 downto 0);-- instruction taken in from instruciton mem
signal PC_to_instr 	: std_logic_vector(15 downto 0);-- sends signal from PC reg to instr memory
signal next_instr 		: std_logic_vector(15 downto 0);-- next instr to be taken in by PC, relayed by mux 5

-- ALU SIGNALS -----------------------------------------------------------------------------
signal b_data : std_logic_vector(15 downto 0);-- connect b_data of reg file to idex reg buffer
signal c_data : std_logic_vector(15 downto 0);-- connect c_data of reg file to idex reg buffer
signal muxResult_to_bALU  	: std_logic_vector(15 downto 0);-- connects: result of mux with b (alu)
signal alu_result	: std_logic_vector(15 downto 0);-- alu result goes to ExMem reg buffer
signal alu_neq		: std_logic;-- alu neq goes to ExMem reg buffer

-- BRANCH-RELATED SIGNALS ------------------------------------------------------------------
signal branch_adder_out : std_logic_vector(15 downto 0);-- branch adder output to ExMem reg buffer
signal pc_plus_2 : std_logic_vector(15 downto 0);-- output of pc adder, goes into branch mux and ifid reg buffer
signal branch_to_AND	: std_logic;-- connect branch from control to AND gate
signal branch_select : std_logic;-- connect AND gate output to select for mux4
signal mux4_to_mux5	: std_logic_vector(15 downto 0);-- connect output of mux4 to a input for mux5

-- CONTROL SIGNALS -------------------------------------------------------------------------
signal alu_src_idex : std_logic;
signal alu_op_idex : std_logic_vector(2 downto 0);
signal branch_idex : std_logic;
signal mem_read_idex : std_logic;
signal mem_write_idex : std_logic;
signal reg_src_idex : std_logic;
signal reg_load_idex : std_logic;

-- DATA MEM SIGNALS ------------------------------------------------------------------------
signal regSrc_to_mux2 		: std_logic;-- connect reg_src to mux wired to memory
signal memRead_to_readEn 	: std_logic;-- connect mem_read write_en in data mem
signal regDest_to_mux4b 	: std_logic;-- connect reg_dest to the only 4-bit mux
signal jump_to_sel			: std_logic;-- connect control jump with sel of mux5
signal dmem_data_out		: std_logic_vector(15 downto 0);-- data_out for data mem to MemWb reg buffer

-- MUX SIGNALS -----------------------------------------------------------------------------
signal mux2_to_aData		: std_logic_vector(15 downto 0);-- connects: mux 2 result to a_data
signal mux4b_to_cAddr 	: std_logic_vector(3 downto 0);-- connects: result of mux_4b (mux 3) to c_addr
signal adder_to_mux4_b 	: std_logic_vector(15 downto 0);-- connect adder for branching (neq) to mux4 input b

-- OTHER SIGNALS ---------------------------------------------------------------------------
signal sign_ext_out  	: std_logic_vector(15 downto 0);-- connects: sign-ext imm value with idex buffer
signal shifted_to_adder : std_logic_vector(15 downto 0);-- connect shift left output to adder

-- BUFFER OUTPUT SIGNALS -------------------------------------------------------------------
signal ifid_out	: std_logic_vector(31 downto 0);
signal idex_out	: std_logic_vector(76 downto 0);
signal exmem_out	: std_logic_vector(57 downto 0);
signal memwb_out	: std_logic_vector(37 downto 0);

-- DUMMY SIGNALS, NOT CONNECTED TO ANY PORT ------------------------------------------------
signal int_cout 	 	: std_logic;
signal int_overflow 	: std_logic;

begin
--==========================================================================================
-- PORT MAPS
--==========================================================================================
	registers : reg_file
		port map(
			a_data 	=> mux2_to_aData,
       	a_addr 	=> memwb_out(37 downto 34),
			load 		=> memwb_out(0),
			b_data 	=> b_data,
        	b_addr 	=> ifid_out(7 downto 4),
        	c_data 	=> c_data,
        	c_addr 	=> mux4b_to_cAddr,
			clear 	=> reset,
			clk 		=> clock 
		);
--------------------------------------------------------------------------------------------
	instrc_mem : memory
		generic map(
			INPUT 	=> "instruction_in.txt",
			OUTPUT 	=> ""
		)
		port map(
			clk => clock,
			read_en => '1',-- read instr
			write_en => '0',-- dont want to override instr
			addr => PC_to_instr,-- take in instr from PC
			data_in => x"0000",
			data_out => instruction,
			mem_dump => '0'
		);
--------------------------------------------------------------------------------------------
	data_mem : memory
		generic map (
			INPUT 	=> "data_in.mem.txt",
			OUTPUT 	=> "data_out.txt"
		)
		port map(
        clk 		=> clock,
        read_en 	=> exmem_out(3),
        write_en 	=> exmem_out(2),
        addr 		=> exmem_out(37 downto 22),
        data_in 	=> exmem_out(20 downto 5),
        data_out 	=> dmem_data_out,
        mem_dump  => mem_dump
		);
--------------------------------------------------------------------------------------------
	main_alu : alu_16b
		port map(
			a 			=> idex_out(56 downto 41),
			b 			=> muxResult_to_bALU, 
			s 			=> idex_out(7 downto 5),
			r 			=> alu_result,
			neq 		=> alu_neq,
			cout 		=> int_cout,
			overflow => int_overflow
		);
--------------------------------------------------------------------------------------------
-- MUX 1: 16 bit, takes in register value from reg file and sign extended imm value
-- and is the b input for the ALU
--------------------------------------------------------------------------------------------
	alu_mux : mux_16b
		port map(
			sel 		=> idex_out(8),
			a			=> idex_out(40 downto 25),
			b 			=> idex_out(24 downto 9),
			output 	=> muxResult_to_bALU
		);
--------------------------------------------------------------------------------------------
-- MUX 2: 16 bit, takes in data_out from memory and alu's result, will drive to a_data
--------------------------------------------------------------------------------------------
	data_mux : mux_16b
		port map(
			sel 	 => memwb_out(1),
			a 		 => memwb_out(17 downto 2),
			b 		 => memwb_out(33 downto 18),
			output => mux2_to_aData
		);
--------------------------------------------------------------------------------------------
-- MUX 3: 4 bit, takes in either bits 3..0 (every other instruction) or 11..8 (sw)
--------------------------------------------------------------------------------------------
	reg_mux : mux_4b
		port map(
			sel 		=> regDest_to_mux4b,
			a 			=> ifid_out(3 downto 0),
			b 			=> ifid_out(11 downto 8),
			output 	=> mux4b_to_cAddr
		);
--------------------------------------------------------------------------------------------
-- MUX 4: Decides to branch n instructions (1) or keep incrementing PC normally (0)
--------------------------------------------------------------------------------------------
	branch_mux : mux_16b
		port map(
			sel 	 => branch_select,
			a 		 => pc_plus_2,
			b 		 => exmem_out(57 downto 42),
			output => mux4_to_mux5
		);
--------------------------------------------------------------------------------------------
-- MUX 5: Decide whether to jump or not
--------------------------------------------------------------------------------------------
	jump_mux : mux_16b
		port map(
			sel 	 => jump_to_sel,
			a 		 => mux4_to_mux5,
			b 		 => ifid_out(31 downto 29) & ifid_out(11 downto 0) & '0',
			output => next_instr
		);
--------------------------------------------------------------------------------------------
	main_control : control
		port map(
       	opcode  	 => ifid_out(15 downto 12),
        	alu_src 	 => alu_src_idex,
        	alu_op  	 => alu_op_idex,
			reg_src	 => reg_src_idex,
			mem_write => mem_write_idex,
			mem_read	 => mem_read_idex,
			reg_load	 => reg_load_idex,
			reg_dest	 => regDest_to_mux4b,
			branch	 => branch_idex,
			jump		 => jump_to_sel
		);
--------------------------------------------------------------------------------------------
	extend : sign_extend
		port map(
			unsigned => branch_idex,
			input  => ifid_out(3 downto 0),
			output => sign_ext_out
		);
--------------------------------------------------------------------------------------------
	program_counter : reg_16b
		port map(
			d => next_instr,
			reset => reset,
			clock => clock,
			q => PC_to_instr
		);
--------------------------------------------------------------------------------------------
	my_shift : shift_left_16b
		port map(
			input => idex_out(24 downto 9),
			output => shifted_to_adder
		);
--------------------------------------------------------------------------------------------
-- REGULAR INSTRUCTION ADDER
--------------------------------------------------------------------------------------------
	instr_adder : PC_adder
		port map(
			a => PC_to_instr,
			b => x"0002",-- add 2 to address index
			r => pc_plus_2
		);
--------------------------------------------------------------------------------------------
-- INSTRUCTION ADDER WHEN BRANCHING
--------------------------------------------------------------------------------------------
	branch_adder : PC_adder
		port map(
			a => idex_out(76 downto 61),
			b => shifted_to_adder,
			r => branch_adder_out
		);
--------------------------------------------------------------------------------------------
	my_AND_gate : and_gate
		port map(
			a => exmem_out(4),
			b => exmem_out(21),
			r => branch_select
		);
--==========================================================================================
-- BUFFER REGISTERS
--==========================================================================================
--------------------------------------------------------------------------------------------
-- IFID REGISTER
--------------------------------------------------------------------------------------------
	IFID : reg_n_bit
		generic map(
			WIDTH => 32
		)
		port map(
			d 		=> pc_plus_2 & instruction,
			
			q 		=> ifid_out,-- single output but will be split up in other components
			en 	=> '1',
			clock => clock,
			reset => reset
		);
--------------------------------------------------------------------------------------------
-- IDEX REGISTER
--------------------------------------------------------------------------------------------
	IDEX : reg_n_bit
		generic map(
			WIDTH => 77
		)
		port map(
			d 		=> ifid_out(31 downto 16) &
						ifid_out(11 downto 8) &
						b_data &
						c_data &
						sign_ext_out &
						alu_src_idex &
						alu_op_idex &
						branch_idex &
						mem_read_idex &
						mem_write_idex &
						reg_src_idex &
						reg_load_idex,
			q 		=> idex_out,
			en 	=> '1',
			clock => clock,
			reset => reset
		);
--------------------------------------------------------------------------------------------
-- EXMEM REGISTER
--------------------------------------------------------------------------------------------
	EXMEM : reg_n_bit
		generic map(
			WIDTH => 58
		)
		port map(
			d 		=> branch_adder_out &
						idex_out(60 downto 57) &
						alu_result &
						alu_neq &
						idex_out(40 downto 25) &
						idex_out(4) &
						idex_out(3) &
						idex_out(2) &
						idex_out(1) &
						idex_out(0),
			q 		=> exmem_out,
			en 	=> '1',
			clock => clock,
			reset => reset
		);
--------------------------------------------------------------------------------------------
-- MEMWB REGISTER
--------------------------------------------------------------------------------------------
	MEMWB : reg_n_bit
		generic map(
			WIDTH => 38
		)
		port map(
			d 		=> exmem_out(41 downto 38) &
						exmem_out(37 downto 22) &
						dmem_data_out &
						exmem_out(1 downto 0),
			q 		=> memwb_out,
			en 	=> '1',
			clock => clock,
			reset => reset
		);
--------------------------------------------------------------------------------------------
end;