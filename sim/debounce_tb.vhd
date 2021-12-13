library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce_tb is

end debounce_tb;

architecture Behavioral of debounce_tb is

    SIGNAL clk_tb : STD_LOGIC := '0';
    SIGNAL reset_n_tb : STD_LOGIC;
    SIGNAL button_tb : STD_LOGIC := '1';
    SIGNAL output_tb : STD_LOGIC;

    COMPONENT debounce IS
      GENERIC(
        clk_freq    : INTEGER := 100000000;  
        stable_time : INTEGER := 10);        
      PORT(
        clk     : IN  STD_LOGIC;  
        reset_n : IN  STD_LOGIC;  
        button  : IN  STD_LOGIC;  
        output  : OUT STD_LOGIC); 
    END COMPONENT;    

begin        
            
    debounce_comp : COMPONENT debounce    
	GENERIC MAP
	(
		clk_freq    => 100000000,  
        stable_time => 10    
	)
	PORT MAP
	(
		clk => clk_tb,
		reset_n => reset_n_tb,
		button => button_tb,
		output => output_tb
	);

    clk_tb <= NOT clk_tb AFTER 10 ns;
	
	reset_n_tb <= '1',
              '0'   AFTER 10 ns,
              '1'   AFTER 20 ns;                            
                    
	
end Behavioral;
