library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity todo is
   port (
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
   -- to_integer not always work (probably the same with conv_integer)
   uns <= "10101001";
   int <= mem(to_integer(uns)); -- here work
   int <= to_integer(uns);      -- here fail
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
