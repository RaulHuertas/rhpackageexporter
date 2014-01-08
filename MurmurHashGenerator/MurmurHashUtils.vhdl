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
    dataLength          : std_logic_vector(1 downto 0);
    resultReady         : boolean;    
    isFirst             : boolean;
    isLast              : boolean;
end record Step5_HashResult;

--PASOS PARA LA ETAPA FINAL EN CASO LA LONGITUD NO SEA MULTIPLO de 4
type Step1_EndianSwap is record
    dataValid           : boolean;    --! Indica que los datos capturados en este datoa ctual son validos
    data                : std_logic_vector(31 downto 0);           --! Guarda los datos recibidos
    dataLength          : std_logic_vector(1 downto 0);
    isFirst             : boolean;
    isLast              : boolean;
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    seed                : std_logic_vector(31 downto 0);
end record Step1_EndianSwap;


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

function char_to_slv8(inputByte: character) return std_logic_vector is
begin    
    return (std_logic_vector(to_unsigned(character'pos(inputByte), 8 )));
    --return (data );
end function char_to_slv8;


--! En caso de recibir datos cuya lingitud no es multiplo de 4
--! estos deben de alinearse empezando por inputBlock(7  downto 0)
--! hasta inputBlock(23  downto 16)
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
end component MurmurHash32Generator;

constant seed : std_logic_vector(31 downto 0) := x"7538c68c";
constant nTuplas : std_logic_vector(31 downto 0) := x"000000bd";
type referencesArray_t is array (0 to 188) of std_logic_vector(31 downto 0);
constant resultsBank : referencesArray_t := ( x"0005e4fe",x"0120548c",x"012b30f2",x"01de0324",x"0383146b",x"03b4f753",x"03e134b3",x"0465f7d0",x"04bec7f6",x"0527cba1",x"0557f965",x"0559b317",x"0753af24",x"0754e422",x"08892d9b",x"08da5d8b",x"0ce5afa5",x"0d23c3d5",x"0d3b5299",x"0d78e716",x"0f46b237",x"1012888a",x"10ea1f74",x"11bab0a2",x"11f6f69e",x"152b9cac",x"16704ec4",x"1755cafa",x"17baa90b",x"181b6936",x"1d419388",x"1e2711ac",x"1f6579b0",x"1fc0e894",x"22f16379",x"234d74e2",x"23925899",x"29b89cd6",x"2adc8800",x"2da45cda",x"2ee16629",x"30270ec9",x"30d416d3",x"31487f79",x"31ae4b6f",x"31defc3c",x"326743fe",x"32a4fa78",x"33e04691",x"385ed0da",x"393d1f2e",x"3a089667",x"3a8f1665",x"3fae4162",x"42d46789",x"43df45e8",x"43e3df86",x"45e24bd2",x"481a4139",x"48f27c34",x"49707b17",x"4adf0df5",x"4b33bd8f",x"4b7e2041",x"4c2ecfad",x"4ce2e62c",x"4d3f080d",x"4e12afb6",x"50d66947",x"5194e696",x"52acb891",x"52ec1964",x"53427a11",x"54413217",x"564f8e54",x"59ad4a13",x"59d2efd2",x"5a66d0f0",x"5d0ba789",x"5fd8b078",x"630298b3",x"6335ee99",x"640f09c0",x"6474be5b",x"65a9646b",x"6616c671",x"663ccfea",x"692e950d",x"6a7d612d",x"6b837fd0",x"6ca874cb",x"6e45ef50",x"6ec2d543",x"6fb48b5f",x"70011e03",x"723308ed",x"747fa6a1",x"7516216f",x"756936a1",x"75734302",x"75f13f94",x"76441924",x"7859e6de",x"787395fa",x"7ab00815",x"7b8869a3",x"7c276640",x"7eaac05f",x"82a02ebc",x"87699861",x"8857cd8a",x"89796081",x"8d68443f",x"8d6c037c",x"931cc510",x"940d2551",x"94885205",x"94d5dbb3",x"961afcaa",x"97049e47",x"99bc16bb",x"9a1a403b",x"9db585a3",x"9e6a33a5",x"9edead29",x"9f203b78",x"9fc6f3d2",x"a0787910",x"a2a1d04f",x"a529eb09",x"a5aefdc2",x"a5ed9e3e",x"a952bdf1",x"aa8b0ff0",x"aca5c7b0",x"ae14470f",x"af197f39",x"afd0b0ac",x"b3a1a6ec",x"b4e9d9f8",x"b6cdcad7",x"b7c75d78",x"ba17837d",x"bc3d33b8",x"bce01814",x"bd607bc0",x"c10ca292",x"c195cc20",x"c1e56cba",x"c2e6bf3f",x"c32a6539",x"c3cba9aa",x"c5aaeb93",x"c82e2bf7",x"ca0cd23c",x"cd88ee27",x"cfcd9af0",x"d0b348aa",x"d0de6981",x"d55e74fb",x"d73ce098",x"d995505a",x"d9d7bc36",x"dbdbdaba",x"dc543f2d",x"dc962921",x"de427b73",x"e02bd14c",x"e1716b85",x"e22bb836",x"e38da496",x"e4d793bc",x"e7fd97fc",x"e9868af1",x"ec2862f7",x"ec453692",x"ed5f28c0",x"eec1db61",x"eef77cee",x"f00f04fb",x"f29f7946",x"f2cf2c51",x"f5706b91",x"f5a4af48",x"f73fc385",x"f852f16b",x"fbcf6333",x"fca34145",x"ff94311f");
constant entrysLengths : referencesArray_t := ( x"00000015",x"00000019",x"0000001d",x"00000010",x"0000000d",x"00000019",x"00000019",x"0000000b",x"0000000e",x"0000000d",x"00000008",x"0000000b",x"00000009",x"0000001b",x"00000010",x"0000000a",x"0000000f",x"00000012",x"00000014",x"0000000b",x"0000000f",x"0000001a",x"0000000b",x"0000001b",x"00000010",x"00000015",x"00000016",x"00000016",x"0000000a",x"0000000c",x"00000018",x"00000017",x"00000010",x"0000000b",x"0000000e",x"0000001a",x"0000000f",x"00000010",x"0000000c",x"0000000f",x"0000001e",x"00000029",x"0000001d",x"0000000c",x"0000000f",x"0000000c",x"0000000b",x"0000001e",x"0000001e",x"00000010",x"0000001a",x"00000020",x"00000011",x"0000001d",x"0000001f",x"0000000c",x"00000009",x"0000000a",x"0000002a",x"0000000d",x"0000000f",x"0000000f",x"00000001",x"00000015",x"00000012",x"0000001b",x"0000001a",x"0000000d",x"0000000b",x"00000011",x"0000001a",x"00000016",x"00000010",x"0000000b",x"0000000a",x"0000001d",x"0000000e",x"00000019",x"0000000a",x"0000000e",x"0000000b",x"0000000b",x"0000001e",x"0000002a",x"0000000c",x"0000001a",x"00000016",x"0000000e",x"00000012",x"0000000e",x"00000013",x"00000019",x"00000010",x"0000000a",x"00000016",x"0000001a",x"0000001b",x"00000019",x"0000000d",x"00000019",x"0000000c",x"00000011",x"00000015",x"0000000f",x"0000000a",x"00000010",x"0000001d",x"0000000a",x"0000000f",x"00000013",x"0000001c",x"0000000f",x"00000010",x"00000010",x"00000016",x"00000011",x"0000001a",x"00000012",x"0000000a",x"00000009",x"0000000e",x"0000000d",x"00000013",x"00000010",x"00000015",x"0000001b",x"00000021",x"0000001a",x"00000010",x"0000002b",x"0000000d",x"00000011",x"0000000a",x"00000010",x"0000000d",x"0000000b",x"0000000a",x"00000015",x"0000001a",x"0000000b",x"0000001b",x"00000019",x"0000001a",x"0000001b",x"0000001a",x"0000000e",x"00000017",x"0000001b",x"00000009",x"0000000f",x"00000019",x"00000018",x"0000001e",x"0000000f",x"00000010",x"0000001a",x"00000020",x"0000001a",x"0000000f",x"0000000c",x"00000017",x"0000000a",x"0000000f",x"0000000c",x"0000000b",x"0000000a",x"0000000f",x"0000000f",x"00000019",x"0000000d",x"0000000d",x"0000000f",x"0000000a",x"0000000a",x"00000010",x"00000016",x"0000000b",x"00000016",x"0000000c",x"0000000f",x"00000010",x"0000000b",x"0000001d",x"0000000e",x"0000000c",x"0000001e",x"0000001a",x"0000000b",x"0000000b");
type referencesDataArray_t is array (0 to 3498) of std_logic_vector(7 downto 0);
constant dataBank : referencesDataArray_t := ( x"6a",x"73",x"2f",x"4f",x"72",x"69",x"65",x"6e",x"74",x"61",x"74",x"69",x"6f",x"6e",x"48",x"65",x"6c",x"70",x"2e",x"6a",x"73",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"74",x"74",x"66",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"33",x"2e",x"70",x"6e",x"67",x"63",x"68",x"61",x"6e",x"67",x"65",x"6c",x"6f",x"67",x"2e",x"74",x"78",x"74",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"2f",x"6a",x"73",x"2f",x"42",x"61",x"73",x"65",x"2e",x"6a",x"73",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2e",x"63",x"73",x"73",x"2f",x"63",x"73",x"73",x"2f",x"6c",x"6f",x"67",x"6f",x"2e",x"70",x"6e",x"67",x"34",x"30",x"34",x"2e",x"68",x"74",x"6d",x"6c",x"2f",x"72",x"6f",x"62",x"6f",x"74",x"73",x"2e",x"74",x"78",x"74",x"2f",x"34",x"30",x"34",x"2e",x"68",x"74",x"6d",x"6c",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"4c",x"6f",x"61",x"64",x"69",x"6e",x"67",x"49",x"6d",x"61",x"67",x"65",x"2e",x"70",x"6e",x"67",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"36",x"2e",x"70",x"6e",x"67",x"2f",x"52",x"45",x"41",x"44",x"4d",x"45",x"2e",x"6d",x"64",x"6a",x"73",x"2f",x"4c",x"6f",x"61",x"64",x"47",x"61",x"6d",x"65",x"73",x"2e",x"6a",x"73",x"2f",x"63",x"73",x"73",x"2f",x"6e",x"6f",x"72",x"6d",x"61",x"6c",x"69",x"7a",x"65",x"2e",x"63",x"73",x"73",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"49",x"6e",x"66",x"6f",x"49",x"6d",x"61",x"67",x"65",x"2e",x"6a",x"70",x"67",x"2f",x"64",x"6f",x"63",x"2f",x"63",x"73",x"73",x"2e",x"6d",x"64",x"63",x"72",x"6f",x"73",x"73",x"64",x"6f",x"6d",x"61",x"69",x"6e",x"2e",x"78",x"6d",x"6c",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"2f",x"69",x"6e",x"64",x"65",x"78",x"2e",x"68",x"74",x"6d",x"6c",x"2f",x"73",x"6f",x"75",x"6e",x"64",x"73",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4d",x"75",x"73",x"69",x"63",x"2e",x"6f",x"67",x"67",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"34",x"2e",x"70",x"6e",x"67",x"6a",x"73",x"2f",x"63",x"6f",x"72",x"64",x"6f",x"76",x"61",x"5f",x"70",x"6c",x"75",x"67",x"69",x"6e",x"73",x"2e",x"6a",x"73",x"2f",x"63",x"73",x"73",x"2f",x"62",x"6f",x"6f",x"74",x"73",x"74",x"72",x"61",x"70",x"2e",x"6d",x"69",x"6e",x"2e",x"63",x"73",x"73",x"2f",x"6a",x"73",x"2f",x"4c",x"69",x"73",x"74",x"61",x"44",x"65",x"4a",x"75",x"65",x"67",x"6f",x"73",x"2e",x"6a",x"73",x"6f",x"6e",x"2f",x"2e",x"68",x"74",x"61",x"63",x"63",x"65",x"73",x"73",x"43",x"48",x"41",x"4e",x"47",x"45",x"4c",x"4f",x"47",x"2e",x"6d",x"64",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"62",x"67",x"5f",x"70",x"6c",x"61",x"79",x"5f",x"70",x"61",x"75",x"73",x"65",x"2e",x"70",x"6e",x"67",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"61",x"6a",x"61",x"78",x"2d",x"6c",x"6f",x"61",x"64",x"65",x"72",x"2e",x"67",x"69",x"66",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"33",x"2e",x"70",x"6e",x"67",x"64",x"6f",x"63",x"2f",x"68",x"74",x"6d",x"6c",x"2e",x"6d",x"64",x"2f",x"63",x"68",x"61",x"6e",x"67",x"65",x"6c",x"6f",x"67",x"2e",x"74",x"78",x"74",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"4c",x"6f",x"61",x"64",x"69",x"6e",x"67",x"49",x"6d",x"61",x"67",x"65",x"2e",x"6a",x"70",x"67",x"2f",x"6a",x"73",x"2f",x"54",x"69",x"6d",x"65",x"48",x"65",x"6c",x"70",x"2e",x"6a",x"73",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"30",x"2e",x"70",x"6e",x"67",x"63",x"73",x"73",x"2f",x"6d",x"61",x"69",x"6e",x"2e",x"63",x"73",x"73",x"2f",x"6a",x"73",x"2f",x"47",x"61",x"6d",x"65",x"44",x"72",x"61",x"77",x"2e",x"6a",x"73",x"2f",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"50",x"6f",x"72",x"74",x"72",x"61",x"69",x"74",x"5f",x"37",x"36",x"38",x"78",x"31",x"32",x"38",x"30",x"2e",x"6a",x"70",x"67",x"6a",x"73",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2e",x"6d",x"6f",x"62",x"69",x"6c",x"65",x"2d",x"31",x"2e",x"33",x"2e",x"32",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"64",x"6f",x"63",x"2f",x"6d",x"69",x"73",x"63",x"2e",x"6d",x"64",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"32",x"2e",x"70",x"6e",x"67",x"64",x"6f",x"63",x"2f",x"75",x"73",x"61",x"67",x"65",x"2e",x"6d",x"64",x"2f",x"64",x"6f",x"63",x"2f",x"66",x"61",x"71",x"2e",x"6d",x"64",x"2f",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"2f",x"6a",x"73",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2e",x"6d",x"6f",x"62",x"69",x"6c",x"65",x"2d",x"31",x"2e",x"33",x"2e",x"32",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"39",x"2e",x"70",x"6e",x"67",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"43",x"6f",x"6d",x"70",x"6f",x"73",x"69",x"74",x"69",x"6f",x"6e",x"2e",x"78",x"63",x"66",x"6a",x"73",x"2f",x"76",x"65",x"6e",x"64",x"6f",x"72",x"2f",x"6d",x"6f",x"64",x"65",x"72",x"6e",x"69",x"7a",x"72",x"2d",x"32",x"2e",x"36",x"2e",x"32",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"30",x"2e",x"70",x"6e",x"67",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"63",x"73",x"73",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2e",x"6d",x"6f",x"62",x"69",x"6c",x"65",x"2d",x"31",x"2e",x"33",x"2e",x"32",x"2e",x"6d",x"69",x"6e",x"2e",x"63",x"73",x"73",x"6a",x"73",x"2f",x"68",x"65",x"6c",x"70",x"65",x"72",x"2e",x"6a",x"73",x"2e",x"68",x"74",x"61",x"63",x"63",x"65",x"73",x"73",x"2e",x"67",x"69",x"74",x"69",x"67",x"6e",x"6f",x"72",x"65",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"50",x"6f",x"72",x"74",x"72",x"61",x"69",x"74",x"5f",x"37",x"36",x"38",x"78",x"31",x"32",x"38",x"30",x"2e",x"6a",x"70",x"67",x"2f",x"69",x"6d",x"67",x"2f",x"6c",x"6f",x"67",x"6f",x"2e",x"70",x"6e",x"67",x"2f",x"69",x"6d",x"67",x"2f",x"2e",x"67",x"69",x"74",x"69",x"67",x"6e",x"6f",x"72",x"65",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"34",x"2e",x"70",x"6e",x"67",x"2f",x"63",x"73",x"73",x"2f",x"62",x"6f",x"6f",x"74",x"73",x"74",x"72",x"61",x"70",x"2e",x"6d",x"69",x"6e",x"2e",x"63",x"73",x"73",x"64",x"6f",x"63",x"2f",x"63",x"72",x"6f",x"73",x"73",x"64",x"6f",x"6d",x"61",x"69",x"6e",x"2e",x"6d",x"64",x"2f",x"73",x"6f",x"75",x"6e",x"64",x"73",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4d",x"75",x"73",x"69",x"63",x"2e",x"6d",x"70",x"33",x"73",x"6f",x"75",x"6e",x"64",x"73",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4d",x"75",x"73",x"69",x"63",x"2e",x"6d",x"70",x"33",x"63",x"73",x"73",x"2f",x"69",x"6e",x"64",x"65",x"78",x"2e",x"63",x"73",x"73",x"6a",x"73",x"2f",x"47",x"61",x"6d",x"65",x"73",x"2e",x"6a",x"73",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"32",x"2e",x"70",x"6e",x"67",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"61",x"6a",x"61",x"78",x"2d",x"6c",x"6f",x"61",x"64",x"65",x"72",x"2e",x"67",x"69",x"66",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"61",x"6a",x"61",x"78",x"2d",x"6c",x"6f",x"61",x"64",x"65",x"72",x"2e",x"67",x"69",x"66",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"31",x"2e",x"70",x"6e",x"67",x"2f",x"6a",x"73",x"2f",x"6d",x"61",x"69",x"6e",x"2e",x"6a",x"73",x"63",x"6f",x"6e",x"66",x"69",x"67",x"2e",x"78",x"6d",x"6c",x"6a",x"73",x"2f",x"76",x"65",x"6e",x"64",x"6f",x"72",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2d",x"31",x"2e",x"39",x"2e",x"31",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"6a",x"73",x"2f",x"70",x"6c",x"75",x"67",x"69",x"6e",x"73",x"2e",x"6a",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"62",x"67",x"5f",x"70",x"6c",x"61",x"79",x"5f",x"70",x"61",x"75",x"73",x"65",x"2e",x"70",x"6e",x"67",x"63",x"6f",x"72",x"64",x"6f",x"76",x"61",x"2e",x"6a",x"73",x"6a",x"73",x"2f",x"54",x"69",x"6d",x"65",x"48",x"65",x"6c",x"70",x"2e",x"6a",x"73",x"64",x"6f",x"63",x"2f",x"6d",x"69",x"73",x"63",x"2e",x"6d",x"64",x"2f",x"63",x"6f",x"72",x"64",x"6f",x"76",x"61",x"2e",x"6a",x"73",x"2f",x"6a",x"73",x"2f",x"76",x"65",x"6e",x"64",x"6f",x"72",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2d",x"31",x"2e",x"39",x"2e",x"31",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4c",x"61",x"6e",x"64",x"73",x"63",x"61",x"70",x"65",x"5f",x"31",x"32",x"38",x"30",x"78",x"37",x"36",x"38",x"2e",x"6a",x"70",x"67",x"63",x"73",x"73",x"2f",x"6c",x"6f",x"67",x"6f",x"2e",x"70",x"6e",x"67",x"2f",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"65",x"6f",x"74",x"2f",x"70",x"6f",x"72",x"74",x"66",x"6f",x"6c",x"69",x"6f",x"2e",x"70",x"61",x"63",x"6b",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"64",x"6f",x"63",x"2f",x"65",x"78",x"74",x"65",x"6e",x"64",x"2e",x"6d",x"64",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"53",x"70",x"69",x"6e",x"2e",x"70",x"6e",x"67",x"2e",x"67",x"69",x"74",x"61",x"74",x"74",x"72",x"69",x"62",x"75",x"74",x"65",x"73",x"2f",x"64",x"6f",x"63",x"2f",x"63",x"72",x"6f",x"73",x"73",x"64",x"6f",x"6d",x"61",x"69",x"6e",x"2e",x"6d",x"64",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"2f",x"43",x"4f",x"4e",x"54",x"52",x"49",x"42",x"55",x"54",x"49",x"4e",x"47",x"2e",x"6d",x"64",x"6a",x"73",x"2f",x"6d",x"61",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"6a",x"73",x"2f",x"4f",x"72",x"69",x"65",x"6e",x"74",x"61",x"74",x"69",x"6f",x"6e",x"48",x"65",x"6c",x"70",x"2e",x"6a",x"73",x"73",x"6f",x"75",x"6e",x"64",x"73",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4d",x"75",x"73",x"69",x"63",x"2e",x"77",x"61",x"76",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"49",x"63",x"6f",x"6e",x"2e",x"70",x"6e",x"67",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"65",x"6f",x"74",x"2f",x"6a",x"73",x"2f",x"68",x"65",x"6c",x"70",x"65",x"72",x"2e",x"6a",x"73",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"73",x"76",x"67",x"69",x"6d",x"67",x"2f",x"6c",x"6f",x"67",x"6f",x"2e",x"70",x"6e",x"67",x"63",x"73",x"73",x"2f",x"6e",x"6f",x"72",x"6d",x"61",x"6c",x"69",x"7a",x"65",x"2e",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"49",x"6e",x"66",x"6f",x"49",x"6d",x"61",x"67",x"65",x"2e",x"6a",x"70",x"67",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"2e",x"70",x"6e",x"67",x"64",x"6f",x"63",x"2f",x"54",x"4f",x"43",x"2e",x"6d",x"64",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"38",x"2e",x"70",x"6e",x"67",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"4c",x"49",x"43",x"45",x"4e",x"53",x"45",x"2e",x"6d",x"64",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"35",x"2e",x"70",x"6e",x"67",x"2f",x"63",x"6f",x"72",x"64",x"6f",x"76",x"61",x"5f",x"70",x"6c",x"75",x"67",x"69",x"6e",x"73",x"2e",x"6a",x"73",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"49",x"63",x"6f",x"6e",x"2e",x"70",x"6e",x"67",x"2f",x"2e",x"67",x"69",x"74",x"61",x"74",x"74",x"72",x"69",x"62",x"75",x"74",x"65",x"73",x"2f",x"6a",x"73",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2e",x"6a",x"73",x"2f",x"63",x"72",x"6f",x"73",x"73",x"64",x"6f",x"6d",x"61",x"69",x"6e",x"2e",x"78",x"6d",x"6c",x"6a",x"73",x"2f",x"41",x"6e",x"69",x"6d",x"61",x"74",x"69",x"6f",x"6e",x"43",x"6f",x"6e",x"74",x"65",x"78",x"74",x"2e",x"6a",x"73",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"33",x"2e",x"70",x"6e",x"67",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"63",x"6f",x"72",x"64",x"6f",x"76",x"61",x"5f",x"70",x"6c",x"75",x"67",x"69",x"6e",x"73",x"2e",x"6a",x"73",x"2f",x"64",x"6f",x"63",x"2f",x"6a",x"73",x"2e",x"6d",x"64",x"64",x"6f",x"63",x"2f",x"6a",x"73",x"2e",x"6d",x"64",x"6a",x"73",x"2f",x"47",x"61",x"6d",x"65",x"44",x"72",x"61",x"77",x"2e",x"6a",x"73",x"2f",x"64",x"6f",x"63",x"2f",x"75",x"73",x"61",x"67",x"65",x"2e",x"6d",x"64",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"53",x"70",x"69",x"6e",x"2e",x"70",x"6e",x"67",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"2e",x"70",x"6e",x"67",x"70",x"6f",x"72",x"74",x"66",x"6f",x"6c",x"69",x"6f",x"2e",x"70",x"61",x"63",x"6b",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"77",x"6f",x"66",x"66",x"2f",x"6a",x"73",x"2f",x"76",x"65",x"6e",x"64",x"6f",x"72",x"2f",x"6d",x"6f",x"64",x"65",x"72",x"6e",x"69",x"7a",x"72",x"2d",x"32",x"2e",x"36",x"2e",x"32",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"4c",x"6f",x"61",x"64",x"69",x"6e",x"67",x"49",x"6d",x"61",x"67",x"65",x"2e",x"70",x"6e",x"67",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"32",x"2e",x"70",x"6e",x"67",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4c",x"61",x"6e",x"64",x"73",x"63",x"61",x"70",x"65",x"5f",x"31",x"32",x"38",x"30",x"78",x"37",x"36",x"38",x"2e",x"6a",x"70",x"67",x"2f",x"43",x"48",x"41",x"4e",x"47",x"45",x"4c",x"4f",x"47",x"2e",x"6d",x"64",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"31",x"2e",x"70",x"6e",x"67",x"69",x"6e",x"64",x"65",x"78",x"2e",x"68",x"74",x"6d",x"6c",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"37",x"2e",x"70",x"6e",x"67",x"2f",x"63",x"73",x"73",x"2f",x"6d",x"61",x"69",x"6e",x"2e",x"63",x"73",x"73",x"2f",x"63",x"6f",x"6e",x"66",x"69",x"67",x"2e",x"78",x"6d",x"6c",x"72",x"6f",x"62",x"6f",x"74",x"73",x"2e",x"74",x"78",x"74",x"6a",x"73",x"2f",x"4c",x"69",x"73",x"74",x"61",x"44",x"65",x"4a",x"75",x"65",x"67",x"6f",x"73",x"2e",x"6a",x"73",x"6f",x"6e",x"2f",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"74",x"74",x"66",x"66",x"61",x"76",x"69",x"63",x"6f",x"6e",x"2e",x"69",x"63",x"6f",x"2f",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"61",x"6a",x"61",x"78",x"2d",x"6c",x"6f",x"61",x"64",x"65",x"72",x"2e",x"67",x"69",x"66",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"43",x"6f",x"6d",x"70",x"6f",x"73",x"69",x"74",x"69",x"6f",x"6e",x"2e",x"78",x"63",x"66",x"73",x"6f",x"75",x"6e",x"64",x"73",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4d",x"75",x"73",x"69",x"63",x"2e",x"6f",x"67",x"67",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"4c",x"6f",x"61",x"64",x"69",x"6e",x"67",x"49",x"6d",x"61",x"67",x"65",x"2e",x"6a",x"70",x"67",x"2f",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"73",x"76",x"67",x"2f",x"63",x"73",x"73",x"2f",x"69",x"6e",x"64",x"65",x"78",x"2e",x"63",x"73",x"73",x"2f",x"6a",x"73",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2d",x"32",x"2e",x"30",x"2e",x"33",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"73",x"6f",x"75",x"6e",x"64",x"73",x"2f",x"42",x"61",x"63",x"6b",x"67",x"72",x"6f",x"75",x"6e",x"64",x"4d",x"75",x"73",x"69",x"63",x"2e",x"77",x"61",x"76",x"52",x"45",x"41",x"44",x"4d",x"45",x"2e",x"6d",x"64",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"33",x"2e",x"70",x"6e",x"67",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"49",x"6e",x"66",x"6f",x"49",x"6d",x"61",x"67",x"65",x"2e",x"6a",x"70",x"67",x"2f",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2e",x"63",x"73",x"73",x"2f",x"6a",x"73",x"2f",x"4c",x"6f",x"61",x"64",x"47",x"61",x"6d",x"65",x"73",x"2e",x"6a",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"77",x"68",x"69",x"74",x"65",x"2e",x"70",x"6e",x"67",x"2f",x"63",x"73",x"73",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2e",x"6d",x"6f",x"62",x"69",x"6c",x"65",x"2d",x"31",x"2e",x"33",x"2e",x"32",x"2e",x"6d",x"69",x"6e",x"2e",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"31",x"38",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"43",x"4f",x"4e",x"54",x"52",x"49",x"42",x"55",x"54",x"49",x"4e",x"47",x"2e",x"6d",x"64",x"2f",x"64",x"6f",x"63",x"2f",x"68",x"74",x"6d",x"6c",x"2e",x"6d",x"64",x"2f",x"6a",x"73",x"2f",x"41",x"6e",x"69",x"6d",x"61",x"74",x"69",x"6f",x"6e",x"43",x"6f",x"6e",x"74",x"65",x"78",x"74",x"2e",x"6a",x"73",x"64",x"6f",x"63",x"2f",x"63",x"73",x"73",x"2e",x"6d",x"64",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"39",x"2e",x"70",x"6e",x"67",x"2f",x"6a",x"73",x"2f",x"47",x"61",x"6d",x"65",x"73",x"2e",x"6a",x"73",x"2f",x"68",x"75",x"6d",x"61",x"6e",x"73",x"2e",x"74",x"78",x"74",x"6a",x"73",x"2f",x"42",x"61",x"73",x"65",x"2e",x"6a",x"73",x"6a",x"73",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2e",x"6a",x"73",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"37",x"2e",x"70",x"6e",x"67",x"2f",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"49",x"6e",x"66",x"6f",x"49",x"6d",x"61",x"67",x"65",x"2e",x"6a",x"70",x"67",x"6a",x"73",x"2f",x"70",x"6c",x"75",x"67",x"69",x"6e",x"73",x"2e",x"6a",x"73",x"64",x"6f",x"63",x"2f",x"65",x"78",x"74",x"65",x"6e",x"64",x"2e",x"6d",x"64",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"38",x"2e",x"70",x"6e",x"67",x"64",x"6f",x"63",x"2f",x"66",x"61",x"71",x"2e",x"6d",x"64",x"68",x"75",x"6d",x"61",x"6e",x"73",x"2e",x"74",x"78",x"74",x"2f",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"35",x"2e",x"70",x"6e",x"67",x"2f",x"6a",x"73",x"2f",x"63",x"6f",x"72",x"64",x"6f",x"76",x"61",x"5f",x"70",x"6c",x"75",x"67",x"69",x"6e",x"73",x"2e",x"6a",x"73",x"2f",x"2e",x"67",x"69",x"74",x"69",x"67",x"6e",x"6f",x"72",x"65",x"6a",x"73",x"2f",x"6a",x"71",x"75",x"65",x"72",x"79",x"2d",x"32",x"2e",x"30",x"2e",x"33",x"2e",x"6d",x"69",x"6e",x"2e",x"6a",x"73",x"2f",x"6a",x"73",x"2f",x"69",x"6e",x"64",x"65",x"78",x"2e",x"6a",x"73",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"36",x"2e",x"70",x"6e",x"67",x"54",x"75",x"74",x"61",x"6e",x"47",x"6f",x"6c",x"64",x"2f",x"31",x"32",x"2e",x"70",x"6e",x"67",x"6a",x"73",x"2f",x"69",x"6e",x"64",x"65",x"78",x"2e",x"6a",x"73",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"69",x"6d",x"67",x"2f",x"2e",x"67",x"69",x"74",x"69",x"67",x"6e",x"6f",x"72",x"65",x"2f",x"66",x"61",x"76",x"69",x"63",x"6f",x"6e",x"2e",x"69",x"63",x"6f",x"2f",x"63",x"73",x"73",x"2f",x"69",x"6d",x"61",x"67",x"65",x"73",x"2f",x"69",x"63",x"6f",x"6e",x"73",x"2d",x"33",x"36",x"2d",x"62",x"6c",x"61",x"63",x"6b",x"2e",x"70",x"6e",x"67",x"66",x"6f",x"6e",x"74",x"73",x"2f",x"66",x"6c",x"65",x"78",x"73",x"6c",x"69",x"64",x"65",x"72",x"2d",x"69",x"63",x"6f",x"6e",x"2e",x"77",x"6f",x"66",x"66",x"2f",x"64",x"6f",x"63",x"2f",x"54",x"4f",x"43",x"2e",x"6d",x"64",x"2f",x"4c",x"49",x"43",x"45",x"4e",x"53",x"45",x"2e",x"6d",x"64");


end MurmurHashUtils;




