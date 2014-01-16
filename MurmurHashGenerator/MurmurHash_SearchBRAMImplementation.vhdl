--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.std_logic_unsigned.ALL;
--use IEEE.numeric_std.all;
--use work.MurmurHashUtils.ALL;



--entity BinarySearchBRAM is 
-- generic(
--    DATA_WIDTH : integer := 32;
--    ADDR_WIDTH : integer := 12
-- );
-- port(
--     clk : in std_logic_vector;-- un solo reloj para ambos puertos de la BRAM
--     --Puerto de escritura en el cual se vana grabar los datos en la tabla
--     porta_wr   : in std_logic;
--     porta_addr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
--     porta_din  : in std_logic_vector( (DATA_WIDTH-1) downto 0);
--     --puerto de lectura, desde el cual se van a leer los 
--     --datos para la comparación
--     portb_rd   : in std_logic;
--     portb_addr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
--     portb_dout  : in std_logic_vector( (DATA_WIDTH-1) downto 0)
-- );  
--end entity BinarySearchBRAM;

--architecture Inferral of BinarySearchBRAM is
--type mem_type is array ( (2**ADDR_WIDTH)-1 downto 0 ) of std_logic_vector(DATA_WIDTH-1 downto 0);
--shared variable mem : mem_type;
--begin




--end architecture Inferral;
