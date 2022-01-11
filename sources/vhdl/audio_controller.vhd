library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity audio_controller is
    Port (
        clk : in std_logic;
        reset_n: in std_logic;
        audio_out_gun : out std_logic;
        audio_out_vest : out std_logic;
        trigger: in std_logic_vector (2 downto 0)
    );

end audio_controller;


architecture Behavioral of audio_controller is
    constant frequency: integer := 2268;
   -- constant ban_const: integer := 191160;  --largest ban limitation number of 191160  flawless_victory.raw

    signal cnt_audio: integer range 0 to frequency;  
  --  signal cnt_ban_trigger: integer range 0 to ban_const; 
    signal pwm_duty_cycle_gun: unsigned(7 downto 0) := (others => '0');
    signal pwm_duty_cycle_vest: unsigned(7 downto 0) := (others => '0');
    
    signal enable_sound_gun: std_logic := '0';
    signal enable_sound_vest: std_logic := '0';
    
    constant ADDR_SIZE: integer := 19;
    
    signal sound_data_gun: std_logic_vector(7 downto 0);
    signal sound_data_vest: std_logic_vector(7 downto 0);
    signal sound_addr_gun: std_logic_vector(ADDR_SIZE-1 downto 0);
    signal sound_addr_vest: std_logic_vector(ADDR_SIZE-1 downto 0);
    
    -- current sounds in memory:
    -- size    sound
    -- -------------
    -- 34792   blaster.raw
    -- 191160  flawless_victory.raw
    -- 151418  game_over.raw
    --
    -- 377370  total
    signal sound_start_gun : unsigned(ADDR_SIZE-1 downto 0);
    signal sound_end_gun   : unsigned(ADDR_SIZE-1 downto 0);
    signal sound_start_half: unsigned(ADDR_SIZE-1 downto 0);
    signal sound_end_half  : unsigned(ADDR_SIZE-1 downto 0);
    signal sound_start_full: unsigned(ADDR_SIZE-1 downto 0);
    signal sound_end_full  : unsigned(ADDR_SIZE-1 downto 0);
    signal playing_gun: std_logic := '0';
    signal playing_vest: std_logic := '0';
    
    signal gun_sound_en: std_logic := '0';
    signal half_sound_en: std_logic := '0';
    signal full_sound_en: std_logic := '0';
   
    
    signal trigger_sig:  std_logic_vector(2 downto 0) := "000";
    signal last_trigger: std_logic_vector(2 downto 0) := "000";

    component blaster_sound_mem
    port (
        clka  : IN STD_LOGIC;
        ena   : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb  : IN STD_LOGIC;
        enb   : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    end component blaster_sound_mem;

    component pwm
        Port (
            clk : in std_logic;
            reset_n: in std_logic;  
            duty_cycle : in unsigned (7 downto 0);
            pwm_out : out std_logic     
        );
    end component pwm;

begin

process(clk, reset_n)begin
    if reset_n = '0' then
        trigger_sig <= "000";
    elsif rising_edge(clk) then
            trigger_sig <= trigger;
    end if;
end process;

--select the kind of sound by trigger_sig
process(clk, reset_n, trigger_sig, playing_gun)begin
    if reset_n = '0' then
        gun_sound_en <= '0';
    elsif rising_edge(clk) then
        if trigger_sig = "001" then
            gun_sound_en <= '1';
        elsif playing_gun = '0' and playing_gun = '0' then
            gun_sound_en <= '0';
        end if;
    end if;
end process;

process(clk, reset_n, trigger_sig, playing_vest)begin
    if reset_n = '0' then
        half_sound_en <= '0';
    elsif rising_edge(clk) then
        if trigger_sig = "010" then
            half_sound_en <= '1';
        elsif trigger_sig = "000" and playing_vest = '0' then
            half_sound_en <= '0';
        end if;
    end if;                
end process;

process(clk, reset_n, trigger_sig, playing_vest)begin
    if reset_n = '0' then
        full_sound_en <= '0';
    elsif rising_edge(clk) then
        if trigger_sig = "100" then
            full_sound_en <= '1';
        elsif trigger_sig = "000" and playing_vest = '0' then
            full_sound_en <= '0';
        end if;
    end if;               
end process;

            
sound_start_gun  <= to_unsigned(0, ADDR_SIZE);
sound_end_gun    <= to_unsigned(34792, ADDR_SIZE);
sound_start_half <= to_unsigned(34792, ADDR_SIZE);
sound_end_half   <= to_unsigned(225952, ADDR_SIZE);
sound_start_full <= to_unsigned(225952, ADDR_SIZE);
sound_end_full   <= to_unsigned(377370, ADDR_SIZE);

--output pwm signal
    pwm_ctrl_gun: pwm
        port map(
            clk => clk,
            reset_n => reset_n,
            duty_cycle => pwm_duty_cycle_gun,
            pwm_out => audio_out_gun
        );
        
     pwm_ctrl_vest: pwm
        port map(
            clk => clk,
            reset_n => reset_n,
            duty_cycle => pwm_duty_cycle_vest,
            pwm_out => audio_out_vest
        );
        
--BRAM of sound file  
    blaster_sound: blaster_sound_mem
        port map(
            clka  => clk,
            ena   => enable_sound_gun,
            addra => sound_addr_gun,
            douta => sound_data_gun,
            clkb  => clk,
            enb   => enable_sound_vest,
            addrb => sound_addr_vest,
            doutb => sound_data_vest
        );

--decide on the pwm_duty_cycle by the sound_data from BRAM
    pwm_duty_cycle_gun <= unsigned(sound_data_gun) when playing_gun = '1' else
                      "00000000";
    pwm_duty_cycle_vest <= unsigned(sound_data_vest) when playing_vest = '1' else
                      "00000000";

--enable the BRAM reading when playing = '1'
process(clk, reset_n)begin
    if reset_n = '0' then
        enable_sound_gun <= '0';
    elsif rising_edge(clk) then
        if playing_gun = '1' then
            enable_sound_gun <= '1';
        else 
            enable_sound_gun <= '0';
        end if;
    end if;
end process;

process(clk, reset_n)begin
    if reset_n = '0' then
        enable_sound_vest <= '0';
    elsif rising_edge(clk) then
        if playing_vest = '1' then
            enable_sound_vest <= '1';
        else 
            enable_sound_vest <= '0';
        end if;
    end if;
end process;

--cnt for the BRAM read addr plus 1
process(clk, reset_n)begin
    if reset_n = '0' then
        cnt_audio <= 0;
    elsif rising_edge(clk) then
        if gun_sound_en = '1' or half_sound_en = '1' or full_sound_en = '1' then
            if cnt_audio = frequency then
                cnt_audio <= 0;
            else 
                cnt_audio <= cnt_audio + 1;
            end if;
        else 
             cnt_audio <= 0;
        end if;
    end if;
end process;

--control the next_addr and next_playing to control the addr from start arrd to end addr and sound playing flag
process(clk, reset_n, sound_addr_gun, trigger, cnt_audio, sound_start_gun, sound_end_gun)
    variable next_addr: unsigned(ADDR_SIZE-1 downto 0);
    variable next_playing: std_logic;
begin
    if reset_n = '0' then
        next_addr := to_unsigned(0, ADDR_SIZE);
        next_playing := '0';
    elsif rising_edge(clk) then
        -- handle trigger
--        if trigger_sig = "001"  and last_trigger = "000" then
        if trigger_sig = "001" then
            next_addr := sound_start_gun;
            next_playing := '1';
        end if;
 --       last_trigger <= trigger_sig;
        
        -- audio player
        if cnt_audio = frequency then
            next_addr := unsigned(sound_addr_gun) + 1;
            if next_addr >= sound_end_gun then
                next_addr := to_unsigned(0, ADDR_SIZE);
                next_playing := '0';
            end if;
        end if;
        playing_gun <= next_playing;
        sound_addr_gun <= std_logic_vector(next_addr);
    end if;  
end process;

process(clk, reset_n, sound_addr_vest, trigger, cnt_audio, sound_start_half, sound_end_half, sound_start_full, sound_end_full, half_sound_en, full_sound_en)
    variable next_addr: unsigned(ADDR_SIZE-1 downto 0);
    variable next_playing: std_logic;
begin
    if reset_n = '0' then
        next_addr := to_unsigned(34792, ADDR_SIZE);
        next_playing := '0';
    elsif rising_edge(clk) then
        -- handle trigger
        if (trigger_sig = "100") then
            next_addr := sound_start_full;
            next_playing := '1';
        elsif (trigger_sig = "010") then
            next_addr := sound_start_half;
            next_playing := '1';
        end if;
 --       last_trigger <= trigger_sig;
        
        -- audio player
        if cnt_audio = frequency then
            next_addr := unsigned(sound_addr_vest) + 1;
            if full_sound_en = '1' and next_addr >= sound_end_full then
                next_addr := to_unsigned(34792, ADDR_SIZE);
                next_playing := '0';
            elsif half_sound_en = '1' and next_addr >= sound_end_half then
                next_addr := to_unsigned(34792, ADDR_SIZE);
                next_playing := '0';
            elsif full_sound_en = '0' and half_sound_en = '0' then
                next_addr := to_unsigned(34792, ADDR_SIZE);
                next_playing := '0';
            end if;
        end if;
        playing_vest <= next_playing;
        sound_addr_vest <= std_logic_vector(next_addr);
    end if;  
end process;
end Behavioral;
