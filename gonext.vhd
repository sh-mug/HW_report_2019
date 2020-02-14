Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
 
entity GoNext is
port (
    NextData            : in    std_logic_vector ( 8 downto 0) := (others => '0');
    Ready               : out   std_logic := '0');
end GoNext;
 
architecture RTL of GoNext is
signal Mod3             : std_logic_vector ( 2 downto 0) := (others => '0');
signal NextDataMod9     : std_logic_vector ( 3 downto 0) := (others => '0');

component Modulo9
    port (
        Reg             : in    std_logic_vector ( 8 downto 0) := (others => '0');
        ModOut          : out   std_logic_vector ( 3 downto 0) := (others => '0'));
end component;
for M90       : Modulo9 use entity work.Modulo9;

begin
    M90 : Modulo9 port map (NextData, NextDataMod9);
    -- with NextDataMod9 select
    --     Mod3(0) <= '1' when "0001" | "0100" | "0111" | "1010",
    --                '0' when others;
    Mod3(0) <= '0'; -- 0 mod 3
    Mod3(1) <= '0'; -- 1 mod 3
    with NextDataMod9 select    -- 2 mod 3
        Mod3(2) <= '1' when "0011" | "0110" | "1001",
                   '0' when others;

    
    Ready <= '0' when (
        (Mod3(2) = '1') or
        (NextDataMod9 = "0101") or
        (NextData(4 downto 0) = "10110") or
        (NextData(8 downto 7) /= "11" and (
            (NextData(2 downto 0) = "001") or
            (NextData(2 downto 0) = "010") or
            (NextData(3 downto 0) = "0110")
        )) or
        (NextData(8) = '0' and (
            (NextData(1 downto 0) /= "11") or
            (NextData(3 downto 0) = "0011")
        ))
    ) else '1';
end RTL;
