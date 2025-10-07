library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- numeric_std tavsiye edilir

entity RTC_7Seg is
    Port (
        clk_100M : in  std_logic;               -- 100 MHz sistem saati
        reset    : in  std_logic;               -- Senkron reset
        BTNC     : in  std_logic;
        BTNU     : in  std_logic;
        BTNL     : in  std_logic; 
        BTND     : in  std_logic;
        LED      : out std_logic_vector (3 downto 0);
        SW : in std_logic_vector(15 downto 0);
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;  -- 7 segment + nokta
        AN : out std_logic_vector(7 downto 0)            -- Anot seçiciler (8 basamak)
    );
end RTC_7Seg;

architecture Behavioral of RTC_7Seg is

    ----------------------------------------------------------------------------
    -- Bileþen Ýlanlarý (clock divider'lar)
    ----------------------------------------------------------------------------
    component ClockDivider_1Hz is
        Port (
            clk_100M : in  std_logic;
            reset    : in  std_logic;
            clk_1Hz  : out std_logic
        );
    end component;

    component ClockDivider_1kHz is
        Port (
            clk_100M : in  std_logic;
            reset    : in  std_logic;
            clk_1kHz : out std_logic
        );
    end component;

    ----------------------------------------------------------------------------
    -- Dahili Sinyaller
    ----------------------------------------------------------------------------
    signal clk_1Hz  : std_logic := '0';  -- RTC güncelleme için
    signal clk_1kHz : std_logic := '0';  -- 7-seg multiplexing için

    -- Zaman sayacý
    signal seconds : integer := 0;
    signal minutes : integer := 0;
    signal hours   : integer := 0;

    -- Multiplexing
    signal current_digit : integer := 0;  -- 0..5 arasý (HH:MM:SS) basamak seçimi
    -- (Ýstenirse 6..7 ekrana baþka þey yazmak mümkün, ama þu an 6 basamak kullanýyoruz.)

    -- 7-segment kodlama
    signal seg_code    : std_logic_vector(6 downto 0);  -- g,f,e,d,c,b,a
    signal digit_value : integer := 0;                  -- 0..9
    
    type State_Type is (IDLE, LED1_U, LED1_L, LED1_C, LED1_D,
                        LED2_U, LED2_L, LED2_C, LED2_D,
                        LED3_U, LED3_L, LED3_C, LED3_D,
                        LED4_U, LED4_L, LED4_C, LED4_D);
    signal current_state : State_Type;

    signal button_pressed : std_logic; -- Herhangi bir butonun basýldýðýný gösterir

begin

    ----------------------------------------------------------------------------
    -- 1) Clock Dividerlar: 1 Hz ve 1 kHz üretimi
    ----------------------------------------------------------------------------
    U_ClkDiv1Hz: ClockDivider_1Hz
        port map (
            clk_100M => clk_100M,
            reset    => reset,
            clk_1Hz  => clk_1Hz
        );

    U_ClkDiv1kHz: ClockDivider_1kHz
        port map (
            clk_100M => clk_100M,
            reset    => reset,
            clk_1kHz => clk_1kHz
        );

    ----------------------------------------------------------------------------
    -- 2) RTC (saniye / dakika / saat) güncellemesi -> 1 Hz clock ile
    ----------------------------------------------------------------------------
    process(clk_1kHz)
    begin
        if rising_edge(clk_1kHz) then
            if reset = '1' then
                current_state <= IDLE;
                LED <= "0000";
            else
                case current_state is
                    -- LED 1 için sýrayla: U -> L -> C -> D
                    when IDLE =>
                        LED <= "0000";
                        if BTNU = '1' then
                            current_state <= LED1_U;
                        end if;
                    when LED1_U =>
                        if BTNL = '1' then
                            current_state <= LED1_L;
                        end if;
                    when LED1_L =>
                        if BTNC = '1' then
                            current_state <= LED1_C;
                        end if;
                    when LED1_C =>
                        if BTND = '1' then
                            current_state <= LED1_D;
                            LED <= "0001"; -- LED1 aktif
                        end if;

                    -- LED 2 için sýrayla: U -> L -> C -> D
                    when LED1_D =>
                        if BTNU = '1' then
                            current_state <= LED2_U;
                        end if;
                    when LED2_U =>
                        if BTNL = '1' then
                            current_state <= LED2_L;
                        end if;
                    when LED2_L =>
                        if BTNC = '1' then
                            current_state <= LED2_C;
                        end if;
                    when LED2_C =>
                        if BTND = '1' then
                            current_state <= LED2_D;
                            LED <= "0011"; -- LED2 aktif
                        end if;
                        
                    when LED2_D =>
                        if BTNU = '1' then
                            current_state <= LED3_U;
                        end if;
                    when LED3_U =>
                        if BTNL = '1' then
                            current_state <= LED3_L;
                        end if;
                    when LED3_L =>
                        if BTNC = '1' then
                            current_state <= LED3_C;
                        end if;
                    when LED3_C =>
                        if BTND = '1' then
                            current_state <= LED3_D;
                            LED <= "0111"; -- LED2 aktif
                        end if;
                    
                    when LED3_D =>
                        if BTNU = '1' then
                            current_state <= LED4_U;
                        end if;
                    when LED4_U =>
                        if BTNL = '1' then
                            current_state <= LED4_L;
                        end if;
                    when LED4_L =>
                        if BTNC = '1' then
                            current_state <= LED4_C;
                        end if;
                    when LED4_C =>
                        if BTND = '1' then
                            LED <= "1111"; -- LED4 aktif
                        end if;
                    
                    when others =>
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
    process(clk_1Hz)
    begin
    if (SW = x"8888") then
        if rising_edge(clk_1Hz) then
            if reset = '1' then
                seconds <= 0;
                minutes <= 0;
                hours   <= 0;
            else
                -- Saniye Güncelle
                if seconds = 59 then
                    seconds <= 0;
                    -- Dakika Güncelle
                    if minutes = 59 then
                        minutes <= 0;
                        -- Saat Güncelle
                        if hours = 9 then
                            seconds <= 0;
                            minutes <= 0;
                            hours   <= 0;
                        else
                            hours <= hours + 1;
                        end if;
                    else
                        minutes <= minutes + 1;
                    end if;
                else
                    seconds <= seconds + 1;
                end if;
            end if;
        end if;
    end if;    
    end process;

    ----------------------------------------------------------------------------
    -- 3) 7-Segment Multiplexing -> 1 kHz clock ile (yaklaþýk her 1 ms)
    ----------------------------------------------------------------------------
    process(clk_1kHz)
    begin
        if rising_edge(clk_1kHz) then
            if reset = '1' then
                current_digit <= 0;
            else
                -- 6 basamak dönecek þekilde (0..5), sonra baþa dön
                if current_digit = 5 then
                    current_digit <= 0;
                else
                    current_digit <= current_digit + 1;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- 4) Aktif Basamaðý Seç + 7-Segment Kodlama (Kombinasyonel Mantýk)
    ----------------------------------------------------------------------------
    process(current_digit, hours, minutes, seconds)
    begin
        ---------------------------
        -- A) Hangi basamak aktif?
        ---------------------------
        case current_digit is
    when 5 =>  -- SAAT ONLAR (en sol)
        digit_value <= hours / 10;
        AN <= "01111111";  

    when 4 =>  -- SAAT BÝRLER
        digit_value <= hours mod 10;
        AN <= "10111111";

    when 3 =>  -- DAK ONLAR
        digit_value <= minutes / 10;
        AN <= "11011111";

    when 2 =>  -- DAK BÝRLER
        digit_value <= minutes mod 10;
        AN <= "11101111";

    when 1 =>  -- SAN ONLAR
        digit_value <= seconds / 10;
        AN <= "11110111";

    when 0 =>  -- SAN BÝRLER (en sað)
        digit_value <= seconds mod 10;
        AN <= "11111011";

    when others =>
        digit_value <= 0;
        AN <= "11111111"; -- hepsini kapat
    end case;

        ---------------------------
        -- B) 7-Segment Kodlama
        --    Sýralama: (g f e d c b a)
        ---------------------------
        case digit_value is
            when 0 => seg_code <= "0000001";
            when 1 => seg_code <= "1001111";
            when 2 => seg_code <= "0010010";
            when 3 => seg_code <= "0000110";
            when 4 => seg_code <= "1001100";
            when 5 => seg_code <= "0100100";
            when 6 => seg_code <= "0100000";
            when 7 => seg_code <= "0001111";
            when 8 => seg_code <= "0000000";
            when 9 => seg_code <= "0000100";
            when others =>
                seg_code <= "0000000";  -- Kapalý
        end case;
    end process;

    ----------------------------------------------------------------------------
    -- 5) Segment Çýkýþlarýný Baðlama
    ----------------------------------------------------------------------------
    CA <= seg_code(6);
    CB <= seg_code(5);
    CC <= seg_code(4);
    CD <= seg_code(3);
    CE <= seg_code(2);
    CF <= seg_code(1);
    CG <= seg_code(0);
    DP <= '1'; -- Ondalýk nokta pasif (her zaman kapalý)

end Behavioral;