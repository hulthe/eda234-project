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
        trigger: in std_logic_vector (2 downto 0)
    );

end audio_controller;


architecture Behavioral of audio_controller is
    constant frequency: integer := 2268;
   -- constant ban_const: integer := 191160;  --largest ban limitation number of 191160  flawless_victory.raw

    signal cnt_audio: integer range 0 to frequency;  
  --  signal cnt_ban_trigger: integer range 0 to ban_const; 
    signal pwm_duty_cycle: unsigned(7 downto 0) := (others => '0');
    
    signal enable_sound: std_logic := '0';
    
    constant ADDR_SIZE: integer := 19;
    
    -- TODO: move this to a port
    signal sound_selector: sound;
    
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
    
    signal trigger_sig:  std_logic_vector(2 downto 0) := "000";
    signal last_trigger: std_logic_vector(2 downto 0) := "000";

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

process(clk, reset_n)begin
    if reset_n = '0' then
        trigger_sig <= "000";
    elsif rising_edge(clk) then
        if playing = '0' then    --playing = '0' means the speaker is not displaying to make sure not new trigger signal interupt the displaying trigger signal
            trigger_sig <= trigger;
        end if;
    end if;
end process;

--select the kind of sound by trigger_sig
     with trigger_sig select
        sound_selector <= blaster when "001",
                          victory when "010",
                          game_over when "100",
                          game_over when others;

--select the sound start addr by sound_selector
    with sound_selector select
        sound_start <=
            to_unsigned(0, ADDR_SIZE) when blaster,
            to_unsigned(34792, ADDR_SIZE) when victory,
            to_unsigned(225952, ADDR_SIZE) when game_over;
            
--select the sound end addr by sound_selector
    with sound_selector select
        sound_end <=
            to_unsigned(34792, ADDR_SIZE) when blaster,
            to_unsigned(225952, ADDR_SIZE) when victory,
            to_unsigned(377370, ADDR_SIZE) when game_over;

--output pwm signal
    pwm_ctrl: pwm
        port map(
            clk => clk,
            reset_n => reset_n,
            duty_cycle => pwm_duty_cycle,
            pwm_out => audio_out
        );
        
--BRAM of sound file  
    blaster_sound: blaster_sound_mem
        port map(
            clka => clk,
            ena => enable_sound,
            addra => sound_addr,
            douta => sound_data
        );

--decide on the pwm_duty_cycle by the sound_data from BRAM
    pwm_duty_cycle <= unsigned(sound_data) when playing = '1' else
                      "00000000";

--enable the BRAM reading when playing = '1'
process(clk, reset_n)begin
    if reset_n = '0' then
        enable_sound <= '0';
    elsif rising_edge(clk) then
        if playing = '1' then
            enable_sound <= '1';
        else 
            enable_sound <= '0';
        end if;
    end if;
end process;

--cnt for the BRAM read addr plus 1
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

--control the next_addr and next_playing to control the addr from start arrd to end addr and sound playing flag
process(clk, reset_n, sound_addr, trigger, cnt_audio)
    variable next_addr: unsigned(ADDR_SIZE-1 downto 0);
    variable next_playing: std_logic;
begin
    if reset_n = '0' then
        next_addr := to_unsigned(0, ADDR_SIZE);
        next_playing := '0';
    elsif rising_edge(clk) then
        -- handle trigger
        if (trigger_sig = "001" or trigger_sig = "010" or trigger_sig = "100") and last_trigger = "000" then
            next_addr := SOUND_START;
            next_playing := '1';
        end if;
        last_trigger <= trigger_sig;
        
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
