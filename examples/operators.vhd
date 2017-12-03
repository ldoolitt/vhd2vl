library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity operators is
   generic (
      g_and  : std_logic_vector(1 downto 0) := "11" and  "10";
      g_or   : std_logic_vector(1 downto 0) := "11" or   "10";
      g_nand : std_logic_vector(1 downto 0) := "11" nand "10";
      g_nor  : std_logic_vector(1 downto 0) := "11" nor  "10";
      g_xor  : std_logic_vector(1 downto 0) := "11" xor  "10";
      g_xnor : std_logic_vector(1 downto 0) := "11" xnor "10";
      g_not  : std_logic_vector(1 downto 0) := not "10"
   );
   port (
      clk_i : in std_logic
   );
end entity operators;

architecture rtl of operators is
   constant c_and  : std_logic_vector(1 downto 0) := "11" and  "10";
   constant c_or   : std_logic_vector(1 downto 0) := "11" or   "10";
   constant c_nand : std_logic_vector(1 downto 0) := "11" nand "10";
   constant c_nor  : std_logic_vector(1 downto 0) := "11" nor  "10";
   constant c_xor  : std_logic_vector(1 downto 0) := "11" xor  "10";
   constant c_xnor : std_logic_vector(1 downto 0) := "11" xnor "10";
   constant c_not  : std_logic_vector(1 downto 0) := not "10";
   signal   s_op1  : std_logic_vector(1 downto 0);
   signal   s_op2  : std_logic_vector(1 downto 0);
   signal   s_res  : std_logic_vector(1 downto 0);
   signal   s_int  : integer;
   signal   s_sig  : signed(7 downto 0);
   signal   s_uns  : unsigned(7 downto 0);
begin

   test_i: process(clk_i)
      variable v_op1  : std_logic_vector(1 downto 0);
      variable v_op2  : std_logic_vector(1 downto 0);
      variable v_res  : std_logic_vector(1 downto 0);
   begin
      if rising_edge(clk_i) then
         if
            (s_op1="11" and  s_op2="00") or
            (s_op1="11" or   s_op2="00") or
            (s_op1="11" nand s_op2="00") or
            (s_op1="11" nor  s_op2="00") or
            (not (s_op1="11"))
         then
            s_res <= s_op1 and  s_op2;
            s_res <= s_op1 or   s_op2;
            v_res := v_op1 nand v_op2;
            v_res := v_op1 nor  v_op2;
            s_res <= s_op1 xor  s_op2;
            v_res := v_op1 xnor v_op2;
            s_res <= not s_op1;
            s_int <= abs(s_int);
            s_sig <= abs(s_sig);
            s_uns <= s_uns sll 2;
            s_uns <= s_uns srl to_integer(s_uns);
            -- s_sig <= s_sig sla 6; -- Unsupported by GHDL?
            -- s_sig <= s_sig sra 8; -- Unsupported by GHDL?
            -- s_uns <= s_uns ror 3; -- Not yet implemented
            -- s_uns <= s_uns rol to_integer(s_uns); -- Not yet implemented
         end if;
      end if;
   end process test_i;

end architecture rtl;
