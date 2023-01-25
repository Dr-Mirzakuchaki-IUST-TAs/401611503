
--------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--------------------------------

entity SPI_LTC2369_18 is
	port(
			--inputs
			CLK_SYS    : in std_logic; -- general system clock
			start      : in std_logic; -- goes High at start of each conversion and low when data(Busy)
			SDO        : in std_logic; -- read data from device
			Busy       : in std_logic;
			--outputs
			CNV        : out std_logic;-- power up and initialize conversion on each rising edge(Cs_n)
			SCK        : out std_logic;
			reset      : out std_logic

		);
end SPI_LTC2369_18;

--------------------------------

architecture Behavioral of SPI_LTC2369_18 is

   -- I/Os
   signal SDO_INT   	  : std_logic  := SDO;
	signal data_in_INT  : std_logic_vector  (17 downto 0) := (others =>'0');-- 18 bit converted data

   -- control signals
	signal CNV_INT      : std_logic  := '0';
	signal start_INT    : std_logic  := '0';  -- in order to start SPI transaction
	signal bit_CNT      : unsigned   (4 downto 0) := "10001"; -- start from 17 (MSB first)
	signal Busy_INT     : std_logic  := '0';
	signal SCK_start    : std_logic  := '0';
	signal reset_INT    : std_logic  := '0';

	--states
	type FSM  is (idle, CONV, ACQ, QUIET);
	signal state       : FSM   := idle;
	signal state_INT   : FSM;
	-- sample data
	--Constant  data_in   : std_logic_vector  (17 downto 0) := "111100001111000011";


BEGIN

    CNV       <= CNV_INT;  -- chip select
	SDO_INT   <= SDO ;     -- MISO
	Busy_INT  <= Busy;
	state_INT <= state;
	reset     <= reset_INT;

	process(CLK_SYS)
	begin

		if (rising_edge(CLK_SYS)) then
		   if (reset_INT  = '1') then
				 state    <= idle;
				 CNV_INT  <= '0';
         else

				start_INT    <= start ;

				case state is
					-- idle : Do nothing till start_INT is goes high
					when idle =>

						SDO_INT <= '0';
						bit_CNT <= "10001";
						if(start_INT = '1') then
							state    <= CONV;
							CNV_INT  <= '1';
						else
							state    <= idle;
							CNV_INT  <= '0';
						end if;
					-- Converting analog to digital when convert goes high
					when CONV =>

						if(CNV_INT = '1' or Busy = '1') then
							state <= CONV;
							CNV_INT  <= '0' after 10 ns;
						else
							state    <= ACQ;
							CNV_INT  <= '0';
						end if;
				    -- converted data is ready to send 
					when ACQ =>

							CNV_INT <= '0';
							--SDO := data_in(bit_CNT);
							data_in_INT (to_integer(bit_CNT)) <= SDO_INT ; 

							if(bit_CNT /= 0) then -- if bit_CNT not 0
								state    <= ACQ;
								bit_CNT  <= bit_CNT -1 ;
							else
								state   <= QUIET;
								bit_CNT <= "10001";
							end if ;

						-- after sending data IC needs quiet time to recieve convert order again
						when QUIET =>

								state <= idle;
								CNV_INT <= '0';
								SDO_INT  <= '0';
								bit_CNT  <= "10001";

				end case;
			end if;
		 end if;
			-- Generating SCK Clock from CLK_SYS when Busy goes Low
			if (Busy_INT = '0' and state_INT = ACQ ) then
			 SCK <= not (CLK_SYS);
			else
			 SCK <= '0';
			end if;

	end process;

	 -- reset process
 	 reset_pro : process
	 begin
	  reset_INT  <= '0' , '1' after 1425 ns;
	  wait;
	 end process;

 	 -- SCK generator
--	SCK_pro : process
--		begin
--			if(SCK_start = '1') then
--				SCK <= '0';
--				wait for SCK_period/2;
--				SCK <= '1';
--				wait for SCK_period/2;
--			else
--				SCK <= '0';
--				wait until SCK_start = '1';
--			end if;
--	end process;


   -- SCK_start generator

--	SCK_start_pro : process
--	begin
--		SCK_start  <= '0','1' after 870 ns, '0' after 1045 ns, '1' after 1430 ns, '0' after 1605 ns;
--	wait;
--	end process;


end Behavioral;

