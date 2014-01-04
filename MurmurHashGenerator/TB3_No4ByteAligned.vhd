----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2013 00:20:28
-- Design Name: 
-- Module Name: TestBench1_FourByteAlignedTests - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Esta prueba solo realzia una unica prueba al modulo
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

entity TB3_No4ByteAligned is
end TB3_No4ByteAligned;

architecture Behavioral of TB3_No4ByteAligned is

-- Signals to evaluate
    --ENTRADAS
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
    signal clk : std_logic;
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

    signal dataStepA_dbg    : std_logic_vector(31 downto 0);
    signal dataStepA_ID_dbg : std_logic_vector(31 downto 0);
    signal dataStepB_dbg    : std_logic_vector(31 downto 0);
    signal dataStepB_ID_dbg : std_logic_vector(31 downto 0);
    signal dataStepC_dbg    : std_logic_vector(31 downto 0);
    signal dataStepC_ID_dbg : std_logic_vector(31 downto 0);
    signal dataStepD_dbg    : std_logic_vector(31 downto 0);
    signal dataStepD_ID_dbg : std_logic_vector(31 downto 0);

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
    
    



    type resultReference is array (0 to 13) of std_logic_vector(31 downto 0);
    constant resultsBank : resultReference := ( x"6b6cf591", x"fbf1402a", x"2362f9de", x"fbf1402a", x"40b23b7f", x"32850971", x"9994d794", x"4c382e54", x"7117fdd0", x"db55ec24", x"76293b50", x"7e33a1a1", x"82f2c7d0", x"885962c1" );
    constant opsIDs      : resultReference := ( x"6b6cf591", x"fbf1402a", x"2362f9de", x"fbf1402a", x"40b23b7f", x"32850971", x"9994d794", x"4c382e54", x"7117fdd0", x"db55ec24", x"76293b50", x"7e33a1a1", x"82f2c7d0", x"885962c1" );
        
    signal resultsBankCounter : integer := 0;   
    signal errorDetected : std_logic := '0';    
    -- Clock period definitions
    constant clk_period : time := 10 ns;
begin
    
    --Inicializar el banco de resultados
    
    verification: process (clk, resultReady, result, resultsBankCounter)             
    begin
        if( rising_edge(clk) ) then
            --if( resultsBankCounter = resultReference'length ) then
            if( resultsBankCounter = 1 ) then
                        errorDetected <= '0';
            else
                if (resultReady = '1') then
                    if( (resultsBank(resultsBankCounter)/=result) or (resultID/=opsIDs(resultsBankCounter)) ) then
                        errorDetected <= '1';
                    else
                        errorDetected <= '0';
                    end if;
                    resultsBankCounter <= resultsBankCounter+1;
                    
                else
                    errorDetected <= '0';
                end if;
            end if;
        end if;
    end process verification;


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
          
          dataStepA_dbg => dataStepA_dbg,
          dataStepB_dbg => dataStepB_dbg,
          dataStepC_dbg => dataStepC_dbg,
          dataStepD_dbg => dataStepD_dbg,
          
          dataStepA_ID_dbg => dataStepA_ID_dbg,
          dataStepB_ID_dbg => dataStepB_ID_dbg,
          dataStepC_ID_dbg => dataStepC_ID_dbg,   
          dataStepD_ID_dbg => dataStepD_ID_dbg,   
                    
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




-- Stimulus process
stim_proc: process
       begin                
          -- hold reset state for 100 ns.
          wait for clk_period*10;
          
          
          blockLength <= "00";
          --operationID <= "0101"&"0101"&"0101"&"0101"&"0101"&"0101"&"0101"&"0101";
          operationID <= opsIDs(0);
          --PRUEBA 1, HASH DEL VECTOR 0
          --Se einicializan los datos y
          inputBlock  <= x"000000de";
          start <= '1';    
          finalBlock <= '1';
          seed <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
          readInput <= '0';
          wait for clk_period;
          --hacer que realize una lectura de datos
          readInput <= '1';          
          wait for clk_period;          
          start <= '0';--que ya no lea otro dato
          readInput <= '0';
          wait for clk_period;
--          --Prueba 2 hash del vector 1
--          blockLength <= "11";
--          inputBlock  <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0001";
--          operationID <= opsIDs(1);
--          finalBlock <= '1';
--          seed <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
--          start <= '1';     
--          readInput <= '0';
--          wait for clk_period;
--          --hacer que realize una lectura de datos
--          readInput <= '1';          
--          wait for clk_period;          
--          start <= '0';--que ya no lea otro dato
--          readInput <= '0';
--          wait for clk_period;
--          wait for clk_period;
--          --PROBAR QUE AMBAS SALIDAS CONSECUTIVAS SE REALIZEN DE FORMA CONSECUTIVA          
--           start <= '1';    
--           finalBlock <= '1';
--           readInput <= '1';
--           seed <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
--           --Probando valroes consecutivos
--           inputBlock  <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
--           operationID <= opsIDs(2);
--           wait for clk_period;
--           inputBlock  <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0001";
--           operationID <= opsIDs(3);
--           wait for clk_period;
--           inputBlock  <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0010";
--           operationID <= opsIDs(4);
--           wait for clk_period;
--           inputBlock  <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0011";
--           operationID <= opsIDs(5);
--           wait for clk_period;
--           readInput <= '0';
--           wait for clk_period;
--           readInput <= '1';
--           inputBlock  <= "1000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
--           operationID <= opsIDs(6);
--           wait for clk_period;
--           inputBlock  <= "0100"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
--           operationID <= opsIDs(7);
--           wait for clk_period;
--           inputBlock  <= "1100"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
--           operationID <= opsIDs(8);
--           wait for clk_period;
--           inputBlock  <= "0010"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
--           operationID <= opsIDs(9);
--           wait for clk_period;           
           
--           inputBlock  <= "1111"&"1111"&"1111"&"1111"&"1111"&"1111"&"1111"&"1111";
--           operationID <= opsIDs(10);
--           wait for clk_period;
--           inputBlock  <= "1111"&"0000"&"1111"&"0000"&"1111"&"0000"&"1111"&"0000";
--           operationID <= opsIDs(11);
--           wait for clk_period;
--           inputBlock  <= "0000"&"1111"&"0000"&"1111"&"0000"&"1111"&"0000"&"1111";
--           operationID <= opsIDs(12);
--           wait for clk_period;
--           inputBlock  <= "1100"&"1100"&"1100"&"1100"&"1100"&"1100"&"1100"&"1100";
--           operationID <= opsIDs(13);
--           wait for clk_period;           
           
           
           
           readInput <= '0';
           wait for clk_period;
           
         wait;
end process stim_proc;

end Behavioral;
