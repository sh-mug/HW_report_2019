Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
 
entity MergeRank is
port (
    Active              : in        std_logic := '0';
    Rank                : in        std_logic_vector ( 1 downto 0) := (others => '0');
    RankIL, RankIH      : in        std_logic_vector ( 1 downto 0) := (others => '0');
    RI1L,RI2L,RI3L,RI4L,RI1H,RI2H,RI3H,RI4H : in std_logic_vector ( 8 downto 0) := (others => '0');
    TI1L,TI2L,TI3L,TI4L,TI1H,TI2H,TI3H,TI4H : in std_logic_vector (16 downto 0) := (others => '0');
    LI1L,LI2L,LI3L,LI4L,LI1H,LI2H,LI3H,LI4H : in std_logic_vector ( 7 downto 0) := (others => '0');
    RankL, RankH        : out       std_logic_vector ( 1 downto 0) := (others => '0');
    RO1, RO2, RO3, RO4  : buffer    std_logic_vector ( 9 downto 0) := (others => '0');
    LO1, LO2, LO3, LO4  : buffer    std_logic_vector ( 7 downto 0) := (others => '0'));
end MergeRank;
 
architecture RTL of MergeRank is
signal    TL, TH    : std_logic_vector (16 downto 0) := (others => '0');
signal R, RL, RH    : std_logic_vector ( 8 downto 0) := (others => '0');
signal L, LL, LH    : std_logic_vector ( 7 downto 0) := (others => '0');
signal Greater      : std_logic := '0';

begin
    RL <= RI1L when RankIL = "00" else RI2L when RankIL = "01" else RI3L when RankIL = "10" else RI4L;
    TL <= TI1L when RankIL = "00" else TI2L when RankIL = "01" else TI3L when RankIL = "10" else TI4L;
    LL <= LI1L when RankIL = "00" else LI2L when RankIL = "01" else LI3L when RankIL = "10" else LI4L;
    RH <= RI1H when RankIH = "00" else RI2H when RankIH = "01" else RI3H when RankIH = "10" else RI4H;
    TH <= TI1H when RankIH = "00" else TI2H when RankIH = "01" else TI3H when RankIH = "10" else TI4H;
    LH <= LI1H when RankIH = "00" else LI2H when RankIH = "01" else LI3H when RankIH = "10" else LI4H;
    
    Greater <= '1' when ((TL > TH) or ((TL = TH) and (RL > RH))) else '0';
    R <= RL when Greater = '1' else RH;
    L <= LL when Greater = '1' else LH;
    
    RO1 <= R & '1' when Rank = "00" else RO1;
    RO2 <= R & '1' when Rank = "01" else RO2;
    RO3 <= R & '1' when Rank = "10" else RO3;
    RO4 <= R & '1' when Rank = "11" else RO4;

    LO1 <= L when Rank = "00" else LO1;
    LO2 <= L when Rank = "01" else LO2;
    LO3 <= L when Rank = "10" else LO3;
    LO4 <= L when Rank = "11" else LO4;

    RankL <= RankIL + 1 when TL >= TH else RankIL;
    RankH <= RankIH + 1 when TH >= TL else RankIH;
end RTL;