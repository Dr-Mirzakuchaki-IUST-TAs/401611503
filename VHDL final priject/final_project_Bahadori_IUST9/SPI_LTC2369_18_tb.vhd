LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
------------------------------
ENTITY SPI_LTC2369_18_tb IS
END SPI_LTC2369_18_tb;
------------------------------
ARCHITECTURE behavior OF SPI_LTC2369_18_tb IS 
 
   --Inputs
   signal CLK_SYS : std_logic := '0';
   signal start    : std_logic := '0';
   signal SDO     : std_logic := '0';
	signal data_in : std_logic_vector(17 downto 0) := "111100001111000011";
   signal Busy    : std_logic := '0';
	
	-- reset signal 
	signal reset        : std_logic  := '0';
	
 	--Outputs
   signal CNV     : std_logic;
   signal SCK     : std_logic;
	


   -- Clock period definitions
   constant CLK_SYS_period : time := 10 ns;
   constant SCK_period     : time := 10 ns;
	
	
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.SPI_LTC2369_18 PORT MAP (
          CLK_SYS => CLK_SYS,
          start => start,
          SDO => SDO,
          CNV => CNV,
          SCK => SCK,
			 Busy => Busy,
			 reset => reset
        ); 
 
   -- Clock process definitions
   CLK_SYS_process :process
   begin
		CLK_SYS <= '0';
		wait for CLK_SYS_period/2;
		CLK_SYS <= '1';
		wait for CLK_SYS_period/2;
   end process;
 
	
	  -- Busy generator
  Busy_pro : process
	begin
	   if(reset = '0') then
		  Busy <= '0','1' after 505 ns , '0' after 865 ns,'1' after 1065 ns, '0' after 1425 ns ;
		else 
		  -- Busy <= '0','1' after 505 ns , '0' after 865 ns,'0' after 1065 ns, '0' after 1425 ns ;
		  Busy <= '0','1' after 505 ns , '0' after 865 ns,'1' after 1065 ns, '0' after 1425 ns ;
		end if;
	 wait;
	end process;
	
	-- start genertor
	start_pro : process
		begin
			start <= '0', '1' after 490 ns, '0' after 530 ns, '1' after 1050 ns, '0' after 1090 ns;
		wait;
	end process;
   
	 -- reset process
-- 	reset_pro : process
--	 begin
--	  reset <= '0' , '1' after 1055 ns;
--	  wait;
--	 end process;
	
   -- Stimulus process
--   stim_proc: process
--   begin		
--      -- hold reset state for 100 ns.
--      wait for 100 ns;	
--
--      wait for CLK_SYS_period*10;
--
--      -- insert stimulus here 
--
--      wait;
--   end process;

END;
