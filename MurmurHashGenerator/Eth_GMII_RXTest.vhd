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
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Eth_GMII_RXTest is
    Port ( 
            botones : in STD_LOGIC_VECTOR (3 downto 0);
            
            leds : out STD_LOGIC_VECTOR (3 downto 0);
            gmii_int : in STD_LOGIC;
            gmii_reset : out STD_LOGIC;
            
            --Interfaz hacia el PHY
            gmii_mdc : out STD_LOGIC;
            gmii_mdio : inout STD_LOGIC;
            
            gmii_tx_clk : out STD_LOGIC;
            gmii_tx_en : out STD_LOGIC;
            gmii_tx_data : out STD_LOGIC_VECTOR (7 downto 0);
            gmii_tx_err : out STD_LOGIC;
            
            gmii_rx_clk : in STD_LOGIC;
            gmii_rx_crs : in STD_LOGIC;
            gmii_rx_col : in STD_LOGIC;
            gmii_rx_data : in STD_LOGIC_VECTOR (7 downto 0);
            gmii_rx_dataValid : in STD_LOGIC;
            gmii_rx_err : in STD_LOGIC;
            
            sysclk_n : in std_logic;
            sysclk_p : in std_logic
           );
end Eth_GMII_RXTest;

architecture Behavioral of Eth_GMII_RXTest is
    

signal packetCounter                    : std_logic_vector(3 downto 0) := "0000";
signal gmii_rx_dataValid_previous       : std_logic;


signal tx_clk                        : std_logic;

signal packetAlreadyReaded  : std_logic := '0';
signal porta_wr             : std_logic;
signal porta_waddr          : std_logic_vector(9 downto 0);
signal porta_din            : std_logic_vector(7 downto 0) := ( others => '0');
signal porta_rd             : std_logic;
signal porta_raddr          : std_logic_vector(9 downto 0);
signal porta_dout           : std_logic_vector(7 downto 0);
signal portb_rd             : std_logic;
signal portb_addr           : std_logic_vector(9 downto 0);
signal portb_dout           : std_logic_vector(7 downto 0);

signal storeCounter          : std_logic_vector(9 downto 0) := ( others => '0');

begin


memory: entity work.BinarySearchBRAM
generic map( DATA_WIDTH => 8, ADDR_WIDTH => 10 ) 
port map (
    clk => gmii_rx_clk,
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

porta_wr <= (gmii_rx_dataValid and not(packetAlreadyReaded));
porta_waddr <= storeCounter;
porta_din  <= gmii_rx_data(7 downto 0);
porta_rd <= '0';
porta_raddr <= ( others => '0');
portb_rd <= '0';
portb_addr <= ( others => '0');

RXClocking: process (gmii_rx_clk, gmii_rx_dataValid, gmii_rx_data, storeCounter, gmii_rx_dataValid_previous, packetCounter) begin
    if ( rising_edge(gmii_rx_clk) ) then
        if(gmii_rx_dataValid = '1') then
            --leds(3 downto 0) <= gmii_rx_data(3 downto 0);
            storeCounter <= storeCounter+1;
        end if;
        gmii_rx_dataValid_previous <= gmii_rx_dataValid;
        if( (gmii_rx_dataValid = '1') and (gmii_rx_dataValid_previous = '0') ) then
            packetCounter <= packetCounter+1;
        elsif ( (gmii_rx_dataValid = '0') and (gmii_rx_dataValid_previous = '1') ) then
            packetAlreadyReaded <= '1';
        end if;
    end if;
end process RXClocking;

leds <= packetCounter;

gmii_reset <= '1';

gmii_tx_en <= '0';
gmii_tx_data <= (others => '0');
gmii_tx_err <= '0';

gmii_mdc <= '0';
gmii_mdio <= 'Z';

txClkGenerator: entity work.clk_wiz_v3_6_0 
port map
 (-- Clock in ports
  CLK_IN1_P   => sysclk_p,
  CLK_IN1_N   => sysclk_n,
  -- Clock out ports
  CLK_OUT1    => tx_clk
 );

gmii_tx_clk_ddr_iob : ODDR2
port map(
     D0          => '0',
     D1          => '1',
     C0          => tx_clk,
     C1          => '0',
     CE => '1',
     R => '0',
     S           => '0',
     Q           => gmii_tx_clk
);

end Behavioral;
