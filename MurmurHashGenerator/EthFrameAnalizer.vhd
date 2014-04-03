----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2014 13:25:44
-- Design Name: 
-- Module Name: Eth_GMII_RXTest - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:     Modulo ue analiza la recepción de 
-- paquetes ethernet y analiza sus estadìsticas.
-- Las señales que utiliza son las recibidas de una interfaz GMII.
-- No valdia preambulo, delimitador de inicio de trama ni checksum.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;


library UNISIM;
use UNISIM.VComponents.all;

entity EthFrameAnalizer is
Port (             
    gmii_rx_clk : in STD_LOGIC;
    gmii_rx_data : in STD_LOGIC_VECTOR (7 downto 0);
    gmii_rx_dataValid : in STD_LOGIC;
    gmii_rx_col : in STD_LOGIC;
    gmii_rx_err : in STD_LOGIC;
    --Caracteristicas extraidas
    --Se actualizan de forma simultanea al momento que se termina la recepcion del paquete
    --Solo son validos durante un cicl ode reloj, cuando packet_evaluationFinished es '1'
    packet_evaluationFinished  : out std_logic;
    packet_actualByte   :   out std_logic_vector(15 downto 0);
    packet_MACDstAddrBroadcast  : out std_logic;
    packet_PHYSignaledError     : out std_logic;
    packet_Valid                : out std_logic;-- Si el paquete es valida, comprueba, PHYSignaledError y Len
    packet_EthTypeOrLen         : out std_logic;
    packet_EtherType_Len            : out std_logic_vector(15 downto 0);
    packet_IPV4                 : out std_logic;
    packet_IPV6                 : out std_logic;
    packet_ARP                  : out std_logic
);
end EthFrameAnalizer;

architecture Behavioral of EthFrameAnalizer is

    signal packet_MACDstAddrBroadcast_newValue  : std_logic;
    signal packet_IPV4_newValue                 : std_logic;
    signal packet_IPV6_newValue                 : std_logic;
    signal packet_ARP_newValue                  : std_logic;
    
     
    signal eth_rx_frameEnded         : boolean;-- Señal que indica que se ha terminado la captura de un frame ethernet
                                --Con esta señal las caracterísitcas del frame recibido deben guardarse y reniciarse para 
                                --estar listas para el sgte
    signal eth_rx_MACDstAddrBroadcast : boolean := false;
    signal eth_rx_PHYErr           : boolean := false; --Cuando el chip PHY ha indicado error durante la recepción del frame
    
    signal eth_rx_Type_Len_Byte1        : std_logic_vector(7 downto 0); --Cuando el chip PHY ha indicado error durante la recepción del frame
    signal eth_rx_Type_Len_Byte2        : std_logic_vector(7 downto 0); --Cuando el chip PHY ha indicado error durante la recepción del frame
    
    signal eth_rx_TypeIPV4         : boolean := false; --Cuando el chip PHY ha indicado error durante la recepción del frame
    signal eth_rx_TypeIPV6         : boolean := false; --Cuando el chip PHY ha indicado error durante la recepción del frame
    signal eth_rx_isARP            : boolean := false; --Cuando el chip PHY ha indicado error durante la recepción del frame
    signal eth_rx_payloadLen       : std_logic_vector(15 downto 0) := x"002E"; --Cuando el chip PHY ha indicado error durante la recepciòn del frame
    signal eth_rx_lenOK            : boolean := false;
    signal eth_rx_EthTypeOrLen     : boolean := false; --EtherType='1', Len= '0'
    signal thisLenOK               : boolean := true;
    signal eth_rx_payloadLen_newValue               : std_logic_vector(15 downto 0);
    
    
    signal oldDataValid            : std_logic;
    
    signal bytesCounter             : std_logic_vector(15 downto 0) := x"0000";
    
    
    signal MACDst_Byte_IsFF                 : std_logic_vector(5 downto 0) := "000000";
    signal MACDst_Byte_IsFF_Registered      : std_logic_vector(5 downto 0) := "000000";
    signal MACDst_IsFF                      : std_logic := '0';
    
    signal evaluateMACBcst : boolean;
    
    signal EtherTypeByte1IsIPV4 : boolean := false;
    signal EtherTypeByte1IsIPV6 : boolean := false;
    signal EtherTypeByte1IsARP  : boolean := false;
    signal EtherTypeByte2IsIPV4 : boolean := false;
    signal EtherTypeByte2IsIPV6 : boolean := false;
    signal EtherTypeByte2IsARP  : boolean := false;
    
    
    
begin
    
    --tratar eth_rx_frameEnd
    
    eth_rx_frameEnded <= (gmii_rx_dataValid='0') and (oldDataValid='1');
    packet_evaluationFinished<= '1' when eth_rx_frameEnded else '0';
    
    detectEndOfFrame: process(gmii_rx_clk, gmii_rx_dataValid, oldDataValid)
    begin
        if ( rising_edge(gmii_rx_clk) ) then
            oldDataValid<=gmii_rx_dataValid;
        end if;
    end process detectEndOfFrame;
    
    bytesCounterUdpate: process (gmii_rx_clk, gmii_rx_dataValid, eth_rx_frameEnded)
    begin
        if( rising_edge(gmii_rx_clk) ) then
            if ( eth_rx_frameEnded ) then
                bytesCounter <= ( others => '0');
            else
                if ( gmii_rx_dataValid = '1') then 
                    bytesCounter <= (bytesCounter+1);
                end if;
            end if;
        end if;
    end process bytesCounterUdpate;
    
    --detectar MAC es broadcast
    evaluateMACBcst <= ((gmii_rx_data = x"FF") and (gmii_rx_dataValid='1') );
    evaluateDstMACIsBroadcast : for macOffset in 0 to 5 generate
            MACDst_Byte_IsFF(macOffset) <=  '1' when (   (bytesCounter = (x"0008"+macOffset)) and evaluateMACBcst  ) else '0';
    end generate evaluateDstMACIsBroadcast; 
    
    detectMACIsBroadcast: process(gmii_rx_clk, gmii_rx_dataValid, oldDataValid, gmii_rx_data, eth_rx_frameEnded, bytesCounter, MACDst_Byte_IsFF)
        
    begin
        if( rising_edge(gmii_rx_clk) ) then
            if (eth_rx_frameEnded) then
                MACDst_Byte_IsFF_Registered <= "000000";
            else
                registerActualByteMACIsBroadcast : for macOffset in 0 to 5 loop
                    if (bytesCounter = (x"0008"+macOffset)) then
                        MACDst_Byte_IsFF_Registered(macOffset) <= MACDst_Byte_IsFF(macOffset);  
                    end if; 
                end loop;
            end if; 
        end if;
    end process detectMACIsBroadcast;
    eth_rx_MACDstAddrBroadcast <=  true when ( MACDst_Byte_IsFF_Registered = (MACDst_Byte_IsFF_Registered'range => '1') ) else false;--haciendo un AND de todos los valores del vector
        
    -- detect PHY error
    detectPHYError: process (gmii_rx_clk, gmii_rx_col, gmii_rx_err, eth_rx_frameEnded, eth_rx_PHYErr )
    begin
        if( rising_edge(gmii_rx_clk) ) then
            if(eth_rx_frameEnded)then
                eth_rx_PHYErr <= false;                
            else
                if( (gmii_rx_err='1') or (gmii_rx_col='1') ) then
                    eth_rx_PHYErr <= true;
                end if;
            end if;
        end if;
    end process;
    --detectar paquetes TypeIPV4, TypeIPV6 ó ARP
    thisLenOK <= ((eth_rx_Type_Len_Byte1 & gmii_rx_data)>x"002E");
    eth_rx_payloadLen_newValue <= (eth_rx_Type_Len_Byte1 & gmii_rx_data) when thisLenOK else x"002E";
    detectTypeOrLen: process (gmii_rx_clk , eth_rx_frameEnded, eth_rx_PHYErr, bytesCounter, gmii_rx_data, gmii_rx_dataValid )
    begin
        if( rising_edge(gmii_rx_clk) ) then
        
            if( (bytesCounter=20)  and (gmii_rx_dataValid='1') ) then
                eth_rx_Type_Len_Byte1 <= gmii_rx_data;
            end if;
            if( (bytesCounter=21)  and (gmii_rx_dataValid='1') ) then
                eth_rx_Type_Len_Byte2 <= gmii_rx_data;
                eth_rx_EthTypeOrLen <=  ((eth_rx_Type_Len_Byte1 & gmii_rx_data)>x"05DC");                
                eth_rx_lenOK <= thisLenOK;
                eth_rx_payloadLen <= eth_rx_payloadLen_newValue;
            end if;
            
            
        end if;
    end process;
    eth_rx_TypeIPV4 <= (eth_rx_Type_Len_Byte1 = x"08") and (eth_rx_Type_Len_Byte2 = x"00");
    eth_rx_TypeIPV6 <= (eth_rx_Type_Len_Byte1 = x"86") and (eth_rx_Type_Len_Byte2 = x"DD");
    eth_rx_isARP    <= (eth_rx_Type_Len_Byte1 = x"08") and (eth_rx_Type_Len_Byte2 = x"06") and eth_rx_MACDstAddrBroadcast;
    
    
    --eth_rx_EthTypeOrLen <= eth_rx_payloadLen>
    
    --Registrar las señales a la salida
    packet_evaluationFinished <= '1' when (eth_rx_frameEnded) else '0';
    packet_actualByte <= bytesCounter;
    packet_PHYSignaledError <= '1' when eth_rx_PHYErr else '0';
    packet_Valid  <= '1' when (not(eth_rx_PHYErr) and eth_rx_lenOK) else '0'; 
    packet_EthTypeOrLen  <= '1' when eth_rx_EthTypeOrLen else '0';
    packet_EtherType_Len <=  eth_rx_payloadLen;
        packet_MACDstAddrBroadcast_newValue  <= '1' when eth_rx_MACDstAddrBroadcast else '0';
        packet_IPV4_newValue <= '1' when eth_rx_TypeIPV4 else '0';
        packet_IPV6_newValue <= '1' when eth_rx_TypeIPV6 else '0';
        packet_ARP_newValue  <= '1' when eth_rx_isARP    else '0';
    registerResults: process (gmii_rx_clk, eth_rx_frameEnded, eth_rx_PHYErr, bytesCounter, gmii_rx_data, gmii_rx_dataValid )
    begin
        if( rising_edge(gmii_rx_clk) ) then
            packet_MACDstAddrBroadcast <= packet_MACDstAddrBroadcast_newValue;
            packet_IPV4 <= packet_IPV4_newValue;
            packet_IPV6 <= packet_IPV6_newValue;
            packet_ARP  <= packet_ARP_newValue;
        end if;
    end process registerResults;
    
    
end Behavioral ;
