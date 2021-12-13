LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY seg_controller_tb IS

END seg_controller_tb;

ARCHITECTURE Behavioral OF seg_controller_tb IS

	COMPONENT seg_controller IS
		GENERIC (
			CLK_FREQ   : INTEGER := 100000000; -- hz
			PULSE_FREQ : INTEGER := 50 --hz		
		);
		PORT (
			clk  : IN  STD_LOGIC;
			code : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
			seg  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			an   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT seg_controller;

	SIGNAL CLK_tb  : STD_LOGIC                    := '1';
	SIGNAL code_tb : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
	SIGNAL SEG_tb  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL AN_tb   : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

	seg_controller_comp : seg_controller
	GENERIC MAP(
		CLK_FREQ   => 100, -- hz		
		PULSE_FREQ => 20
	)
	PORT MAP
	(
		clk  => CLK_tb,
		code => code_tb,
		seg  => SEG_tb,
		an   => AN_tb
	);

	clk_proc :
	PROCESS
	BEGIN
		WAIT FOR 5 ns;
		CLK_tb <= NOT(CLK_tb);
	END PROCESS clk_proc;

END Behavioral;
