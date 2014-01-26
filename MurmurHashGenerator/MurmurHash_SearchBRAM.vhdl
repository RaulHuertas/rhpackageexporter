----------------------------------------------------------------------------------
-- Author: Raul gerardo Huertas Paiva 
-- 
-- Description: Bloque de memoria a usar en el 
-- modulo que va a realizar la búsqueda binaria 
--
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.ALL;

package MurmurHashUtils is

component BinarySearchBRAM is
generic(
   DATA_WIDTH : integer := 32;
   ADDR_WIDTH : integer := 10
);
port(
    clk : in std_logic;-- un solo reloj para ambos puertos de la BRAM
    --Puerto de escritura en el cual se vana grabar los datos en la tabla
    porta_wr   : in std_logic;
    porta_waddr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
    porta_din  : in std_logic_vector( (DATA_WIDTH-1) downto 0);
    porta_rd   : in std_logic;
    porta_raddr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
    porta_dout  : out std_logic_vector( (DATA_WIDTH-1) downto 0);
    --puerto de lectura, desde el cual se van a leer los 0
    --datos para la comparación
    portb_rd   : in std_logic;
    portb_addr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
    portb_dout  : out std_logic_vector( (DATA_WIDTH-1) downto 0)
);  
end component BinarySearchBRAM;


end package MurmurHashUtils;
