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
		ADDR_WIDTH: integer := 10
	);
    port(
        clk : in std_logic;-- un solo reloj para ambos puertos de la BRAM
        dataToCompare : in std_logic_vector((DATA_WIDTH-1) downto 0);
        result : out std_logic;--El resultado es encontrado'1' o no
        compareResult : out std_logic;--El resultado es encontrado'1' o no   
        --Señales del bloque de memoria interno
        porta_wr   : in std_logic;
        porta_waddr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
        porta_din  : in std_logic_vector( (DATA_WIDTH-1) downto 0);
        porta_rd   : in std_logic;
        porta_raddr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
        porta_dout  : out std_logic_vector( (DATA_WIDTH-1) downto 0);
        portb_rd   : in std_logic;
        portb_addr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
        portb_dout  : out std_logic_vector( (DATA_WIDTH-1) downto 0)
    );  
end component BinarySearch_ComparingRow;





end MurmurHashUtils;


