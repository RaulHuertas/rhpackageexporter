----------------------------------------------------------------------------------
-- Engineer: Raul gerardo Huertas Paiva rax20037@gmail.com
-- 
-- Create Date: 09.02.2014 01:10:38
-- Module Name: SearchModule - Behavioral
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SearchModule is
    generic ( 
		DATA_WIDTH: integer := 32; 
		ADDR_WIDTH: integer := 10		
	);
    Port ( 
        clk : in std_logic;-- un solo reloj para ambos puertos de la BRAM
        --Signals to start a search
        compare : in std_logic;--El dato actual se debe comparar
        dataToCompare : in std_logic_vector((DATA_WIDTH-1) downto 0);
        operationID : in std_logic_vector((DATA_WIDTH-1) downto 0);
        --Puerto de escritura de datos
        porta_wr   : in std_logic;
        porta_waddr : in std_logic_vector( (ADDR_WIDTH-1) downto 0);
        porta_din  : in std_logic_vector( (DATA_WIDTH-1) downto 0);
        --Result
        searchFinished : out std_logic;--Resultado de una comparación listo
        searchresult : out std_logic;--Si se ha encontrado o no. searchresult='1' indica que si se ha encontrado el elemento
        resultIndex : out std_logic_vector( (ADDR_WIDTH-1) downto 0);--Solo es valido si  searchresult='1'
        result_operationID : out std_logic_vector((DATA_WIDTH-1) downto 0);
        --debug signals
        internalResultFinished_dbg : out std_logic_vector( (ADDR_WIDTH-1) downto 0)
    );
end SearchModule;

architecture Behavioral of SearchModule is



--entradas de los renglones de busqueda
type arrayOfDATA_WIDTH is array ((ADDR_WIDTH-1) downto 0) of std_logic_vector((DATA_WIDTH-1) downto 0);
type arrayOfADDR_WIDTH is array ((ADDR_WIDTH-1) downto 0) of std_logic_vector((ADDR_WIDTH-1) downto 0);
signal dataToCompare_iarray   : arrayOfDATA_WIDTH;
signal operationID_iarray   : arrayOfDATA_WIDTH;
signal previousIndex_iarray : arrayOfADDR_WIDTH;
signal compare_iarray : std_logic_vector( (ADDR_WIDTH-1) downto 0);
signal previousResult_iarray : std_logic_vector( (ADDR_WIDTH-1) downto 0);
--salidas de los renglones de busqueda
signal result_oarray : std_logic_vector( (ADDR_WIDTH-1) downto 0);
signal nextIndex_oarray : arrayOfADDR_WIDTH;
signal compareFinished_oarray : std_logic_vector( (ADDR_WIDTH-1) downto 0);
constant  firstRadio : std_logic_vector( (ADDR_WIDTH-1) downto 0) := ( (ADDR_WIDTH-1) => '1', others => '0' );
constant  firstPreviousIndex : std_logic_vector( (ADDR_WIDTH-1) downto 0) := ( (ADDR_WIDTH-1) => '0', others => '1' );
signal operationID_oarray   : arrayOfDATA_WIDTH;

signal searchFinished_temp       : std_logic;--Resultado de una comparación listo
signal searchresult_temp         : std_logic;--Si se ha encontrado o no. searchresult='1' indica que si se ha encontrado el elemento
signal resultIndex_temp          : std_logic_vector( (ADDR_WIDTH-1) downto 0);--Solo es valido si  searchresult='1'
signal result_operationID_temp   : std_logic_vector((DATA_WIDTH-1) downto 0);

begin

generarFilasDeBusqueda: for i in 0 to (ADDR_WIDTH-1) generate

    firstRow: if i=0 generate
        row: entity work.BinarySearch_ComparingRow
        generic map( DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH ) 
        port map(
                clk                 => clk,  
                radio               => firstRadio,
                dataToCompare       => dataToCompare,
                operationID         => operationID,
                previousIndex       => firstPreviousIndex,         
                compare             => compare,
                previousResult      => '0', 
                porta_wr            => porta_wr,
                porta_waddr         => porta_waddr,
                porta_din           => porta_din,  
                result              => result_oarray(i), 
                nextIndex           => nextIndex_oarray(i),  
                compareFinished     => compareFinished_oarray(i),
                result_operationID  => operationID_oarray(i),
                valorLeido_dbg      => open
        );
    end generate firstRow;

    otherRows: if i/=0 generate
        row: entity work.BinarySearch_ComparingRow
        generic map( DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH ) 
        port map(
                clk                 => clk,  
                radio               => ( (ADDR_WIDTH-1-i) => '1', others => '0' ),
                dataToCompare       => dataToCompare,
                operationID         => operationID,
                previousIndex       => nextIndex_oarray(i-1),         
                compare             => compare,
                previousResult      => result_oarray(i-1), 
                porta_wr            => porta_wr,
                porta_waddr         => porta_waddr,
                porta_din           => porta_din,  
                result              => result_oarray(i), 
                nextIndex           => nextIndex_oarray(i),  
                compareFinished     => compareFinished_oarray(i),
                result_operationID  => operationID_oarray(i),
                valorLeido_dbg      => open
        );
        
        internalResultFinished_dbg(i) <= compareFinished_oarray(i);
    end generate otherRows;
  
    
    
end generate generarFilasDeBusqueda;


searchFinished_temp      <= compareFinished_oarray(ADDR_WIDTH-1);
searchresult_temp        <= result_oarray(ADDR_WIDTH-1);
resultIndex_temp         <= nextIndex_oarray(ADDR_WIDTH-1);
result_operationID_temp  <= operationID_oarray(ADDR_WIDTH-1);

FinalStage: process(clk, searchFinished_temp, searchresult_temp, resultIndex_temp, result_operationID_temp)  begin
    
    if rising_edge(clk) then
        searchFinished         <= searchFinished_temp;
        searchresult           <= searchresult_temp;
        resultIndex            <= resultIndex_temp;
        result_operationID     <= result_operationID_temp;
    end if;--clk
    
end process FinalStage;



end Behavioral;
