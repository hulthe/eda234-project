LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hit_detector_tb IS

END hit_detector_tb;

ARCHITECTURE Behabiour OF hit_detector_tb IS

COMPONENT hit_detector IS
     PORT (
        clk_100M 	 : in std_logic;
		reset_n	 	 : in std_logic;
		half_detector: in std_logic; 
		full_detector: in std_logic;
		half_shot    : out std_logic;
		full_shot 	 : out std_logic 
     );
   END COMPONENT hit_detector;

signal clk_100M_tb 		: STD_LOGIC:='0';
signal reset_n_tb 		: STD_LOGIC:='0';
signal half_detector_tb : STD_LOGIC:='1';
signal full_detector_tb : STD_LOGIC:='1';
signal half_shot_tb 	: STD_LOGIC:='0';
signal full_shot_tb 	: STD_LOGIC:='0';

begin

controller_comp:
   COMPONENT hit_detector
     PORT MAP(
        clk_100M 	 =>	clk_100M_tb 	,
		reset_n	 	 => reset_n_tb 		,
		half_detector=> half_detector_tb, 
		full_detector=> full_detector_tb, 
		half_shot    => half_shot_tb 	,
		full_shot 	 => full_shot_tb 	
     );

	clk_proc:
	PROCESS
	BEGIN
      WAIT FOR 5 ns;
      clk_100M_tb <= NOT(clk_100M_tb);
	END PROCESS clk_proc;
	
	reset_proc:
	PROCESS
	BEGIN
		WAIT FOR 15 ns;
		reset_n_tb <= '1';
	END PROCESS reset_proc;
	
	detector_proc:
	PROCESS
	BEGIN
		WAIT FOR 25 ns;
			half_detector_tb <= '0';
			full_detector_tb <= '1';
		wait for 10 ns;
			half_detector_tb <= '1';
			full_detector_tb <= '0';
		wait for 10 ns;
			half_detector_tb <= '1';
			full_detector_tb <= '1';
	END PROCESS detector_proc;


END Behabiour;