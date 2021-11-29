LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library work;
USE work.types.sound;

ENTITY SecondCounterTB IS

END SecondCounterTB;

ARCHITECTURE SecondCounterTBArch OF SecondCounterTB IS

  COMPONENT audio_controller IS
     PORT (
        clk : in std_logic;
        reset_n: in std_logic;
        audio_out: out std_logic;
        sound_selector: in sound; 
        trigger: in std_logic
     );
   END COMPONENT audio_controller;

   SIGNAL Clk_tb: STD_LOGIC:='1';
   SIGNAL reset_n_tb: STD_LOGIC:='1';
   SIGNAL audio_out_tb: STD_LOGIC;
   signal sound_selector_tb: sound := victory; 
   SIGNAL trigger_tb: std_logic := '0';


BEGIN
   controller_comp:
   COMPONENT audio_controller
     PORT MAP(
        clk => Clk_tb,
        reset_n => reset_n_tb,
        audio_out => audio_out_tb,
        sound_selector => sound_selector_tb,
        trigger => trigger_tb
     );


   clk_proc:
   PROCESS
   BEGIN
      WAIT FOR 25 ns;
      Clk_tb <= NOT(Clk_tb);
   END PROCESS clk_proc;
   
   trigger_proc:
   process
   begin
      wait for 500 us;
      trigger_tb <= not(trigger_tb);
   end process trigger_proc;
END SecondCounterTBArch;
