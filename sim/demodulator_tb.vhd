library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demodulator_tb is
--  Port ( );
end demodulator_tb;

architecture Behavioral of demodulator_tb is
    constant DATA_LEN: integer := 4;

    signal clk_tb: std_logic := '0';
    signal reset_p_tb : std_logic := '0';

    signal rx_tb: std_logic := '0';
    
    signal restart_tb: std_logic := '0';
    signal data_tb: std_logic_vector(DATA_LEN -1 downto 0);
    signal data_ready_tb: std_logic;
    
    COMPONENT demodulator IS
    GENERIC (
        CLK_FREQ     : INTEGER; -- clk freq in Hz
        DATA_LEN     : INTEGER; -- carrier freq in Hz
        BPS          : INTEGER  -- bits per second
    );
    PORT (
        clk     : IN  STD_LOGIC;
        reset_p : IN  STD_LOGIC;
        restart : IN  STD_LOGIC;
        data    : OUT STD_LOGIC_VECTOR(DATA_LEN-1 DOWNTO 0);
        data_ready: OUT STD_LOGIC;
        rx      : IN STD_LOGIC);
	END COMPONENT demodulator;
begin

demodulator_comp :
	COMPONENT demodulator
	   GENERIC MAP(
			CLK_FREQ => 100000000, -- clk freq in Hz
		    DATA_LEN  => DATA_LEN,     -- carrier freq in Hz
            BPS => 100000        -- bits per second
		)
		PORT MAP(
			clk     => clk_tb,
			reset_p => reset_p_tb,
			restart => restart_tb,
			data    => data_tb,
			data_ready => data_ready_tb,
			rx      => rx_tb
	);
	
    clk_tb <= NOT clk_tb AFTER 10 ns;
    
    reset_p_tb <= '1',
                  '0' AFTER 1 ns;
    
    rx_tb <= '0',
             '1'   AFTER 020 us, -- 0 (start bit)
             '0'   AFTER 030 us,
             
             '0'   AFTER 040 us, -- 1
             '1'   AFTER 050 us,
             
             '1'   AFTER 060 us, -- 0
             '0'   AFTER 070 us,
             
             '0'   AFTER 080 us, -- 1
             '1'   AFTER 090 us,
             
             '1'   AFTER 100 us, -- 0
             '0'   AFTER 110 us,
             
             '1'   AFTER 120 us, -- 0
             '0'   AFTER 130 us,
             
             '0'   AFTER 140 us, -- 1
             '1'   AFTER 150 us,
             
             '1'   AFTER 160 us, -- 0
             '0'   AFTER 170 us,
             
             '1'   AFTER 180 us, -- 0
             '0'   AFTER 190 us,
             
             '0'   AFTER 200 us, -- 1 (stop bit)
             '1'   AFTER 210 us;
end Behavioral;
