-- Murmur Hash Code Generator
-- Author: Raul Gerardo Huertas Paiva

--Copyright (c) 2014, Raul Huertas
--All rights reserved.
----Redistribution and use in source and binary forms, with or without
----modification, are permitted provided that the following conditions are met: 
----
----1. Redistributions of source code must retain the above copyright notice, this
--   list of conditions and the following disclaimer. 
--2. Redistributions in binary form must reproduce the above copyright notice,
--   this list of conditions and the following disclaimer in the documentation
--   and/or other materials provided with the distribution. 
--
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
--ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--The views and conclusions contained in the software and documentation are those
--of the authors and should not be interpreted as representing official policies, 
--either expressed or implied, of the FreeBSD Project.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MurmurHash32Generator is
	generic ( 
		ID_PRESENT: boolean = true; 
		ID_LENGTH: integer = 31
	);
	port(
		--ENTRADAS
		inputBlock : in std_logic_vector(31 downto 0);
		readInput : in std_logic;
		blockLength : in std_logic_vector(1 downto 0);
		finalBlock : in std_logic;
		start : in std_logic;
		operationID : in std_logic_vector(ID_LENGTH downto 0);
		seed : in std_logic_vector(31 downto 0);
		--SALIDAS
		resultReady : in std_logic;
		result : out std_logic_vector(31 downto 0)
		resultID : in std_logic_vector(ID_LENGTH downto 0);
		--RELOJ
		clk : in std_logic;
		
	);
end MurmurHash32Generator;

architecture Estructural of MurmurHash32Generator is

begin


end architecture MurmurHash32Generator;

