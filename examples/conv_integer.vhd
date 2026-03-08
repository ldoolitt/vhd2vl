library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity conv_integer_sink is
  port(
    val_u      : in integer;
    val_i      : in integer;
    val_u4     : in integer;
    val_i4     : in integer;
    val_u_port : in integer;
    val_i_port : in integer
  );
end entity;

architecture rtl of conv_integer_sink is
begin
  -- keep empty, only for verifying expression conversion in port map
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity conv_integer_demo is
  port(
    s : in  std_logic_vector(7 downto 0);
    u : out integer;
    i : out integer
  );
end entity;

architecture rtl of conv_integer_demo is
  constant s_test_neg : std_logic_vector(7 downto 0) :=  x"FF";
  signal   sig_4      : std_logic_vector(3 downto 0) := "1111";
begin
  -- conv_integer should be parsed as CONVFUNC_1 and preserved as expr
  u <= conv_integer(unsigned(s)+1);
  i <= conv_integer(signed(s));

  -- conv_integer in port map: constant/signal/port, signed/unsigned, various widths
  sink_inst : entity work.conv_integer_sink
    port map(
      -- constant (param_list): 8-bit
      val_u      => conv_integer(unsigned(s_test_neg)),  -- expected 255
      val_i      => conv_integer(signed(s_test_neg)),    -- expected -1
      -- signal (sig_list): 4-bit
      val_u4     => conv_integer(unsigned(sig_4)),      -- expected 15
      val_i4     => conv_integer(signed(sig_4)),        -- expected -1
      -- port (io_list): 8-bit
      val_u_port => conv_integer(unsigned(s)),
      val_i_port => conv_integer(signed(s))
    );
end architecture;