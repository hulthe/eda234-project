-----------------------------------------------------
-- Title: seg_controller.vhdl
-- Author: Rafael Romon
-----------------------------------------------------
-- Description:
-- 7 segment controller, simplifies displaying menus
-- and values on the inboard 7 segment displays
-----------------------------------------------------

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
		code: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	
		input: IN STD_LOGIC_VECTOR(10 DOWNTO 0);	
		seg : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		an : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END seg_controller;

ARCHITECTURE Behavioral OF seg_controller IS

    SIGNAL seg1 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL seg2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL seg3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL seg4 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL seg5 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL seg6 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL seg7 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL seg8 : STD_LOGIC_VECTOR (7 DOWNTO 0);

	SIGNAL display_selector : UNSIGNED(2 DOWNTO 0) := "000";
	SIGNAL clk_cycles : INTEGER := 0;	
    
    SIGNAL char_A : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10001000";    
    SIGNAL char_D : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10100001";
    SIGNAL char_E : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10000110";
    SIGNAL char_H : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10001001";
    SIGNAL char_I : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111001";    
    SIGNAL char_L : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11000111";
    SIGNAL char_P : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10001100";
    SIGNAL char_r : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11001100";
    SIGNAL char_S : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10010010";
    SIGNAL char_t : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10000111";
    SIGNAL char_Y : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10010001";
    
    SIGNAL num_0 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11000000";
    SIGNAL num_1 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111001";
    SIGNAL num_2 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10100100";
    SIGNAL num_3 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10110000";
    SIGNAL num_4 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10011001";
    SIGNAL num_5 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10010010";
    SIGNAL num_6 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10000010";
    SIGNAL num_7 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111000";
    SIGNAL num_8 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10000000";
    SIGNAL num_9 : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10010000";
    
    
    SIGNAL char_dot : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01111111";
    SIGNAL char_slash : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10111111";        
    SIGNAL char_off : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111111";        
    
BEGIN
    
    -- generates a pulse to switch between displays
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
	
	-- sets each 7seg display according to the input code
	code_process :
	PROCESS (code)        
	BEGIN
		CASE code IS
			WHEN "000" => -- off 
                seg8 <= char_off;
                seg7 <= char_off;
                seg6 <= char_off;
                seg5 <= char_off;
                seg4 <= char_off;
                seg3 <= char_off;
                seg2 <= char_off;
                seg1 <= char_off;
                
            WHEN "001" => -- Start.
                seg8 <= char_S; -- S
                seg7 <= char_t; -- t
                seg6 <= char_A; -- A
                seg5 <= char_r; -- r
                seg4 <= char_t; -- t
                seg3 <= char_dot; -- .
                seg2 <= char_off;
                seg1 <= char_off;
                
			WHEN "010" => -- Player.
                seg8 <= char_P; -- P
                seg7 <= char_L; -- L
                seg6 <= char_A; -- A
                seg5 <= char_Y; -- Y
                seg4 <= char_E; -- E
                seg3 <= char_r; -- r               
                
                CASE input(3 DOWNTO 0) IS
                  WHEN "0000" => -- 1 
                    seg2 <= num_0;
                    seg1 <= num_1;
                  WHEN "0001" => -- 2
                    seg2 <= num_0; 
                    seg1 <= num_2;
                  WHEN "0010" => -- 3
                    seg2 <= num_0; 
                    seg1 <= num_3;
                  WHEN "0011" => -- 4
                    seg2 <= num_0; 
                    seg1 <= num_4;
                  WHEN "0100" => -- 5
                    seg2 <= num_0; 
                    seg1 <= num_5;
                  WHEN "0101" => -- 6
                    seg2 <= num_0; 
                    seg1 <= num_6;
                  WHEN "0110" => -- 7 
                    seg2 <= num_0; 
                    seg1 <= num_7;
                  WHEN "0111" => -- 8
                    seg2 <= num_0; 
                    seg1 <= num_8;
                  WHEN "1000" => -- 9
                    seg2 <= num_0;  
                    seg1 <= num_9;
                  WHEN "1001" => -- 10
                    seg2 <= num_1;  
                    seg1 <= num_0;
                  WHEN "1010" => -- 11
                    seg2 <= num_1;  
                    seg1 <= num_1;
                  WHEN "1011" => -- 12
                    seg2 <= num_1;  
                    seg1 <= num_2;
                  WHEN "1100" => -- 13
                    seg2 <= num_1;  
                    seg1 <= num_3;
                  WHEN "1101" => -- 14
                    seg2 <= num_1;  
                    seg1 <= num_4;
                  WHEN "1110" => -- 15
                    seg2 <= num_1;  
                    seg1 <= num_5;
                  WHEN "1111" => -- 16
                    seg2 <= num_1;  
                    seg1 <= num_6;                                
                  WHEN OTHERS => seg1 <= char_E; -- Error
                END CASE;
            WHEN "011" => -- Play
                seg8 <= char_P; -- P
                seg7 <= char_L; -- L
                seg6 <= char_A; -- A
                seg5 <= char_Y; -- Y
                seg4 <= char_slash; -- -                
                seg3 <= char_H; -- H               
                seg2 <= char_P; -- P                
                
                CASE input(3 DOWNTO 0) IS
                  WHEN "0001" => -- 1 
                    seg1 <= num_1;
                  WHEN "0010" => -- 2 
                    seg1 <= num_2;
                  WHEN "0011" => -- 3 
                    seg1 <= num_3;
                  WHEN "0100" => -- 4 
                    seg1 <= num_4;
                  WHEN "0101" => -- 5 
                    seg1 <= num_5;
                  WHEN "0110" => -- 6 
                    seg1 <= num_6;
                  WHEN "0111" => -- 7                     
                    seg1 <= num_7;
                  WHEN "1000" => -- 8                     
                    seg1 <= num_8;                                                     
                  WHEN OTHERS => 
                  seg1 <= char_E; -- Error            
               END CASE;
               
           WHEN "101" => -- Timeout
                seg8 <= char_P; -- P
                
                CASE input(10 DOWNTO 7) IS
                  WHEN "0000" => -- 1 
                    seg7 <= num_0;
                    seg6 <= num_1;
                  WHEN "0001" => -- 2
                    seg7 <= num_0; 
                    seg6 <= num_2;
                  WHEN "0010" => -- 3
                    seg7 <= num_0; 
                    seg6 <= num_3;
                  WHEN "0011" => -- 4
                    seg7 <= num_0; 
                    seg6 <= num_4;
                  WHEN "0100" => -- 5
                    seg7 <= num_0; 
                    seg6 <= num_5;
                  WHEN "0101" => -- 6
                    seg7 <= num_0; 
                    seg6 <= num_6;
                  WHEN "0110" => -- 7 
                    seg7 <= num_0; 
                    seg6 <= num_7;
                  WHEN "0111" => -- 8
                    seg7 <= num_0; 
                    seg6 <= num_8;
                  WHEN "1000" => -- 9
                    seg7 <= num_0;  
                    seg6 <= num_9;
                  WHEN "1001" => -- 10
                    seg7 <= num_1;  
                    seg6 <= num_0;
                  WHEN "1010" => -- 11
                    seg7 <= num_1;  
                    seg6 <= num_1;
                  WHEN "1011" => -- 12
                    seg7 <= num_1;  
                    seg6 <= num_2;
                  WHEN "1100" => -- 13
                    seg7 <= num_1;  
                    seg6 <= num_3;
                  WHEN "1101" => -- 14
                    seg7 <= num_1;  
                    seg6 <= num_4;
                  WHEN "1110" => -- 15
                    seg7 <= num_1;  
                    seg6 <= num_5;
                  WHEN "1111" => -- 16
                    seg7 <= num_1;  
                    seg6 <= num_6;                                
                  WHEN OTHERS =>
                    seg7 <= char_E; 
                    seg6 <= char_E; -- Error
                END CASE;
                
                
                seg5 <= char_H; -- H
                seg4 <= char_I; -- I                
                seg3 <= char_t; -- t                  
                
                CASE input(6 DOWNTO 4) IS
                  WHEN "000" => -- 0 
                    seg2 <= num_0;  
                  WHEN "001" => -- 1 
                    seg2 <= num_1;
                  WHEN "010" => -- 2 
                    seg2 <= num_2;
                  WHEN "011" => -- 3 
                    seg2 <= num_3;
                  WHEN "100" => -- 4 
                    seg2 <= num_4;
                  WHEN "101" => -- 5 
                    seg2 <= char_S;
                  WHEN "110" => -- 6 
                    seg2 <= num_6;                                            
                  WHEN OTHERS => 
                    seg2 <= char_E; -- Error            
               END CASE;    
               
               CASE input(3 DOWNTO 0) IS               
                  WHEN "0000" => -- 0 
                    seg1 <= num_0;  
                  WHEN "0001" => -- 1 
                    seg1 <= num_1;
                  WHEN "0010" => -- 2 
                    seg1 <= num_2;
                  WHEN "0011" => -- 3 
                    seg1 <= num_3;
                  WHEN "0100" => -- 4 
                    seg1 <= num_4;
                  WHEN "0101" => -- 5 
                    seg1 <= char_S;
                  WHEN "0110" => -- 6 
                    seg1 <= num_6;    
                  WHEN "0111"  => -- 7  
                    seg1 <= num_7;
                  WHEN "1000" => -- 8 
                    seg1 <= num_8;
                  WHEN "1001" => -- 9  
                    seg1 <= num_9;                                                 
                  WHEN OTHERS => 
                   seg1 <= char_E; -- Error            
               END CASE;   
           
           WHEN "100" => -- Finished            

                seg8 <= char_D; -- D
                seg7 <= char_E; -- E
                seg6 <= char_A; -- A                
                seg5 <= char_D; -- D
                seg4 <= char_dot; -- .
                seg3 <= char_off;
                seg2 <= char_off;
                seg1 <= char_off;                                           
                                        
            WHEN "111" => -- Reset.
                seg8 <= char_r; -- r
                seg7 <= char_E; -- E
                seg6 <= char_S; -- S
                seg5 <= char_E; -- E
                seg4 <= char_t; -- t
                seg3 <= char_dot; -- .
                seg2 <= char_off;
                seg1 <= char_off;      
                          
			WHEN OTHERS => -- error
				seg8 <= char_E; -- E
                seg7 <= char_r; -- r
                seg6 <= char_r; -- r
                seg5 <= num_0; -- O
                seg4 <= char_r; -- r
                seg3 <= char_dot; -- .
                seg2 <= char_off;
                seg1 <= char_off;	
		END CASE;	
	END PROCESS code_process;
    
    -- switches between the output 7 seg displays 
	display_process :
	PROCESS (clk, display_selector)
	BEGIN
		CASE display_selector IS
			WHEN "000" => -- 1st 7seg is being written to
				AN <= "11111110"; 
				SEG <= seg1;
			WHEN "001" => -- 2nd 7seg is being written to
				AN <= "11111101";
				SEG <= seg2; 
			WHEN "010" => -- 3rd 7seg is being written to
				AN <= "11111011";
				SEG <= seg3;
			WHEN "011" => -- 4th 7seg is being written to
				AN <= "11110111";
				SEG <= seg4;
			WHEN "100" => -- 5th 7seg is being written to
			    AN <= "11101111";
			    SEG <= seg5;				
			WHEN "101" => -- 6th 7seg is being written to
			    AN <= "11011111";
				SEG <= seg6;				
			WHEN "110" => -- 7th 7seg is being written to
			    AN <= "10111111";
				SEG <= seg7;
			WHEN "111" => -- 8th 7seg is being written to
			    AN <= char_dot;
				SEG <= seg8;
			WHEN OTHERS =>
				AN <= "00000000";
				SEG <= char_E; -- Error	
		END CASE;	
	END PROCESS display_process;

END Behavioral;
