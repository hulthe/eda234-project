LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY top_level IS
	GENERIC (
		CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
		CARRIER_FREQ : INTEGER := 36000; -- laser carrier freq in Hz
		BPS          : INTEGER := 2 -- laser bits per second
	);
	PORT (
		CLK100MHZ : IN STD_LOGIC;
		BTNC : IN STD_LOGIC;
		BTND : IN STD_LOGIC;
		UART_RXD_OUT : OUT STD_LOGIC;
		LASER_TX: OUT STD_LOGIC;
		SEG: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		AN: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END top_level;

ARCHITECTURE Behavioral OF top_level IS

	SIGNAL uart_start : STD_LOGIC := '0';
	SIGNAL uart_msg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL uart_busy : STD_LOGIC;
	SIGNAL uart_done : STD_LOGIC;

	COMPONENT UART_TX IS
		PORT (
			clk : IN STD_LOGIC;
			TX_DV : IN STD_LOGIC;
			TX_Byte : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			TX_Active : OUT STD_LOGIC;
			TX_Serial : OUT STD_LOGIC;
			TX_Done : OUT STD_LOGIC
		);
	END COMPONENT UART_TX;
    
    
    COMPONENT seg_controller IS
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
    END COMPONENT seg_controller;
    
	SIGNAL modulator_start : STD_LOGIC;
	SIGNAL modulator_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10100100";
	SIGNAL modulator_busy : STD_LOGIC;
	SIGNAL modulator_done : STD_LOGIC;    
    
    COMPONENT modulator IS
		GENERIC (
			CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
			CARRIER_FREQ : INTEGER := 36000; -- carrier freq in Hz
			BPS          : INTEGER := 100 -- bits per second
		);
		PORT (
			clk     : IN  STD_LOGIC;
			reset_p : IN  STD_LOGIC;
			start   : IN  STD_LOGIC;
			data    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			tx      : OUT STD_LOGIC;
			busy    : OUT STD_LOGIC;
			done    : OUT STD_LOGIC);
	END COMPONENT modulator;

BEGIN

	UART_TX_comp : UART_TX
	PORT MAP
	(
		clk => CLK100MHZ,
		TX_DV => uart_start,
		TX_Byte => uart_msg,
		TX_Active => uart_busy,
		TX_Serial => UART_RXD_OUT,
		TX_Done => uart_done
	);
	
	seg_controller_comp : seg_controller
	PORT MAP
	(		
		clk => CLK100MHZ,
		seg8 => "10010010",
		seg7 => "10000111",
		seg6 => "10001000",
		seg5 => "11001100",
		seg4 => "10000111",
		seg3 => "01111111",
		seg2 => "11111111",
		seg1 => "11111111",
		seg => SEG,
		an => AN
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
			reset_p => '0',
			start   => modulator_start,
			data    => modulator_data,
			tx      => LASER_TX,
			busy    => modulator_busy,
			done    => modulator_done
	);
    
	debounce_process : PROCESS (CLK100MHZ)
		VARIABLE start_var1 : STD_LOGIC := '0';
		VARIABLE start_var2 : STD_LOGIC := '0';
	BEGIN
        
        uart_msg <= "01011010";
        modulator_data <= "01011010";
        
        IF rising_edge(CLK100MHZ) THEN        
            
            IF BTND = '1' and uart_busy = '0' THEN
                start_var1 := '1';
    
            ELSIF BTND = '0' AND start_var1 = '1' THEN
                start_var1 := '0';
                uart_start <= '1';
    
            ELSIF uart_busy = '1' AND uart_start = '1' THEN
                uart_start <= '0';
            END IF;
            
            IF BTNC = '1' and modulator_busy = '0' THEN
                start_var2 := '1';
    
            ELSIF BTNC = '0' AND start_var2 = '1' THEN
                start_var2 := '0';
                modulator_start <= '1';
    
            ELSIF modulator_busy = '1' AND modulator_start = '1' THEN
                modulator_start <= '0';
            END IF;
		
		END IF;

	END PROCESS debounce_process;

END Behavioral;
