library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity string_test is
    generic (
    str_constant : string := "this is a string";
    std_test : std_logic_vector(4 downto 0) := "11011";
    str1_constant : string := "this is also a string"
    );
    port (
    reset, sysclk, ival : in std_logic;
    str_port : in string;
    str1_port : in string := "test_string";
    str1_port : in std_logic_vector(3 downto 0) := "0101"
    );
end string_test;

architecture rtl of string_test is
  signal foo : string := "test string";
  signal foo :  std_logic_vector(2 downto 0) := "011";
  constant foo1 : string := "test string1";
  constant foo :  std_logic_vector(2 downto 0) := "000";
begin
    foo <= foo1;
end rtl;
