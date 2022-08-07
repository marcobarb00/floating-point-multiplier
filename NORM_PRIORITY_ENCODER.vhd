library ieee;
use ieee.std_logic_1164.all;

-- this priority encoder is modified to output the number to be added to
-- the exponent to make the normalization, for example:
-- mantissa: 00011010... means that i need to subtract 2 to the exponent, so i need to add 2 in two's complement

entity NORM_PRIORITY_ENCODER is
	port(
		X : in  std_logic_vector(47 downto 0); -- input
		Y : out std_logic_vector(5 downto 0)   -- output
	);
end NORM_PRIORITY_ENCODER;

architecture RTL of NORM_PRIORITY_ENCODER is
begin
	Y <= "111111" when X(47)           = '1' else
		  "000000" when X(47 downto 46) = "01" else
		  "000001" when X(47 downto 45) = "001" else
		  "000010" when X(47 downto 44) = "0001" else
		  "000011" when X(47 downto 43) = "00001" else
		  "000100" when X(47 downto 42) = "000001" else
		  "000101" when X(47 downto 41) = "0000001" else
		  "000110" when X(47 downto 40) = "00000001" else
		  "000111" when X(47 downto 39) = "000000001" else
		  "001000" when X(47 downto 38) = "0000000001" else
		  "001001" when X(47 downto 37) = "00000000001" else
		  "001010" when X(47 downto 36) = "000000000001" else
		  "001011" when X(47 downto 35) = "0000000000001" else
		  "001100" when X(47 downto 34) = "00000000000001" else
		  "001101" when X(47 downto 33) = "000000000000001" else
		  "001110" when X(47 downto 32) = "0000000000000001" else
		  "001111" when X(47 downto 31) = "00000000000000001" else
		  "010000" when X(47 downto 30) = "000000000000000001" else
		  "010001" when X(47 downto 29) = "0000000000000000001" else
		  "010010" when X(47 downto 28) = "00000000000000000001" else
		  "010011" when X(47 downto 27) = "000000000000000000001" else
		  "010100" when X(47 downto 26) = "0000000000000000000001" else
		  "010101" when X(47 downto 25) = "00000000000000000000001" else
		  "010110" when X(47 downto 24) = "000000000000000000000001" else
		  "010111" when X(47 downto 23) = "0000000000000000000000001" else
		  "011000" when X(47 downto 22) = "00000000000000000000000001" else
		  "011001" when X(47 downto 21) = "000000000000000000000000001" else
		  "011010" when X(47 downto 20) = "0000000000000000000000000001" else
		  "011011" when X(47 downto 19) = "00000000000000000000000000001" else
		  "011100" when X(47 downto 18) = "000000000000000000000000000001" else
		  "011101" when X(47 downto 17) = "0000000000000000000000000000001" else
		  "011110" when X(47 downto 16) = "00000000000000000000000000000001" else
		  "011111" when X(47 downto 15) = "000000000000000000000000000000001" else
		  "100000" when X(47 downto 14) = "0000000000000000000000000000000001" else
		  "100001" when X(47 downto 13) = "00000000000000000000000000000000001" else
		  "100010" when X(47 downto 12) = "000000000000000000000000000000000001" else
		  "100011" when X(47 downto 11) = "0000000000000000000000000000000000001" else
		  "100100" when X(47 downto 10) = "00000000000000000000000000000000000001" else
		  "100101" when X(47 downto 9)  = "000000000000000000000000000000000000001" else
		  "100110" when X(47 downto 8)  = "0000000000000000000000000000000000000001" else
		  "100111" when X(47 downto 7)  = "00000000000000000000000000000000000000001" else
		  "101000" when X(47 downto 6)  = "000000000000000000000000000000000000000001" else
		  "101001" when X(47 downto 5)  = "0000000000000000000000000000000000000000001" else
		  "101010" when X(47 downto 4)  = "00000000000000000000000000000000000000000001" else
		  "101011" when X(47 downto 3)  = "000000000000000000000000000000000000000000001" else
		  "101100" when X(47 downto 2)  = "0000000000000000000000000000000000000000000001" else
		  "101101" when X(47 downto 1)  = "00000000000000000000000000000000000000000000001" else
		  "101110" when X               = "000000000000000000000000000000000000000000000001" else
		  "101111" when X               = "000000000000000000000000000000000000000000000000" else
		  "------";
end RTL;