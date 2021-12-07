----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/03/2021 10:27:39 AM
-- Design Name: 
-- Module Name: modulator_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modulator_tb is
--  Port ( );
end modulator_tb;



architecture Behavioral of modulator_tb is

    SIGNAL clk_tb : STD_LOGIC := '0';
    SIGNAL reset_p_tb : STD_LOGIC := '0';
    SIGNAL tx_tb : STD_LOGIC := '0';
	
	SIGNAL modulator_start : STD_LOGIC;
	SIGNAL modulator_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10100100";
	SIGNAL modulator_busy : STD_LOGIC;
	SIGNAL modulator_done : STD_LOGIC;    
    
    COMPONENT modulator IS
		GENERIC (
			CLK_FREQ     : INTEGER := 100000000; -- clk freq in Hz
			CARRIER_FREQ : INTEGER := 38000; -- carrier freq in Hz
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


    

begin

modulator_comp :
	COMPONENT modulator
	   GENERIC MAP(
			CLK_FREQ     => 100, -- clk freq in Hz
			CARRIER_FREQ => 20, -- carrier freq in Hz
			BPS          => 10 -- bits per second
		)
		PORT MAP(
			clk     => clk_tb,
			reset_p => reset_p_tb,
			start   => modulator_start,
			data    => modulator_data,
			tx      => tx_tb,
			busy    => modulator_busy,
			done    => modulator_done
	);

clk_tb <= NOT clk_tb AFTER 10 ns;

reset_p_tb <= '0',
              '1'   AFTER 10 ns,
              '0'   AFTER 20 ns;
              
modulator_start <= '0',
              '1'   AFTER 30 ns,
              '0'   AFTER 50 ns;              

end Behavioral;
