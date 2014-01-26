library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
use work.MurmurHashUtils.ALL;




entity BinarySearchBRAM is 
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
end entity BinarySearchBRAM;



architecture Inferral of BinarySearchBRAM is
type mem_type is array ( (2**ADDR_WIDTH)-1 downto 0 ) of std_logic_vector(DATA_WIDTH-1 downto 0);
shared variable mem : mem_type;
begin



    portA:process (clk, porta_wr, porta_waddr, porta_raddr, porta_din, porta_rd)
    begin
        if rising_edge(clk) then
            if ( porta_wr = '1' ) then
                mem(conv_integer(porta_waddr)) := porta_din;
            elsif ( porta_rd = '1' ) then
                porta_dout <= mem(conv_integer(porta_raddr));
            end if;
        end if;
    end process portA;
    
    
    
    portB:process (clk, portb_rd, portb_addr)
    begin
        if rising_edge(clk) then
            if ( portb_rd = '1' ) then
                portb_dout <= mem(conv_integer(portb_addr));
            end if;
        end if;
    end process portB;



end architecture Inferral;
