library ieee;
use ieee.std_logic_1164.all;

entity FA is
	port(
		X    : in  std_logic; -- first input
		Y    : in  std_logic; -- second input
		CIN  : in  std_logic; -- carry in
		S    : out std_logic; -- sum
		COUT : out std_logic  -- carry out
	);
end FA;

architecture RTL of FA is
begin
	S <= X xor Y xor CIN;
	COUT <= (X and Y) or (Y and CIN) or (X and CIN);
end RTL;