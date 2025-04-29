----------------------------------------------------------------------------------
-- Noridel Herron
-- test bench of the adder
-- 4/25/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

entity tb_sub_8bits is
--  Port ( );
end tb_sub_8bits;

architecture test of tb_sub_8bits is
    component sub_8bits 
    Port (A,B            : in std_logic_vector (7 downto 0);       -- 8-bits inputs
          Bi             : in std_logic;                           -- 1-bit inputs
          difference     : out std_logic_vector (7 downto 0);      -- 8-bits output result
          Z_flag, V_flag, C_flag, N_flag: out std_logic            -- 1-bit output flags
          ); 
    end component; 
     
    constant number_of_test: integer := 7;

    -- declare array
    type bit_arr is array(1 to number_of_test) of std_logic;
    type int_arr is array(1 to number_of_test) of integer;
 
    -- test vector values
    constant Bi_arr       : bit_arr := ('0', '0', '0', '0', '0', '1', '0');
    constant A_arr : int_arr := (7, 45, 127, -33, 87, 64, -121);
    constant B_arr : int_arr := (5, 69, 127, 7, 79, 64, -121);
    constant diff_arr : int_arr := (2, -24, 0, -40, 8, -1, 0);
    constant Z_arr : bit_arr := ('0', '0', '1', '0', '0', '0', '1');
    constant V_arr : bit_arr := ('0', '0', '0', '0', '0', '0', '0');
    constant C_arr : bit_arr := ('1', '0', '1', '1', '1', '0', '1'); -- borrow flag
    constant N_arr : bit_arr := ('0', '1', '0', '1', '0', '1', '0');

    -- internal signal
    signal input_A, input_B, output_result : std_logic_vector(7 downto 0);
    signal Z, V, C, N, Bin : std_logic; 

begin

    -- DUT instantiation
    ADDER: sub_8bits port map (input_A, input_B, Bin, output_result, Z, V, C, N);

    -- Test process
    process
    begin
        for i in 1 to number_of_test loop
            -- Apply test vectors
            input_A  <= std_logic_vector(to_signed(A_arr(i), 8));
            input_B  <= std_logic_vector(to_signed(B_arr(i), 8));
            Bin      <= Bi_arr(i);          

            wait for 1 ns;
            wait for 40 ns;

            report "Testing iteration " & integer'image(i);

            -- Check difference
            assert output_result = std_logic_vector(to_signed(diff_arr(i), 8))
                report "Difference mismatch at iteration " & integer'image(i) &
                       ". Expected = " & integer'image(to_integer(signed(to_signed(diff_arr(i), 8)))) &
                       ", Got = " & integer'image(to_integer(signed(output_result)))
                severity error;

            -- Check Zero flag
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


            -- Check N flag only if signed
                assert N = N_arr(i)
                    report "N_flag mismatch at iteration " & integer'image(i)
                    severity error;
        end loop;

        report "All test cases passed successfully!" severity note;
        wait; -- End simulation
    end process;

end test;
