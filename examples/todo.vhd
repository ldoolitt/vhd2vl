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
   signal uns : unsigned(3 downto 0);
begin
   -- to_integer is unsupported (is not removed)
   uns <= "1010";
   int <= to_integer(uns);
   -- 
end rtl;
