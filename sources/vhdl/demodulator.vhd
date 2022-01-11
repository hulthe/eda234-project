-----------------------------------------------------
-- Title: demodulator.vhdl
-- Author: Rafael Romon
-----------------------------------------------------
-- Description:
-- IR demodulator for Bi Phase Coding
--
-- TODO:
-- * Actually recover information
-----------------------------------------------------

library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity demodulator is
	GENERIC (
		CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
		CARRIER_FREQ : INTEGER := 36000; -- laser carrier freq in Hz
        DATA_LEN: integer := 6
	);
	port
	(
		clk       : in  std_logic;
		reset_n   : in  std_logic;
		start     : in  std_logic;		
		input     : in  std_logic;
		ready     : out std_logic;
		output    : out std_logic_vector(DATA_LEN-1 DOWNTO 0)		
	);
end demodulator;

architecture Behavioral of demodulator is
	type states is (Idle, Sync, Recover, Finish);    
    signal StateMachine : states := Idle;
    signal samples : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
    signal samples_ready : STD_LOGIC := '0';
begin
    
    -- captures two samples per transmitted bit
    sampling_process:
	PROCESS (clk)
		VARIABLE clk_cycles : INTEGER := 0;
		VARIABLE sample_index : INTEGER := 0;
	BEGIN
		IF rising_edge(clk) THEN
			IF (clk_cycles + 1) = (CLK_FREQ/CARRIER_FREQ/2) THEN
				
				samples(sample_index) <= input;
				
				if sample_index = 0 THEN
				    sample_index := 1;
				    samples_ready <= '0';
				ELSE
				    sample_index := 0;
				    samples_ready <= '1';
				END IF;
				
				clk_cycles := 0;
			ELSE
				clk_cycles := clk_cycles + 1;
			END IF;
		END IF;
	END PROCESS sampling_process;
    
    demodulator_process:
	PROCESS (clk, samples_ready)
		VARIABLE sample_index : INTEGER := 0;
	BEGIN
	    IF reset_n = '0' THEN
	       ready <= '0';
	       output <= (OTHERS => '0');
		ELSIF rising_edge(clk) THEN
		    case StateMachine is
		      when Idle =>
		          ready <= '0';
		          		          
		          IF start = '1' THEN
		              StateMachine <= Sync;
		          END IF;
		      when Sync => -- detects a falling edge that marks the beginning of a transmission
		          
		          IF samples_ready = '1' and samples = "10" THEN
		              StateMachine <= Recover;
		          END IF;
		      when Recover =>
		          StateMachine <= Finish;
		          
		      when Finish =>
		          ready <= '1';
		          
		          IF start = '0' THEN
		              StateMachine <= Idle;
		          END IF;  		            
		    END CASE;
		END IF;
	END PROCESS demodulator_process;

end Behavioral;
