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
use std.textio.all;
use work.MurmurHashUtils.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB4_FileBasedTest is
end TB4_FileBasedTest;

architecture Behavioral of TB4_FileBasedTest is
    
    type resultReference is array (0 to 100) of std_logic_vector(31 downto 0);
    
    type file_t is file of character; 
    file dataFile : file_t open READ_MODE is "HashGenerationsTest.hgt";
begin
    Test: process  is
        variable code : std_logic_vector(31 downto 0);
        variable seed : std_logic_vector(31 downto 0);
        variable nTuplas : std_logic_vector(31 downto 0);
        variable testHashs : resultReference;
        variable testsLengths : resultReference;
        variable inputByte: character;    
        file dataFile : file_t;
        variable fstatus: FILE_OPEN_STATUS;        
    begin
        --file_open(fstatus, dataFile, "HashGenerationsTest.hgt", read_mode);
        read( dataFile,  inputByte);
        code( 7 downto 0) := char_to_slv8(inputByte);
        read( dataFile,  inputByte);
        code(15 downto 8) := char_to_slv8(inputByte);
        read( dataFile,  inputByte);
        code(23 downto 16) := char_to_slv8(inputByte);                
        read( dataFile,  inputByte);
        code(31 downto 24) := char_to_slv8(inputByte);
        
        if (code/=x"00000001") then
            report "El archivo no tiene el codigo inicial esperado";
        else
            report "Codigo leido correctamente del archivo";
        end if;
        
        
        
        --file_close(dataFile);
        wait;-- Que no se repita de forma indefinida
    end process Test;

end Behavioral;
