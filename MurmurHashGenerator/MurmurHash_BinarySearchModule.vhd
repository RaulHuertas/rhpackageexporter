----------------------------------------------------------------------------------
-- Author: Raul gerardo Huertas Paiva 
-- 
-- Description: Modulos apra implementar al bsuqueda binaria en el FPGA
--
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.ALL;

package MurmurHashUtils is

component BinarySearch_ComparingRow is
    generic ( 
		DATA_WIDTH: integer := 32; 
		ADDR_WIDTH: integer := 10;
		RADIO: std_logic_vector
	);
    port(
        clk : in std_logic;-- un solo reloj para ambos puertos de la BRAM        
        dataToCompare : in std_logic_vector((DATA_WIDTH-1) downto 0);
        operationID : in std_logic_vector((DATA_WIDTH-1) downto 0);
        previousIndex : in std_logic_vector( (ADDR_WIDTH-1) downto 0);        
        compare : in std_logic;--El dato actual se debe comparar   
        previousResult : in std_logic;--El resultado es encontrado'1' o no
        porta_wr   : in std_logic;
        porta_waddr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
        porta_din  : in std_logic_vector( (DATA_WIDTH-1) downto 0);
        --valores de saldia de esta columna
        result : out std_logic;--El resultado es encontrado'1' o no
        nextIndex : out std_logic_vector( (ADDR_WIDTH-1) downto 0); 
        compareFinished : out std_logic--Resultado de una comparación listo
    ); 
end component BinarySearch_ComparingRow;





end MurmurHashUtils;


