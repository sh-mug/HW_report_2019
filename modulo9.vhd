Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
 
-- mod|  0 |  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 
-- ---+----+----+----+----+----+----+----+----+----
-- out|1,10|  2 |  3 |  4 |  5 |  6 |  7 |  8 |  9

entity Modulo9 is
port (
    Reg                 : in    std_logic_vector ( 8 downto 0) := (others => '0');
    ModOut              : out   std_logic_vector ( 3 downto 0) := (others => '0'));
end Modulo9;
 
architecture RTL of Modulo9 is
signal NextCount        : std_logic_vector ( 7 downto 0) := (others => '0');
signal A, B, C, S, Cout : std_logic_vector ( 2 downto 0) := (others => '0');
signal SumTemp          : std_logic_vector ( 4 downto 0) := (others => '0');

component FullAdder
    port (
        A, B, Cin       : in    std_logic := '0';
        S, Cout         : out   std_logic := '0');
end component;
for FA0, FA1, FA2       : FullAdder use entity work.FullAdder;

begin
    A <= Reg(7 downto 5);
    B <= not Reg(4 downto 2);
    C <= Reg(1 downto 0) & not Reg(8);
    FA0 : FullAdder port map (A(0), B(0), C(0), S(0), Cout(0));
    FA1 : FullAdder port map (A(1), B(1), C(1), S(1), Cout(1));
    FA2 : FullAdder port map (A(2), B(2), C(2), S(2), Cout(2));
    SumTemp <= (('0' & Cout) + ("00" & S(2 downto 1))) & S(0);
    ModOut <= ('0' & SumTemp(2 downto 0)) + ("00" & (not SumTemp(4 downto 3)));
end RTL;
