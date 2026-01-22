library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity with_select_comb is
  port(
    sel : in std_logic_vector(1 downto 0);
    a   : in std_logic_vector(3 downto 0);
    b   : in std_logic_vector(3 downto 0);
    y   : out std_logic_vector(3 downto 0)
  );
end with_select_comb;

architecture rtl of with_select_comb is
  signal sum4 : std_logic_vector(3 downto 0);
begin
  sum4 <= std_logic_vector(unsigned(a) + unsigned(b));

  -- Verify WITH SELECT multi-choice (with '|' and others) stays combinational assign, avoiding reg/always conflict
  with sel select
    y <= a     when "00" | "11",
         b     when "01",
         sum4  when others;
end rtl;
