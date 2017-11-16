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
   signal int : integer;
   signal uns : unsigned(7 downto 0);
begin
   --**************************************************************************
   -- Wrong translations
   --**************************************************************************
   -- to_integer is unsupported (is not removed)
   uns <= "10101001";
   int <= to_integer(uns);
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
