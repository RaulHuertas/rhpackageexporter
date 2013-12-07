-- Murmur Hash Code Generator
-- Author: Raul Gerardo Huertas Paiva

--Copyright (c) 2014, Raul Huertas
--All rights reserved.
----Redistribution and use in source and binary forms, with or without
----modification, are permitted provided that the following conditions are met: 
----
----1. Redistributions of source code must retain the above copyright notice, this
--   list of conditions and the following disclaimer. 
--2. Redistributions in binary form must reproduce the above copyright notice,
--   this list of conditions and the following disclaimer in the documentation
--   and/or other materials provided with the distribution. 
--
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
--ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--The views and conclusions contained in the software and documentation are those
--of the authors and should not be interpreted as representing official policies, 
--either expressed or implied, of the FreeBSD Project.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
use work.MurmurHashUtils.ALL;

entity MurmurHash32Generator is
	generic ( 
		ID_PRESENT: boolean := true; 
		ID_LENGTH: integer := 31
	);
	port(
		--ENTRADAS
		inputBlock : in std_logic_vector(31 downto 0);
		readInput : in std_logic;
		blockLength : in std_logic_vector(1 downto 0);
		finalBlock : in std_logic;
		start : in std_logic;
		operationID : in std_logic_vector(ID_LENGTH downto 0);
		seed : in std_logic_vector(31 downto 0);
		--SALIDAS
		canAccept : out std_logic;
		resultReady : out std_logic;
		result : out std_logic_vector(31 downto 0);
		resultID : out std_logic_vector(ID_LENGTH downto 0);
		--RELOJ
		clk : in std_logic;
		--Salidas de depuracion
		dataStep1_dbg : out std_logic_vector(31 downto 0);
		dataStep2_dbg : out std_logic_vector(31 downto 0);
		dataStep3_dbg : out std_logic_vector(31 downto 0);
		dataStep4_dbg : out std_logic_vector(31 downto 0);
		dataStep5_dbg : out std_logic_vector(31 downto 0);
        dataStep1_ID_dbg : out std_logic_vector(31 downto 0);
        dataStep2_ID_dbg : out std_logic_vector(31 downto 0);
        dataStep3_ID_dbg : out std_logic_vector(31 downto 0);
        dataStep4_ID_dbg : out std_logic_vector(31 downto 0);
      	dataStep5_ID_dbg : out std_logic_vector(31 downto 0)
	);
end MurmurHash32Generator;



architecture Estructural of MurmurHash32Generator is
    
    signal trabajando :  boolean ;
    signal resultStep1 : Step1_Capture;
    signal resultStep2 : Step2_C1Mult;
    signal resultStep3 : Step3_R1;
    signal resultStep4 : Step4_C2Mult;
    signal resultStep5 : Step5_HashResult;
    
    signal K : std_logic_vector(31 downto 0);
    signal Hash : std_logic_vector(31 downto 0);
    
begin
--Conectando las salidas de depuracion 
dataStep1_dbg <= resultStep1.data;
dataStep2_dbg <= resultStep2.data;
dataStep3_dbg <= resultStep3.data;
dataStep4_dbg <= resultStep4.data;
dataStep5_dbg <= resultStep5.hash;
dataStep1_ID_dbg <= resultStep1.operationID;
dataStep2_ID_dbg <= resultStep2.operationID;
dataStep3_ID_dbg <= resultStep3.operationID;
dataStep4_ID_dbg <= resultStep4.operationID;
dataStep5_ID_dbg <= resultStep5.operationID;


canAccept <= '1';-- Siemrpe se debe poder recibir datos en este core

K <= resultStep4.data;-- El valor final de K en la pipeline
Hash <= resultStep5.hash;



--Definiendo la captura de datos
CaptureStep: process(clk, inputBlock, readInput, blockLength, finalBlock, start, operationID, seed)  begin
    if rising_edge(clk) then
        if(readInput = '1') then
            resultStep1.dataValid <= true;
            resultStep1.data <= (inputBlock);
            resultStep1.dataLength <= blockLength;
            resultStep1.isFirst <= (start='1');
            resultStep1.isLast <= (finalBlock='1');
            if (start='1') then
                resultStep1.operationID <= operationID;
            end if;
            resultStep1.seed <= seed;
        else
            resultStep1.dataValid <= false;
        end if;--readInput
    end if;--clk
    
end process CaptureStep;

C1MultStep: process(clk, resultStep1)  
    variable c1MutlResult : std_logic_vector(63 downto 0); 
    begin    
    if rising_edge(clk) then
        if(resultStep1.dataValid) then
            c1MutlResult := (resultStep1.data*C1); 
            resultStep2.dataValid <= true;
            resultStep2.data <= c1MutlResult(31 downto 0);
            resultStep2.dataLength <= resultStep1.dataLength;
            resultStep2.isFirst <= resultStep1.isFirst;
            resultStep2.isLast <= resultStep1.isLast;
            resultStep2.operationID <= resultStep1.operationID;
            resultStep2.seed <= resultStep1.seed;
        else
            resultStep2.dataValid <= false;
        end if;--readInput   
        
    end if;--clk
end process C1MultStep;

R1Step: process(clk, resultStep2)  
    begin    
    if rising_edge(clk) then
        
        if(resultStep2.dataValid) then
            
            resultStep3.dataValid           <= true;
            resultStep3.data(31 downto 13)                <= resultStep2.data(18 downto 0);
            resultStep3.data(12 downto 0)                <= resultStep2.data(31 downto 19);
            resultStep3.dataLength          <= resultStep2.dataLength;
            resultStep3.isFirst             <= resultStep2.isFirst;
            resultStep3.isLast              <= resultStep2.isLast;
            resultStep3.operationID         <= resultStep2.operationID;
            resultStep3.seed                <= resultStep2.seed;
        else
            resultStep3.dataValid           <= false;
        end if;--readInput   
        
    end if;--clk
end process R1Step;


C2MultStep: process(clk, resultStep3)  
    variable c2MutlResult : std_logic_vector(63 downto 0); 
    begin    
    if rising_edge(clk) then
        
        if(resultStep3.dataValid) then
            c2MutlResult := (resultStep3.data*C2); 
            resultStep4.dataValid       <= true;
            resultStep4.data            <= c2MutlResult(31 downto 0);
            resultStep4.dataLength      <= resultStep3.dataLength;
            resultStep4.isFirst         <= resultStep3.isFirst;
            resultStep4.isLast          <= resultStep3.isLast;
            resultStep4.operationID     <= resultStep3.operationID;
            resultStep4.seed            <= resultStep3.seed;
        else           
            resultStep4.dataValid <= false;
        end if;--readInput   
        
    end if;--clk
end process C2MultStep;

UpdateHashStep: process(clk, resultStep4, Hash, K) 
begin
    if(resultStep4.dataValid) then
        
        if(resultStep4.isFirst)then
            resultStep5.hash <= funcionFinalHashOperation_4B(resultStep4.seed, K);
        else
            resultStep5.hash <= funcionFinalHashOperation_4B(Hash, K);
        end if;
        resultStep5.operationID <= resultStep4.operationID;
        resultStep5.resultReady <= (resultStep4.isLast);
    else
        
    end if;--readInput  
    
end process UpdateHashStep;

--Conectando las salidas a este ultimo paso
resultReady <= mh3_boolean_to_std_logic(resultStep5.resultReady);
result <= resultStep5.hash;
resultID <= resultStep5.operationID;


end architecture Estructural;

