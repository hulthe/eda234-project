library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hit_detector is
    Port (
        clk_100M 	  : in std_logic;
        reset_n	 	  : in std_logic;
		half_detector : in std_logic;   --detect the half shot signal from one of receivers
        full_detector : in std_logic;	--detect the full shot signal from other receiver
		half_shot     : out std_logic;  --output the half shot signal
        full_shot 	  : out std_logic  	--output the full shot signal
										--output the kink of audio sound?
    );
end hit_detector;

architecture Behavioral of hit_detector is

signal half_detector_sig : std_logic_vector(2 downto 0);
signal full_detector_sig : std_logic_vector(2 downto 0);

begin
--2 filp flops synchronizer for avoiding metastability and 1 more filp flop for edge dectetion
process(clk_100M, reset_n, half_detector, full_detector)begin
	if reset_n = '0' then
		half_detector_sig <= "000";
		full_detector_sig <= "000";
	elsif rising_edge(clk_100M) then
		half_detector_sig(0) <=  half_detector;
		half_detector_sig(2 downto 1) <= half_detector_sig(1 downto 0);
		
		full_detector_sig(0) <=  full_detector;
		full_detector_sig(2 downto 1) <= full_detector_sig(1 downto 0);
		
	end if;
end process;

--edge dectetion
process(clk_100M, reset_n, half_detector_sig, full_detector_sig)begin
	if reset_n = '0' then
		half_shot <= '0';
		full_shot <= '0';
	elsif rising_edge(clk_100M) then
		if (half_detector_sig(2) = '1' and half_detector_sig(1) = '0')then
			half_shot <= '1';
		else 
			half_shot <= '0';
		end if;
			
		if (full_detector_sig(2) = '1' and full_detector_sig(1) = '0')then
			full_shot <= '1';
		else 
			full_shot <= '0';
		end if;
	end if;
	
end process;

end Behavioral;
