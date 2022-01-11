-----------------------------------------------------
-- Title: timer.vhdl
-- Author: Rafael Romon
-----------------------------------------------------
-- Description:
-- Timer entity used to timeout player for 30 or 60s
-----------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;

ENTITY timer IS
	GENERIC (
		CLK_FREQ : INTEGER := 100000000); -- clk freq in HZ		
	PORT (
		clk   : IN  STD_LOGIC;
		reset_n : IN  STD_LOGIC;
		start   : IN STD_LOGIC;
		length  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		unit    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		tenth   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		done    : OUT STD_LOGIC);
END timer; 

ARCHITECTURE Behavioral OF timer IS

	SIGNAL unit_signal  : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL tenth_signal : STD_LOGIC_VECTOR (2 DOWNTO 0);
	
    TYPE states IS (Idle, Timer, Finished);
	SIGNAL StateMachine   : states := Idle;

BEGIN
	PROCESS (clk, reset_n)
		VARIABLE unit_var       : unsigned(3 DOWNTO 0) := "1001";
		VARIABLE tenth_var     : unsigned(2 DOWNTO 0) := "000";
		VARIABLE clk_cycles : INTEGER              := 0;        
	BEGIN
		IF reset_n = '0' THEN
			unit_var       := "1001";
			tenth_var      := "000";
			clk_cycles := 0;
			StateMachine <= Idle;
			

		ELSIF rising_edge(clk) THEN
            
            CASE StateMachine IS
        
                WHEN Idle =>                                                            
                    IF start = '1' THEN                    
                        done <= '0';
                        unit_var := "0000";
                            
                        if length = "01" THEN
                            tenth_var      := "011";
                        ELSIF length = "10" THEN
                            tenth_var      := "110";                         
                        END IF;
                        
                        StateMachine <= Timer;
                    END IF;
                    
                WHEN Timer =>
                    IF (clk_cycles + 1) = CLK_FREQ THEN
                        clk_cycles := 0;
                    
                        IF unit_var = "0000" THEN
                            unit_var := "1001";
                    
                            IF tenth_var = "000" THEN
                                StateMachine <= Finished;
                            ELSE
                                tenth_var := tenth_var - 1;
                            END IF;
                    
                        ELSE
                            unit_var := unit_var - 1;
                        END IF;
                    ELSE
                        clk_cycles := clk_cycles + 1;                
                    END IF;
                
                When Finished =>
                    done <= '1';
                
                    IF start = '0' THEN
                        StateMachine <= Idle;
                    END IF;
            END CASE;
        END IF;
            			

		unit_signal  <= STD_LOGIC_VECTOR(unit_var);
		tenth_signal <= STD_LOGIC_VECTOR(tenth_var);

	END PROCESS;

	unit  <= unit_signal;
	tenth <= tenth_signal;

END Behavioral;
