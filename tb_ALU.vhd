----------------------------------------------------------------------------------
-- Noridel Herron
-- ALU 8-bit with Flags
-- 4/26/2025
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU is
end tb_ALU;

architecture behavior of tb_ALU is

    -- ALU component
    component ALU
        Port (A, B       : in std_logic_vector (7 downto 0);    -- 8-bits inputs
              Ci_Bi      : in std_logic;                        -- 1-bit input
              f3         : in std_logic_vector (2 downto 0);    -- 3-bits input
              f7         : in std_logic_vector (4 downto 0);    -- 5-bits input
              result     : out std_logic_vector (7 downto 0);   -- 8-bits output
              Z_flag, V_flag, C_flag, N_flag : out std_logic);  -- 1-bit outputs
    end component;

    -- Constants
    constant number_of_tests : integer := 10;
    -- Array declarations
    type eightBits_arr is array(1 to number_of_tests) of std_logic_vector(7 downto 0);
    type threeBits_arr is array(1 to number_of_tests) of std_logic_vector(2 downto 0);
    type fiveBits_arr is array(1 to number_of_tests) of std_logic_vector(4 downto 0);
    type bit_arr is array(1 to number_of_tests) of std_logic;
    
    -- Expected z-flags
    constant expected_Z_arr : bit_arr := ('0', '0', '0', '0', '0', '0', '0', '1', '0', '0');
    constant expected_N_arr : bit_arr := ('0', '1', '0', '0', '1', '0', '0', '0', '0', '0');
    constant expected_C_arr : bit_arr := ('0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
    constant expected_V_arr : bit_arr := ('0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
    
    -- input A
    constant A_arr : eightBits_arr := (
        "00000111", -- 7
        "00101101", -- 45
        "00000011", -- 3
        "00001000", -- 8
        "11111000", -- -8 (signed)
        "00001100", -- 12
        "00000101", -- 5
        "11111010", -- 250
        "00001100", -- 12
        "00001100"  -- 12
    );
    
    -- input B
    constant B_arr : eightBits_arr := (
        "00000101", -- 5
        "01000101", -- 69
        "00000010", -- 2
        "00000011", -- 3
        "00000010", -- 2
        "00000101", -- 5
        "00001010", -- 10
        "00001010", -- 10
        "00000101", -- 5
        "00000101"  -- 5
    );

    -- Expected output
    constant expected_result_arr : eightBits_arr := (
        "00001100", -- 12 (7+5)
        "11101000", -- 45-69
        "00001100", -- 3<<2 = 12
        "00000001", -- 8>>3 = 1
        "11111110", -- -8 >>> 2 = -2
        "00001001", -- 12 XOR 5 = 9
        "00000001", -- 5 < 10 signed = 1
        "00000000", -- 250 < 10 unsigned = 0
        "00001101", -- 12 OR 5 = 13
        "00000100"  -- 12 AND 5 = 4
    );

    -- input operation function 3
    constant f3_arr : threeBits_arr := (
        "000", -- ADD
        "000", -- SUB
        "001", -- SLL
        "101", -- SRL
        "101", -- SRA
        "100", -- XOR
        "010", -- SLT
        "011", -- SLTU
        "110", -- OR
        "111"  -- AND
    );

    -- input operation function 7
    constant f7_arr : fiveBits_arr := (
        "00000", -- ADD
        "10100", -- SUB
        "00000", -- SLL
        "00000", -- SRL
        "10100", -- SRA
        "00000", -- XOR
        "00000", -- SLT
        "00000", -- SLTU
        "00000", -- OR
        "00000"  -- AND
    );

    -- Signals
    signal A, B : std_logic_vector(7 downto 0);
    signal Ci_Bi : std_logic := '0';
    signal f3 : std_logic_vector(2 downto 0);
    signal f7 : std_logic_vector(4 downto 0);
    signal result : std_logic_vector(7 downto 0);
    signal Z_flag, V_flag, C_flag, N_flag : std_logic;

begin
    -- Instantiate ALU
    Generate_ALU: ALU port map (A, B, Ci_Bi, f3, f7, result, Z_flag, V_flag, C_flag, N_flag);

    -- Test Process
    process
    begin
        for i in 1 to number_of_tests loop
            -- Apply inputs
            A <= A_arr(i);
            B <= B_arr(i);
            f3 <= f3_arr(i);
            f7 <= f7_arr(i);
            Ci_Bi <= '0'; -- Always 0 for this simple ALU tests
          
            wait for 20 ns; 
            
            -- Check result if same        
            assert result = expected_result_arr(i)
                report "Result mismatch at iteration " & integer'image(i)
                severity error;
            
            -- Check Z_flag if same   
            assert Z_flag = expected_Z_arr(i)
                report "Z_flag mismatch at iteration " & integer'image(i)
                severity error;
            
            -- Check N_flag if same
            assert N_flag = expected_N_arr(i)
                report "N_flag mismatch at iteration " & integer'image(i)
                severity error;
            
            -- Check C_flag if same
            assert C_flag = expected_C_arr(i)
                report "C_flag mismatch at iteration " & integer'image(i)
                severity error;
            
            -- Check V_flag if same
            assert V_flag = expected_V_arr(i)
                report "V_flag mismatch at iteration " & integer'image(i)
                severity error;
            
        end loop;

        -- All tests finished
        report "All ALU tests passed!" severity note;
        wait;
    end process;

end behavior;