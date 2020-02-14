Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity SubCollatz is
port(
    SysClk          : in        std_logic := '0';
    Reset           : in	    std_logic := '0';
    Go              : in        std_logic := '0';
    Active          : in        std_logic := '0';
    GoPlus          : in        std_logic := '0';
    Data            : buffer    std_logic_vector ( 8 downto 0) := (others => '0');
    R1, R2, R3, R4  : buffer    std_logic_vector ( 8 downto 0) := (others => '0');    -- Route
    T1, T2, T3, T4  : buffer    std_logic_vector (16 downto 0) := (others => '0');    -- Top
    L1, L2, L3, L4  : buffer    std_logic_vector ( 7 downto 0) := (others => '0')     -- Length
    );
end SubCollatz;

architecture RTL of SubCollatz is
constant Init           : std_logic_vector ( 8 downto 0) := "010000010";
signal Ready            : std_logic := '0';
signal NextData         : std_logic_vector ( 8 downto 0) := (others => '0');
signal NextDataIn       : std_logic_vector ( 8 downto 0) := (others => '0');
signal Dreg, NextDreg   : std_logic_vector (16 downto 0) := (others => '0');
signal LocalMaximum     : std_logic_vector (16 downto 0) := (others => '0');
signal Dmax             : std_logic_vector (16 downto 0) := (others => '0');
signal Count, NextCount : std_logic_vector ( 7 downto 0) := (others => '0');
signal CountDiff        : std_logic_vector ( 7 downto 0) := (others => '0');
signal RI1,RI2,RI3,RI4  : std_logic_vector ( 8 downto 0) := (others => '0');    -- Route
signal TI1,TI2,TI3,TI4  : std_logic_vector (16 downto 0) := (others => '0');    -- Top
signal LI1,LI2,LI3,LI4  : std_logic_vector ( 7 downto 0) := (others => '0');    -- Length

component CalcCollatz
    port (
        Dreg            : in        std_logic_vector (16 downto 0) := (others => '0');
        LocalMaximum    : buffer    std_logic_vector (16 downto 0) := (others => '0');
        NextDreg        : out       std_logic_vector (16 downto 0) := (others => '0');
        CountDiff       : out       std_logic_vector ( 7 downto 0) := (others => '0'));
end component;
for CC0                 : CalcCollatz use entity work.CalcCollatz;

component GoNext
    port (
        NextData        : in    std_logic_vector ( 8 downto 0) := (others => '0');
        Ready           : out   std_logic := '0');
end component;
for GN0                 : GoNext use entity work.GoNext;

component Rank
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
end component;
for Rank0               : Rank use entity work.Rank;

begin
    process begin
    wait until rising_edge(SysClk);
    if Reset = '1' then
        if GoPlus = '1' then
            Data <= Init;
            NextData <= Init + 3;
            Dreg <= ("00000000" & Init);
        else
            Data <= "111111111";
            NextData <= "111111110";
            Dreg <= "00000000111111111";
        end if;
        Dmax <= (others => '0');
        R1 <= (others => '0'); R2 <= (others => '0');
        R3 <= (others => '0'); R4 <= (others => '0');
        T1 <= (others => '0'); T2 <= (others => '0');
        T3 <= (others => '0'); T4 <= (others => '0');
        L1 <= (others => '0'); L2 <= (others => '0');
        L3 <= (others => '0'); L4 <= (others => '0');
        
    else
        if Active = '1' then
            if NextDreg = "00000000000000000" and Ready = '1' then
                -- renewal of ranking
                R1 <= RI1; R2 <= RI2; R3 <= RI3; R4 <= RI4;
                T1 <= TI1; T2 <= TI2; T3 <= TI3; T4 <= TI4;
                L1 <= LI1; L2 <= LI2; L3 <= LI3; L4 <= LI4;

                -- initialization
                Data <= NextData;
                Dreg <= ("00000000" & NextData);
                Dmax <= "00000000000000000"; 
                Count <= "00000000";

            else    -- calculation
                -- keep max
                if LocalMaximum > Dmax then
                    Dmax <= LocalMaximum;
                end if;

                -- Collatz
                Dreg <= NextDreg;
                Count <= NextCount;                
            end if;
            NextData <= NextDataIn;
        end if;
    end if;
    end process;

    -- calculate collatz
    CC0 : CalcCollatz port map (Dreg, LocalMaximum, NextDreg, CountDiff);
    -- ready to go next data?
    GN0 : GoNext port map (NextData, Ready);
    NextDataIn <= NextData
            when NextDreg /= "00000000000000000" and Ready = '1'
        else NextData - 1
            when GoPlus = '0'
        else NextData + 3
            when NextData(8 downto 7) /= "11"
        else NextData + 1;
    -- count of collatz
    NextCount <= Count + CountDiff;

    -- for renewal of ranking
    Rank0 : Rank port map (
        Data, Dmax, NextCount,
        R1,  R2,  R3,  R4,  T1,  T2,  T3,  T4,  L1,  L2,  L3,  L4 ,
        RI1, RI2, RI3, RI4, TI1, TI2, TI3, TI4, LI1, LI2, LI3, LI4);
    
end RTL;