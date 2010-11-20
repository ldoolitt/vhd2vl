LIBRARY IEEE;
USE IEEE.std_logic_1164.all, IEEE.std_logic_arith.all, IEEE.std_logic_unsigned.all;
entity test is port(
  clk, rstn : in std_logic
);
end test;
architecture rtl of test is
  type   t is array (3 downto 0) of std_logic_vector(31 downto 0);
  signal a : std_logic_vector(3 downto 0);
  signal b : std_logic_vector(3 downto 0);
  signal status : std_logic;
  signal c : t;
begin
  process(clk) begin
    if clk'event and clk = '1' then
      if  b(1) & a(3 downto 2)  = "001" then
        status <= "1";
        c(0) <= x"FFFF";
      end if;          
    end if;
  end process;

end rtl;
