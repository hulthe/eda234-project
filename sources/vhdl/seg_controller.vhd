----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 03:00:54 PM
-- Design Name: 
-- Module Name: seg_controller - Behavioral
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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY seg_controller IS
	GENERIC (
		CLK_FREQ : INTEGER := 100000000; -- hz
		PULSE_FREQ : INTEGER := 1000 --hz		
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
END seg_controller;

ARCHITECTURE Behavioral OF seg_controller IS

	SIGNAL display_selector : UNSIGNED(2 DOWNTO 0) := "000";
	SIGNAL clk_cycles : INTEGER := 0;

BEGIN

	pulse_process :
	PROCESS (clk)
		
	BEGIN
		IF rising_edge(clk) THEN

			IF (clk_cycles + 1) = (CLK_FREQ/PULSE_FREQ) THEN
			
			     IF display_selector = "111" THEN
				    display_selector <= (others=>'0');
				 ELSE
				    display_selector <= display_selector + 1;
				 END IF;
				 
				 clk_cycles <= 0;
			ELSE
				clk_cycles <= clk_cycles + 1;
			END IF;
		END IF;
	END PROCESS pulse_process;

	display_process :
	PROCESS (clk, display_selector)
	BEGIN
		CASE display_selector IS
			WHEN "000" =>
				AN <= "11111110";
				SEG <= seg1;
			WHEN "001" =>
				AN <= "11111101";
				SEG <= seg2;
			WHEN "010" =>
				AN <= "11111011";
				SEG <= seg3;
			WHEN "011" =>
				AN <= "11110111";
				SEG <= seg4;
			WHEN "100" =>
			    AN <= "11101111";
			    SEG <= seg5;				
			WHEN "101" =>
			    AN <= "11011111";
				SEG <= seg6;				
			WHEN "110" =>
			    AN <= "10111111";
				SEG <= seg7;
			WHEN "111" =>
			    AN <= "01111111";
				SEG <= seg8;
			WHEN OTHERS =>
				AN <= "11111111";
				SEG <= "10000110"; -- Error	
		END CASE;	

	END PROCESS display_process;

END Behavioral;
