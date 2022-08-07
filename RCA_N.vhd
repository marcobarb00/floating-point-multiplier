library ieee;
use ieee.std_logic_1164.all;

entity RCA_N is
	generic(N : integer := 8);
	port(
		X    : in  std_logic_vector(N-1 downto 0); -- first input
		Y    : in  std_logic_vector(N-1 downto 0); -- second input
		CIN  : in  std_logic;                      -- input carry
		S    : out std_logic_vector(N-1 downto 0); -- sum
		COUT : out std_logic                       -- output carry
	);
end RCA_N;

architecture RTL of RCA_N is
	-- full adder
	component FA is
		port(
			X    : in  std_logic;
			Y    : in  std_logic;
			CIN  : in  std_logic;
			S    : out std_logic;
			COUT : out std_logic
		);
	end component;
	
	-- internal signals
	signal C : std_logic_vector(N downto 0); -- temporary carry vector with N+1 components
														  -- to save the overflow bit
	
begin
	-- generate N full adders
	RCA_N_GEN:
	for I in 0 to N-1 generate
		FA_INSTANCE : FA port map(
			X    => X(I),
			Y    => Y(I),
			CIN  => C(I),
			S    => S(I),
			COUT => C(I+1));
	end generate RCA_N_GEN;
	
	-- first temporary carry bit is CIN
	C(0) <= CIN;
	-- COUT is the last temporary carry bit
	COUT <= C(N);
end RTL;