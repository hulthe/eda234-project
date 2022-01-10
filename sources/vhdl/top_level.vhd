LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_level IS
	GENERIC (
		CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
		CARRIER_FREQ : INTEGER := 36000; -- laser carrier freq in Hz
		BPS          : INTEGER := 50; -- laser bits per second
		DATA_LEN     : INTEGER := 6
	);
	PORT (
		CLK100MHZ    : IN  STD_LOGIC;
		GUN_TRIGGER  : IN  STD_LOGIC;
		CPU_RESETN   : IN  STD_LOGIC;
		SEND_BUTTON  : IN  STD_LOGIC;
		BTNC         : IN  STD_LOGIC;
		BTNU         : IN  STD_LOGIC;
		FULL_HIT     : IN  STD_LOGIC;
		HALF_HIT     : IN  STD_LOGIC;
		PLAYER_NUM   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		UART_RXD_OUT : OUT STD_LOGIC;
		LASER_TX     : OUT STD_LOGIC;
		SPEAKER      : OUT STD_LOGIC;
		LED16        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		LED17        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		SEG          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		AN           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END top_level;

ARCHITECTURE Behavioral OF top_level IS

	TYPE states IS (Start, PlayerSelect, Play, Timeout,
		Finished, PCTransmission);
	SIGNAL StateMachine : states := Start;

	SIGNAL reset_signal : STD_LOGIC;
	SIGNAL send_signal : STD_LOGIC;
	SIGNAL trigger_signal : STD_LOGIC;
	SIGNAL ok_signal : STD_LOGIC;

	COMPONENT debounce IS
		GENERIC (
			clk_freq    : INTEGER := 100000000;
			stable_time : INTEGER := 10);
		PORT (
			clk     : IN  STD_LOGIC;
			reset_n : IN  STD_LOGIC;
			button  : IN  STD_LOGIC;
			output  : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL uart_start : STD_LOGIC := '0';
	SIGNAL uart_msg : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01101000";
	SIGNAL uart_busy : STD_LOGIC;
	SIGNAL uart_out : STD_LOGIC;
	SIGNAL uart_done : STD_LOGIC;

	COMPONENT UART_TX IS
		GENERIC (
			CLK_FREQ  : INTEGER := 100000000; -- hz
			BAUD_RATE : INTEGER := 115200
		);
		PORT (
			clk       : IN  STD_LOGIC;
			TX_DV     : IN  STD_LOGIC;
			TX_Byte   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			TX_Active : OUT STD_LOGIC;
			TX_Serial : OUT STD_LOGIC;
			TX_Done   : OUT STD_LOGIC
		);
	END COMPONENT UART_TX;

	SIGNAL seg_code_signal : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL seg_input_signal : STD_LOGIC_VECTOR(10 DOWNTO 0);

	COMPONENT seg_controller IS
		GENERIC (
			CLK_FREQ   : INTEGER := 100000000; -- hz
			PULSE_FREQ : INTEGER := 1000 --hz		
		);
		PORT (
			clk   : IN  STD_LOGIC;
			code  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			input : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
			seg   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			an    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT seg_controller;

	SIGNAL modulator_start : STD_LOGIC;
	SIGNAL modulator_data : STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);
	SIGNAL modulator_out : STD_LOGIC;
	SIGNAL modulator_busy : STD_LOGIC;
	SIGNAL modulator_done : STD_LOGIC;

	COMPONENT modulator IS
		GENERIC (
			CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
			CARRIER_FREQ : INTEGER := 36000; -- carrier freq in Hz
			DATA_LEN     : INTEGER := 6;
			BPS          : INTEGER := 5 -- bits per second
		);
		PORT (
			clk     : IN  STD_LOGIC;
			reset_n : IN  STD_LOGIC;
			start   : IN  STD_LOGIC;
			data    : IN  STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);
			tx      : OUT STD_LOGIC;
			busy    : OUT STD_LOGIC;
			done    : OUT STD_LOGIC);
	END COMPONENT modulator;

	SIGNAL demod_start_signal : STD_LOGIC;
	SIGNAL demod_ready_signal : STD_LOGIC;
	SIGNAL demod_out_signal : STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0);

	COMPONENT demodulator IS
		GENERIC (
			CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
			CARRIER_FREQ : INTEGER := 36000; -- laser carrier freq in Hz
			DATA_LEN     : INTEGER := 6
		);
		PORT (
			clk     : IN  STD_LOGIC;
			reset_n : IN  STD_LOGIC;
			start   : IN  STD_LOGIC;
			input   : IN  STD_LOGIC;
			ready   : OUT STD_LOGIC;
			output  : OUT STD_LOGIC_VECTOR(DATA_LEN - 1 DOWNTO 0)
		);
	END COMPONENT demodulator;

	SIGNAL timer_start_signal : STD_LOGIC;
	SIGNAL timer_length_signal : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL timer_unit_signal : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL timer_tenth_signal : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL timer_done_signal : STD_LOGIC;

	COMPONENT timer IS
		GENERIC (
			CLK_FREQ : INTEGER := 100000000); -- clk freq in HZ		
		PORT (
			clk     : IN  STD_LOGIC;
			reset_n : IN  STD_LOGIC;
			start   : IN  STD_LOGIC;
			length  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			unit    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			tenth   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			done    : OUT STD_LOGIC);
	END COMPONENT timer;

	SIGNAL audio_trigger_signal : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

	COMPONENT audio_controller IS
		PORT (
			clk       : IN  STD_LOGIC;
			reset_n   : IN  STD_LOGIC;
			audio_out : OUT STD_LOGIC;
			trigger   : IN  STD_LOGIC_VECTOR (2 DOWNTO 0)
		);

	END COMPONENT audio_controller;

	SIGNAL hits : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');

BEGIN

	audio_comp : audio_controller
	PORT MAP
	(
		clk       => CLK100MHZ,
		reset_n   => reset_signal,
		audio_out => SPEAKER,
		trigger   => audio_trigger_signal
	);

	timer_comp : timer
	GENERIC MAP(
		CLK_FREQ => CLK_FREQ/100 -- clk freq in Hz			
	)
	PORT MAP
	(
		clk     => CLK100MHZ,
		reset_n => reset_signal,
		start   => timer_start_signal,
		length  => timer_length_signal,
		unit    => timer_unit_signal,
		tenth   => timer_tenth_signal,
		done    => timer_done_signal
	);

	reset_button_comp : debounce
	PORT MAP
	(
		clk     => CLK100MHZ,
		reset_n => '1',
		button  => CPU_RESETN,
		output  => reset_signal
	);

	send_button_comp : debounce
	PORT MAP
	(
		clk     => CLK100MHZ,
		reset_n => reset_signal,
		button  => SEND_BUTTON,
		output  => send_signal
	);

	trigger_button_comp : debounce
	PORT MAP
	(
		clk     => CLK100MHZ,
		reset_n => reset_signal,
		button  => GUN_TRIGGER,
		output  => trigger_signal
	);

	ok_button_comp : debounce
	PORT MAP
	(
		clk     => CLK100MHZ,
		reset_n => reset_signal,
		button  => BTNC,
		output  => ok_signal
	);

	UART_TX_comp : UART_TX
	GENERIC MAP(
		CLK_FREQ => CLK_FREQ -- clk freq in Hz			
	)
	PORT MAP
	(
		clk       => CLK100MHZ,
		TX_DV     => uart_start,
		TX_Byte   => uart_msg,
		TX_Active => uart_busy,
		TX_Serial => uart_out,
		TX_Done   => uart_done
	);

	seg_controller_comp : seg_controller
	PORT MAP
	(
		clk   => CLK100MHZ,
		code  => seg_code_signal,
		input => seg_input_signal,
		seg   => SEG,
		an    => AN
	);
	modulator_comp :
	COMPONENT modulator
		GENERIC MAP(
			CLK_FREQ     => CLK_FREQ, -- clk freq in Hz
			CARRIER_FREQ => CARRIER_FREQ, -- carrier freq in Hz
			DATA_LEN     => DATA_LEN,
			BPS          => BPS -- bits per second
		)
		PORT MAP(
			clk     => CLK100MHZ,
			reset_n => reset_signal,
			start   => modulator_start,
			data    => modulator_data,
			tx      => modulator_out,
			busy    => modulator_busy,
			done    => modulator_done
		);
		demod_comp : demodulator
		PORT MAP
		(
			clk     => CLK100MHZ,
			reset_n => reset_signal,
			start   => demod_start_signal,
			ready   => demod_ready_signal,
			output  => demod_out_signal,
			input   => FULL_HIT
		);

		top_level_process : PROCESS (CLK100MHZ)
			VARIABLE start_flag : STD_LOGIC := '0';
			VARIABLE lives : UNSIGNED(3 DOWNTO 0) := "1000";
		BEGIN

			IF reset_signal = '0' THEN
				seg_code_signal <= "111";
				StateMachine <= Start;
				lives := "1000";
				hits <= (OTHERS => '0');
				start_flag := '0';

            ELSIF rising_edge(CLK100MHZ) THEN
				CASE StateMachine IS
					WHEN Start =>
						seg_code_signal <= "001";

						IF NOT(trigger_signal) = '1' THEN
							start_flag := '1';
						ELSIF start_flag = '1' AND NOT(trigger_signal) = '0' THEN
							start_flag := '0';
							StateMachine <= PlayerSelect;
				        END IF;
                    WHEN PlayerSelect =>
                        seg_code_signal <= "010";
                        seg_input_signal <= "0000000" & PLAYER_NUM;

                        IF NOT(trigger_signal) = '1' THEN
                            start_flag := '1';
                        ELSIF start_flag = '1' AND NOT(trigger_signal) = '0' THEN
                            start_flag := '0';
                            modulator_data <= "0" & PLAYER_NUM & "0";
                            lives := "1000";
                            StateMachine <= Play;
                            demod_start_signal <= '1';
                        END IF;
                    
                    WHEN Play =>
                        modulator_start <= NOT(trigger_signal);
                    
                        IF trigger_signal = '0' THEN
                            audio_trigger_signal <= "001";
                        ELSE
                            audio_trigger_signal <= "000";
                        END IF;
                    
                        seg_code_signal <= "011";
                        seg_input_signal <= "0000000" & STD_LOGIC_VECTOR(lives);
                    
                        IF start_flag = '1' THEN -- This avoids substracting 2                                                        
                            start_flag := '0';
                            audio_trigger_signal <= "000";
                            demod_start_signal <= '0';
                            StateMachine <= Timeout;
                        ELSE
                    
                            IF demod_ready_signal = '1' THEN
                                audio_trigger_signal <= "100";
                    
                                IF lives <= "0010" THEN
                                    demod_start_signal <= '0';
                                    start_flag := '0';
                                    StateMachine <= Finished;
                                ELSE
                                    timer_start_signal <= '1';
                                    timer_length_signal <= "10";
                                    lives := lives - 2;
                                    hits <= hits + 2;
                                    start_flag := '1';
                                END IF;
                    
                            ELSIF BTNC = '1' THEN
                    
                                audio_trigger_signal <= "010";
                    
                                IF lives = "0001" THEN
                                    demod_start_signal <= '0';
                                    start_flag := '0';
                                    StateMachine <= Finished;
                                ELSE
                                    timer_start_signal <= '1';
                                    timer_length_signal <= "01";
                                    lives := lives - 1;
                                    hits <= hits + 1;
                                    start_flag := '1';
                                END IF;
                            END IF;
                    
                        END IF;
                    WHEN Timeout =>
                    
                        seg_code_signal <= "101";
                        seg_input_signal <= demod_out_signal(DATA_LEN - 2 DOWNTO 1) & timer_tenth_signal & timer_unit_signal;
                    
                        IF timer_done_signal = '1' THEN
                            demod_start_signal <= '1';
                            timer_start_signal <= '0';
                            StateMachine <= Play;
                        END IF;
                    
                    WHEN Finished =>
                        seg_code_signal <= "100";
                        IF NOT(trigger_signal) = '1' THEN
                            start_flag := '1';
                        ELSIF start_flag = '1' AND NOT(trigger_signal) = '0' THEN
                            start_flag := '0';
                            StateMachine <= Start;
                        END IF;
                    
                        WHEN OTHERS =>
                        seg_code_signal <= "000";
                    END CASE;
                END IF;
            END PROCESS top_level_process;

            uart_process : PROCESS (CLK100MHZ)
                VARIABLE start_flag : STD_LOGIC := '0';
            BEGIN
                IF rising_edge(CLK100MHZ) THEN
            
                    uart_msg <= STD_LOGIC_VECTOR(hits);
            
                    IF uart_busy = '1' THEN
                        uart_start <= '0';
                    ELSE
                        IF NOT(send_signal) = '1' THEN
                            start_flag := '1';
                        ELSIF start_flag = '1' AND NOT(send_signal) = '0' THEN
                            start_flag := '0';
                            uart_start <= '1';
                        END IF;
                    END IF;
            
                END IF;
            END PROCESS uart_process;

            debug_process : PROCESS (HALF_HIT, uart_out, modulator_out)
            BEGIN
                UART_RXD_OUT <= uart_out;
                LASER_TX <= modulator_out;
                LED16 <= NOT(FULL_HIT) & NOT(uart_out) & modulator_out;
            END PROCESS debug_process;
            
            led_status_process : PROCESS (reset_signal, uart_busy, modulator_busy)
            BEGIN
                IF reset_signal = '0' THEN
                    LED17 <= "100"; -- red for reset
                ELSIF modulator_busy = '1' OR uart_busy = '1' THEN
                    LED17 <= "110"; -- yellow for busy
                ELSE
                    LED17 <= "001"; -- blue for idle
                END IF;
            END PROCESS led_status_process;

END Behavioral;
