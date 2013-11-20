----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2013 23:39:33
-- Design Name: 
-- Module Name: MurmurHashUtils - Behavioral
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
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package MurmurHashUtils is

    constant C1 : std_logic_vector(31 downto 0) := x"cc9e2d51";
    constant C2 : std_logic_vector(31 downto 0) := x"1b873593";
    constant M  : std_logic_vector(31 downto 0) := x"00000005";
    constant N  : std_logic_vector(31 downto 0) := x"e6546b64";

type Step1_Capture is record
    dataValid           : boolean;    --! Indica que los datos capturados en este datoa ctual son validos
    data                : std_logic_vector(31 downto 0);           --! Guarda los datos recibidos
    dataLength          : std_logic_vector(1 downto 0);
    isFirst             : boolean;
    isLast              : boolean;
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    seed                : std_logic_vector(31 downto 0);
end record Step1_Capture;

type Step2_C1Mult is record
    dataValid           : boolean;    --! Indica que los datos capturados en este datoa ctual son validos
    data                : std_logic_vector(31 downto 0);           --! Guarda los datos recibidos
    dataLength          : std_logic_vector(1 downto 0);
    isFirst             : boolean;
    isLast              : boolean;
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    seed                : std_logic_vector(31 downto 0);
end record Step2_C1Mult;

type Step3_R1 is record
    dataValid           : boolean;    --! Indica que los datos capturados en este datoa ctual son validos
    data                : std_logic_vector(31 downto 0);           --! Guarda los datos recibidos
    dataLength          : std_logic_vector(1 downto 0);
    isFirst             : boolean;
    isLast              : boolean;
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    seed                : std_logic_vector(31 downto 0);
end record Step3_R1;


type Step4_C2Mult is record
    dataValid           : boolean;    --! Indica que los datos capturados en este datoa ctual son validos
    data                : std_logic_vector(31 downto 0);           --! Guarda los datos recibidos
    dataLength          : std_logic_vector(1 downto 0);
    isFirst             : boolean;
    isLast              : boolean;
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    seed                : std_logic_vector(31 downto 0);
end record Step4_C2Mult;

type Step5_HashResult is record
    dataValid           : boolean;    --! Indica que los datos capturados en este datoa ctual son validos
    data                : std_logic_vector(31 downto 0);           --! Guarda los datos recibidos
    dataLength          : std_logic_vector(1 downto 0);
    isFirst             : boolean;
    isLast              : boolean;
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    seed                : std_logic_vector(31 downto 0);
    resultReady         : std_logic;
end record Step5_HashResult;



function funcionFinalHashOperation_4B( 
        hash:std_logic_vector(31 downto 0);
        k:std_logic_vector(31 downto 0) 
) return std_logic_vector is
    variable xorResult          : std_logic_vector(31 downto 0);
    variable rotR2Result        : std_logic_vector(31 downto 0);
    variable multMResult_temp   : std_logic_vector(64 downto 0);
    variable multMResult        : std_logic_vector(31 downto 0);
    variable additionNResult    : std_logic_vector(31 downto 0);
begin
     xorResult                  := hash xor k;
     rotR2Result(31 downto 13)  := xorResult(18 downto 0);
     rotR2Result(12 downto 0)   := xorResult(31 downto 19);
     multMResult_temp           := rotR2Result*M;
     multMResult                := multMResult_temp(31 downto 0);
     additionNResult            := multMResult+N;
     return additionNResult;
end function funcionFinalHashOperation_4B;





end MurmurHashUtils;




