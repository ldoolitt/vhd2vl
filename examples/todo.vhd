library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity todo is
   port (
      clk_i  : in  std_logic;
      data_i : in  std_logic_vector(7 downto 0);
      data_o : out std_logic_vector(7 downto 0)
   );
end todo;

architecture rtl of todo is
   type mem_type is array (0 to 255) of integer;
   signal mem : mem_type;

   signal int : integer;
   signal uns : unsigned(7 downto 0);
begin
   --**************************************************************************
   -- Wrong translations
   --**************************************************************************
   --
   test_i: process(clk_i)
      -- iverilog: variable declaration assignments are only allowed at the module level.
      variable i : integer:=8;
   begin
      for i in 0 to 7 loop
          if i=4 then
             exit; -- iverilog: error: malformed statement
          end if;
      end loop;
   end process test_i;

   --**************************************************************************
   -- Translations which abort with syntax error (uncomment to test)
   --**************************************************************************
   -- Concatenation in port assignament fail
--   uns <= "0000" & X"1"; -- It is supported
--   dut1_i: signextend
--      port map (
--        i => "00000000" & X"11", -- But here fail
--        o => open
--      );
   -- Unsupported type of instantiation
--   dut2_i: entity work.signextend
--   port map (
--      i => (others => '0'),
--      o => open
--   );

end rtl;
