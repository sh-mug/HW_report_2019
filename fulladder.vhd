Library IEEE;
use IEEE.std_logic_1164.all;
 
entity FullAdder is
port (
    A, B, Cin           : in    std_logic := '0';
    S, Cout             : out   std_logic := '0');
end FullAdder;
 
architecture RTL of FullAdder is
begin 
    S <= A xor B xor Cin ;
    Cout <= (A and B) or (Cin and A) or (Cin and B) ;
end RTL;