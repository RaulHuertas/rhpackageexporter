
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
use work.MurmurHashUtils.ALL;

entity ImplementationTest1 is
    port(
        --entradas
        clk  : in std_logic;
        inputData : in std_logic_vector(7 downto 0);
        --salidas
        canAccept_output : out std_logic;
        resultReady_output : out std_logic;
        result_output : out std_logic_vector(31 downto 0)
    );
end entity ImplementationTest1;


architecture structural of ImplementationTest1 is
    -- generar un registro de salto en la entrada para generar las entradas
    -- al modulo
    type registroEntradas is array (27 downto 0) of std_logic_vector(7 downto 0);
    signal registro : registroEntradas;
    signal resultID_output : std_logic_vector(31 downto 0);
--    signal dataStep1_dbg : std_logic_vector(31 downto 0);
--    signal dataStep2_dbg : std_logic_vector(31 downto 0);
--    signal dataStep3_dbg : std_logic_vector(31 downto 0);
--    signal dataStep4_dbg : std_logic_vector(31 downto 0);
--    signal dataStep5_dbg : std_logic_vector(31 downto 0);
        
--    signal dataStep1_ID_dbg : std_logic_vector(31 downto 0);
--    signal dataStep2_ID_dbg : std_logic_vector(31 downto 0);
--    signal dataStep3_ID_dbg : std_logic_vector(31 downto 0);
--    signal dataStep4_ID_dbg : std_logic_vector(31 downto 0);
--    signal dataStep5_ID_dbg : std_logic_vector(31 downto 0);
    
--    signal finalStep1_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep2_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep3_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep4_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep5_dbg : out std_logic_vector(31 downto 0)
--    signal finalStep1_ID_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep2_ID_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep3_ID_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep4_ID_dbg : out std_logic_vector(31 downto 0);
--    signal finalStep5_ID_dbg : out std_logic_vector(31 downto 0)
    
    
        
    signal inputBlock : std_logic_vector(31 downto 0);
    signal operationID : std_logic_vector(31 downto 0);
    signal seed : std_logic_vector(31 downto 0); 
begin
    -- generar al logica del registro de salto
--EntradaDatos: process( clk, registro, inputData)  begin
--    if rising_edge(clk) then
        
--    end if;--clk
    
--end process EntradaDatos;
    salto: for i in 0 to 27 generate
        first_reg: if i=0 generate
            clk0: process(clk, inputData)  begin
                  if rising_edge(clk)then
                    registro(0)<= inputData;
                  end if;
            end process clk0;            
        end generate first_reg;
        
        restOf_reg: if i>0 generate
                    clkall: process(clk, registro)  begin
                          if rising_edge(clk)then
                            registro(i)<= registro(i-1);
                          end if;
                    end process clkall; 
        end generate restOf_reg;
          
    end generate salto;
    
    inputBlock <= registro(0)&registro(1)&registro(2)&registro(3);
    operationID <= registro(8)&registro(9)&registro(10)&registro(11);
    seed <= registro(12)&registro(13)&registro(14)&registro(15);
 --instanciar el modulo a probar
 hashGenerator: work.MurmurHashUtils.MurmurHash32Generator port map
 (  
    --entradas
    inputBlock      => inputBlock ,     
    readInput       => registro(4)(0),
    blockLength     => registro(5)(1 downto 0), 
    finalBlock      => registro(6)(0),
    start           => registro(7)(0),
    operationID     => (others => '-'),
    seed            => seed,
    --salidas
    canAccept =>   canAccept_output,
    resultReady =>   resultReady_output,
    result =>   open,
    resultID =>   open,
    clk => clk,
    dataStep1_dbg => open,
    dataStep2_dbg => open,
    dataStep3_dbg => open,
    dataStep4_dbg => open,
    dataStep5_dbg => open,
    dataStep1_ID_dbg => open,
    dataStep2_ID_dbg => open,
    dataStep3_ID_dbg => open,
    dataStep4_ID_dbg => open,
    dataStep5_ID_dbg => open,
    
    finalStep1_dbg => open,
    finalStep2_dbg => open,
    finalStep3_dbg => open,
    finalStep4_dbg => open,
    finalStep5_dbg => open,
    finalStep1_ID_dbg => open,
    finalStep2_ID_dbg => open,
    finalStep3_ID_dbg => open,
    finalStep4_ID_dbg => open,
    finalStep5_ID_dbg => open
 );
    
end architecture structural;
