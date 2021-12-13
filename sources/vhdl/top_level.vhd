LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY top_level IS
	GENERIC (
		CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
		CARRIER_FREQ : INTEGER := 36000; -- laser carrier freq in Hz
		BPS          : INTEGER := 2 -- laser bits per second
	);
	PORT (
		CLK100MHZ    : IN  STD_LOGIC;
		GUN_TRIGGER  : IN  STD_LOGIC;
		CPU_RESETN   : IN  STD_LOGIC;
		SEND_BUTTON  : IN  STD_LOGIC;
		UART_RXD_OUT : OUT STD_LOGIC;
		LASER_TX     : OUT STD_LOGIC;
		LED16        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		LED17        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		SEG          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		AN           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END top_level;

ARCHITECTURE Behavioral OF top_level IS

	TYPE states IS (Start, PlayerSelect, Play,
		Finished, PCTransmission);
	SIGNAL StateMachine   : states := Start;

	SIGNAL reset_signal   : STD_LOGIC;
	SIGNAL send_signal    : STD_LOGIC;
	SIGNAL trigger_signal : STD_LOGIC;

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

	SIGNAL uart_start : STD_LOGIC                    := '0';
	SIGNAL uart_msg   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01101000";
	SIGNAL uart_busy  : STD_LOGIC;
	SIGNAL uart_out   : STD_LOGIC;
	SIGNAL uart_done  : STD_LOGIC;

	COMPONENT UART_TX IS
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

	COMPONENT seg_controller IS
		GENERIC (
			CLK_FREQ   : INTEGER := 100000000; -- hz
			PULSE_FREQ : INTEGER := 1000 --hz		
		);
		PORT (
			clk  : IN  STD_LOGIC;
			code : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			seg  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			an   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT seg_controller;

	SIGNAL modulator_start : STD_LOGIC;
	SIGNAL modulator_data  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10100100";
	SIGNAL modulator_out   : STD_LOGIC;
	SIGNAL modulator_busy  : STD_LOGIC;
	SIGNAL modulator_done  : STD_LOGIC;

	COMPONENT modulator IS
		GENERIC (
			CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
			CARRIER_FREQ : INTEGER := 36000; -- carrier freq in Hz
			BPS          : INTEGER := 5 -- bits per second
		);
		PORT (
			clk     : IN  STD_LOGIC;
			reset_n : IN  STD_LOGIC;
			start   : IN  STD_LOGIC;
			data    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			tx      : OUT STD_LOGIC;
			busy    : OUT STD_LOGIC;
			done    : OUT STD_LOGIC);
	END COMPONENT modulator;

BEGIN
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

	UART_TX_comp : UART_TX
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
		clk  => CLK100MHZ,
		code => seg_code_signal,
		seg  => SEG,
		an   => AN
	);

	modulator_comp :
	COMPONENT modulator
		GENERIC MAP(
			CLK_FREQ     => CLK_FREQ, -- clk freq in Hz
			CARRIER_FREQ => CARRIER_FREQ, -- carrier freq in Hz
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

		top_level_process : PROCESS (CLK100MHZ)
		BEGIN
			IF rising_edge(CLK100MHZ) THEN

				UART_RXD_OUT    <= uart_out;
				LASER_TX        <= modulator_out;
				uart_start      <= NOT(send_signal);
				modulator_start <= NOT(trigger_signal);

				LED16           <= "0" & NOT(uart_out) & modulator_out;								
				
			END IF;
        END PROCESS top_level_process;
        
        seg_status_process : PROCESS (StateMachine)
        BEGIN
            IF reset_signal = '0' THEN
                seg_code_signal <= "111";
            ELSE
                CASE StateMachine IS
                    WHEN Start =>
                        seg_code_signal <= "001";        
                    WHEN OTHERS =>
                        seg_code_signal <= "000";
                END CASE;
            END IF;
        END PROCESS seg_status_process;
        
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
