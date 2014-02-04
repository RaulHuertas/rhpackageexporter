----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.01.2014 14:32:21
-- Design Name: 
-- Module Name: TB4_FileBasedTest - Behavioral
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
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
use work.MurmurHashUtils.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SearchRowTestbench is
end SearchRowTestbench;

architecture Behavioral of SearchRowTestbench is
                
    constant DATA_WIDTH_A_USAR : integer := 32;
    constant ADDR_WIDTH_A_USAR : integer := 10;
    
    signal clk              : std_logic;-- un solo reloj para ambos puertos de la BRAM        
    signal dataToCompare    : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0);
    signal operationID      : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0);
    signal previousIndex    : std_logic_vector( (ADDR_WIDTH_A_USAR-1) downto 0);        
    signal compare          : std_logic := '0';--El dato actual se debe comparar   
    signal previousResult   : std_logic;--El resultado es encontrado'1' o no
    signal porta_wr         : std_logic;
    signal porta_waddr      : std_logic_vector( (ADDR_WIDTH_A_USAR-1) downto 0);
    signal porta_din        : std_logic_vector( (DATA_WIDTH_A_USAR-1) downto 0);
        --valores de saldia de esta columna
    signal result           : std_logic;--El resultado es encontrado'1' o no
    signal nextIndex        : std_logic_vector( (ADDR_WIDTH_A_USAR-1) downto 0); 
    signal compareFinished  : std_logic; --Resultado de una comparación listo
    
    
    signal dataReadDuringIOTest  : std_logic_vector( (DATA_WIDTH_A_USAR-1) downto 0);

    constant clk_period : time := 10 ns;
                
begin
   
   
   uut : work.MurmurHashUtils.BinarySearch_ComparingRow
    generic map ( 
		DATA_WIDTH => DATA_WIDTH_A_USAR,
		ADDR_WIDTH => ADDR_WIDTH_A_USAR,
		RADIO => "1000000000"
	)
    port map(
        clk                 => clk,        
        dataToCompare       => dataToCompare,
        operationID         => operationID,
        previousIndex       => previousIndex,         
        compare             => compare,
        previousResult      => previousResult, 
        porta_wr            => porta_wr,
        porta_waddr         => porta_waddr,
        porta_din           => porta_din,  
        result              => result, 
        nextIndex           => nextIndex,  
       compareFinished      =>  compareFinished
    );  

   clk_process :process
   begin
       clk <= '0';
       wait for clk_period/2;
       clk <= '1';
       wait for clk_period/2;
   end process;   
   
   
    test : process
        variable readWriteCounter : integer := 0;
        variable dataToWrite : std_logic_vector((DATA_WIDTH_A_USAR-1) downto 0) := ( others => '0');
        variable addrToWrite : std_logic_vector((ADDR_WIDTH_A_USAR-1) downto 0) := ( others => '0');        
    begin
        -- Primero grabar los datos en la memoria
        porta_wr <= '0';
        porta_waddr     <=      addrToWrite;
        porta_din     <=      dataToWrite;
        wait for clk_period;
        porta_wr   <= '1';
        while readWriteCounter < (2**ADDR_WIDTH_A_USAR)  loop
                porta_waddr     <=      addrToWrite;
                porta_din     <=      dataToWrite;
                wait for clk_period;
                dataToWrite := dataToWrite+1;
                addrToWrite := addrToWrite+1;
                readWriteCounter := readWriteCounter+1;
        end loop;
        -- Ahora comparar un dato de prueba
        dataToCompare <= x"00000001";
        operationID <= (others=>'1');
        previousIndex <= "1000000000";
        compare<= '0';
        previousResult <= '0';
        wait for clk_period;
        compare<= '1';
        wait for clk_period;
        compare<= '0';
    end process;
    
    
    
end Behavioral;