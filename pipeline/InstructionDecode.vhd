library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity InstructionDecode is
    port (
        clk : in std_logic;
        en : in std_logic;
        reg_dst : in std_logic;
        extend_op : in std_logic;
        reg_write : in std_logic;

        instruction : in std_logic_vector(25 downto 0);
        write_address:in std_logic_vector(4 downto 0);
        write_data : in std_logic_vector(31 downto 0);
        read_data_1 : out std_logic_vector(31 downto 0);
        read_data_2 : out std_logic_vector(31 downto 0);
        ext_imm : out std_logic_vector(31 downto 0);
        func : out std_logic_vector(5 downto 0);
        shift_amount : out std_logic_vector(4 downto 0);
        register_t: out std_logic_vector(4 downto 0);
        register_d: out std_logic_vector(4 downto 0)
    );
end InstructionDecode;

architecture Behavioral of InstructionDecode is

    component RegisterFile is
        port (
            clk : in std_logic;
            en : in std_logic;
            ra1 : in std_logic_vector(4 downto 0);
            ra2 : in std_logic_vector(4 downto 0);
            wa : in std_logic_vector(4 downto 0);
            wd : in std_logic_vector(31 downto 0);
            regwr : in std_logic;
            rd1 : out std_logic_vector(31 downto 0);
            rd2 : out std_logic_vector(31 downto 0));
    end component;


begin

    registers : RegisterFile port map(clk, en, instruction(25 downto 21), instruction(20 downto 16), write_address, write_data, reg_write, read_data_1, read_data_2);


    process (extend_op)
    begin
        if extend_op = '1' then
            ext_imm <= instruction(15) & instruction(15) & instruction(15) & instruction(15) &
                       instruction(15) & instruction(15) & instruction(15) & instruction(15) &
                       instruction(15) & instruction(15) & instruction(15) & instruction(15) &
                       instruction(15) & instruction(15) & instruction(15) & instruction(15) &
                       instruction(15 downto 0);
        else
            ext_imm <= "0000000000000000" & instruction(15 downto 0);
        end if;
    end process;

    func <= instruction(5 downto 0);
    shift_amount <= instruction(10 downto 6);
    register_t<=instruction(20 downto 16);
    register_d<=instruction(15 downto 11);

end Behavioral;