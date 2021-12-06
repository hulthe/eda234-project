-----------------------------------------------------
-- Title: modulator.vhdl
-- Author: Rafael Romon
-----------------------------------------------------
-- Description:
-- Laser modulator using Bi Phase Coding
-----------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY modulator IS
	GENERIC
	(
		CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
		CARRIER_FREQ : INTEGER := 36000;     -- carrier freq in Hz
		BPS          : INTEGER := 100        -- bits per second
	);
	PORT
	(
		clk     : IN  STD_LOGIC;
		reset_p : IN  STD_LOGIC;
		start   : IN  STD_LOGIC;
		data    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		tx      : OUT STD_LOGIC;
		busy    : OUT STD_LOGIC;
		done    : OUT STD_LOGIC);
END modulator;

ARCHITECTURE Behavioral OF modulator IS

	TYPE states IS (Idle, Sync, Set, Edge, Finish);
	SIGNAL state_machine : states    := Idle;

	SIGNAL tx_signal     : STD_LOGIC := '0';
	SIGNAL bps_signal    : STD_LOGIC := '0';

BEGIN

	carrier_process :
	PROCESS (clk)
		VARIABLE clk_cycles : INTEGER := 0;
	BEGIN
		IF rising_edge(clk) THEN
			IF (clk_cycles + 1) = (CLK_FREQ/CARRIER_FREQ) THEN
				tx_signal <= NOT(tx_signal);
				clk_cycles := 0;
			ELSE
				clk_cycles := clk_cycles + 1;
			END IF;
		END IF;
	END PROCESS carrier_process;

	bps_process :
	PROCESS (clk)
		VARIABLE clk_cycles : INTEGER := 0;
	BEGIN
		IF rising_edge(clk) THEN
			IF (clk_cycles + 1) = (CLK_FREQ/BPS)/2 THEN
				bps_signal <= NOT(bps_signal);
				clk_cycles := 0;
			ELSE
				clk_cycles := clk_cycles + 1;
			END IF;
		END IF;
	END PROCESS bps_process;

	modulator_process :
	PROCESS (clk)
		VARIABLE data_index : INTEGER   := 6;
		VARIABLE start_flag : STD_LOGIC := '0';
	BEGIN
		IF reset_p = '1' THEN
			data_index := 6;
			start_flag := '0';
			tx   <= '0';
			busy <= '0';
			done <= '0';

		ELSIF rising_edge(clk) THEN
			CASE state_machine IS

				WHEN Idle =>
					IF start = '1' THEN
					    done <= '0';
						busy <= '1';
						start_flag := '1';
					END IF;

					IF start_flag = '1' AND bps_signal = '1' THEN
						start_flag := '0';
						state_machine <= Sync;
					END IF;

				WHEN Sync =>
					IF bps_signal = '0' THEN
						state_machine <= Set;
					END IF;

				WHEN Set =>

					IF data(data_index) = '0' THEN
						tx <= tx_signal;
					ELSE
						tx <= '0';
					END IF;

					IF bps_signal = '1' THEN
						state_machine <= Edge;
					END IF;

				WHEN Edge =>

					IF data(data_index) = '1' THEN
						tx <= tx_signal;
					ELSE
						tx <= '0';
					END IF;

					IF bps_signal = '0' THEN
						IF data_index = 0 THEN
							data_index := 0;
							state_machine <= Finish;
						ELSE
							data_index := data_index - 1;
							state_machine <= Set;
						END IF;
					END IF;

				WHEN Finish =>
					busy <= '0';
					done <= '1';

					IF start = '0' THEN						
						state_machine <= Idle;
					END IF;
			END CASE;
		END IF;
	END PROCESS modulator_process;

END Behavioral;
