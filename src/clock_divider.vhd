library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- numeric_std tavsiye edilir

entity ClockDivider is
    Port (
        clk_100M : in  std_logic;  -- 100 MHz saat giriþi
        reset    : in  std_logic;  -- Senkron reset
        clk_1Hz  : out std_logic   -- 1 Hz saat çýkýþý
    );
end ClockDivider;

architecture Behavioral of ClockDivider is

    -- 100 MHz --> 1 Hz için saymamýz gereken deðer: 100_000_000
    -- Bu deðer 1 sn'de 100 milyon darbe anlamýna gelir.
    constant C_MAX_COUNT : unsigned(26 downto 0) := to_unsigned(100000000 - 1, 27); 
    -- 2^27 = 134217728, 100000000 < 2^27, o yüzden 27 bit yeter.

    signal count_reg : unsigned(26 downto 0) := (others => '0');
    signal clk_out   : std_logic := '0';

begin

    process(clk_100M, reset)
    begin
        if reset = '1' then
            count_reg <= (others => '0');
            clk_out   <= '0';

        elsif rising_edge(clk_100M) then
            if count_reg = C_MAX_COUNT then
                count_reg <= (others => '0');
                clk_out   <= not clk_out;  -- Her 100 milyon darbe sonunda toggle
            else
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;

    -- Çýkýþ clock_1Hz sinyalini atayalým
    clk_1Hz <= clk_out;

end Behavioral;