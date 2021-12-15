library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity demodulator is
	generic
	(
		CLK_FREQ: integer := 100000000; -- clk freq in Hz
		BPS:      integer := 100;        -- bits per second
		DATA_LEN: integer := 8
	);
	port
	(
		clk       : in  std_logic;
		reset_n   : in  std_logic;
		restart   : in  std_logic;
		data      : out std_logic_vector(DATA_LEN-1 DOWNTO 0);
		data_ready: out std_logic := '0';
		rx        : in  std_logic
	);
end demodulator;

architecture Behavioral of demodulator is
	type states is (Idle, HalfFirst, SyncFirst, HalfSecond, SyncSecond, Finish);
    signal data_index: integer := 0;
    signal data_buffer: std_logic_vector(DATA_LEN+1 downto 0); -- +1 to account for the start & stop bits
    signal state : states := Idle;
    signal sample_signal: std_logic;
begin

    process(clk, reset_n)
        variable cycles: integer := 0;
    begin
        if reset_n = '0' then
            sample_signal <= '0';
            cycles := 0;
        elsif rising_edge(clk) then
            if state = Idle then
                sample_signal <= '0';
            else
                if cycles + 1 = CLK_FREQ / BPS / 4 then
                    sample_signal <= '1';
                    cycles := 0;
                else
                    sample_signal <= '0';
                    cycles := cycles + 1;
                end if;
            end if;
        end if;    
    end process;

    process(clk, reset_n, restart)
        variable rx_prev: std_logic := '0';
        variable bit_sample: std_logic_vector(1 downto 0) := "00";
    begin
        if reset_n = '0' or restart = '1' then
            state <= Idle;
            data_index <= DATA_LEN + 1;
            data_ready <= '0';
            data <= (others => '0');
            rx_prev := rx;
        elsif rising_edge(clk) then
            case state is
                when Idle =>
                    if rx = '1' and rx_prev = '0' then
                        state <= HalfFirst;
                        data_index <= DATA_LEN + 1;
                    end if;
                when HalfFirst => 
                    if sample_signal = '1' then
                        state <= SyncFirst;
                        bit_sample(1) := rx;
                    end if;
                when SyncFirst =>
                    if sample_signal = '1' then
                        state <= HalfSecond;
                    end if;
                when HalfSecond => 
                    if sample_signal = '1' then
                        state <= HalfFirst; --todo
                        bit_sample(0) := rx;
                        
                        case bit_sample is
                            when "10" => data_buffer(data_index) <= '0';
                            when "01" => data_buffer(data_index) <= '1';
                            when others => -- not a valid bit pattern, 
                                state <= Idle;
                                data_index <= DATA_LEN - 1;
                                data_ready <= '0';
                                data <= (others => '0');
                        end case;
                        
                        if data_index = 0 then
                            state <= Finish;
                        else
                            data_index <= data_index - 1;
                            state <= SyncSecond;
                        end if;
                    end if;
                when SyncSecond =>
                    if sample_signal = '1' then
                        state <= HalfFirst;
                    end if;
                 when Finish =>
                    -- TODO: validate start and stop bits?
                    -- copy bits (excluding start and stop) to output
                    data <= data_buffer(DATA_LEN downto 1);
                    data_ready <= '1';
            end case;
            
            rx_prev := rx;
        end if;
    end process;
end Behavioral;
