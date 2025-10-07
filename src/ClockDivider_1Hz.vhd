library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- numeric_std tavsiye edilir

entity ClockDivider_1Hz is
    Port (
        clk_100M : in  std_logic;  -- 100 MHz giriþ clock
        reset    : in  std_logic;  -- Senkron reset
        clk_1Hz  : out std_logic   -- 1 Hz çýkýþ clock
    );
end ClockDivider_1Hz;

architecture Behavioral_1Hz of ClockDivider_1Hz is

    -- 100 MHz --> 1 Hz için saymamýz gereken deðer: 100_000_000
    -- 0'dan 99_999_999'a kadar saymak için 27 bit yeter (2^27 = 134217728).
    constant C_MAX_COUNT_1Hz : unsigned(26 downto 0) := to_unsigned(100000000 - 1, 27);

    signal count_reg : unsigned(26 downto 0) := (others => '0');
    signal clk_out   : std_logic := '0';

begin
    process(clk_100M, reset)
    begin
        if reset = '1' then
            count_reg <= (others => '0');
            clk_out   <= '0';
        elsif rising_edge(clk_100M) then
            if count_reg = C_MAX_COUNT_1Hz then
                count_reg <= (others => '0');
                clk_out   <= not clk_out;  -- 100 milyon darbe sonunda toggle
            else
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;

    clk_1Hz <= clk_out;

end Behavioral_1Hz;