
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
	
	code_process :
	PROCESS (code)
	BEGIN
		CASE code IS
			WHEN "000" => -- off 
                seg8 <= "11111111";
                seg7 <= "11111111";
                seg6 <= "11111111";
                seg5 <= "11111111";
                seg4 <= "11111111";
                seg3 <= "11111111";
                seg2 <= "11111111";
                seg1 <= "11111111";
                
            WHEN "001" => -- Start.
                seg8 <= "10010010"; -- S
                seg7 <= "10000111"; -- t
                seg6 <= "10001000"; -- A
                seg5 <= "11001100"; -- r
                seg4 <= "10000111"; -- t
                seg3 <= "01111111"; -- .
                seg2 <= "11111111";
                seg1 <= "11111111";
                
			WHEN "010" => -- Player.
                seg8 <= "10001100"; -- P
                seg7 <= "11000111"; -- L
                seg6 <= "10001000"; -- A
                seg5 <= "10010001"; -- Y
                seg4 <= "10000110"; -- E
                seg3 <= "11001100"; -- r               
                
                CASE input(3 DOWNTO 0) IS
                  WHEN "0000" => -- 1 
                    seg2 <= "11000000";
                    seg1 <= "11111001";
                  WHEN "0001" => -- 2
                    seg2 <= "11000000"; 
                    seg1 <= "10100100";
                  WHEN "0010" => -- 3
                    seg2 <= "11000000"; 
                    seg1 <= "10110000";
                  WHEN "0011" => -- 4
                    seg2 <= "11000000"; 
                    seg1 <= "10011001";
                  WHEN "0100" => -- 5
                    seg2 <= "11000000"; 
                    seg1 <= "10010010";
                  WHEN "0101" => -- 6
                    seg2 <= "11000000"; 
                    seg1 <= "10000010";
                  WHEN "0110" => -- 7 
                    seg2 <= "11000000"; 
                    seg1 <= "11111000";
                  WHEN "0111" => -- 8
                    seg2 <= "11000000"; 
                    seg1 <= "10000000";
                  WHEN "1000" => -- 9
                    seg2 <= "11000000";  
                    seg1 <= "10010000";
                  WHEN "1001" => -- 10
                    seg2 <= "11111001";  
                    seg1 <= "11000000";
                  WHEN "1010" => -- 11
                    seg2 <= "11111001";  
                    seg1 <= "11111001";
                  WHEN "1011" => -- 12
                    seg2 <= "11111001";  
                    seg1 <= "10100100";
                  WHEN "1100" => -- 13
                    seg2 <= "11111001";  
                    seg1 <= "10110000";
                  WHEN "1101" => -- 14
                    seg2 <= "11111001";  
                    seg1 <= "10011001";
                  WHEN "1110" => -- 15
                    seg2 <= "11111001";  
                    seg1 <= "10010010";
                  WHEN "1111" => -- 16
                    seg2 <= "11111001";  
                    seg1 <= "10000010";                                
                  WHEN OTHERS => seg1 <= "10000110"; -- Error
                END CASE;
            WHEN "011" => -- Play
                seg8 <= "10001100"; -- P
                seg7 <= "11000111"; -- L
                seg6 <= "10001000"; -- A
                seg5 <= "10010001"; -- Y
                seg4 <= "10111111"; -- -                
                seg3 <= "10001001"; -- H               
                seg2 <= "10001100"; -- P                
                
                CASE input(3 DOWNTO 0) IS
                  WHEN "0001" => -- 1 
                    seg1 <= "11111001";
                  WHEN "0010" => -- 2 
                    seg1 <= "10100100";
                  WHEN "0011" => -- 3 
                    seg1 <= "10110000";
                  WHEN "0100" => -- 4 
                    seg1 <= "10011001";
                  WHEN "0101" => -- 5 
                    seg1 <= "10010010";
                  WHEN "0110" => -- 6 
                    seg1 <= "10000010";
                  WHEN "0111" => -- 7                     
                    seg1 <= "11111000";
                  WHEN "1000" => -- 8                     
                    seg1 <= "10000000";                                                     
                  WHEN OTHERS => 
                  seg1 <= "10000110"; -- Error            
               END CASE;
               
           WHEN "101" => -- Timeout
                seg8 <= "10001100"; -- P
                
                CASE input(10 DOWNTO 7) IS
                  WHEN "0000" => -- 1 
                    seg7 <= "11000000";
                    seg6 <= "11111001";
                  WHEN "0001" => -- 2
                    seg7 <= "11000000"; 
                    seg6 <= "10100100";
                  WHEN "0010" => -- 3
                    seg7 <= "11000000"; 
                    seg6 <= "10110000";
                  WHEN "0011" => -- 4
                    seg7 <= "11000000"; 
                    seg6 <= "10011001";
                  WHEN "0100" => -- 5
                    seg7 <= "11000000"; 
                    seg6 <= "10010010";
                  WHEN "0101" => -- 6
                    seg7 <= "11000000"; 
                    seg6 <= "10000010";
                  WHEN "0110" => -- 7 
                    seg7 <= "11000000"; 
                    seg6 <= "11111000";
                  WHEN "0111" => -- 8
                    seg7 <= "11000000"; 
                    seg6 <= "10000000";
                  WHEN "1000" => -- 9
                    seg7 <= "11000000";  
                    seg6 <= "10010000";
                  WHEN "1001" => -- 10
                    seg7 <= "11111001";  
                    seg6 <= "11000000";
                  WHEN "1010" => -- 11
                    seg7 <= "11111001";  
                    seg6 <= "11111001";
                  WHEN "1011" => -- 12
                    seg7 <= "11111001";  
                    seg6 <= "10100100";
                  WHEN "1100" => -- 13
                    seg7 <= "11111001";  
                    seg6 <= "10110000";
                  WHEN "1101" => -- 14
                    seg7 <= "11111001";  
                    seg6 <= "10011001";
                  WHEN "1110" => -- 15
                    seg7 <= "11111001";  
                    seg6 <= "10010010";
                  WHEN "1111" => -- 16
                    seg7 <= "11111001";  
                    seg6 <= "10000010";                                
                  WHEN OTHERS =>
                    seg7 <= "10000110"; 
                    seg6 <= "10000110"; -- Error
                END CASE;
                
                
                seg5 <= "10001001"; -- H
                seg4 <= "11111001"; -- I                
                seg3 <= "10000111"; -- t                  
                
                CASE input(6 DOWNTO 4) IS
                  WHEN "000" => -- 0 
                    seg2 <= "11000000";  
                  WHEN "001" => -- 1 
                    seg2 <= "11111001";
                  WHEN "010" => -- 2 
                    seg2 <= "10100100";
                  WHEN "011" => -- 3 
                    seg2 <= "10110000";
                  WHEN "100" => -- 4 
                    seg2 <= "10011001";
                  WHEN "101" => -- 5 
                    seg2 <= "10010010";
                  WHEN "110" => -- 6 
                    seg2 <= "10000010";                                            
                  WHEN OTHERS => 
                    seg2 <= "10000110"; -- Error            
               END CASE;    
               
               CASE input(3 DOWNTO 0) IS               
                  WHEN "0000" => -- 0 
                    seg1 <= "11000000";  
                  WHEN "0001" => -- 1 
                    seg1 <= "11111001";
                  WHEN "0010" => -- 2 
                    seg1 <= "10100100";
                  WHEN "0011" => -- 3 
                    seg1 <= "10110000";
                  WHEN "0100" => -- 4 
                    seg1 <= "10011001";
                  WHEN "0101" => -- 5 
                    seg1 <= "10010010";
                  WHEN "0110" => -- 6 
                    seg1 <= "10000010";    
                  WHEN "0111"  => -- 7  
                    seg1 <= "11111000";
                  WHEN "1000" => -- 8 
                    seg1 <= "10000000";
                  WHEN "1001" => -- 9  
                    seg1 <= "10010000";                                                 
                  WHEN OTHERS => 
                   seg1 <= "10000110"; -- Error            
               END CASE;   
           
           WHEN "100" => -- Finished            

                seg8 <= "10100001"; -- D
                seg7 <= "10000110"; -- E
                seg6 <= "10001000"; -- A                
                seg5 <= "10100001"; -- D
                seg4 <= "01111111"; -- .
                seg3 <= "11111111";
                seg2 <= "11111111";
                seg1 <= "11111111";                                           
                                        
            WHEN "111" => -- Reset.
                seg8 <= "11001100"; -- r
                seg7 <= "10000110"; -- E
                seg6 <= "10010010"; -- S
                seg5 <= "10000110"; -- E
                seg4 <= "10000111"; -- t
                seg3 <= "01111111"; -- .
                seg2 <= "11111111";
                seg1 <= "11111111";      
                          
			WHEN OTHERS => -- error
				seg8 <= "10000110"; -- E
                seg7 <= "11001100"; -- r
                seg6 <= "11001100"; -- r
                seg5 <= "11000000"; -- O
                seg4 <= "11001100"; -- r
                seg3 <= "01111111"; -- .
                seg2 <= "11111111";
                seg1 <= "11111111";	
		END CASE;	
	END PROCESS code_process;
    
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
			    AN <= "01111111";
				SEG <= seg8;
			WHEN OTHERS =>
				AN <= "11111111";
				SEG <= "10000110"; -- Error	
		END CASE;	
	END PROCESS display_process;

END Behavioral;
