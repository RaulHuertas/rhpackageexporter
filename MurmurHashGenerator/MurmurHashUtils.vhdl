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
    constant FinalShift1 : integer := 16;
    constant FinalC1 : std_logic_vector(31 downto 0) := x"85ebca6b";
    constant FinalShift2 : integer := 13;
    constant FinalC2 : std_logic_vector(31 downto 0) := x"c2b2ae35";
    constant FinalShift3 : integer := 16;
    
    

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
    hash                : std_logic_vector(31 downto 0);           --! Guarda los datos recibidos
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    resultReady         : boolean;    
    isFirst             : boolean;
    isLast              : boolean;
end record Step5_HashResult;

--PASOS DE LA ETAPA FINAL DEL CALCULO DEl HASH
type FinalStep is record    
    hash                : std_logic_vector(31 downto 0);           --! Hash
    totalLen            : std_logic_vector(31 downto 0);   --! Longitud de todos los datos recibidos    
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID    
    resultReady         : boolean;    
    isFirst             : boolean;
    isLast              : boolean;
end record FinalStep;




function funcionFinalHashOperation_4B( 
        hash:std_logic_vector(31 downto 0);
        k:std_logic_vector(31 downto 0) 
) return std_logic_vector is
    variable xorResult          : std_logic_vector(31 downto 0);
    variable rotR2Result        : std_logic_vector(31 downto 0);
    variable multMResult_temp   : std_logic_vector(63 downto 0);
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


function mh3_boolean_to_std_logic(a: boolean) return std_logic is
begin
    if a then
        return('1');
    else
        return('0');
    end if;
end function mh3_boolean_to_std_logic;


function ClampedMult(a: std_logic_vector; b: std_logic_vector) return std_logic_vector is
variable fullMultResult : std_logic_vector( (a'length*2-1) downto 0); 
begin
    fullMultResult := a*b;
    return fullMultResult( (a'length-1) downto 0);
end function ClampedMult;

function xor_with_shiftRight(data: std_logic_vector; constant count:integer) return std_logic_vector is
variable value : std_logic_vector( (data'length-1) downto 0 );
variable shifted : std_logic_vector( (data'length-1) downto 0 );
--variable returnValue : std_logic_vector( data'length downto 0 );
begin    
    shifted((data'length-1-count) downto 0 ) := data((data'length-1) downto count);
    shifted((data'length-1) downto (data'length-count) ) := ( others=>'0' );
    return (data xor shifted);
    --return (data );
end function xor_with_shiftRight;





component MurmurHash32Generator is
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
end component MurmurHash32Generator;


end MurmurHashUtils;




