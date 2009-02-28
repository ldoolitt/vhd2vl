LIBRARY IEEE;
USE IEEE.std_logic_1164.all, IEEE.std_logic_arith.all, IEEE.std_logic_unsigned.all;

entity based is port( sysclk : in std_logic);
end based;
architecture rtl of based is
  signal foo,foo2,foo8,foo10,foo11,foo16 : integer;
begin
  foo <= 123;
  foo2 <= 2#00101101110111#;
  foo8 <= 8#0177362#;
  foo10<= 10#01234#;
  foo11<= 11#01234#;
  foo16<= 16#12af#;
end rtl;
