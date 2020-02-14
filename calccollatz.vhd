Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
 
entity CalcCollatz is
    port (
        Dreg            : in        std_logic_vector (16 downto 0) := (others => '0');
        LocalMaximum    : buffer    std_logic_vector (16 downto 0) := (others => '0');
        NextDreg        : out       std_logic_vector (16 downto 0) := (others => '0');
        CountDiff       : out       std_logic_vector ( 7 downto 0) := (others => '0'));
end CalcCollatz;
 
architecture RTL of CalcCollatz is
signal LocalMaximumTmp  : std_logic_vector (17 downto 0) := (others => '0');
signal TwoStep          : std_logic := '0';
signal ForCountDiff     : std_logic_vector (10 downto 0) := (others => '0');

begin
    TwoStep <= Dreg(0);
    LocalMaximumTmp <= 
         (Dreg(15 downto 0) & "11") + (Dreg & '1') when TwoStep = '0'
    else (Dreg(14 downto 0) & "111") + Dreg;
    LocalMaximum <= LocalMaximumTmp(17 downto 1);
    ForCountDiff <= 
        (LocalMaximum(8 downto 0) & "00") when TwoStep = '1' 
    else LocalMaximum(10 downto 0);
    CountDiff <= "00000010" when ForCountDiff( 0) = '1'
            else "00000011" when ForCountDiff( 1) = '1'
            else "00000100" when ForCountDiff( 2) = '1'
            else "00000101" when ForCountDiff( 3) = '1'
            else "00000110" when ForCountDiff( 4) = '1'
            else "00000111" when ForCountDiff( 5) = '1'
            else "00001000" when ForCountDiff( 6) = '1'
            else "00001001" when ForCountDiff( 7) = '1'
            else "00001010" when ForCountDiff( 8) = '1'
            else "00001011" when ForCountDiff( 9) = '1'
            else "00001100" when ForCountDiff(10) = '1'
            else "00001101";

    NextDreg <= ('0'          & LocalMaximum(16 downto  1)) when LocalMaximum(0) = '1'
           else ("00"         & LocalMaximum(16 downto  2)) when LocalMaximum(1) = '1'
           else ("000"        & LocalMaximum(16 downto  3)) when LocalMaximum(2) = '1'
           else ("0000"       & LocalMaximum(16 downto  4)) when LocalMaximum(3) = '1'
           else ("00000"      & LocalMaximum(16 downto  5)) when LocalMaximum(4) = '1'
           else ("000000"     & LocalMaximum(16 downto  6)) when LocalMaximum(5) = '1'
           else ("0000000"    & LocalMaximum(16 downto  7)) when LocalMaximum(6) = '1'
           else ("00000000"   & LocalMaximum(16 downto  8)) when LocalMaximum(7) = '1'
           else ("000000000"  & LocalMaximum(16 downto  9)) when LocalMaximum(8) = '1'
           else ("0000000000" & LocalMaximum(16 downto 10));


end RTL;