----------------------------------------------------------------------------------
-- Noridel Herron
-- Extended Testbench for ALU (with Flag Checking)
-- 4/27/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU_ext is
end tb_ALU_ext;

architecture behavior of tb_ALU_ext is

    component ALU
        Port (A, B       : in std_logic_vector (7 downto 0);    -- 8-bits inputs
              Ci_Bi      : in std_logic;                        -- 1-bit input
              f3         : in std_logic_vector (2 downto 0);    -- 3-bits input
              f7         : in std_logic_vector (4 downto 0);    -- 5-bits input
              result     : out std_logic_vector (7 downto 0);   -- 8-bits output
              Z_flag, V_flag, C_flag, N_flag : out std_logic);  -- 1-bit outputs
    end component;

    constant num_tests : integer := 20;

    -- array declaration
    type eightBits_arr is array(1 to num_tests) of std_logic_vector(7 downto 0);
    type fourBits_arr  is array(1 to num_tests) of std_logic_vector(2 downto 0);
    type fiveBits_arr  is array(1 to num_tests) of std_logic_vector(4 downto 0);
    type bit_arr       is array(1 to num_tests) of std_logic;

    -- Test Vectors
    constant A_arr : eightBits_arr := (
        "00000111", "00101101", "00000011", "00001000", "11111000", "00001100", "00000101", "11111010",
        "10000001", "01111111", "11111111", "00000001", "00001010", "00000000", "00000010", "11111110",
        "00001111", "11110000", "10101010", "01010101"
    );

    constant B_arr : eightBits_arr := (
        "00000101", "01000101", "00000010", "00000011", "00000010", "00000101", "00001010", "00001010",
        "10000001", "01111111", "11111111", "00000001", "00000000", "00000000", "00000100", "00000010",
        "00000101", "00000100", "01010101", "10101010"
    );

    constant f3_arr : fourBits_arr := (
        "000", "000", "001", "101", "101", "100", "010", "011",
        "110", "111", "000", "000", "010", "011", "100", "101",
        "101", "110", "111", "000"
    );

    constant f7_arr : fiveBits_arr := (
        "00000", "10100", "00000", "00000", "10100", "00000", "00000", "00000",
        "00000", "00000", "00000", "10100", "00000", "00000", "00000", "00000",
        "10100", "00000", "00000", "00000"
    );

    constant expected_result_arr : eightBits_arr := (
        "00001100", "11101000", "00001100", "00000001", "11111110", "00001001", "00000001", "00000000",
        "10000001", "01111111", "11111110", "00000000", "00000000", "00000000", "00000110", "00111111",
        "00000000", "11110100", "00000000", "11111111"
    );

    constant expected_Z_arr : bit_arr := (
        '0', '0', '0', '0', '0', '0', '0', '1',
        '0', '0', '0', '1', '1', '1', '0', '0',
        '1', '0', '1', '0'
    );

    constant expected_N_arr : bit_arr := (
        '0', '1', '0', '0', '1', '0', '0', '0',
        '1', '0', '1', '0', '0', '0', '0', '0',
        '0', '1', '0', '1'
    );

    constant expected_C_arr : bit_arr := (
        '0', '0', '0', '0', '0', '0', '0', '0',
        '0', '0', '0', '1', '0', '0', '0', '0',
        '0', '0', '0', '0'
    );

    constant expected_V_arr : bit_arr := (
        '0', '0', '0', '0', '0', '0', '0', '0',
        '0', '0', '0', '0', '0', '0', '0', '0',
        '0', '0', '0', '0'
    );

    -- internal signals
    signal A, B : std_logic_vector(7 downto 0);
    signal Ci_Bi : std_logic := '0';
    signal f3 : std_logic_vector(2 downto 0);
    signal f7 : std_logic_vector(4 downto 0);
    signal result : std_logic_vector(7 downto 0);
    signal Z_flag, V_flag, C_flag, N_flag : std_logic;

begin
    -- instantiate ALU
    DUT: ALU port map (A, B, Ci_Bi, f3, f7, result, Z_flag, V_flag, C_flag, N_flag);

    stim_proc: process
    begin
        for i in 1 to num_tests loop
            A <= A_arr(i);
            B <= B_arr(i);
            f3 <= f3_arr(i);
            f7 <= f7_arr(i);
            Ci_Bi <= '0';

            wait for 20 ns;

            report "Testing iteration " & integer'image(i) severity note;

            assert result = expected_result_arr(i)
                report "Result mismatch at iteration " & integer'image(i) severity error;

            assert Z_flag = expected_Z_arr(i)
                report "Z_flag mismatch at iteration " & integer'image(i) severity error;

            assert N_flag = expected_N_arr(i)
                report "N_flag mismatch at iteration " & integer'image(i) severity error;

            assert C_flag = expected_C_arr(i)
                report "C_flag mismatch at iteration " & integer'image(i) severity error;

            assert V_flag = expected_V_arr(i)
                report "V_flag mismatch at iteration " & integer'image(i) severity error;
        end loop;

        report "All extended ALU tests passed successfully!" severity note;
        wait;
    end process;

end behavior;
