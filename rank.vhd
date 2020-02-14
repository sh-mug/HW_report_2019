Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
 
entity Rank is
    port (
    Data                : in    std_logic_vector ( 8 downto 0) := (others => '0');
    Dmax                : in    std_logic_vector (16 downto 0) := (others => '0');
    Count               : in    std_logic_vector ( 7 downto 0) := (others => '0');
    RI1, RI2, RI3, RI4  : in    std_logic_vector ( 8 downto 0) := (others => '0');  -- Route Input
    TI1, TI2, TI3, TI4  : in    std_logic_vector (16 downto 0) := (others => '0');  -- Top Input
    LI1, LI2, LI3, LI4  : in    std_logic_vector ( 7 downto 0) := (others => '0');  -- Length Input
    RO1, RO2, RO3, RO4  : out   std_logic_vector ( 8 downto 0) := (others => '0');  -- Route Output
    TO1, TO2, TO3, TO4  : out   std_logic_vector (16 downto 0) := (others => '0');  -- Top Output
    LO1, LO2, LO3, LO4  : out   std_logic_vector ( 7 downto 0) := (others => '0')); -- Length Output
end Rank;
 
architecture RTL of Rank is
signal Equal            : std_logic_vector ( 3 downto 0) := (others => '0');
signal GreaterThan      : std_logic_vector ( 3 downto 0) := (others => '0');
signal Between          : std_logic_vector ( 3 downto 0) := (others => '0');
signal CountGreaterThan : std_logic_vector ( 3 downto 0) := (others => '0');
signal EqualOr          : std_logic := '0';

begin
    Equal(0) <= '1' when TI1 = Dmax else '0';
    Equal(1) <= '1' when TI2 = Dmax else '0';
    Equal(2) <= '1' when TI3 = Dmax else '0';
    Equal(3) <= '1' when TI4 = Dmax else '0';
    EqualOr <= Equal(0) or Equal(1) or Equal(2) or Equal(3);

    GreaterThan(0) <= '1' when Dmax > TI1 else '0';
    GreaterThan(1) <= '1' when Dmax > TI2 else '0';
    GreaterThan(2) <= '1' when Dmax > TI3 else '0';
    GreaterThan(3) <= '1' when Dmax > TI4 else '0';
    
    Between(0) <= GreaterThan(0);
    Between(1) <= '1' when ((not (GreaterThan(0) or Equal(0))) and GreaterThan(1)) = '1' else '0';
    Between(2) <= '1' when ((not (GreaterThan(1) or Equal(1))) and GreaterThan(2)) = '1' else '0';
    Between(3) <= '1' when ((not (GreaterThan(2) or Equal(2))) and GreaterThan(3)) = '1' else '0';
    
    CountGreaterThan(0) <= '1' when (Equal(0) = '1') and Count > LI1 else '0';
    CountGreaterThan(1) <= '1' when (Equal(1) = '1') and Count > LI2 else '0';
    CountGreaterThan(2) <= '1' when (Equal(2) = '1') and Count > LI3 else '0';
    CountGreaterThan(3) <= '1' when (Equal(3) = '1') and Count > LI4 else '0';
    
    TO1 <= Dmax
        when Between(0) = '1'
        else TI1;
    LO1 <= Count
        when (Between(0) or CountGreaterThan(0)) = '1'
        else LI1;
    RO1 <= Data
        when (Between(0) or CountGreaterThan(0)) = '1'
        else RI1;
    
    TO2 <= Dmax
        when Between(1) = '1'
        else TI1 when GreaterThan(0) = '1'
        else TI2;
    LO2 <= Count
        when (Between(1) or CountGreaterThan(0)) = '1'
        else LI1 when GreaterThan(0) = '1'
        else LI2;
    RO2 <= Data
        when (Between(1) or CountGreaterThan(0)) = '1'
        else RI1 when GreaterThan(0) = '1'
        else RI2;

    TO3 <= Dmax
        when Between(2) = '1'
        else TI2 when (GreaterThan(1) and not Equal(0)) = '1'
        else TI3;
    LO3 <= Count
        when (Between(2) or CountGreaterThan(2)) = '1'
        else LI2 when (GreaterThan(1) and not Equal(0)) = '1'
        else LI3;
    RO3 <= Data
        when (Between(2) or CountGreaterThan(2)) = '1'
        else RI2 when (GreaterThan(1) and not Equal(0)) = '1'
        else RI3;

    TO4 <= Dmax
        when Between(3) = '1'
        else TI3 when (GreaterThan(2) and not (Equal(0) or Equal(1))) = '1'
        else TI4;
    LO4 <= Count
        when (Between(3) or CountGreaterThan(3)) = '1'
        else LI3 when (GreaterThan(2) and not (Equal(0) or Equal(1))) = '1'
        else LI4;
    RO4 <= Data
        when (Between(3) or CountGreaterThan(3)) = '1'
        else RI3 when (GreaterThan(2) and not (Equal(0) or Equal(1))) = '1'
        else RI4;
    
end RTL;
