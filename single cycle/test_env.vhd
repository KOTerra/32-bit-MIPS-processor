library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity test_env is
    port (
        btn : in std_logic_vector(4 downto 0);
        clk : in std_logic;
        sw : in std_logic_vector(15 downto 0);
        led : out std_logic_vector(15 downto 0);
        an : out std_logic_vector(7 downto 0);
        cat : out std_logic_vector(6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

    component MPG
        port (
            enable : out std_logic;
            btn : in std_logic;
            clk : in std_logic
        );
    end component;

    signal enable0 : std_logic := '0';

    signal branch_address : std_logic_vector(31 downto 0) := X"00000010";
    signal jump_address : std_logic_vector(31 downto 0) := X"00000000";
    signal jump_register_address : std_logic_vector(31 downto 0) := X"00000000";

    component InstructionFetch is
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
            pc_4 : inout std_logic_vector (31 downto 0));
    end component;

    signal instruction : std_logic_vector(31 downto 0);
    signal pc_incremented : std_logic_vector(31 downto 0);

    component ControlUnit is
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
    end component;

    signal ALU_operation : std_logic_vector(2 downto 0);
    signal ALU_src : std_logic;
    signal branch : std_logic;
    signal mem_write : std_logic;
    signal mem_to_reg : std_logic;

    signal reg_dst : std_logic;
    signal extend_op : std_logic;
    signal reg_write : std_logic;
    signal jump : std_logic;
    signal jump_reg : std_logic;

    component InstructionDecode
        port (
            clk : in std_logic;
            en : in std_logic;
            reg_dst : in std_logic;
            extend_op : in std_logic;
            reg_write : in std_logic;

            instruction : in std_logic_vector(25 downto 0);
            write_data : in std_logic_vector(31 downto 0);
            read_data_1 : out std_logic_vector(31 downto 0);
            read_data_2 : out std_logic_vector(31 downto 0);
            ext_imm : out std_logic_vector(31 downto 0);
            func : out std_logic_vector(5 downto 0);
            shift_amount : out std_logic_vector(4 downto 0)
        );
    end component;

    signal read_data_1 : std_logic_vector(31 downto 0);
    signal read_data_2 : std_logic_vector(31 downto 0);
    signal ext_imm : std_logic_vector(31 downto 0);
    signal func : std_logic_vector(5 downto 0);
    signal shift_amount : std_logic_vector(4 downto 0);
    signal branch_and_zero : std_logic := '0';
    component InstructionExecute is
        port (
            ALU_operation : in std_logic_vector(2 downto 0);
            ALU_src : in std_logic;
            read_data_1 : in std_logic_vector(31 downto 0);
            read_data_2 : in std_logic_vector(31 downto 0);
            ext_imm : in std_logic_vector(31 downto 0);
            func : in std_logic_vector(5 downto 0);
            shift_amount : in std_logic_vector(4 downto 0);
            pc_4 : in std_logic_vector(31 downto 0);

            zero_flag : out std_logic;
            branch_address : out std_logic_vector(31 downto 0);
            ALU_result : out std_logic_vector(31 downto 0)
        );
    end component;

    signal zero_flag : std_logic;
    signal ALU_result : std_logic_vector(31 downto 0);

    component Memory is
        port (
            clk : in std_logic;
            en : in std_logic;
            ALU_result_in : in std_logic_vector (31 downto 0);
            read_data_2 : in std_logic_vector (31 downto 0);

            ALU_result_out : out std_logic_vector (31 downto 0);
            memory_data : out std_logic_vector (31 downto 0)
        );
    end component;

    signal ALU_result_out : std_logic_vector(31 downto 0);
    signal memory_data : std_logic_vector(31 downto 0);

    signal write_data : std_logic_vector(31 downto 0);

    signal digits : std_logic_vector(31 downto 0) := (others => '0');

    component SSD
        port (
            clk : in std_logic;
            digits : in std_logic_vector(31 downto 0);
            an : out std_logic_vector(7 downto 0);
            cat : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    mpg1 : MPG port map(enable0, btn(0), clk);
    fetch : InstructionFetch port map(clk, enable0, btn(1), branch_address, branch_and_zero, jump_address, jump, jump_register_address, jump_reg, instruction, pc_incremented);
    control : ControlUnit port map(instruction(31 downto 26), ALU_operation, reg_dst, extend_op, ALU_src, branch, jump, mem_write, mem_to_reg, reg_write, jump_reg);
    decode : InstructionDecode port map(clk, enable0, reg_dst, extend_op, reg_write, instruction(25 downto 0), write_data, read_data_1, read_data_2, ext_imm, func, shift_amount);
    execute : InstructionExecute port map(ALU_operation, ALU_src, read_data_1, read_data_2, ext_imm, func, shift_amount, pc_incremented, zero_flag, branch_address, ALU_result);
    mem : Memory port map(clk, enable0, ALU_result, read_data_2, ALU_result_out, memory_data);
    sesede : SSD port map(clk, digits, an, cat);
    write_back : process (mem_to_reg)
    begin
        if mem_to_reg = '1' then
            write_data <= memory_data;
        else
            write_data <= ALU_result_out;
        end if;
    end process;

    led(10 downto 8) <= ALU_operation;
    led(7) <= reg_dst;
    led(6) <= extend_op;
    led(5) <= ALU_src;
    led(4) <= branch;
    led(3) <= jump;
    led(2) <= mem_write;
    led(1) <= mem_to_reg;
    led(0) <= reg_write;

    process (sw)
    begin
        case sw(7 downto 5) is
            when "000" => digits <= instruction;
            when "001" => digits <= pc_incremented;
            when "010" => digits <= read_data_1;
            when "011" => digits <= read_data_2;
            when "100" => digits <= ext_imm;
            when "101" => digits <= ALU_result;
            when "110" => digits <= memory_data;
            when "111" => digits <= write_data;
            when others => digits <= (others => '0');
        end case;
    end process;

    jump_register_address <= read_data_1;
    jump_address <= pc_incremented(31 downto 28) & instruction(25 downto 0) & "00";

    branch_and_zero <= branch and zero_flag;
end Behavioral;