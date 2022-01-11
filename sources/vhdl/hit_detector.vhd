library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hit_detector is
    Port ( clk_100M : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           half_detector : in STD_LOGIC;
           full_detector : in STD_LOGIC;
           gun_detector : in STD_LOGIC;
           half_shot : out STD_LOGIC;
           full_shot : out STD_LOGIC;
           gun_hit : out STD_LOGIC);
end hit_detector;

architecture Behavioral of hit_detector is

signal half_detector_sig : std_logic_vector(2 downto 0);
signal full_detector_sig : std_logic_vector(2 downto 0);
signal gun_detector_sig : std_logic_vector(2 downto 0);
signal cnt_last_out : integer := 0;
constant cnt_last : integer := 7;
signal cnt_en : std_logic := '0';


begin
--2 filp flops synchronizer for avoiding metastability and 1 more filp flop for edge dectetion
process(clk_100M, reset_n, half_detector, full_detector, gun_detector)begin
	if reset_n = '0' then
		half_detector_sig <= "111";
		full_detector_sig <= "111";
		gun_detector_sig <= "111";
	elsif rising_edge(clk_100M) then
		half_detector_sig(0) <=  half_detector;
		half_detector_sig(2 downto 1) <= half_detector_sig(1 downto 0);
		
		full_detector_sig(0) <=  full_detector;
		full_detector_sig(2 downto 1) <= full_detector_sig(1 downto 0);
		
		gun_detector_sig(0) <=  gun_detector;
		gun_detector_sig(2 downto 1) <= gun_detector_sig(1 downto 0);
		
	end if;
end process;


process(reset_n)begin
    if reset_n = '0' then
        cnt_en <= '0';
    elsif rising_edge(clk_100M) then
        if ((half_detector_sig(2) = '1' and half_detector_sig(1) = '0') 
               or  (full_detector_sig(2) = '1' and full_detector_sig(1) = '0') 
               or  (gun_detector_sig(2) = '1' and gun_detector_sig(1) = '0')) then
            cnt_en <= '1';
        elsif (cnt_last_out = cnt_last)then
            cnt_en <= '0';
        end if;
    end if;
end process;

--falling edge dectetion
process(clk_100M, reset_n, half_detector_sig, full_detector_sig, gun_detector_sig)begin
	if reset_n = '0' then
		half_shot <= '0';
		full_shot <= '0';
		gun_hit <= '0';
	elsif rising_edge(clk_100M) then
	    if (cnt_last_out < cnt_last)then
	       if (half_detector_sig(2) = '1' and half_detector_sig(1) = '0')then
			     half_shot <= '1';
		   end if;
		else 
			half_shot <= '0';
		end if;
		
		if (cnt_last_out < cnt_last)then
	       if (full_detector_sig(2) = '1' and full_detector_sig(1) = '0')then
			     full_shot <= '1';
		   end if;
		else 
			full_shot <= '0';
		end if;
	
	   if (cnt_last_out < cnt_last)then
	       if (gun_detector_sig(2) = '1' and gun_detector_sig(1) = '0')then
			     gun_hit <= '1';
		   end if;
		else 
			gun_hit <= '0';
		end if;
	end if;
end process;

process(clk_100M, reset_n)begin
	if reset_n = '0' then
		cnt_last_out <= 0;
	elsif rising_edge(clk_100M) then
	   if (cnt_last_out = cnt_last)then
	       cnt_last_out <= 0;
	   elsif (cnt_en = '1') then
           cnt_last_out <= cnt_last_out + 1;
       end if;
	end if;
end process;

end Behavioral;
