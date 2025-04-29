----------------------------------------------------------------------------------
-- Noridel Herron
-- Randomized Testbench for ALU (Strict Vivado 2019 style)
-- 5/1/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM()

entity tb_ALU_random is
end tb_ALU_random;

architecture behavior of tb_ALU_random is

    -- ALU component
    component ALU
        Port (A, B       : in std_logic_vector (7 downto 0);    -- 8-bits inputs
              Ci_Bi      : in std_logic;                        -- 1-bit input
              f3         : in std_logic_vector (2 downto 0);    -- 8-bits input
              f7         : in std_logic_vector (4 downto 0);    -- 5-bits input
              result     : out std_logic_vector (7 downto 0);   -- 8-bits output
              Z_flag, V_flag, C_flag, N_flag : out std_logic);  -- 1-bit outputs
    end component;

    -- Internal Signals
    signal A, B : std_logic_vector(7 downto 0);
    signal Ci_Bi : std_logic := '0';
    signal f3 : std_logic_vector(2 downto 0);
    signal f7 : std_logic_vector(4 downto 0);
    signal result : std_logic_vector(7 downto 0);
    signal Z_flag, V_flag, C_flag, N_flag : std_logic;

begin

    -- Instantiate ALU
    uut: ALU port map (A, B, Ci_Bi, f3, f7, result, Z_flag, V_flag, C_flag, N_flag);

    -- Test process
    process
        variable rand_real : real;
        variable rand_scaled : real;
        variable temp_int : integer;
        variable rand_A, rand_B : integer;
        variable rand_f3 : integer;
        variable seed1, seed2 : positive := 42;
        
    begin
        for i in 1 to 100 loop  -- 100 random tests
            -- Generate random A
            UNIFORM(seed1, seed2, rand_real); -- value in rand_real is between 0.0 to 1.0
            rand_scaled := rand_real * 256.0; -- rand_scaled is between 0.0 to 256.0
            temp_int := integer(rand_scaled); --  truncates, yielding values from 0 to 255.
            rand_A := temp_int - 128;         -- this will make the rand_A value between -128 to 127 
            
            -- Generate random B
            UNIFORM(seed1, seed2, rand_real);
            rand_scaled := rand_real * 256.0;
            temp_int := integer(rand_scaled);
            rand_B := temp_int - 128;

            -- Randomly pick operation (0 to 7)
            UNIFORM(seed1, seed2, rand_real);
            rand_scaled := rand_real * 8.0;
            rand_f3 := integer(rand_scaled);
                      
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

            -- Apply to ALU
            A <= std_logic_vector(to_signed(rand_A, 8));
            B <= std_logic_vector(to_signed(rand_B, 8));
            Ci_Bi <= '0';
            f3 <= std_logic_vector(to_unsigned(rand_f3, 3));

            wait for 20 ns;

            -- Golden model check
            case rand_f3 is
                when 0 => 
                    if f7 = "00000" then -- add
                        report "ADD" severity note;
                        assert signed(result) = signed(to_signed(rand_A, 8)) + signed(to_signed(rand_B, 8))
                            report "Random ADD failed at iteration " & integer'image(i)
                            severity error;
                    elsif f7 = "10100" then  -- sub
                        report "SUB" severity note;
                        assert signed(result) = signed(to_signed(rand_A, 8)) - signed(to_signed(rand_B, 8))
                            report "Random SUB failed at iteration " & integer'image(i)
                            severity error;
                    else
                        null;
                    end if;   
                when 1 =>  -- SLL
                    report "SLL" severity note;
                    assert unsigned(result) = shift_left(unsigned(to_unsigned(rand_A,8)), to_integer(unsigned(to_unsigned(rand_B,8)(2 downto 0))))
                        report "Random SLL failed at iteration " & integer'image(i)
                        severity error;
                when 2 => -- SLT
                    report "SLT" severity note;
                    assert ((signed(to_signed(rand_A,8)) < signed(to_signed(rand_B,8))) and result = "00000001") or
                           ((signed(to_signed(rand_A,8)) >= signed(to_signed(rand_B,8))) and result = "00000000")
                        report "Random SLT failed at iteration " & integer'image(i)
                        severity error;
                when 3 => -- SLTU
                    report "SLTU" severity note;
                    assert ((unsigned(to_unsigned(rand_A,8)) < unsigned(to_unsigned(rand_B,8))) and result = "00000001") or
                           ((unsigned(to_unsigned(rand_A,8)) >= unsigned(to_unsigned(rand_B,8))) and result = "00000000")
                        report "Random SLTU failed at iteration " & integer'image(i)
                        severity error;
                when 4 => -- XOR
                    report "XOR" severity note;
                    assert result = std_logic_vector(unsigned(to_unsigned(rand_A,8)) xor unsigned(to_unsigned(rand_B,8)))
                        report "Random XOR failed at iteration " & integer'image(i)
                        severity error;
                when 5 => -- SRL
                    if f7 = "00000" then --SRL
                        report "SRL" severity note;
                        assert result = std_logic_vector(shift_right(unsigned(to_unsigned(rand_A,8)), to_integer(unsigned(to_unsigned(rand_B,8)(2 downto 0)))))
                            report "Random SRL failed at iteration " & integer'image(i)
                            severity error;
                    elsif f7 = "10100" then -- SRA
                        report "SRA" severity note;
                        assert result = std_logic_vector(shift_right(signed(to_unsigned(rand_A,8)), to_integer(unsigned(to_unsigned(rand_B,8)(2 downto 0)))))
                            report "Random SRA failed at iteration " & integer'image(i)
                            severity error;
                    else
                        null;
                    end if;                      
                when 6 => -- OR
                    report "OR" severity note;
                    assert result = std_logic_vector(unsigned(to_unsigned(rand_A,8)) or unsigned(to_unsigned(rand_B,8)))
                        report "Random OR failed at iteration " & integer'image(i)
                        severity error;
                when 7 => -- AND
                    report "AND" severity note;
                    assert result = std_logic_vector(unsigned(to_unsigned(rand_A,8)) and unsigned(to_unsigned(rand_B,8)))
                        report "Random AND failed at iteration " & integer'image(i)
                        severity error;
                when others => null;
            end case;
            
            report "random test iteration " & integer'image(i) & " passed " 
            severity note;
        end loop;

        report "All randomized ALU tests completed!" severity note;
        wait;
    end process;

end behavior;
