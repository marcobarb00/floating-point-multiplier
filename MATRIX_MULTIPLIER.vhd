library ieee;
use ieee.std_logic_1164.all;

entity MATRIX_MULTIPLIER is
	port(
		X : in  std_logic_vector(23 downto 0);
		Y : in  std_logic_vector(23 downto 0);
		P : out std_logic_vector(47 downto 0)
	);
end MATRIX_MULTIPLIER;

architecture RTL of MATRIX_MULTIPLIER is
	signal PART_S  : std_logic_vector(599 downto 0); -- 24X25 matrix (I, J) -> (25*I + J) (PART_S(575:599) should not be used)
	signal CARRY   : std_logic_vector(599 downto 0); -- 25X24 matrix (I, J) -> (24*I + J)
	signal PART_P  : std_logic_vector(575 downto 0); -- 24X24 matrix (I, J) -> (24*I + J)
	
	-- full adder
	component FA is
		port(
			X    : in  std_logic; -- first input
			Y    : in  std_logic; -- second input
			CIN  : in  std_logic; -- carry in
			S    : out std_logic; -- sum
			COUT : out std_logic  -- carry out
		);
	end component FA;
begin
	-- add 24*24 MAC modules
	
	-- first row of MAC is different from others
		Y_FOR_FIRST_ROW:
		for J in 23 downto 0 generate
			PART_P(J) <= y(0) and X(J);
			
			FA_INSTANCE : FA port map(
				X    => '0',
				Y    => PART_P(J),
				CIN  => CARRY(24*J),
				COUT => CARRY(24*(J+1)),
				S    => PART_S(J)
			);
		end generate Y_FOR_FIRST_ROW;
	
	X_FOR:
	for I in 23 downto 1 generate
		Y_FOR:
		for J in 22 downto 0 generate
			PART_P(24*I + J) <= Y(I) and X(J);
			
			FA_INSTANCE : FA port map(
				X    => PART_S(25*(I-1) + (J+1)),
				Y    => PART_P(24*I + J),
				CIN  => CARRY(24*J + I),
				COUT => CARRY(24*(J+1) + I),
				S    => PART_S(25*I + J)
			);
		end generate Y_FOR;
		
		-- last column of MAC is different from others
		PART_P(24*I + 23) <= Y(I) and X(23);
		
		FA_INSTANCE : FA port map(
			X    => CARRY(24*24 + (I-1)),
			Y    => PART_P(24*I + 23),
			CIN  => CARRY(24*23 + I),
			COUT => CARRY(24*24 + I),
			S    => PART_S(25*I + 23)
		);
	end generate X_FOR;
	
	-- define the values of the first column of carry
	INIT:
	for I in 23 downto 0 generate
		CARRY(I) <= '0';
	end generate INIT;
	
	-- define the output product
	P_23_DOWNTO_0:
	for I in 23 downto 0 generate
		P(I) <= PART_S(25*I);
	end generate P_23_DOWNTO_0;
	
	P_46_DOWNTO_24:
	for I in 22 downto 0 generate
		P(I+24) <= PART_S(25*23 + (I+1));
	end generate P_46_DOWNTO_24;
	
	P(47) <= CARRY(24*24 + 23);
end RTL;