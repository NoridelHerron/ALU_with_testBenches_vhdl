----------------------------------------------------------------------------------
-- Noridel Herron
-- FullAdder for ALU
-- 4/25/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sub_8bits is
    Port (A,B            : in std_logic_vector (7 downto 0);       -- 8-bits inputs
          Bi             : in std_logic;                           -- 1-bit inputs
          difference     : out std_logic_vector (7 downto 0);      -- 8-bits output result
          Z_flag, V_flag, C_flag, N_flag: out std_logic            -- 1-bit output flags
          ); 
end sub_8bits;

architecture equation of sub_8bits is

    component FullSubtractor 
    port ( X, Y, Bin : in std_logic; 
            Bout, D: out std_logic); 
   end component;  

    -- Signals
    signal Bo : std_logic;
    signal Br  : std_logic_vector (7 downto 1); 
    signal Do  : std_logic_vector (7 downto 0); 

begin 
    -- Instantiate the FullSubtractor
    FS1: FullSubtractor port map (A(0), B(0), Bi, Br(7), Do(0)); 
    FS2: FullSubtractor port map (A(1), B(1), Br(7), Br(6), Do(1)); 
    FS3: FullSubtractor port map (A(2), B(2), Br(6), Br(5), Do(2)); 
    FS4: FullSubtractor port map (A(3), B(3), Br(5), Br(4), Do(3)); 
    FS5: FullSubtractor port map (A(4), B(4), Br(4), Br(3), Do(4)); 
    FS6: FullSubtractor port map (A(5), B(5), Br(3), Br(2), Do(5)); 
    FS7: FullSubtractor port map (A(6), B(6), Br(2), Br(1), Do(6)); 
    FS8: FullSubtractor port map (A(7), B(7), Br(1),Bo, Do(7));  

process(Do, A, B, Bo )
begin
    difference <= Do;   -- assign the subtractor result to the 8-bits output
    
    -- check and set the zero flag
    if Do = "00000000" then
        z_flag <= '1';
    else
        z_flag <= '0';
    end if;
    
    -- check and set the overflow flag
    if ((A(7) /= B(7)) and (Do(7) /= A(7))) then
        V_flag <= '1';
    else
        V_flag <= '0';
    end if;
    
    -- set the C flag  
    C_flag <= not Bo; -- if borrow c = 0; if not then c = 1;
  
    -- set the negative flag
     N_flag <= Do(7);
    
end process;
   
end equation;
