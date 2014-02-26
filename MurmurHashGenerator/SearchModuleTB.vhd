
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
use work.SearchModule_pkg.ALL;

entity SearchModuleTB is

end SearchModuleTB;



architecture Behavioral of SearchModuleTB is
    
    constant DATA_WIDTH_A_USAR: integer := 32; 
	constant ADDR_WIDTH_A_USAR: integer := 10;
	--type arrayOfADDR_WIDTH is array ((ADDR_WIDTH_A_USAR-1) downto 0) of std_logic_vector((ADDR_WIDTH_A_USAR-1) downto 0);
	
	signal clk                          : std_logic;
    signal compare                      : std_logic;
    signal dataToCompare                : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0);
    signal operationID                  : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0);
    signal porta_wr                     : std_logic;
    signal porta_waddr                  : std_logic_vector( (ADDR_WIDTH_A_USAR-1) downto 0);
    signal porta_din                    : std_logic_vector( (DATA_WIDTH_A_USAR-1) downto 0);
    signal searchFinished               : std_logic;
    signal searchresult                 : std_logic;
    signal resultIndex                  : std_logic_vector( (ADDR_WIDTH_A_USAR-1) downto 0);
    signal result_operationID           : std_logic_vector( (DATA_WIDTH_A_USAR-1) downto 0);
    signal internalResultFinished_dbg   : std_logic_vector( (ADDR_WIDTH_A_USAR-1) downto 0);
    signal resultIndexs_dbg             : arrayOfADDR_WIDTH((ADDR_WIDTH_A_USAR-1) downto 0);
    signal dataFound_dbg                : arrayUOfDATA_WIDTH((ADDR_WIDTH_A_USAR-1) downto 0);
    
    signal errorDetected                : std_logic := '0';
    
    constant clk_period : time := 10 ns;
    
begin
    uut: entity work.SearchModule 
    generic map ( 
    	DATA_WIDTH => DATA_WIDTH_A_USAR,
    	ADDR_WIDTH => ADDR_WIDTH_A_USAR
    )
    port map (
        clk => clk, 
        compare => compare, 
        dataToCompare => dataToCompare,
        operationID => operationID,
        porta_wr   => porta_wr,
        porta_waddr => porta_waddr,
        porta_din  => porta_din,
        searchFinished => searchFinished,
        searchresult => searchresult,
        resultIndex => resultIndex,
        result_operationID => result_operationID,
        internalResultFinished_dbg => internalResultFinished_dbg,
        resultIndexs_dbg => resultIndexs_dbg,
        dataFound_dbg => dataFound_dbg
    );
    
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process; 


    test : process
        variable readWriteCounter : integer := 0;
        variable dataToWrite : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0) := ( others => '0');
        variable addrToWrite : std_logic_vector((ADDR_WIDTH_A_USAR-1) downto 0) := ( others => '0');        
    begin
        -- Primero grabar los datos en la memoria
        compare <= '0';
        dataToCompare <= (others => '0');
        operationID <= (others => '0');
        dataToWrite := x"10000000";
        porta_wr <= '0';
        porta_waddr <= (others => '0');
        porta_din <= (others => '0');
        wait for 10*clk_period;
        porta_wr <= '0';
        porta_waddr     <=      addrToWrite;
        porta_din     <=      dataToWrite;
        wait for clk_period;
        
        while readWriteCounter < (2**ADDR_WIDTH_A_USAR)  loop
               porta_wr   <= '1';
               porta_waddr     <=      addrToWrite;
               porta_din     <=      dataToWrite;
               wait for clk_period;
               porta_wr   <= '0';
               wait for clk_period;
               dataToWrite := dataToWrite+1;
               addrToWrite := addrToWrite+1;
               readWriteCounter := readWriteCounter+1;
        end loop;
        
        
        
        porta_wr   <= '0';
        wait for clk_period;
        compare <= '0';
        dataToWrite := x"10000005";
        wait for clk_period;
        wait for clk_period;
        dataToCompare     <=      dataToWrite;
        compare <= '0';
        wait for clk_period;
        dataToWrite := x"10000006";
        dataToCompare     <=      dataToWrite;
        wait for clk_period;
        compare <= '0';
        wait for clk_period;           
        readWriteCounter        :=      0;
        dataToWrite             :=      x"10000000";
        addrToWrite             :=      ( others => '0' );
        while readWriteCounter < (2**ADDR_WIDTH_A_USAR)  loop
           dataToCompare     <=      dataToWrite;
           compare <= '1';
           wait for clk_period;
           compare <= '0';
           wait for clk_period;
           dataToWrite := dataToWrite+1;
           addrToWrite := addrToWrite+1;
           readWriteCounter := readWriteCounter+1;
        end loop;
        compare <= '0';

        wait for clk_period;
        wait;
    end process;


    verification: process
        variable verifCounter : integer := 0;    
        variable dataToWrite : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0) := x"10000000";
        variable verifDataCounter : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0) := (others => '0');      
    begin
    errorDetected <= '0';

    
    if( rising_edge(clk) ) then
       
       if( verifCounter >= (2**ADDR_WIDTH_A_USAR) ) then
                   errorDetected <= '0';
       else
           if (searchFinished = '1') then
               if( (verifDataCounter/=resultIndex)  ) then
                   errorDetected <= '1';
               else
                   errorDetected <= '0';
               end if;             
               verifCounter        := verifCounter+1;
               dataToWrite         := dataToWrite+1;
               verifDataCounter    := verifDataCounter+1;
           else
               errorDetected <= '0';
           end if;
       end if;
    end if;
    
    wait;
         
    end process verification;










end Behavioral;
