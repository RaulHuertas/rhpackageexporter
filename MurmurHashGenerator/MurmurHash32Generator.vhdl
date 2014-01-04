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
      	dataStep5_ID_dbg : out std_logic_vector(31 downto 0);
      	
      	dataStepA_dbg : out std_logic_vector(31 downto 0);
      	dataStepB_dbg : out std_logic_vector(31 downto 0);
        dataStepC_dbg : out std_logic_vector(31 downto 0);
        dataStepD_dbg : out std_logic_vector(31 downto 0);
        
        dataStepA_ID_dbg : out std_logic_vector(31 downto 0);
        dataStepB_ID_dbg : out std_logic_vector(31 downto 0);        
        dataStepC_ID_dbg : out std_logic_vector(31 downto 0);        
        dataStepD_ID_dbg : out std_logic_vector(31 downto 0);
      	        
        finalStep1_dbg : out std_logic_vector(31 downto 0);
        finalStep2_dbg : out std_logic_vector(31 downto 0);
        finalStep3_dbg : out std_logic_vector(31 downto 0);
        finalStep4_dbg : out std_logic_vector(31 downto 0);
        finalStep5_dbg : out std_logic_vector(31 downto 0);
        finalStep1_ID_dbg : out std_logic_vector(31 downto 0);
        finalStep2_ID_dbg : out std_logic_vector(31 downto 0);
        finalStep3_ID_dbg : out std_logic_vector(31 downto 0);
        finalStep4_ID_dbg : out std_logic_vector(31 downto 0);
        finalStep5_ID_dbg : out std_logic_vector(31 downto 0)        
	);
end MurmurHash32Generator;



architecture Estructural of MurmurHash32Generator is
    
    signal trabajando   :  boolean ;
    -- Resultados de analizar datos alineados a 4 bytes
    signal resultStep1  : Step1_Capture;
    signal resultStep2  : Step2_C1Mult;
    signal resultStep3  : Step3_R1;
    signal resultStep4  : Step4_C2Mult;
    signal resultStep5  : Step5_HashResult;
    -- Resultados de analizar datos NO alineados a 4 bytes
    signal resultStepA  : Step1_EndianSwap;
    signal resultStepB  : Step2_C1Mult;
    signal resultStepC  : Step3_R1;
    signal resultStepD  : Step4_C2Mult;
    --Combinar ambos resultados
    signal mixed        : FinalStep;
    signal finalStep1   : FinalStep;
    signal finalStep2   : FinalStep;
    signal finalStep3   : FinalStep;
    signal finalStep4   : FinalStep;
    signal finalStep5   : FinalStep;
    signal finalStep6   : FinalStep;
    signal lengthCounter: unsigned(31 downto 0);    
    
    signal stepAdata        : std_logic_vector(31 downto 0);
    signal CompletedDataA   : std_logic_vector(31 downto 0);
    signal CompletedDataB   : std_logic_vector(31 downto 0);
    signal CompletedDataC   : std_logic_vector(31 downto 0);
    signal dataBeatValidQ : boolean;	
    --signal K : std_logic_vector(31 downto 0);
    --signal Hash : std_logic_vector(31 downto 0);
    
begin
--Conectando las salidas de depuracion 
dataStep1_dbg <= resultStep1.data;
dataStep2_dbg <= resultStep2.data;
dataStep3_dbg <= resultStep3.data;
dataStep4_dbg <= resultStep4.data;
dataStep5_dbg <= resultStep5.hash;

dataStepA_dbg <= resultStepA.data;
dataStepA_ID_dbg <= resultStepA.operationID;
dataStepB_dbg <= resultStepB.data;
dataStepB_ID_dbg <= resultStepB.operationID;
dataStepC_dbg <= resultStepC.data;
dataStepC_ID_dbg <= resultStepC.operationID;
dataStepD_dbg <= resultStepD.data;
dataStepD_ID_dbg <= resultStepD.operationID;

dataStep1_ID_dbg <= resultStep1.operationID;
dataStep2_ID_dbg <= resultStep2.operationID;
dataStep3_ID_dbg <= resultStep3.operationID;
dataStep4_ID_dbg <= resultStep4.operationID;
dataStep5_ID_dbg <= resultStep5.operationID;


finalStep1_dbg <= finalStep1.hash;
finalStep2_dbg <= finalStep2.hash;
finalStep3_dbg <= finalStep3.hash;
finalStep4_dbg <= finalStep4.hash;
finalStep5_dbg <= finalStep5.hash;
finalStep1_ID_dbg <= finalStep1.operationID;
finalStep2_ID_dbg <= finalStep2.operationID;
finalStep3_ID_dbg <= finalStep3.operationID;
finalStep4_ID_dbg <= finalStep4.operationID;
finalStep5_ID_dbg <= finalStep5.operationID;

canAccept <= '1';-- Siemrpe se debe poder recibir datos en este core

--Definiendo la captura de datos
CaptureStep: process(clk, inputBlock, readInput, blockLength, finalBlock, start, operationID, seed)  begin
    if rising_edge(clk) then
        if(readInput = '1') then
            
            resultStep1.data <= (inputBlock);
            resultStep1.dataLength <= blockLength;
            resultStep1.isFirst <= (start='1');
            resultStep1.isLast <= (finalBlock='1');            
            if (start='1') then
                resultStep1.operationID <= operationID;    
            end if;
            resultStep1.seed <= seed;
       
        end if;--readInput
        resultStep1.dataValid <= (readInput='1');
    end if;--clk
    
end process CaptureStep;


C1MultStep: process(clk, resultStep1)  
    variable c1MutlResult : std_logic_vector(63 downto 0);
    variable dataBeatValidQ : boolean; 
    begin   
    c1MutlResult := (resultStep1.data*C1); 
    dataBeatValidQ := resultStep1.dataValid and (resultStep1.dataLength="11");
    if rising_edge(clk) then
        if(dataBeatValidQ) then   
            resultStep2.data <= c1MutlResult(31 downto 0);
            resultStep2.dataLength <= resultStep1.dataLength;
            resultStep2.isFirst <= resultStep1.isFirst;
            resultStep2.isLast <= resultStep1.isLast;
            resultStep2.operationID <= resultStep1.operationID;
            resultStep2.seed <= resultStep1.seed;
        end if;--readInput   
        resultStep2.dataValid <= dataBeatValidQ;
    end if;--clk
end process C1MultStep;


CompletedDataA <= x"00"&x"00"&x"00"&resultStep1.data(7 downto 0);
CompletedDataB <= x"00"&x"00"&resultStep1.data(15 downto 0);
CompletedDataC <= x"00"&resultStep1.data(23 downto 0);
with resultStep1.dataLength select
    			 stepAdata <=         CompletedDataA     when "00",
    								  CompletedDataB     when "01",
    								  CompletedDataC     when "10",
    								  (others => '-')    when others;
dataBeatValidQ	<= (resultStep1.dataValid) and (resultStep1.dataLength/="11");						  
StepA_EndianSwapProcess: process(clk, resultStep1, stepAdata, dataBeatValidQ)  	
begin  
--	   if (resultStep1.dataLength="00") then
--		  stepAdata := CompletedDataA;
--	   elsif (resultStep1.dataLength="01") then
--		  stepAdata := CompletedDataB;
--	   elsif (resultStep1.dataLength="10") then
--		  stepAdata := CompletedDataC;
--	   else
--		  stepAdata := (others => '-');
--	   end if; 
--	   case resultStep1.dataLength is
--	       when "00"   => stepAdata := CompletedDataA;
--		   when "01"   => stepAdata := CompletedDataB;
--		   when "10"   => stepAdata := CompletedDataC;               
--		   when others => stepAdata := (others => '-');                
--	   end case;
       if rising_edge(clk) then        
         if(dataBeatValidQ) then        	
            resultStepA.data <= stepAdata;
            resultStepA.dataLength <= resultStep1.dataLength;
            resultStepA.isFirst <= resultStep1.isFirst;
            resultStepA.isLast <= resultStep1.isLast;
            resultStepA.operationID <= resultStep1.operationID;
            resultStepA.seed <= resultStep1.seed;
         end if;
         resultStepA.dataValid <= dataBeatValidQ;
       end if;--clk
end process StepA_EndianSwapProcess;

StepB_C1Mult: process(clk, resultStepA)  
    variable c1MutlResult : std_logic_vector(63 downto 0); 
    begin   
    c1MutlResult := (resultStepA.data*C1); 
    if rising_edge(clk) then
        if(resultStepA.dataValid) then   
            resultStepB.data <= c1MutlResult(31 downto 0);
            resultStepB.dataLength <= resultStepA.dataLength;
            resultStepB.isFirst <= resultStepA.isFirst;
            resultStepB.isLast <= resultStepA.isLast;
            resultStepB.operationID <= resultStepA.operationID;
            resultStepB.seed <= resultStepA.seed;
        end if;--readInput   
        resultStepB.dataValid <= resultStepA.dataValid;
    end if;--clk
end process StepB_C1Mult;

StepC_R1Rotation: process(clk, resultStepB)  
    begin    
    if rising_edge(clk) then        
        if(resultStepB.dataValid) then
            resultStepC.data(31 downto 15)                <= resultStepB.data(16 downto 0);
            resultStepC.data(14 downto 0)                 <= resultStepB.data(31 downto 17);
            resultStepC.dataLength          <= resultStepB.dataLength;
            resultStepC.isFirst             <= resultStepB.isFirst;
            resultStepC.isLast              <= resultStepB.isLast;
            resultStepC.operationID         <= resultStepB.operationID;
            resultStepC.seed                <= resultStepB.seed;        
        end if;--readInput   
        resultStepC.dataValid           <= resultStepB.dataValid;
    end if;--clk
end process StepC_R1Rotation;

StepD_C2Mult: process(clk, resultStepC)  
    variable c2MutlResult : std_logic_vector(63 downto 0); 
    begin
    c2MutlResult := (resultStepC.data*C2);     
    if rising_edge(clk) then        
        if(resultStepC.dataValid) then                        
            resultStepD.data            <= c2MutlResult(31 downto 0);
            resultStepD.dataLength      <= resultStepC.dataLength;
            resultStepD.isFirst         <= resultStepC.isFirst;
            resultStepD.isLast          <= resultStepC.isLast;
            resultStepD.operationID     <= resultStepC.operationID;
            resultStepD.seed            <= resultStepC.seed;        
        end if;--readInput   
        resultStepD.dataValid       <= resultStepC.dataValid;
    end if;--clk
end process StepD_C2Mult;


R1Step: process(clk, resultStep2)  
    begin    
    if rising_edge(clk) then        
        if(resultStep2.dataValid) then
            resultStep3.data(31 downto 15)                <= resultStep2.data(16 downto 0);
            resultStep3.data(14 downto 0)                 <= resultStep2.data(31 downto 17);
            resultStep3.dataLength          <= resultStep2.dataLength;
            resultStep3.isFirst             <= resultStep2.isFirst;
            resultStep3.isLast              <= resultStep2.isLast;
            resultStep3.operationID         <= resultStep2.operationID;
            resultStep3.seed                <= resultStep2.seed;        
        end if;--readInput   
        resultStep3.dataValid           <= resultStep2.dataValid;
    end if;--clk
end process R1Step;


C2MultStep: process(clk, resultStep3)  
    variable c2MutlResult : std_logic_vector(63 downto 0); 
    begin
    c2MutlResult := (resultStep3.data*C2);     
    if rising_edge(clk) then        
        if(resultStep3.dataValid) then                        
            resultStep4.data            <= c2MutlResult(31 downto 0);
            resultStep4.dataLength      <= resultStep3.dataLength;
            resultStep4.isFirst         <= resultStep3.isFirst;
            resultStep4.isLast          <= resultStep3.isLast;
            resultStep4.operationID     <= resultStep3.operationID;
            resultStep4.seed            <= resultStep3.seed;        
        end if;--readInput   
        resultStep4.dataValid       <= resultStep3.dataValid;
    end if;--clk
end process C2MultStep;

UpdateHashStep: process(clk, resultStep4, resultStep5, resultStepD)  
variable dataAvailable : boolean;
variable selectOrigin: std_logic_vector( 1 downto 0 );
variable newHash: std_logic_vector( 31 downto 0 );
begin
    if rising_edge(clk) then
		  dataAvailable := resultStep4.dataValid or resultStepD.dataValid;
		  selectOrigin := mh3_boolean_to_std_logic(resultStep4.dataValid) & mh3_boolean_to_std_logic(resultStepD.dataValid);
          if(dataAvailable) then          
              case selectOrigin is
              when "01" => 
                if(resultStepD.isFirst)then
                      newHash := resultStepD.seed xor resultStepD.data;
                else
                      newHash := resultStep5.hash xor resultStepD.data;
                end if;
					 
					 resultStep5.operationID <= resultStepD.operationID;
					 resultStep5.isFirst <= (resultStepD.isFirst);
					 resultStep5.isLast <= (resultStepD.isLast);
					 resultStep5.dataLength      <= resultStepD.dataLength;
					 
              when "10" =>
                  if(resultStep4.isFirst)then
                        newHash :=funcionFinalHashOperation_4B(resultStep4.seed, resultStep4.data);
                  else
                        newHash := funcionFinalHashOperation_4B(resultStep5.hash, resultStep4.data);
                  end if;
						resultStep5.operationID <= resultStep4.operationID;
					   resultStep5.isFirst <= (resultStep4.isFirst);
					   resultStep5.isLast <= (resultStep4.isLast);
					   resultStep5.dataLength      <= resultStep4.dataLength;
              when others =>
                  newHash := resultStep5.hash;
              end case;

            resultStep5.hash <= newHash;
            
        end if;--readInput  
		  resultStep5.resultReady <= dataAvailable;
    end if;--clk
end process UpdateHashStep;



UpdateMix: process(clk, resultStep5, lengthCounter) 
variable sum1   : unsigned(1 downto 0);
variable sum2   : unsigned(2 downto 0);
variable newLen : unsigned(31 downto 0);  
begin
    if rising_edge(clk) then
        if(resultStep5.resultReady ) then
            mixed.hash <= resultStep5.hash;
            mixed.operationID <= resultStep5.operationID;            
            --mixed.totalLen <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"1000";
            mixed.isFirst <= (resultStep5.isFirst);
            mixed.isLast <= (resultStep5.isLast);
            if (resultStep5.isFirst) then
                sum1 := unsigned(resultStep5.dataLength);
                sum2 := ("0"&sum1)+1;
                newLen( 2 downto 0) :=  (sum2);
                newLen(lengthCounter'HIGH downto 3) := ( others=> '0');
                mixed.totalLen <= std_logic_vector(newLen);
                lengthCounter <= newLen;
            else
                sum1 := unsigned(resultStep5.dataLength);
                sum2 := ("0"&sum1)+1;
                newLen:= (lengthCounter+sum2);
                mixed.totalLen <= std_logic_vector(newLen);
                lengthCounter <= newLen;
            end if;            
        end if;--readInput  
        mixed.resultReady <= resultStep5.resultReady;
    end if;--clk
end process UpdateMix;


FinalProc_Step1: process(clk, mixed) 
begin
    if rising_edge(clk) then
        if(mixed.resultReady and mixed.isLast) then        
            finalStep1.hash <= mixed.hash xor mixed.totalLen;
            finalStep1.operationID <= mixed.operationID;
            finalStep1.totalLen <= mixed.totalLen;
            finalStep1.isFirst <= (mixed.isFirst);
            finalStep1.isLast <= (mixed.isLast); 
        end if;--readInput
        finalStep1.resultReady <= mixed.resultReady and mixed.isLast;
    end if;--clk
end process FinalProc_Step1;

FinalProc_Step2: process(clk, finalStep1) 
begin
    if rising_edge(clk) then
        if(finalStep1.resultReady) then        
            finalStep2.hash <= xor_with_shiftRight(finalStep1.hash, FinalShift1);
            finalStep2.operationID <= finalStep1.operationID;
            finalStep2.totalLen <= finalStep1.totalLen;
            finalStep2.isFirst <= finalStep1.isFirst;
            finalStep2.isLast <= finalStep1.isLast; 
        end if;--readInput
        finalStep2.resultReady <= finalStep1.resultReady;
    end if;--clk
end process FinalProc_Step2;

FinalProc_Step3: process(clk, finalStep2) 
variable fullMultResult : std_logic_vector( 63 downto 0); 
begin
    fullMultResult := finalStep2.hash*FinalC1;
    if rising_edge(clk) then
        if(finalStep2.resultReady) then 
            finalStep3.hash <= fullMultResult(31 downto 0);
            finalStep3.operationID <= finalStep2.operationID;
            finalStep3.isFirst <= (finalStep2.isFirst);
            finalStep3.isLast <= (finalStep2.isLast); 
            finalStep3.totalLen <= finalStep2.totalLen;
        end if;--readInput
        finalStep3.resultReady <= finalStep2.resultReady;
    end if;--clk
end process FinalProc_Step3;

FinalProc_Step4: process(clk, finalStep3) 
begin
    if rising_edge(clk) then
        if(finalStep3.resultReady) then        
            finalStep4.hash <= xor_with_shiftRight(finalStep3.hash, FinalShift2);
            finalStep4.operationID <= finalStep3.operationID;
            --finalStep4.resultReady <= finalStep3.resultReady;
            finalStep4.isFirst <= (finalStep3.isFirst);
            finalStep4.isLast <= (finalStep3.isLast); 
            finalStep4.totalLen <= finalStep3.totalLen;
        end if;--readInput
        finalStep4.resultReady <= finalStep3.resultReady;
    end if;--clk
end process FinalProc_Step4;






FinalProc_Step5: process(clk, finalStep4) 
begin
    if rising_edge(clk) then
        if(finalStep4.resultReady) then        
            finalStep5.hash <= ClampedMult(finalStep4.hash , FinalC2);
            finalStep5.operationID <= finalStep4.operationID;
            finalStep5.totalLen <= finalStep4.totalLen;
            finalStep5.isFirst <= (finalStep4.isFirst);
            finalStep5.isLast <= (finalStep4.isLast); 
        end if;--readInput
        finalStep5.resultReady <= finalStep4.resultReady; 
    end if;--clk
end process FinalProc_Step5;

FinalProc_Step6: process(clk, finalStep5) 
begin
    if rising_edge(clk) then
        if(finalStep5.resultReady) then        
            finalStep6.hash <= xor_with_shiftRight(finalStep5.hash, FinalShift3);
            finalStep6.operationID <= finalStep5.operationID;
            finalStep6.totalLen <= finalStep5.totalLen;
            finalStep6.isFirst <= (finalStep5.isFirst);
            finalStep6.isLast <= (finalStep5.isLast); 
        end if;--readInput
        finalStep6.resultReady <= finalStep5.resultReady and finalStep5.isLast; 
    end if;--clk
end process FinalProc_Step6;




--Conectando las salidas a este ultimo paso
resultReady <= mh3_boolean_to_std_logic(finalStep6.resultReady);
result <= finalStep6.hash; 
resultID <= finalStep6.operationID;


end architecture Estructural;

