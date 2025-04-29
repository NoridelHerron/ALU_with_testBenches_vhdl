----------------------------------------------------------------------------------
-- Noridel Herron
-- Randomized Golden Testbench for ALU
-- With Pass/Fail Counters Per Operation
-- 4/30/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL; -- for uniform()

entity tb_ALU_rand is
end tb_ALU_rand;

architecture behavior of tb_ALU_rand is

    component ALU
        Port (A, B       : in std_logic_vector(7 downto 0);     -- 8-bits inputs
              Ci_Bi      : in std_logic;                        -- 1-bit input
              f3         : in std_logic_vector(2 downto 0);     -- 3-bits input
              f7         : in std_logic_vector(4 downto 0);     -- 5-bits input
              result     : out std_logic_vector(7 downto 0);    -- 8-bits output 
              Z_flag, V_flag, C_flag, N_flag : out std_logic);  -- 1-bit outputs 
    end component;

    -- internal signal
    signal A, B : std_logic_vector(7 downto 0);
    signal Ci_Bi : std_logic := '0';
    signal f3 : std_logic_vector(2 downto 0);
    signal f7 : std_logic_vector(4 downto 0);
    signal result : std_logic_vector(7 downto 0);
    signal Z_flag, V_flag, C_flag, N_flag : std_logic;

begin
    -- instantiate ALU
    DUT: ALU port map (A, B, Ci_Bi, f3, f7, result, Z_flag, V_flag, C_flag, N_flag);

    process
        -- variables
        variable rand_real : real;
        variable rand_A, rand_B : integer;
        variable rand_f3 : integer;
        variable rand_func7_choice : integer;
        variable expected_result : std_logic_vector(7 downto 0);
        variable expected_Z, expected_N, expected_C, expected_V : std_logic;
        variable seed1 : positive := 42;  -- this can be any value as long as it is positive
        variable seed2 : positive := 24;  -- this can be any value as long as it is positive
        
        -- Pass/fail counters
        variable total_tests : integer := 5000; -- number of test
        variable pass_count  : integer := 0;     -- keep track of the passed tests
        variable fail_count  : integer := 0;     -- keep track of the failed tests

        -- Separate fail counters per operation, it helped to spot on which operation have bugs
        variable fail_add, fail_sub, fail_sll, fail_slt, fail_sltu, fail_xor, fail_srl, fail_sra, fail_or, fail_and : integer := 0;
    begin
        report "----- Simulation started -----";
        wait for 100 ns;
        
        for i in 1 to total_tests loop
            -- Randomize inputs
            uniform(seed1, seed2, rand_real);
            rand_A := integer(rand_real * 256.0) - 128;

            uniform(seed1, seed2, rand_real);
            rand_B := integer(rand_real * 256.0) - 128;

            uniform(seed1, seed2, rand_real);
            rand_f3 := integer(rand_real * 8.0); -- 0 to 7             
            if rand_f3 > 7 then
                rand_f3 := 0;
            end if;
                   
            -- Randomize func7 when needed
            if rand_f3 = 0 or rand_f3 = 5 then
                -- randomly generate value to help decide if f7 is 0 or 20
                UNIFORM(seed1, seed2, rand_real);
                if rand_real > 0.5 then
                    f7 <= "00000";
                else
                    f7 <= "10100";
                end if;
            else
                f7 <= "00000";          
            end if;
      
            -- Set inputs
            A <= std_logic_vector(to_signed(rand_A, 8));
            B <= std_logic_vector(to_signed(rand_B, 8));
            Ci_Bi <= '0';
            f3 <= std_logic_vector(to_unsigned(rand_f3, 3));
            
            -- Wait for ALU to respond to inputs
            wait for 10 ns;
            
            -- Compute expected result manually
            case rand_f3 is
                when 0 =>          
                    --wait for 10 ns;
                    if f7 = "00000" then -- ADD
                        expected_result := std_logic_vector(signed(to_signed(rand_A, 8)) + signed(to_signed(rand_B, 8)));
                    else                 -- SUB
                        expected_result := std_logic_vector(signed(to_signed(rand_A, 8)) - signed(to_signed(rand_B, 8)));
                    end if;
                when 1 => -- SLL            
                    expected_result := std_logic_vector(shift_left(unsigned(to_unsigned(rand_A,8)), to_integer(unsigned(to_unsigned(rand_B,8)(2 downto 0)))));
                when 2 => -- SLT
                    if (signed(to_signed(rand_A,8)) < signed(to_signed(rand_B,8))) then
                        expected_result := "00000001";
                    else
                        expected_result := "00000000";
                    end if;
                when 3 => -- SLTU
                   if (unsigned(to_unsigned(rand_A,8)) < unsigned(to_unsigned(rand_B,8))) then
                        expected_result := "00000001";
                    else
                        expected_result := "00000000";
                    end if;
                when 4 => -- XOR
                    expected_result :=  std_logic_vector(unsigned(to_unsigned(rand_A,8)) xor unsigned(to_unsigned(rand_B,8)));
                when 5 =>
                    if f7 = "00000" then -- SRL
                        expected_result := std_logic_vector(shift_right(unsigned(to_unsigned(rand_A,8)), to_integer(unsigned(to_unsigned(rand_B,8)(2 downto 0)))));
                    else -- SRA
                        expected_result := std_logic_vector(shift_right(signed(to_unsigned(rand_A,8)), to_integer(unsigned(to_unsigned(rand_B,8)(2 downto 0)))));
                    end if;
                when 6 => -- OR
                    expected_result := std_logic_vector(unsigned(to_unsigned(rand_A,8)) or unsigned(to_unsigned(rand_B,8)));
                when 7 => -- AND
                    expected_result := std_logic_vector(unsigned(to_unsigned(rand_A,8)) and unsigned(to_unsigned(rand_B,8)));    
                when others => null;      
            end case;

            -- Check result
            if result = expected_result then
                pass_count := pass_count + 1;
            else
                fail_count := fail_count + 1;
                
                report "TEST FAIL!" severity warning;
                report "    Operation      : " & integer'image(rand_f3);
                report "    Input A        : " & integer'image(to_integer(unsigned(A)));
                report "    Input B        : " & integer'image(to_integer(unsigned(B)));
                report "    Expected Output: " & integer'image(to_integer(unsigned(expected_result)));
                report "    Actual Output  : " & integer'image(to_integer(unsigned(result)));

          
                -- Update specific fail counter
                case rand_f3 is
                    when 0 =>
                        if f7 = "00000" then
                            fail_add := fail_add + 1;
                        else
                            fail_sub := fail_sub + 1;
                        end if;
                    when 1 => fail_sll := fail_sll + 1;
                    when 2 => fail_slt := fail_slt + 1;
                    when 3 => fail_sltu := fail_sltu + 1;
                    when 4 => fail_xor := fail_xor + 1;
                    when 5 =>
                        if f7 = "00000" then
                            fail_srl := fail_srl + 1;
                        else
                            fail_sra := fail_sra + 1;
                        end if;
                    when 6 => fail_or := fail_or + 1;
                    when 7 => fail_and := fail_and + 1; 
                    when others => null;                    
                end case;
            end if;            
        end loop;

        -- Final report
        report "----------------------------------------------------";
        report "ALU Randomized Test Summary:";
        report "Total Tests      : " & integer'image(total_tests);
        report "Total Passes     : " & integer'image(pass_count);
        report "Total Failures   : " & integer'image(fail_count);
        report "Fails per Operation:";
        report "ADD  fails: " & integer'image(fail_add);
        report "SUB  fails: " & integer'image(fail_sub);
        report "SLL  fails: " & integer'image(fail_sll);
        report "SLT  fails: " & integer'image(fail_slt);
        report "SLTU fails: " & integer'image(fail_sltu);
        report "XOR  fails: " & integer'image(fail_xor);
        report "SRL  fails: " & integer'image(fail_srl);
        report "SRA  fails: " & integer'image(fail_sra);
        report "OR   fails: " & integer'image(fail_or);
        report "AND  fails: " & integer'image(fail_and);
        report "----------------------------------------------------";
    
        wait;
    end process;

end behavior;
