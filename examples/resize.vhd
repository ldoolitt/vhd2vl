library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity resize_demo is
  port(
    u4 : in  unsigned(3 downto 0);
    y8 : out unsigned(7 downto 0);
    y2 : out unsigned(1 downto 0)
  );
end resize_demo;

architecture rtl of resize_demo is
begin
  y8 <= resize(u4, 8); -- expect extension to 8 bits
  y2 <= resize(u4, 2); -- expect truncation to 2 bits
end rtl;