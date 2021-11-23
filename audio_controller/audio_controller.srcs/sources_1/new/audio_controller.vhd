library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    
    signal blaster_sound_data: std_logic_vector(7 downto 0);
    signal blaster_sound_addr: std_logic_vector(15 downto 0);
    
    constant sound_length: unsigned(15 downto 0) := to_unsigned(34792, 16);
    signal playing: std_logic := '0';

    component blaster_sound_mem
    port (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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
            addra => blaster_sound_addr,
            douta => blaster_sound_data
        );

    pwm_duty_cycle <= unsigned(blaster_sound_data) when playing = '1' else
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

process(clk, reset_n, blaster_sound_addr, trigger, cnt_audio)
    variable next_addr: unsigned(15 downto 0);
    variable next_playing: std_logic;
begin
    if rising_edge(trigger) then
        next_addr := "0000000000000000";
        next_playing := '1';
    end if;

    if reset_n = '0' then
        next_addr := "0000000000000000";
        next_playing := '0';
    elsif rising_edge(clk) then
        if cnt_audio = frequency then
            next_addr := unsigned(blaster_sound_addr) + 1;
            if next_addr >= sound_length then
                next_addr := to_unsigned(0, 16);
                next_playing := '0';
            end if;
        end if;
    end if;
    playing <= next_playing;
    blaster_sound_addr <= std_logic_vector(next_addr);
end process;
end Behavioral;
