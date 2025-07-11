library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity ControlUnit is
    port (
        instruction_opcode : in std_logic_vector(5 downto 0);
        ALU_operation : out std_logic_vector(2 downto 0);
        reg_dst : out std_logic;
        ext_op : out std_logic;
        ALU_src : out std_logic;
        branch : out std_logic;
        jump : out std_logic;
        memory_write : out std_logic;
        mem_to_reg : out std_logic;
        reg_write : out std_logic;
        jump_reg : out std_logic

    );
end ControlUnit;

architecture Behavioral of ControlUnit is

begin
    process (instruction_opcode)
    begin
        ALU_operation <= "000";
        reg_dst <= '0';
        ext_op <= '0';
        ALU_src <= '0';
        branch <= '0';
        jump <= '0';
        memory_write <= '0';
        mem_to_reg <= '0';
        reg_write <= '0';
        jump_reg <= '0';

        case instruction_opcode is
            when "000000" => -- R Type
                reg_dst <= '1';
                reg_write <= '1';
                ALU_operation <= "000";--"codR";

            when "000001" => --ADDI
                ext_op <= '1';
                ALU_src <= '1';
                reg_write <= '1';
                ALU_operation <= "001";-- (+)
            when "000010" => --LW
                ext_op <= '1';
                ALU_src <= '1';
                mem_to_reg <= '1';
                reg_write <= '1';
                ALU_operation <= "001";-- (+)
            when "000011" => --SW
                ext_op <= '1';
                ALU_src <= '1';
                memory_write <= '1';
                ALU_operation <= "001";-- (+)
            when "000100" => --BEQ
                ext_op <= '1';
                branch <= '1';
                ALU_operation <= "100";-- (-)
            when "000101" => --ANDI
                ext_op <= '1';
                ALU_src <= '1';
                reg_write <= '1';
                ALU_operation <= "010";-- (&)
            when "000110" => --SLTI
                ext_op <= '1';
                ALU_src <= '1';
                reg_write <= '1';
                ALU_operation <= "111";-- (slti)
            when "000111" => --J
                ext_op <= '1';
                jump <= '1';
            when "100111" => --JR
                jump_reg <= '1';
            when others => ALU_operation <= "000";
        end case;
    end process;
end Behavioral;