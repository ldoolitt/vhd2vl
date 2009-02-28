LIBRARY IEEE;
USE IEEE.std_logic_1164.all, IEEE.std_logic_arith.all, IEEE.std_logic_unsigned.all;
entity test is port(
  clk, rstn : in std_logic
);
end test;
architecture rtl of test is
  signal a : std_logic_vector(3 downto 0);
  signal b : std_logic_vector(3 downto 0);
  signal status : std_logic;
begin
  process(clk) begin
    if clk'event and clk = '1' then
      if  b(1) & a(3 downto 2)  = "001" then
        status <= "1";
      end if;          
    end if;
  end process;

end rtl;
