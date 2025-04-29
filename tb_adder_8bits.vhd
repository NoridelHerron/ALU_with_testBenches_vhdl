----------------------------------------------------------------------------------
-- Noridel Herron
-- test bench of the adder
-- 4/25/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

entity tb_adder_8bits is
--  Port ( );
end tb_adder_8bits;

architecture test_adder of tb_adder_8bits is

    component adder_8bits 
    Port (A,B : in std_logic_vector (7 downto 0);       -- 8-bits inputs
          Ci  : in std_logic;                           -- 1-bit inputs 
          Sum : out std_logic_vector (7 downto 0);      -- 8-bits output result
          Z_flag, V_flag, C_flag, N_flag: out std_logic -- 1-bit output flags
          ); 
    end component; 
     
    constant number_of_test: integer := 11; 
    
    -- declare array
    type bit_arr is array(1 to number_of_test) of std_logic;
    type int_arr is array(1 to number_of_test) of integer;
    
    -- test vector values
    constant Ci_arr       : bit_arr := ('0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0');
    constant A_arr        : int_arr := (7, 45, 0, -57, 71, 64, -121, 50,  -30,  20, -70);
    constant B_arr        : int_arr := (5, 69, 0, -57, 71, 64, -121, -20, 100, -50,  30);
    constant sum_arr      : int_arr := (12, 114, 0, -114, -114, -127, 14,  30,  70,  -30, -40 );
    constant Z_arr        : bit_arr := ('0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0');
    constant V_arr        : bit_arr := ('0', '0', '0', '0', '1', '1', '1', '0', '0', '0', '0');
    constant C_arr        : bit_arr := ('0', '0', '0', '1', '0', '0', '1',  '1', '1', '0', '0');
    constant N_arr        : bit_arr := ('0', '0', '0', '1', '1', '1', '0',  '0', '0', '1', '1');
    
    -- internal signals
    signal input_A, input_B, output_result : std_logic_vector(7 downto 0);
    signal Z, V, C, N, Cin : std_logic; 

begin

    -- DUT instantiation
    ADDER: adder_8bits port map (input_A, input_B, Cin, output_result, Z, V, C, N);

    -- Test process
    process
    begin
        for i in 1 to number_of_test loop
            -- Apply test vectors
            input_A <= std_logic_vector(to_signed(A_arr(i), 8));
            input_B <= std_logic_vector(to_signed(B_arr(i), 8));
            Cin     <= Ci_arr(i);
            
            wait for 1 ns;  -- Allow inputs to settle
            wait for 40 ns; -- Allow outputs to propagate
            
            report "Testing iteration " & integer'image(i);

            -- Check Sum
            assert output_result = std_logic_vector(to_signed(sum_arr(i), 8))
            report "Sum mismatch at iteration " & integer'image(i) &
                   ". Expected = " & integer'image(to_integer(signed(to_signed(sum_arr(i), 8)))) &
                   ", Got = " & integer'image(to_integer(signed(output_result)))
            severity error;

            
            -- Check Z flag
            assert Z = Z_arr(i)
                report "Z_flag mismatch at iteration " & integer'image(i)
                severity error;
            
            -- Check V flag only if signed
            
            assert V = V_arr(i)
                report "V_flag mismatch at iteration " & integer'image(i)
                severity error;
          
            
            -- Check C flag only if unsigned          
            assert C = C_arr(i)
                report "C_flag mismatch at iteration " & integer'image(i)
                severity error;            
            
            -- Check N flag           
            assert N = N_arr(i)
                report "N_flag mismatch at iteration " & integer'image(i)
                severity error;
        end loop;
        
        report "All test cases passed successfully!" severity note;
        wait; -- Stop simulation
    end process;

end test_adder;
