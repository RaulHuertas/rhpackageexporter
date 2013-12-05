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

entity ImplementationTest1 is
    port(
        --entradas
        clk  : in std_logic;
        inputData : in std_logic_vector(7 downto 0);
        --salidas
        canAccept_output : out std_logic;
        resultReady_output : out std_logic;
        result_output : out std_logic_vector(31 downto 0)
    );
end entity ImplementationTest1;


architecture structural of ImplementationTest1 is
    -- generar un registro de salto en la entrada para generar las entradas
    -- al modulo
    type registroEntradas is array (27 downto 0) of std_logic_vector(7 downto 0);
    signal registro : registroEntradas;
    signal resultID_output : std_logic_vector(31 downto 0);
    signal dataStep1_dbg : std_logic_vector(31 downto 0);
    signal dataStep2_dbg : std_logic_vector(31 downto 0);
    signal dataStep3_dbg : std_logic_vector(31 downto 0);
    signal dataStep4_dbg : std_logic_vector(31 downto 0);
    signal dataStep5_dbg : std_logic_vector(31 downto 0);
    signal inputBlock : std_logic_vector(31 downto 0);
    signal operationID : std_logic_vector(31 downto 0);
    signal seed : std_logic_vector(31 downto 0); 
begin
    -- generar al logica del registro de salto
--EntradaDatos: process( clk, registro, inputData)  begin
--    if rising_edge(clk) then
        
--    end if;--clk
    
--end process EntradaDatos;
    salto: for i in 0 to 27 generate
        first_reg: if i=0 generate
            clk0: process(clk, inputData)  begin
                  if rising_edge(clk)then
                    registro(0)<= inputData;
                  end if;
            end process clk0;            
        end generate first_reg;
        
        restOf_reg: if i>0 generate
                    clkall: process(clk, registro)  begin
                          if rising_edge(clk)then
                            registro(i)<= registro(i-1);
                          end if;
                    end process clkall; 
        end generate restOf_reg;
          
    end generate salto;
    
    inputBlock <= registro(0)&registro(1)&registro(2)&registro(3);
    operationID <= registro(8)&registro(9)&registro(10)&registro(11);
    seed <= registro(12)&registro(13)&registro(14)&registro(15);
 --instanciar el modulo a probar
 hashGenerator: work.MurmurHashUtils.MurmurHash32Generator port map
 (  
    --entradas
    inputBlock      => inputBlock ,     
    readInput       => registro(4)(0),
    blockLength     => registro(5)(1 downto 0), 
    finalBlock      => registro(6)(0),
    start           => registro(7)(0),
    operationID     => operationID,
    seed            => seed,
    --salidas
    canAccept =>   canAccept_output,
    resultReady =>   resultReady_output,
    result =>   result_output,
    resultID =>   resultID_output,
    clk => clk,
    dataStep1_dbg => dataStep1_dbg,
    dataStep2_dbg => dataStep2_dbg,
    dataStep3_dbg => dataStep3_dbg,
    dataStep4_dbg => dataStep4_dbg,
    dataStep5_dbg => dataStep5_dbg
 );
    
end architecture structural;
