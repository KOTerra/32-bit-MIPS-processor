library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity InstructionFetch is
    port (
        clk : in std_logic;
        en : in std_logic;
        rst : in std_logic;
        branch_addr : in std_logic_vector (31 downto 0);
        pc_src : in std_logic;
        jump_addr : in std_logic_vector (31 downto 0);
        jump : in std_logic;
        jump_reg_addr : in std_logic_vector (31 downto 0);
        jump_reg : in std_logic;
        instruction : out std_logic_vector (31 downto 0);
        pc_4 : out std_logic_vector (31 downto 0));
end InstructionFetch;

architecture Behavioral of InstructionFetch is
    type ROM_memory is array (0 to 31) of std_logic_vector(31 downto 0);
    signal rom : ROM_memory := (
        B"000000_00000_00000_00001_00000_100000", --X 0000_0820         -- add  $1, $0, $0  
        B"000001_00000_00100_0000000000001010", --X 0404_000A           -- addi $4, $0, 10   
        B"000000_00000_00000_00010_00000_100000", --X 0000_1020         -- add  $2, $0, $0 
        B"000000_00000_00000_00101_00000_100000", --X 0000_2820         -- add  $5, $0, $0  
        B"000100_00001_00100_0000000000001001", --X 1024_0009           -- beq  $1, $4, 9  
        B"000010_00010_00011_0000000000101000", --X 0843_0028           --    lw      $3, 40($2) 
        B"000010_00010_00110_0000000000101000", --X 0846_0028           --    lw      $6, 40($2) 
        B"000001_00000_00111_0000000000000001", --X 0407_0001           --    addi    $7, $0, 1 
        B"000000_00110_00111_00110_00000_100100", --X 00C7_3024         --    and     $6, $6, $7 
        B"000100_00111_00110_0000000000000001", --X 10E6_0001           --    beq     $7, $6, 1  
        B"000000_00101_00011_00101_00000_100000", --X 00A3_2820         --            add     $5, $5, $3  
        B"000001_00001_00001_0000000000000001", --X 0421_0001           --    addi    $1, $1, 1  
        B"000001_00010_00010_0000000000000100", --X 0442_0004           --    addi    $2, $2, 4   
        B"000111_00000000000000000000000100", --X 1800_0004             --     j   4     
        B"000000_00000_00101_00101_00010_100010", --X 0005_28A2         -- sll  $5, $5, 2 
              
        B"000011_00000_00101_0000000001010000", --X 0C05_0050           -- sw   $5, 80($0)   
        B"000010_00000_01111_0000000001010000",
        B"000000_01111_00000_01111_00000_100000",

        others => X"00000000"
    );

    signal pc : std_logic_vector(31 downto 0);
    signal address : std_logic_vector(31 downto 0);

begin

    process (jump_reg, jump_reg_addr, jump, pc_src, address)
    begin
        if jump_reg = '1' then
            pc <= jump_reg_addr;
        else
            if jump = '1' then
                pc <= jump_addr;
            else
                if pc_src = '1' then
                    pc <= branch_addr;
                else
                    pc <= address + 4;
                end if;
            end if;
        end if;
    end process;

    process (clk, rst)
    begin
        if rst = '1' then
            address <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                address <= pc;
            end if;
        end if;
    end process;

    pc_4 <= address + 4;

    instruction <= rom(conv_integer(address(6 downto 2)));

end Behavioral;