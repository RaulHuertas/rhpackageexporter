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

entity TestBench1_FourByteAlignedTests is
end TestBench1_FourByteAlignedTests;

architecture Behavioral of TestBench1_FourByteAlignedTests is

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





    -- Clock period definitions
    constant clk_period : time := 10 ns;
begin
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

-- Stimulus process
stim_proc: process
       begin                
          -- hold reset state for 100 ns.
          wait for clk_period*10;
          
          --PRUEBA 1, HASH DEL VECTOR 0
          --Se einicializan los datos y
          inputBlock  <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";   
          blockLength <= "11";
          finalBlock <= '1';
          start <= '1';          
          operationID <= "0101"&"0101"&"0101"&"0101"&"0101"&"0101"&"0101"&"0101";
          seed <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
          readInput <= '0';
          wait for clk_period;
          --hacer que realize una lectura de datos
          readInput <= '1';          
          wait for clk_period;
          
          start <= '0';--que ya no lea otro dato
          readInput <= '0';
          wait for clk_period;
          
         wait;
end process stim_proc;

end Behavioral;
