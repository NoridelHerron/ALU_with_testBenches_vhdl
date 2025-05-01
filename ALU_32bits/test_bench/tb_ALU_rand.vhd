----------------------------------------------------------------------------------
-- Noridel Herron
-- Randomized Golden Testbench for 32-bit ALU
-- With Pass/Fail Counters Per Operation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_ALU_rand is
end tb_ALU_rand;

architecture behavior of tb_ALU_rand is

    component ALU
        Port (
            A, B       : in std_logic_vector(31 downto 0);
            Ci_Bi      : in std_logic;
            f3         : in std_logic_vector(2 downto 0);
            f7         : in std_logic_vector(6 downto 0);
            result     : out std_logic_vector(31 downto 0);
            Z_flag, V_flag, C_flag, N_flag : out std_logic
        );
    end component;

    signal A, B : std_logic_vector(31 downto 0);
    signal Ci_Bi : std_logic := '0';
    signal f3 : std_logic_vector(2 downto 0);
    signal f7 : std_logic_vector(6 downto 0);
    signal result : std_logic_vector(31 downto 0);
    signal Z_flag, V_flag, C_flag, N_flag : std_logic;

begin

    DUT: ALU port map (A, B, Ci_Bi, f3, f7, result, Z_flag, V_flag, C_flag, N_flag);

    process
        variable rand_real : real;
        variable rand_A, rand_B : integer;
        variable rand_f3 : integer;
        variable expected_result : std_logic_vector(31 downto 0);
        variable seed1 : positive := 42;
        variable seed2 : positive := 24;

        variable total_tests : integer := 100;
        variable pass_count, fail_count : integer := 0;
        variable fail_add, fail_sub, fail_sll, fail_slt, fail_sltu, fail_xor, fail_srl, fail_sra, fail_or, fail_and : integer := 0;
    begin
        report "----- Simulation started -----";
        wait for 100 ns;

        for i in 1 to total_tests loop
            -- Randomize inputs
            -- rand_A
            uniform(seed1, seed2, rand_real);
            rand_A := integer(rand_real * 2_000_000_000.0) - 1_000_000_000;
            
            -- rand_B
            uniform(seed1, seed2, rand_real);
            rand_B := integer(rand_real * 2_000_000_000.0) - 1_000_000_000;
            
            uniform(seed1, seed2, rand_real);
            rand_f3 := integer(rand_real * 8.0);
            if rand_f3 > 7 then rand_f3 := 0; end if;

            -- Randomize f7
            if rand_f3 = 0 or rand_f3 = 5 then
                uniform(seed1, seed2, rand_real);
                if rand_real > 0.5 then
                    f7 <= "0000000"; -- ADD / SRL
                else
                    f7 <= "0100000"; -- SUB / SRA (RISC-V style)
                end if;
            else
                f7 <= "0000000";
            end if;

            A <= std_logic_vector(to_signed(rand_A, 32));
            B <= std_logic_vector(to_signed(rand_B, 32));
            Ci_Bi <= '0';
            f3 <= std_logic_vector(to_unsigned(rand_f3, 3));

            wait for 10 ns;

            -- Compute expected result
            case rand_f3 is
                when 0 =>  -- ADD/SUB
                    if f7 = "0000000" then
                        expected_result := std_logic_vector(signed(to_signed(rand_A,32)) + signed(to_signed(rand_B,32)));
                    else
                        expected_result := std_logic_vector(signed(to_signed(rand_A,32)) - signed(to_signed(rand_B,32)));
                    end if;
                when 1 =>  -- SLL
                    expected_result := std_logic_vector(shift_left(unsigned(to_unsigned(rand_A,32)), to_integer(unsigned(to_unsigned(rand_B,32)(4 downto 0)))));
                when 2 =>  -- SLT
                    if signed(to_signed(rand_A,32)) < signed(to_signed(rand_B,32)) then
                        expected_result := (31 downto 1 => '0') & '1';
                    else
                        expected_result := (others => '0');
                    end if;
                when 3 =>  -- SLTU
                    if unsigned(to_unsigned(rand_A,32)) < unsigned(to_unsigned(rand_B,32)) then
                        expected_result := (31 downto 1 => '0') & '1';
                    else
                        expected_result := (others => '0');
                    end if;
                when 4 =>  -- XOR
                    expected_result := std_logic_vector(unsigned(to_unsigned(rand_A,32)) xor unsigned(to_unsigned(rand_B,32)));
                when 5 =>  -- SRL/SRA
                    if f7 = "0000000" then
                        expected_result := std_logic_vector(shift_right(unsigned(to_unsigned(rand_A,32)), to_integer(unsigned(to_unsigned(rand_B,32)(4 downto 0)))));
                    else
                        expected_result := std_logic_vector(shift_right(signed(to_signed(rand_A,32)), to_integer(unsigned(to_unsigned(rand_B,32)(4 downto 0)))));
                    end if;
                when 6 =>  -- OR
                    expected_result := std_logic_vector(unsigned(to_unsigned(rand_A,32)) or unsigned(to_unsigned(rand_B,32)));
                when 7 =>  -- AND
                    expected_result := std_logic_vector(unsigned(to_unsigned(rand_A,32)) and unsigned(to_unsigned(rand_B,32)));
                when others => null;
            end case;

            -- Compare
            if result = expected_result then
                pass_count := pass_count + 1;
            else
                fail_count := fail_count + 1;
                
                report "TEST FAIL!" severity warning;
                report "    Operation      : " & integer'image(rand_f3);
                report "    Input A        : " & integer'image(rand_A);
                report "    Input B        : " & integer'image(rand_B);
                report "    Expected Output: " & integer'image(to_integer(unsigned(expected_result)));
                report "    Actual Output  : " & integer'image(to_integer(unsigned(result)));

                case rand_f3 is
                    when 0 => 
                        if f7 = "0000000" then 
                            fail_add := fail_add + 1; 
                        else 
                            fail_sub := fail_sub + 1; 
                        end if;
                    when 1 => fail_sll := fail_sll + 1;
                    when 2 => fail_slt := fail_slt + 1;
                    when 3 => fail_sltu := fail_sltu + 1;
                    when 4 => fail_xor := fail_xor + 1;
                    when 5 => 
                        if f7 = "0000000" then 
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
