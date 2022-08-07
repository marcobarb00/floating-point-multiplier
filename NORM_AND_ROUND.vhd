library ieee;
use ieee.std_logic_1164.all;

entity NORM_AND_ROUND is
	port(
		MANTISSA                : in  std_logic_vector(47 downto 0); -- input mantissa
		EXPONENT                : in  std_logic_vector(7 downto 0);  -- input exponent
		ADJUSTED_MANTISSA       : out std_logic_vector(22 downto 0); -- mantissa after normalization and round off
		ADJUSTED_EXPONENT       : out std_logic_vector(7 downto 0);  -- exponent after normalization and round off of the mantissa
		INEXACT                 : out std_logic;                     -- inexact flag is set to 1 if there was a round off
		NORM_AND_ROUND_OVERFLOW : out std_logic                      -- raised if the exponent overflows
		);
end NORM_AND_ROUND;

architecture RTL of NORM_AND_ROUND is
	--signals
	signal FIRST_ONE                  : std_logic_vector(5 downto 0);  -- position of the first one in the mantissa (1 in mantissa's MSB is position 0)
	signal NEG_FIRST_ONE              : std_logic_vector(8 downto 0);  -- negation of FIRST_ONE with added bits to add it with EXPONENT
	signal EXT_EXPONENT               : std_logic_vector(8 downto 0);
	signal MIN_NORM_EXPONENT          : std_logic_vector(8 downto 0);  -- sum of EXPONENT and NEG_FIRST_ONE
	signal MIN_NORM_EXPONENT_INFINITY : std_logic;                     -- raised if the MIN_NORM_EXPONENT overflows
	
	signal MANTISSA_SHIFT             : std_logic_vector(7 downto 0);  -- indicates how much bits to shift the mantissa
	
	signal NORM_MANTISSA              : std_logic_vector(23 downto 0); -- normalized mantissa
	signal NORM_EXPONENT              : std_logic_vector(7 downto 0);  -- exponent after normalization of the mantissa
	
	signal ROUND_OFF_OVERFLOW         : std_logic;
	signal EXPONENT_OVERFLOW          : std_logic;                     -- raised if the exponent overflows during round off

	-- components
	-- priority encoder
	component NORM_PRIORITY_ENCODER is
		port(
			X : in  std_logic_vector(47 downto 0); -- input
			Y : out std_logic_vector(5 downto 0)   -- output
		);
	end component NORM_PRIORITY_ENCODER;
	
	component RCA_N is
		generic(N : integer := 8);
		port(
			X    : in  std_logic_vector(N-1 downto 0); -- first input
			Y    : in  std_logic_vector(N-1 downto 0); -- second input
			CIN  : in  std_logic;                      -- input carry
			S    : out std_logic_vector(N-1 downto 0); -- sum
			COUT : out std_logic                       -- output carry
		);
	end component RCA_N;
begin
	MIN_NORM_EXPONENT_INFINITY <= '1' when (EXPONENT(7 downto 0) = "11111111") or (EXPONENT(7 downto 0) = "11111110" and MANTISSA(47) = '1') else
									      '0';
	
	-- priority encoder to find where the first 1 is
	FIRST_ONE_CALC:
	NORM_PRIORITY_ENCODER
	port map(
		X => MANTISSA,
		Y => FIRST_ONE
	);
	
	-- subtract first one position to the exponent to calculate the adjusted exponent
	-- and to check wether or not the result will be normalized or not
	with MANTISSA(47) select
		NEG_FIRST_ONE <= "111" & not FIRST_ONE when '0',
							  "000000000"           when '1',
							  "---------"           when others;
	EXT_EXPONENT  <= '0' & EXPONENT;
	
	MIN_NORM_EXPONENT_CALC:
	RCA_N
	generic map(N => 9)
	port map(
		X    => EXT_EXPONENT,
		Y    => NEG_FIRST_ONE,
		CIN  => '1',
		S    => MIN_NORM_EXPONENT
	);
	
	-- check if the mantissa will be normalized or not, if the mantissa will be denormalized,
	-- shift the mantissa as much as possible (as much as EXPONENT remains >= 0)
	with MIN_NORM_EXPONENT(8) select
		MANTISSA_SHIFT <= EXPONENT         when '1',
								"00" & FIRST_ONE when '0',
								"--------"       when others;
	
	-- shift the mantissa
	with MANTISSA_SHIFT select
		NORM_MANTISSA <= MANTISSA(46 downto 23)     when "00111111", -- special case for first one = 1
							  MANTISSA(45 downto 22)     when "00000000",
							  MANTISSA(44 downto 21)     when "00000001",
							  MANTISSA(43 downto 20)     when "00000010",
							  MANTISSA(42 downto 19)     when "00000011",
							  MANTISSA(41 downto 18)     when "00000100",
							  MANTISSA(40 downto 17)     when "00000101",
							  MANTISSA(39 downto 16)     when "00000110",
							  MANTISSA(38 downto 15)     when "00000111",
							  MANTISSA(37 downto 14)     when "00001000",
							  MANTISSA(36 downto 13)     when "00001001",
							  MANTISSA(35 downto 12)     when "00001010",
							  MANTISSA(34 downto 11)     when "00001011",
							  MANTISSA(33 downto 10)     when "00001100",
							  MANTISSA(32 downto 9)      when "00001101",
							  MANTISSA(31 downto 8)      when "00001110",
							  MANTISSA(30 downto 7)      when "00001111",
							  MANTISSA(29 downto 6)      when "00010000",
							  MANTISSA(28 downto 5)      when "00010001",
							  MANTISSA(27 downto 4)      when "00010010",
							  MANTISSA(26 downto 3)      when "00010011",
							  MANTISSA(25 downto 2)      when "00010100",	 
							  MANTISSA(24 downto 1)      when "00010101",
							  MANTISSA(23 downto 0)      when "00010110",
							  MANTISSA(22 downto 0) & '0' when "00010111",
							  MANTISSA(21 downto 0) & "00" when "00011000",
							  MANTISSA(20 downto 0) & "000" when "00011001",
							  MANTISSA(19 downto 0) & "0000" when "00011010",
							  MANTISSA(18 downto 0) & "00000" when "00011011",
							  MANTISSA(17 downto 0) & "000000" when "00011100",
							  MANTISSA(16 downto 0) & "0000000" when "00011101",
							  MANTISSA(15 downto 0) & "00000000" when "00011110",
							  MANTISSA(14 downto 0) & "000000000" when "00011111",
							  MANTISSA(13 downto 0) & "0000000000" when "00100000",
							  MANTISSA(12 downto 0) & "00000000000" when "00100001",
							  MANTISSA(11 downto 0) & "000000000000" when "00100010",
							  MANTISSA(10 downto 0) & "0000000000000" when "00100011",
							  MANTISSA(9  downto 0) & "00000000000000" when "00100100",
							  MANTISSA(8  downto 0) & "000000000000000" when "00100101",
							  MANTISSA(7  downto 0) & "0000000000000000" when "00100110",
							  MANTISSA(6  downto 0) & "00000000000000000" when "00100111",
							  MANTISSA(5  downto 0) & "000000000000000000" when "00101000",
							  MANTISSA(4  downto 0) & "0000000000000000000" when "00101001",
							  MANTISSA(3  downto 0) & "00000000000000000000" when "00101010",
							  MANTISSA(2  downto 0) & "000000000000000000000" when "00101011",
							  MANTISSA(1  downto 0) & "0000000000000000000000" when "00101100",
							  MANTISSA(0)           & "00000000000000000000000" when "00101101",
							  "000000000000000000000000" when "00101110",
							  "000000000000000000000000" when "00101111",
							  "000000000000000000000000" when "11111111", -- exponent is 11111111
							  "------------------------" when others;

	with MIN_NORM_EXPONENT(8) select
		NORM_EXPONENT <= MIN_NORM_EXPONENT(7 downto 0) when '0',
						     "00000000"                    when '1',
						     "--------"                    when others;
	
	-- mantissa round off
	-- set inexact flag
	INEXACT <= NORM_MANTISSA(0);
	
	-- if the LSB of NORM_MANTISSA is 1, sum 1 to the mantissa
	ADJUTED_MANTISSA_CALC:
	RCA_N
	generic map(N => 23)
	port map(
		X    => NORM_MANTISSA(23 downto 1),
		Y    => "00000000000000000000000",
		CIN  => NORM_MANTISSA(0),
		S    => ADJUSTED_MANTISSA,
		COUT => ROUND_OFF_OVERFLOW
	);
	
	-- if the mantissa overflows during round off, sum 1 to the exponent
	-- if NORM_EXPONENT is 11111111 and the mantissa overflows, the result should be INFINITY
	ADJUSTED_EXPONENT_CALC:
	RCA_N
	generic map(N => 8)
	port map(
		X    => NORM_EXPONENT,
		Y    => "00000000",
		CIN  => ROUND_OFF_OVERFLOW,
		S    => ADJUSTED_EXPONENT,
		COUT => EXPONENT_OVERFLOW
	);
	
	NORM_AND_ROUND_OVERFLOW <= MIN_NORM_EXPONENT_INFINITY or EXPONENT_OVERFLOW;
end RTL;