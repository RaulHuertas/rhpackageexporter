----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.01.2014 14:32:21
-- Design Name: 
-- Module Name: TB4_FileBasedTest - Behavioral
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
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
use work.MurmurHashUtils.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB4_FileBasedTest is
end TB4_FileBasedTest;

architecture Behavioral of TB4_FileBasedTest is
        signal clk : std_logic;
        constant clk_period : time := 10 ns;
        signal errorDetected : std_logic := '0';   
        -- Signals to evaluate
        --ENTRADAS
        signal actualTestTotalLength : std_logic_vector(31 downto 0);
        signal inputBlock : std_logic_vector(31 downto 0);
        signal readInput : std_logic;
        signal blockLength : std_logic_vector(1 downto 0);
        signal finalBlock : std_logic;
        signal start : std_logic;
        signal operationID : std_logic_vector(31 downto 0);
        signal seed : std_logic_vector(31 downto 0);
        --SALIDAS
        signal canAccept : std_logic;
        signal resultReady : std_logic;
        signal result : std_logic_vector(31 downto 0);
        signal resultID : std_logic_vector(31 downto 0);
        --RELOJ
        --Salidas de depuracion
        signal dataStep1_dbg : std_logic_vector(31 downto 0);
        signal dataStep2_dbg : std_logic_vector(31 downto 0);
        signal dataStep3_dbg : std_logic_vector(31 downto 0);
        signal dataStep4_dbg : std_logic_vector(31 downto 0);
        signal dataStep5_dbg : std_logic_vector(31 downto 0);
        signal dataStep1_ID_dbg : std_logic_vector(31 downto 0);
        signal dataStep2_ID_dbg : std_logic_vector(31 downto 0);
        signal dataStep3_ID_dbg : std_logic_vector(31 downto 0);
        signal dataStep4_ID_dbg : std_logic_vector(31 downto 0);
        signal dataStep5_ID_dbg : std_logic_vector(31 downto 0);
    
        signal finalStep1_dbg : std_logic_vector(31 downto 0);
        signal finalStep2_dbg : std_logic_vector(31 downto 0);
        signal finalStep3_dbg : std_logic_vector(31 downto 0);
        signal finalStep4_dbg : std_logic_vector(31 downto 0);
        signal finalStep5_dbg : std_logic_vector(31 downto 0);
        signal finalStep1_ID_dbg : std_logic_vector(31 downto 0);
        signal finalStep2_ID_dbg : std_logic_vector(31 downto 0);
        signal finalStep3_ID_dbg : std_logic_vector(31 downto 0);
        signal finalStep4_ID_dbg : std_logic_vector(31 downto 0);
        signal finalStep5_ID_dbg : std_logic_vector(31 downto 0);
        
        signal resultsBankCounterSignal : integer := 0;
        
begin
    seed <= simulationSeed;
    uut: work.MurmurHashUtils.MurmurHash32Generator PORT MAP (
          --ENTRADAS
          inputBlock => inputBlock,
          readInput => readInput,
          blockLength => blockLength,
          finalBlock => finalBlock,
          start => start,
          operationID => operationID,
          seed => seed,
          --SALIDAS
          canAccept => canAccept,
          resultReady => resultReady,
          result => result,
          resultID => resultID,
          --RELOJ
          clk => clk,
          --Salidas de depuracion
          dataStep1_dbg => dataStep1_dbg,
          dataStep2_dbg => dataStep2_dbg,
          dataStep3_dbg => dataStep3_dbg,
          dataStep4_dbg => dataStep4_dbg,
          dataStep5_dbg => dataStep5_dbg,
          dataStep1_ID_dbg => dataStep1_ID_dbg,
          dataStep2_ID_dbg => dataStep2_ID_dbg,
          dataStep3_ID_dbg => dataStep3_ID_dbg,
          dataStep4_ID_dbg => dataStep4_ID_dbg,
          dataStep5_ID_dbg => dataStep5_ID_dbg,
          finalStep1_dbg => finalStep1_dbg,
          finalStep2_dbg => finalStep2_dbg,
          finalStep3_dbg => finalStep3_dbg,
          finalStep4_dbg => finalStep4_dbg,
          finalStep5_dbg => finalStep5_dbg,
          finalStep1_ID_dbg => finalStep1_ID_dbg,
          finalStep2_ID_dbg => finalStep2_ID_dbg,
          finalStep3_ID_dbg => finalStep3_ID_dbg,
          finalStep4_ID_dbg => finalStep4_ID_dbg,
          finalStep5_ID_dbg => finalStep5_ID_dbg
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;   
    
    
    verification: process (clk, resultReady, result, resultsBankCounterSignal)             
    begin
        if( rising_edge(clk) ) then
            if( resultsBankCounterSignal = resultsBank'length ) then
                        errorDetected <= '0';
            else
                if (resultReady = '1') then
                    if( (resultsBank(resultsBankCounterSignal)/=result)  ) then
                        errorDetected <= '1';
                    else
                        errorDetected <= '0';
                    end if;
                    resultsBankCounterSignal <= resultsBankCounterSignal+1;                    
                else
                    errorDetected <= '0';
                end if;
            end if;
        end if;
    end process verification;
    
    
    Test: process  is
        variable byteCounter : integer := 0;--contador de bytes en el bloque de datos actual
        variable byteInputCounter : integer := 0;-- contador de bytes totales elidos en el testBench
        variable resultsBankCounter : integer := 0;
        variable actualByte : std_logic_vector(7 downto 0);-- byet actualmetne leido
        variable inputBlockCurrentByte : integer :=0;
        variable input : std_logic_vector(31 downto 0) := (others => '0') ;
        variable startBlock : boolean := false;
        variable endBlock : boolean := false;
    begin
        start <= '0';--que ya no lea otro dato
        readInput <= '0';
        operationID <= ( others => '0');
        wait for clk_period*10;
        
        
        while (resultsBankCounter < resultsBank'length) loop
            start <= '0';--que ya no lea otro dato
            readInput <= '0'; 
            inputBlockCurrentByte  := 0;
            byteCounter:=0;
            inputBlockCurrentByte := 0;
            wait for clk_period;
            start <= '1';
            actualTestTotalLength <= entrysLengths(resultsBankCounter);
            while(byteCounter<entrysLengths(resultsBankCounter)) loop
                actualByte := dataBank(byteInputCounter);
                input((inputBlockCurrentByte*8+7) downto (inputBlockCurrentByte*8)) := actualByte;
                --input(7 downto 0) := actualByte;
                
                endBlock := ((byteCounter+1)=entrysLengths(resultsBankCounter));
                if (   ( (byteCounter mod 4) = 3 ) or (endBlock) ) then
                    finalBlock<= mh3_boolean_to_std_logic(endBlock);
                    inputBlock <= input;
                    readInput <= '1'; 
                    blockLength <= std_logic_vector( to_unsigned(byteCounter, 2) );
                    wait for clk_period;
                    start <= '0';
                    input := (others => '0') ;
                end if;
                if (endBlock) then
                    readInput <= '0';
                    wait for clk_period;
                end if;
                byteCounter := byteCounter+1;
                byteInputCounter := byteInputCounter+1;
                inputBlockCurrentByte := ( (inputBlockCurrentByte+1) mod 4);
            end loop;        
            resultsBankCounter := resultsBankCounter+1;   
            --wait for clk_period;
        end loop;
        
        wait;-- Que no se repita de forma indefinida
    end process Test;

end Behavioral;
