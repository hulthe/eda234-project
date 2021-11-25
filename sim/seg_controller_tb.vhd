----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 03:39:32 PM
-- Design Name: 
-- Module Name: seg_controller_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seg_controller_tb is
--  Port ( );
end seg_controller_tb;

architecture Behavioral of seg_controller_tb is

COMPONENT seg_controller IS
	GENERIC (
		CLK_FREQ : INTEGER := 100000000; -- hz
		PULSE_FREQ : INTEGER := 50 --hz		
	);		
	PORT (
		clk : IN STD_LOGIC;
		seg1 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg2 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg3 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg4 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg5 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg6 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg7 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg8 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		an : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT seg_controller;
    
    SIGNAL CLK_tb : std_logic := '1';
    SIGNAL SEG_tb : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL AN_tb : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin

seg_controller_comp : seg_controller
    GENERIC MAP(
        CLK_FREQ   => 100, -- hz		
        PULSE_FREQ => 20
    )
	PORT MAP
	(		
		clk => CLK_tb,
		seg1 => "10010010",
		seg2 => "10000111",
		seg3 => "11001000",
		seg4 => "11001100",
		seg5 => "10000111",
		seg6 => "01111111",
		seg7 => "01111111",
		seg8 => "01111111",
		seg => SEG_tb,
		an => AN_tb
	);

       clk_proc :
		PROCESS
		BEGIN
			WAIT FOR 5 ns;
			CLK_tb <= NOT(CLK_tb);
		END PROCESS clk_proc;
end Behavioral;
