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

    signal branch_address : std_logic_vector(31 downto 0) := X"00000000";
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
            pc_4 : out std_logic_vector (31 downto 0));
    end component;

    signal instruction_ftch_dcd : std_logic_vector(31 downto 0);
    signal pc_incremented_ftch_dcd : std_logic_vector(31 downto 0);

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

    signal extend_op : std_logic;
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
            write_address : in std_logic_vector(4 downto 0);
            write_data : in std_logic_vector(31 downto 0);
            read_data_1 : out std_logic_vector(31 downto 0);
            read_data_2 : out std_logic_vector(31 downto 0);
            ext_imm : out std_logic_vector(31 downto 0);
            func : out std_logic_vector(5 downto 0);
            shift_amount : out std_logic_vector(4 downto 0);
            register_t : out std_logic_vector(4 downto 0);
            register_d : out std_logic_vector(4 downto 0)
        );
    end component;

    signal ALU_operation_dcd_exec : std_logic_vector(2 downto 0);
    signal ALU_src_dcd_exec : std_logic;
    signal branch_dcd_exec : std_logic;
    signal mem_write_dcd_exec : std_logic;
    signal mem_to_reg_dcd_exec : std_logic;
    signal reg_write_dcd_exec : std_logic;
    signal reg_dst_dcd_exec : std_logic;

    signal read_data_1_dcd_exec : std_logic_vector(31 downto 0);
    signal read_data_2_dcd_exec : std_logic_vector(31 downto 0);
    signal ext_imm_dcd_exec : std_logic_vector(31 downto 0);
    signal func_dcd_exec : std_logic_vector(5 downto 0);
    signal shift_amount_dcd_exec : std_logic_vector(4 downto 0);
    signal register_d_dcd_exec : std_logic_vector(4 downto 0);
    signal register_t_dcd_exec : std_logic_vector(4 downto 0);
    signal pc_incremented_dcd_exec : std_logic_vector(31 downto 0);

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
            reg_dst : in std_logic;
            register_d : in std_logic_vector(4 downto 0);
            register_t : in std_logic_vector(4 downto 0);

            zero_flag : out std_logic;
            branch_address : out std_logic_vector(31 downto 0);
            ALU_result : out std_logic_vector(31 downto 0);
            rWA : out std_logic_vector(4 downto 0)
        );
    end component;

    signal branch_exec_mem : std_logic;
    signal mem_write_exec_mem : std_logic;
    signal mem_to_reg_exec_mem : std_logic;
    signal reg_write_exec_mem : std_logic;

    signal zero_flag_exec_mem : std_logic;
    signal branch_address_exec_mem : std_logic_vector(31 downto 0);
    signal ALU_result_exec_mem : std_logic_vector(31 downto 0);
    signal read_data_2_exec_mem : std_logic_vector(31 downto 0);
    signal rWA_exec_mem : std_logic_vector(4 downto 0);

    signal pc_src : std_logic;

    component Memory is
        port (
            clk : in std_logic;
            en : in std_logic;
            mem_write : in std_logic := '0';
            ALU_result_in : in std_logic_vector (31 downto 0);
            read_data_2 : in std_logic_vector (31 downto 0);

            ALU_result_out : out std_logic_vector (31 downto 0);
            memory_data : out std_logic_vector (31 downto 0)
        );
    end component;

    signal mem_to_reg_mem_wrb : std_logic;
    signal reg_write_mem_wrb : std_logic;
    signal ALU_result_out_mem_wrb : std_logic_vector(31 downto 0);
    signal memory_data_mem_wrb : std_logic_vector(31 downto 0);
    signal rWA_mem_wrb : std_logic_vector(4 downto 0);
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

    fetch : InstructionFetch port map(clk, enable0, btn(1), branch_address_exec_mem, pc_src, jump_address, jump, jump_register_address, jump_reg, instruction_ftch_dcd, pc_incremented_ftch_dcd);

    control : ControlUnit port map(instruction_ftch_dcd(31 downto 26), ALU_operation_dcd_exec, reg_dst_dcd_exec, extend_op, ALU_src_dcd_exec, branch_dcd_exec, jump, mem_write_dcd_exec, mem_to_reg_dcd_exec, reg_write_dcd_exec, jump_reg);

    decode : InstructionDecode port map(clk, enable0, reg_dst_dcd_exec, extend_op, reg_write_mem_wrb, instruction_ftch_dcd(25 downto 0), rWA_mem_wrb, write_data, read_data_1_dcd_exec, read_data_2_dcd_exec, ext_imm_dcd_exec, func_dcd_exec, shift_amount_dcd_exec, register_t_dcd_exec, register_d_dcd_exec);

    execute : InstructionExecute port map(ALU_operation_dcd_exec, ALU_src_dcd_exec, read_data_1_dcd_exec, read_data_2_dcd_exec, ext_imm_dcd_exec, func_dcd_exec, shift_amount_dcd_exec, pc_incremented_dcd_exec, reg_dst_dcd_exec, register_d_dcd_exec, register_t_dcd_exec, zero_flag_exec_mem, branch_address_exec_mem, ALU_result_exec_mem, rWA_exec_mem);

    mem : Memory port map(clk, enable0, mem_write_exec_mem, ALU_result_exec_mem, read_data_2_exec_mem, ALU_result_out_mem_wrb, memory_data_mem_wrb);

    sesede : SSD port map(clk, digits, an, cat);

    fetch_decode : process (enable0, clk)--trebe semnale intermediare noi pt astea si portmap nou
    begin
        if enable0 = '1' and rising_edge(clk) then
            jump_register_address <= read_data_1_dcd_exec;
            jump_address <= pc_incremented_ftch_dcd(31 downto 28) & instruction_ftch_dcd(25 downto 0) & "00";
        end if;
    end process;

    decode_execute : process (enable0, clk)
    begin

    end process;

    execute_memory : process (enable0, clk)
    begin
        if enable0 = '1' and rising_edge(clk) then
            branch_exec_mem <= branch_dcd_exec;
            mem_write_exec_mem <= mem_write_dcd_exec;
            mem_to_reg_exec_mem <= mem_to_reg_dcd_exec;
            reg_write_exec_mem <= reg_write_dcd_exec;

            pc_src <= branch_exec_mem and zero_flag_exec_mem;

        end if;
    end process;
    memory_write_back : process (enable0, clk)
    begin
        if enable0 = '1' and rising_edge(clk) then

            rWA_mem_wrb <= rWA_exec_mem;

            if mem_to_reg_mem_wrb = '1' then
                write_data <= memory_data_mem_wrb;
            else
                write_data <= ALU_result_out_mem_wrb;
            end if;
        end if;

    end process;

    led(10 downto 8) <= ALU_operation_dcd_exec;
    led(7) <= reg_dst_dcd_exec;
    led(6) <= extend_op;
    led(5) <= ALU_src_dcd_exec;
    led(4) <= branch_dcd_exec;
    led(3) <= jump;
    led(2) <= mem_write_dcd_exec;
    led(1) <= mem_to_reg_dcd_exec;
    led(0) <= reg_write_dcd_exec;

    process (sw)
    begin
        case sw(7 downto 5) is
            when "000" => digits <= instruction_ftch_dcd;
            when "001" => digits <= pc_incremented_ftch_dcd;
            when "010" => digits <= read_data_1_dcd_exec;
            when "011" => digits <= read_data_2_dcd_exec;
            when "100" => digits <= ext_imm_dcd_exec;
            when "101" => digits <= ALU_result_exec_mem;
            when "110" => digits <= memory_data_mem_wrb;
            when "111" => digits <= write_data;
            when others => digits <= (others => '0');
        end case;
    end process;
end Behavioral;