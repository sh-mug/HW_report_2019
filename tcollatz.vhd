Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity TopCollatz is
end TopCollatz;
architecture SIM of TopCollatz is
    signal SysClk  : std_logic := '0';
    signal Reset   : std_logic := '0';
    signal Go      : std_logic := '0';
    signal RO1, RO2, RO3, RO4   : std_logic_vector ( 9 downto 0) := (others => '0');
    signal LO1, LO2, LO3, LO4   : std_logic_vector ( 7 downto 0) := (others => '0');
    signal Done    : std_logic := '0';

component Collatz
    port(
        SysClk	            : in    std_logic := '0';
        Reset	            : in	std_logic := '0';
        Go                  : in    std_logic := '0';
        RO1, RO2, RO3, RO4  : out   std_logic_vector ( 9 downto 0) := (others => '0');  -- Route Output
        LO1, LO2, LO3, LO4  : out   std_logic_vector ( 7 downto 0) := (others => '0');  -- Length Output
        Done                : out   std_logic := '0');
end component;

begin

CL: Collatz port map(
    SysClk  => SysClk,
    Reset   => Reset,
    Go      => Go,
    RO1     => RO1,
    RO2     => RO2,
    RO3     => RO3,
    RO4     => RO4,
    LO1     => LO1,
    LO2     => LO2,
    LO3     => LO3,
    LO4     => LO4,
    Done    => Done);

process begin
    SysClk <= '1';
    wait for 10 ns;
    SysClk <= '0';
    wait for 10 ns;
end process;

process begin
    wait for 5 ns;
    Reset <= '1';
    wait for 40 ns;
    Reset <= '0';
    wait for 120 ns;
    Go <= '1';
    wait for 40 ns;
    Go <= '0';
    wait for 2000 us;
end process;

end SIM;