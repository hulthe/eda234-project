library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types.sound;

entity audio_controller is
    Port (
        clk : in std_logic;
        reset_n: in std_logic;
        audio_out : out std_logic;
        trigger: in std_logic
    );

end audio_controller;


architecture Behavioral of audio_controller is
    constant frequency: integer := 2268;

    signal cnt_audio: integer range 0 to frequency;  
    signal pwm_duty_cycle: unsigned(7 downto 0) := (others => '0');
    
    signal enable_sound: std_logic := '1';
    
    constant ADDR_SIZE: integer := 19;
    
    -- TODO: move this to a port
    signal sound_selector: sound := blaster;
    
    signal sound_data: std_logic_vector(7 downto 0);
    signal sound_addr: std_logic_vector(ADDR_SIZE-1 downto 0);
    
    -- current sounds in memory:
    -- size    sound
    -- -------------
    -- 34792   blaster.raw
    -- 191160  flawless_victory.raw
    -- 151418  game_over.raw
    --
    -- 377370  total
    signal sound_start: unsigned(ADDR_SIZE-1 downto 0);
    signal sound_end: unsigned(ADDR_SIZE-1 downto 0);
    signal playing: std_logic := '0';
    
    signal last_trigger: std_logic := '0';

    component blaster_sound_mem
    port (
        clka : in std_logic;
        ena : in std_logic;
        addra : in std_logic_vector(ADDR_SIZE-1 DOWNTO 0);
        douta : out std_logic_vector(7 DOWNTO 0)
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

    with sound_selector select
        sound_start <=
            to_unsigned(0, ADDR_SIZE) when blaster,
            to_unsigned(34792, ADDR_SIZE) when victory,
            to_unsigned(225952, ADDR_SIZE) when game_over;
    with sound_selector select
        sound_end <=
            to_unsigned(34792, ADDR_SIZE) when blaster,
            to_unsigned(225952, ADDR_SIZE) when victory,
            to_unsigned(377370, ADDR_SIZE) when game_over;

    pwm_ctrl: pwm
        port map(
            clk => clk,
            reset_n => reset_n,
            duty_cycle => pwm_duty_cycle,
            pwm_out => audio_out
        );
    
    blaster_sound: blaster_sound_mem
        port map(
            clka => clk,
            ena => enable_sound,
            addra => sound_addr,
            douta => sound_data
        );

    pwm_duty_cycle <= unsigned(sound_data) when playing = '1' else
                      "00000000";

process(clk, reset_n)begin
    if reset_n = '0' then
        cnt_audio <= 0;
    elsif rising_edge(clk) then
        if cnt_audio = frequency then
            cnt_audio <= 0;
        else 
            cnt_audio <= cnt_audio + 1;
        end if;
    end if;
end process;

process(clk, reset_n, sound_addr, trigger, cnt_audio)
    variable next_addr: unsigned(ADDR_SIZE-1 downto 0);
    variable next_playing: std_logic;
begin
    if reset_n = '0' then
        next_addr := to_unsigned(0, ADDR_SIZE);
        next_playing := '0';
    elsif rising_edge(clk) then
        -- handle trigger
        if trigger = '1' and last_trigger = '0' then
            next_addr := SOUND_START;
            next_playing := '1';
        end if;
        last_trigger <= trigger;
        
        -- audio player
        if cnt_audio = frequency then
            next_addr := unsigned(sound_addr) + 1;
            if next_addr >= SOUND_END then
                next_addr := to_unsigned(0, ADDR_SIZE);
                next_playing := '0';
            end if;
        end if;
    end if;
    playing <= next_playing;
    sound_addr <= std_logic_vector(next_addr);
end process;
end Behavioral;
