----------------------------------------------------------------------------------
-- Noridel Herron
-- ALU 8-bit with Flags
-- 4/26/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (A, B       : in std_logic_vector (7 downto 0);  -- 8-bits inputs
          Ci_Bi      : in std_logic;                      -- 1-bit input
          f3         : in std_logic_vector (2 downto 0);  -- 3-bits input
          f7         : in std_logic_vector (4 downto 0);  -- 5-bits input
          result     : out std_logic_vector (7 downto 0); -- 8-bits output
          Z_flag, V_flag, C_flag, N_flag : out std_logic);-- 1-bits outputs
end ALU;

architecture operations of ALU is
    
    -- Adder
    component adder_8bits
        Port (A,B : in std_logic_vector(7 downto 0);           -- 8-bits inputs
              Ci  : in std_logic;                              -- 1-bit input
              Sum : out std_logic_vector(7 downto 0);          -- 8-bits outputs
              Z_flag, V_flag, C_flag, N_flag : out std_logic); -- 1-bit output
    end component;
    
    -- Subtractor
    component sub_8bits
        Port (A,B : in std_logic_vector(7 downto 0);            -- 8-bits inputs
              Bi  : in std_logic;                               -- 1-bit input
              difference : out std_logic_vector(7 downto 0);    -- 8-bits outputs
              Z_flag, V_flag, C_flag, N_flag : out std_logic);  -- 1-bit output
    end component;

    -- Internal signals
    signal func_3 : integer range 0 to 7;   -- function 3 
    signal func_7 : integer range 0 to 20;  -- function 7
    signal Z, V, C, N, Za, Va, Ca, Na, Zs, Vs, Cs, Ns : std_logic; -- flags
    signal res_add, res_sub : std_logic_vector(7 downto 0);  -- for add/sub
    signal res_temp : std_logic_vector(7 downto 0);

begin
    -- Instantiate adder and subtractor
    Add: adder_8bits port map (A, B, Ci_Bi, res_add, Za, Va, Ca, Na);
    Sub: sub_8bits port map (A, B, Ci_Bi, res_sub, Zs, Vs, Cs, Ns);

    func_3 <= TO_INTEGER(unsigned(f3));
    func_7 <= TO_INTEGER(unsigned(f7));

    -- Datapath process
    process (func_3, func_7, A, B, res_add, res_sub, Z, V, C, N)
    begin
        case func_3 is
            when 0 => -- ADD/SUB
                case func_7 is
                    when 0 => -- add
                        res_temp <= res_add;
                        Z_flag <= Za;   -- zero flag
                        V_flag <= Va;   -- overflow flag
                        C_flag <= Ca;   -- carry flag
                        N_flag <= Na;   -- negative flag
                    when 20 => -- sub
                        res_temp <= res_sub;
                        Z_flag <= Zs;   -- zero flag
                        V_flag <= Vs;   -- overflow flag
                        C_flag <= Cs;   -- borrow flag
                        N_flag <= Ns;   -- negative flag
                    when others => 
                        res_temp <= (others => '0');
                        Z_flag <= '0'; V_flag <= '0'; 
                        C_flag <= '0'; N_flag <= '0';   
                end case;
                
            when 1 => -- SLL
                res_temp <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(2 downto 0))))); 
            when 2 => -- SLT
                if signed(A) < signed(B) then
                    res_temp <= "00000001";
                else
                    res_temp <= "00000000";
                end if;
            when 3 => -- SLTU
                if unsigned(A) < unsigned(B) then
                    res_temp <= "00000001";
                else
                    res_temp <= "00000000";
                end if;
            when 4 => -- XOR
                res_temp <= A xor B;
            when 5 => -- SRL/SRA 1 is true 0 is false
                case func_7 is
                    when 0 =>
                        res_temp <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(2 downto 0)))));
                    when 20 =>
                        res_temp <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(2 downto 0)))));
                    when others => 
                        res_temp <= (others => '0');
                end case;
            when 6 => -- OR
                res_temp <= A or B;
            when 7 => -- AND
                res_temp <= A and B;
            when others =>
                res_temp <= (others => '0');
        end case;
        
        if func_3 /= 0then         
            if res_temp = "00000000" then
                Z_flag <= '1';
            else
                Z_flag <= '0';
            end if;
            N_flag <= res_temp(7); 
            V_flag <= '0'; 
            C_flag <= '0';      
        end if;
    end process;
    
    result <= res_temp;

end operations;
