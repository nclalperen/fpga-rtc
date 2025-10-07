library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- numeric_std tavsiye edilir

entity ClockDivider_1kHz is
    Port (
        clk_100M : in  std_logic;  -- 100 MHz giriþ clock
        reset    : in  std_logic;  -- Senkron reset
        clk_1kHz : out std_logic   -- 1 kHz çýkýþ clock
    );
end ClockDivider_1kHz;

architecture Behavioral_1kHz of ClockDivider_1kHz is

    -- 100 MHz --> 1 kHz için saymamýz gereken deðer: 100_000
    -- 0'dan 99_999'a kadar sayýyoruz.
    constant C_MAX_COUNT_1kHz : unsigned(16 downto 0) := to_unsigned(100000 - 1, 17);

    signal count_reg : unsigned(16 downto 0) := (others => '0');
    signal clk_out   : std_logic := '0';

begin
    process(clk_100M, reset)
    begin
        if reset = '1' then
            count_reg <= (others => '0');
            clk_out   <= '0';
        elsif rising_edge(clk_100M) then
            if count_reg = C_MAX_COUNT_1kHz then
                count_reg <= (others => '0');
                clk_out   <= not clk_out;  -- Her 100.000 darbe sonunda toggle
            else
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;

    clk_1kHz <= clk_out;

end Behavioral_1kHz;