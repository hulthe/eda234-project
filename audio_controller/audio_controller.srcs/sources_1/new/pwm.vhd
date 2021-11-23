----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 02:57:03 PM
-- Design Name: 
-- Module Name: pwm - Behavioral
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
use ieee.numeric_std.all;

entity pwm is
    Port (
        clk : in std_logic;
        reset_n: in std_logic;  
        duty_cycle : in unsigned (7 downto 0) := "00000000";
        pwm_out : out std_logic := '0'
    );
end pwm;

architecture Behavioral of pwm is
    signal cnt_duty: unsigned (7 downto 0) := "00000000";
begin


    process(clk, reset_n)
    begin
        if reset_n = '0' then
            cnt_duty <= "00000000";
        elsif rising_edge(clk) then
            if cnt_duty = "11111111" then
                cnt_duty <= "00000000";
            else
                cnt_duty <= cnt_duty + 1;
            end if;
            
        end if;
    end process;
    
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            pwm_out <= '0';
        elsif rising_edge(clk) then     
            if cnt_duty < duty_cycle then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;
        end if;
    end process;

end Behavioral;
