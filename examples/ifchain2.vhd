LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity ifchain is port(
  clk, rstn : in std_logic;
  enable: in std_logic;
  result: out std_logic
);
end ifchain;

architecture rtl of ifchain is
  signal counter : std_logic_vector(3 downto 0);
  constant CLK_DIV_VAL : unsigned(3 downto 0) := 11;
begin

clk_src : process(clk, rstn) is
begin
    if (rstn = '0') then
        counter <= (others => '0');
        result <= '0';
    elsif (rising_edge(clk)) then -- Divide by 2 by default
        if (enable = '1') then
            if (counter = 0) then
                counter <= CLK_DIV_VAL;
                result <= '1';
            else
                counter <= counter - 1;
                result <= '0';
            end if; -- counter
        end if; -- enable
    end if; -- clk, rst_n
end process clk_src;

end rtl;
