entity concat_demo is
    generic( abc  : std_logic_vector(26 downto 0) := "010" & x"aaa";
             xyz  : std_logic_vector(31 downto 0) := x"ff"
           );
    port(reset  : in std_logic
        );

end entity concat_demo;
