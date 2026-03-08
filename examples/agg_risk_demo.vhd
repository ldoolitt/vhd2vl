library ieee;
use ieee.std_logic_1164.all;

entity agg_risk is
    port(
        a : in std_logic;
        b : in std_logic;
        y : out std_logic
    );
end entity agg_risk;

architecture rtl of agg_risk is
begin
    -- Concatenation selector uses op='c' and must be wrapped in Verilog.
    -- If not wrapped, this becomes "case(a,b)".
    with a & b select
        y <= '0' when "00",
             '1' when "01",
             '0' when "10",
             '1' when others;
end architecture rtl;
