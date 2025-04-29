----------------------------------------------------------------------------------
-- Noridel Herron
-- FullAdder for ALU
-- 4/25/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- range value of the inputs are between -128 to 127
entity adder_8bits is
    Port (A,B            : in std_logic_vector (7 downto 0);       -- 8-bits inputs
          Ci             : in std_logic;                           -- 1-bit inputs
          Sum            : out std_logic_vector (7 downto 0);      -- 8-bits output result
          Z_flag, V_flag, C_flag, N_flag: out std_logic            -- 1-bit output flags
          ); 
end adder_8bits;

architecture Equation of adder_8bits is

    component FullAdder is 
       port(A, B, Ci: in std_logic;     -- inputs
            Co, S   : out std_logic);   -- output
    end component; 
    
    -- Signals
    signal Co : std_logic;
    signal C  : std_logic_vector (7 downto 1); 
    signal S  : std_logic_vector (7 downto 0); 
    
begin  
    -- Instantiate the FullAdder 
    FA1: FullAdder port map (A(0), B(0), Ci, C(1), S(0)); 
    FA2: FullAdder port map (A(1), B(1), C(1),C(2), S(1)); 
    FA3: FullAdder port map (A(2), B(2), C(2),C(3), S(2)); 
    FA4: FullAdder port map (A(3), B(3), C(3), C(4), S(3)); 
    FA5: FullAdder port map (A(4), B(4), C(4), C(5), S(4)); 
    FA6: FullAdder port map (A(5), B(5), C(5), C(6), S(5)); 
    FA7: FullAdder port map (A(6), B(6), C(6), C(7), S(6)); 
    FA8: FullAdder port map (A(7), B(7), C(7), Co, S(7));     
    
process(S, A(7), B(7), Co )
begin
    Sum <= S; -- assign the subtractor result to the 8-bits output
    
    -- set the zero flag
    if S = "00000000" then
        z_flag <= '1';
    else
        z_flag <= '0';
    end if;
    
    -- set the overflow flag
    if ((A(7) = B(7)) and (S(7) /= A(7))) then
        V_flag <= '1';
    else
        V_flag <= '0';
    end if;
    
    -- set the carry flag  
    if Co = '1' then
        C_flag <= '1';
    else
        C_flag <= '0';
    end if;
     
    -- set the negative flag
    N_flag <= S(7);
   
end process;

end Equation;
