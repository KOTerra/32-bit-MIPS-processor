library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
entity RegisterFile is
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
end RegisterFile;

architecture Behavioral of RegisterFile is
    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_array := (
        others => X"00000000");
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if en='1' and regwr = '1' then
                reg_file(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;
    rd1 <= reg_file(conv_integer(ra1));
    rd2 <= reg_file(conv_integer(ra2));
end Behavioral;