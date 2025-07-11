library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Memory is
    port (
        clk : in std_logic;
        en : in std_logic;
        mem_write : in std_logic:='0';
        ALU_result_in : in std_logic_vector (31 downto 0);
        read_data_2 : in std_logic_vector (31 downto 0);

        ALU_result_out : out std_logic_vector (31 downto 0);
        memory_data : out std_logic_vector (31 downto 0)
    );
end Memory;

architecture Behavioral of Memory is

    type DataArray is array(0 to 63) of std_logic_vector(31 downto 0);
    signal data : DataArray := (
        0 => (others => '0'), 1 => (others => '0'), 2 => (others => '0'), 3 => (others => '0'), 4 => (others => '0'), 5 => (others => '0'), 6 => (others => '0'), 7 => (others => '0'), 8 => (others => '0'), 9 => (others => '0'),

        10 => X"00000001", --1
        11 => X"00000004", --4
        12 => X"00000005", --5
        13 => X"00000007", --7
        14 => X"00000008", --8
        15 => X"00000006", --6
        16 => X"00000002", --2
        17 => X"00000027", --39
        18 => X"00000034", --52
        19 => X"0000000B", --11
        others => (others => '0'));
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if en = '1' and mem_write = '1' then
                data(conv_integer(ALU_result_in(7 downto 2))) <= read_data_2;
            end if;
        end if;
    end process;
    memory_data <= data(conv_integer(ALU_result_in(7 downto 2)));
    ALU_result_out <= ALU_result_in;
end Behavioral;