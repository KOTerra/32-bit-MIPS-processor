library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity InstructionExecute is
    port (
        ALU_operation : in std_logic_vector(2 downto 0);
        ALU_src : in std_logic;
        read_data_1 : in std_logic_vector(31 downto 0);
        read_data_2 : in std_logic_vector(31 downto 0);
        ext_imm : in std_logic_vector(31 downto 0);
        func : in std_logic_vector(5 downto 0);
        shift_amount : in std_logic_vector(4 downto 0);
        pc_4 : in std_logic_vector(31 downto 0);
        reg_dst : in std_logic;
        register_d : in std_logic_vector(4 downto 0);
        register_t : in std_logic_vector(4 downto 0);

        zero_flag : out std_logic;
        branch_address : out std_logic_vector(31 downto 0);
        ALU_result : out std_logic_vector(31 downto 0);
        rWA : out std_logic_vector(4 downto 0)
    );
end InstructionExecute;

architecture Behavioral of InstructionExecute is
    signal ALUCtrl : std_logic_vector(3 downto 0);

    signal A_operand : std_logic_vector(31 downto 0);
    signal B_operand : std_logic_vector(31 downto 0);
    signal C : std_logic_vector(31 downto 0);

begin
    ALUControl : process (ALU_operation, func)
    begin
        case ALU_operation is
            when "000" => --R
                case func is
                    when "100000" => ALUCtrl <= "0001";--(+)
                    when "100001" => ALUCtrl <= "0100";--(-)
                    when "100010" => ALUCtrl <= "0110";--(<<)
                    when "100011" => ALUCtrl <= "0011";--(>>)
                    when "100100" => ALUCtrl <= "0010";--(&)
                    when "100101" => ALUCtrl <= "0111";--(|)
                    when "100110" => ALUCtrl <= "0101";--(^)
                    when others => ALUCtrl <= "XXXX";
                end case;
            when "001" => ALUCtrl <= "0001"; --(+)
            when "100" => ALUCtrl <= "0100";--(-)
            when "010" => ALUCtrl <= "0010";--(&)
            when "111" => ALUCtrl <= "1111"; --(SLTI)
            when others => ALUCtrl <= (others => 'X');
        end case;
    end process;

    A_operand <= read_data_1;
    setB : process (ALU_src)
    begin
        if ALU_src = '1' then
            B_operand <= ext_imm;
        else
            B_operand <= read_data_2;
        end if;
    end process;

    calculate : process (A_operand, B_operand, ALUCtrl, shift_amount)
    begin
        zero_flag <= '0';
        case ALUCtrl is
            when "0001" => C <= A_operand + B_operand; --(+)
            when "0100" => C <= A_operand - B_operand; --(-)

            when "0110" => C <= to_stdlogicvector(--(<<)
                to_bitvector(B_operand) sll conv_integer(shift_amount));
            when "0011" => C <= to_stdlogicvector(--(>>)
                to_bitvector(B_operand) srl conv_integer(shift_amount));
            when "0010" => C <= to_stdlogicvector(--(&)
                to_bitvector(A_operand) and to_bitvector(B_operand));
            when "0111" => C <= to_stdlogicvector(--(|)
                to_bitvector(A_operand) or to_bitvector(B_operand));
            when "0101" => C <= to_stdlogicvector(--(^)
                to_bitvector(A_operand) xor to_bitvector(B_operand));
            when "1111" => --SLTI
                if signed(A_operand) < signed(B_operand) then
                    C <= X"00000001";
                else
                    C <= X"00000000";
                end if;
            when others => C <= (others => 'X');
        end case;
        if C = "0000" then
            zero_flag <= '1';
        end if;
    end process;

    ALU_result <= C;
    branch_address <= (ext_imm(29 downto 0) & "00") + pc_4;

    process (reg_dst)
    begin
        if reg_dst = '1' then
            rWA<=register_d;
        else
            rWA<=register_t;
        end if;
    end process;
end Behavioral;