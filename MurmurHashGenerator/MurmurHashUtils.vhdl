----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2013 23:39:33
-- Design Name: 
-- Module Name: MurmurHashUtils - Behavioral
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
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package MurmurHashUtils is

    constant c1 : unsigned(31 downto 0) := x"cc9e2d51";
    constant c2 : unsigned(31 downto 0) := x"1b873593";
    constant m  : unsigned(31 downto 0) := x"00000005";
    constant n  : unsigned(31 downto 0) := x"e6546b64";

type Step1_Capture is record
    dataValid           : boolean;    --! Indica que los datos capturados en este datoa ctual son validos
    data                : unsigned(31 downto 0);           --! Guarda los datos recibidos
    dataLength          : std_logic_vector(1 downto 0);
    isFirst             : boolean;
    isLast              : boolean;
    operationID         : std_logic_vector(31 downto 0); --31 es el 'size' maximo del opID
    seed                : std_logic_vector(31 downto 0);
end record Step1_Capture;




end MurmurHashUtils;



