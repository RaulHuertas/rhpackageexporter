library IEEE;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;
use work.MurmurHashUtils.ALL;

entity BinarySearch_ComparingRow is
    generic ( 
		DATA_WIDTH: integer := 32; 
		ADDR_WIDTH: integer := 10		
	);
    port(
        clk : in std_logic;-- un solo reloj para ambos puertos de la BRAM
        
        radio: std_logic_vector( (ADDR_WIDTH-1) downto 0 );
                
        dataToCompare : in std_logic_vector((DATA_WIDTH-1) downto 0);
        operationID : in std_logic_vector((DATA_WIDTH-1) downto 0);
        previousIndex : in std_logic_vector( (ADDR_WIDTH-1) downto 0 );        
        compare : in std_logic;--El dato actual se debe comparar   
        previousResult : in std_logic;--El resultado es encontrado'1' o no
        porta_wr   : in std_logic;
        porta_waddr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
        porta_din  : in std_logic_vector( (DATA_WIDTH-1) downto 0);
        --valores de saldia de esta columna
        result : out std_logic;--El resultado es encontrado'1' o no
        nextIndex : out std_logic_vector( (ADDR_WIDTH-1) downto 0); 
        compareFinished : out std_logic;--Resultado de una comparación listo
        result_operationID : out std_logic_vector((DATA_WIDTH-1) downto 0);
        --DEBUG SIGNALS
        valorLeido_dbg       : out ieee.numeric_std.unsigned( (DATA_WIDTH-1) downto 0)
    );  
end entity BinarySearch_ComparingRow;

architecture Normal of BinarySearch_ComparingRow is

    signal actualValue          : std_logic_vector( (DATA_WIDTH-1) downto 0);
    
    signal porta_rd             : std_logic;
    signal porta_raddr          : std_logic_vector( (ADDR_WIDTH-1) downto 0);

    signal portb_rd             : std_logic;
    signal portb_addr           : std_logic_vector( (ADDR_WIDTH-1) downto 0);
    signal portb_dout           : std_logic_vector( (DATA_WIDTH-1) downto 0);
    
    signal valorAComparar       : ieee.numeric_std.unsigned( (DATA_WIDTH-1) downto 0);
    signal compareResultTuple   : std_logic_vector(1 downto 0);--bit '1' indica mayor, bit '0' indica menor
    signal valorLeido       : ieee.numeric_std.unsigned( (DATA_WIDTH-1) downto 0);
    type memoryRead is record    
        operationID         : std_logic_vector((DATA_WIDTH-1) downto 0);
        compare             : boolean;
    end record memoryRead;
      
    function boolean_to_std_logic(a: boolean) return std_logic is
    begin
        if a then
            return('1');
        else
            return('0');
        end if;
    end function boolean_to_std_logic;
            
begin

valorLeido_dbg <= valorLeido;
--puerto a es solo de escriitura 
porta_rd <= '0';
porta_raddr <= (others => '-');


portb_rd <= compare;
portb_addr <= previousIndex;
valorLeido <= ieee.numeric_std.unsigned(portb_dout);
valorAComparar <= ieee.numeric_std.unsigned(dataToCompare);
--instanciar la memoria
memory: entity work.BinarySearchBRAM
generic map( DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH ) 
port map (
    clk => clk,
    porta_wr => porta_wr,
    porta_waddr => porta_waddr,
    porta_din => porta_din,
    porta_rd => porta_rd,
    porta_raddr => porta_raddr,
    porta_dout => open,
    portb_rd => portb_rd,
    portb_addr => portb_addr,
    portb_dout => portb_dout
);

--GENERAR LOS VALORES CORRECTOS DE SALIDA
result <= previousResult or boolean_to_std_logic(valorAComparar = valorLeido);
compareResultTuple(1) <= boolean_to_std_logic(valorAComparar > valorLeido);
compareResultTuple(0) <= boolean_to_std_logic(valorAComparar < valorLeido);

generarNuevoIndice: process(compareResultTuple)
--variable searchRadio_temp : std_logic_vector( (ADDR_WIDTH) downto 0) ;
variable searchRadio : std_logic_vector( (ADDR_WIDTH-1) downto 0) ;
begin
    --searchRadio_temp := (RADIO srl 1);
    --searchRadio := searchRadio_temp( (ADDR_WIDTH-1) downto 0 );
    searchRadio := radio( (ADDR_WIDTH-1) downto 0 );  
    if (previousResult= '1') then
        nextIndex<= previousIndex;
    else 
        case compareResultTuple is
            when "10" =>
                nextIndex<= previousIndex+searchRadio;
            when "01" =>
                nextIndex<= previousIndex-searchRadio;
            when others =>
                nextIndex<= (others => '-');
        end case;
    end if ;
end process generarNuevoIndice;

validarSalida : process ( clk, previousIndex, compare, previousResult ) begin
    if rising_edge(clk) then
        compareFinished         <=      compare;
        result_operationID      <=      operationID;   
    end if;
end process validarSalida;


end architecture Normal;





