LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SecondCounterTB IS

END SecondCounterTB;

ARCHITECTURE SecondCounterTBArch OF SecondCounterTB IS

  COMPONENT audio_controller IS
     PORT (
        clk : in std_logic;
        reset_n: in std_logic;
        audio_out : out std_logic
    
     );
   END COMPONENT audio_controller;

   SIGNAL Clk_tb: STD_LOGIC:='1';
   SIGNAL reset_n_tb: STD_LOGIC:='1';
   SIGNAL audio_out_tb: STD_LOGIC;


BEGIN
   controller_comp:
   COMPONENT audio_controller
     PORT MAP(
        clk => Clk_tb,
        reset_n => reset_n_tb,
        audio_out => audio_out_tb
     );


   clk_proc:
   PROCESS
   BEGIN
      WAIT FOR 25 ns;
      Clk_tb <= NOT(Clk_tb);
   END PROCESS clk_proc;
END SecondCounterTBArch;
