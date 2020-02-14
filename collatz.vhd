Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity Collatz is
port(
    SysClk              : in        std_logic := '0';
    Reset               : in	    std_logic := '0';
    Go                  : in        std_logic := '0';
    RO1, RO2, RO3, RO4  : out       std_logic_vector ( 9 downto 0) := (others => '0');  -- Route Output
    LO1, LO2, LO3, LO4  : out       std_logic_vector ( 7 downto 0) := (others => '0');  -- Length Output
    Done                : buffer    std_logic := '0');
end Collatz;

architecture RTL of Collatz is
signal Active           : std_logic := '0';
signal Started          : std_logic := '0';
signal DataL, DataH     : std_logic_vector ( 8 downto 0) := (others => '0');
signal R1L, R2L, R3L, R4L, R1H, R2H, R3H, R4H   : std_logic_vector ( 8 downto 0) := (others => '0');
signal T1L, T2L, T3L, T4L, T1H, T2H, T3H, T4H   : std_logic_vector (16 downto 0) := (others => '0');
signal L1L, L2L, L3L, L4L, L1H, L2H, L3H, L4H   : std_logic_vector ( 7 downto 0) := (others => '0');
signal CalcRank         : std_logic := '0';
signal Rank             : std_logic_vector ( 1 downto 0) := (others => '0');
signal RankL, RankH     : std_logic_vector ( 1 downto 0) := (others => '0');
signal RankIL, RankIH   : std_logic_vector ( 1 downto 0) := (others => '0');
signal R1, R2, R3, R4   : std_logic_vector ( 9 downto 0) := (others => '0');
signal L1, L2, L3, L4   : std_logic_vector ( 7 downto 0) := (others => '0');
signal CountAll         : std_logic_vector (15 downto 0) := (others => '0');

component SubCollatz
port (
    SysClk              : in        std_logic := '0';
    Reset               : in	    std_logic := '0';
    Go                  : in        std_logic := '0';
    Active              : in        std_logic := '0';
    GoPlus              : in        std_logic := '0';
    Data                : buffer    std_logic_vector ( 8 downto 0) := (others => '0');
    R1, R2, R3, R4      : buffer    std_logic_vector ( 8 downto 0) := (others => '0');    -- Route
    T1, T2, T3, T4      : buffer    std_logic_vector (16 downto 0) := (others => '0');    -- Top
    L1, L2, L3, L4      : buffer    std_logic_vector ( 7 downto 0) := (others => '0'));   -- Length
end component;
for SCL, SCH            : SubCollatz use entity work.SubCollatz;

component MergeRank
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
end component;
for MR                  : MergeRank use entity work.MergeRank;

begin
    process begin
    wait until rising_edge(SysClk);
    if Reset = '1' then
        Active <= '0';
        Started <= '0';
        RO1 <= (others => '0'); RO2 <= (others => '0');
        RO3 <= (others => '0'); RO4 <= (others => '0');
        LO1 <= (others => '0'); LO2 <= (others => '0');
        LO3 <= (others => '0'); LO4 <= (others => '0');
        CountAll <= (others => '0');
    else
        if Go = '1' then
            Active <= '1';
            Started <= '1';
            Done <= '0';
            Rank <= "00"; RankL <= "00"; RankH <= "00";
            CountAll <= (others => '0');
        else
            if DataH < DataL then
                Active <= '0';
            end if;
            if Done = '0' then
                CountAll <= CountAll + 1;
            end if;
        end if;

        if CalcRank = '1' then
            RO1 <= R1; RO2 <= R2; RO3 <= R3; RO4 <= R4;
            LO1 <= L1; LO2 <= L2; LO3 <= L3; LO4 <= L4;

            RankL <= RankIL;
            RankH <= RankIH;
            Rank <= Rank + 1;
            if Rank = "11" then
                Started <= '0';
                Done <= '1';
            end if;
        end if;
    end if;
    end process;

    SCL : SubCollatz port map (
        SysClk, Reset, Go, Active,
        '1', DataL,
        R1L, R2L, R3L, R4L,
        T1L, T2L, T3L, T4L,
        L1L, L2L, L3L, L4L);
    SCH : SubCollatz port map (
        SysClk, Reset, Go, Active,
        '0', DataH,
        R1H, R2H, R3H, R4H,
        T1H, T2H, T3H, T4H,
        L1H, L2H, L3H, L4H);
    
    CalcRank <= Started and not (Go or Active or Done);
    MR : MergeRank port map (
        CalcRank,
        Rank,
        RankL, RankH,
        R1L, R2L, R3L, R4L, R1H, R2H, R3H, R4H,
        T1L, T2L, T3L, T4L, T1H, T2H, T3H, T4H,
        L1L, L2L, L3L, L4L, L1H, L2H, L3H, L4H,
        RankIL, RankIH,
        R1, R2, R3, R4,
        L1, L2, L3, L4);
    end RTL;