LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY debounce IS
  GENERIC(
    clk_freq    : INTEGER := 100000000;  
    stable_time : INTEGER := 10);        
  PORT(
    clk     : IN  STD_LOGIC;  
    reset_n : IN  STD_LOGIC;  
    button  : IN  STD_LOGIC;  
    output  : OUT STD_LOGIC); 
END debounce;

ARCHITECTURE debounce_arch OF debounce IS
  SIGNAL registers   : STD_LOGIC_VECTOR(1 DOWNTO 0); 
  SIGNAL counter_reset : STD_LOGIC;                    

BEGIN
  
  PROCESS(clk, reset_n)
    VARIABLE clk_count :  INTEGER := 0;  
  
  BEGIN
    IF(reset_n = '0') THEN                        
      registers <= (OTHERS => '0');   
      counter_reset <= '1';              
      output <= '1';                                 
    
    ELSIF RISING_EDGE(clk) THEN          
      
      registers(1) <= registers(0);
      registers(0) <= button;                              
      
      counter_reset <= registers(0) xor registers(1); -- xor to determine if both registers have same value                  
      
      If(counter_reset = '1') THEN   -- if registers do not have the same value then reset counter                  
        clk_count := 0;                                  
      
      ELSIF(clk_count < clk_freq*stable_time/1000) THEN  
        clk_count := clk_count + 1;                            
      ELSE                                           
        output <= registers(1);                        
      END IF;    
    END IF;
  END PROCESS;
  
END debounce_arch;