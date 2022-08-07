library ieee;
use ieee.std_logic_1164.all;

entity FLOATING_POINT_MULTIPLIER is
	port(
		CLK       : in  std_logic;
		RESET     : in  std_logic;
		X         : in  std_logic_vector(31 downto 0);
		Y         : in  std_logic_vector(31 downto 0);
		P         : out std_logic_vector(31 downto 0);
		OVERFLOW  : out std_logic;
		UNDERFLOW : out std_logic;
		INVALID   : out std_logic;
		INEXACT   : out std_logic
	);
end FLOATING_POINT_MULTIPLIER;

architecture RTL of FLOATING_POINT_MULTIPLIER is
	-- signals used for stage 1 of the pipeline
	signal X_SIGN_S1                        : std_logic;
	signal X_EXPONENT_S1                    : std_logic_vector(7 downto 0);
	signal X_MANTISSA_S1                    : std_logic_vector(23 downto 0);
	signal Y_SIGN_S1                        : std_logic;
	signal Y_EXPONENT_S1                    : std_logic_vector(7 downto 0);
	signal Y_MANTISSA_S1                    : std_logic_vector(23 downto 0);
	
	signal EXPONENT_SUM_S1                  : std_logic_vector(8 downto 0);
	signal P_SIGN_S1                        : std_logic;
	signal INVALID_S1                       : std_logic;
	signal NAN_S1                           : std_logic;
	
	-- signals used for stage 2 of the pipeline
	signal X_MANTISSA_S2                    : std_logic_vector(23 downto 0);
	signal Y_MANTISSA_S2                    : std_logic_vector(23 downto 0);
	signal EXPONENT_SUM_S2                  : std_logic_vector(8 downto 0);
	signal P_SIGN_S2                        : std_logic;
	
	signal TEMP_BIASED_EXPONENT_S2          : std_logic_vector(8 downto 0);
	signal BIASED_EXPONENT_OVERFLOW_S2      : std_logic;
	signal BIASED_EXPONENT_NOT_UNDERFLOW_S2 : std_logic;
	signal BIASED_EXPONENT_S2               : std_logic_vector(7 downto 0);
	signal PRODUCT_S2                       : std_logic_vector(47 downto 0);
	signal INVALID_S2                       : std_logic;
	signal NAN_S2                           : std_logic;

	-- signals used for stage 3 of the pipeline
	signal P_SIGN_S3                        : std_logic;
	signal PRODUCT_S3                       : std_logic_vector(47 downto 0);
	signal BIASED_EXPONENT_S3               : std_logic_vector(7 downto 0);
	signal BIASED_EXPONENT_OVERFLOW_S3      : std_logic;
	signal BIASED_EXPONENT_NOT_UNDERFLOW_S3 : std_logic;
	
	signal NAN_S3                           : std_logic;
	signal NORM_AND_ROUND_OVERFLOW_S3       : std_logic;
	signal ADJUSTED_MANTISSA_S3             : std_logic_vector(22 downto 0);
	signal ADJUSTED_EXPONENT_S3             : std_logic_vector(7 downto 0);
	
	-- components
	-- matrix multiplier
	component MATRIX_MULTIPLIER is
		port(
			X : in  std_logic_vector(23 downto 0); -- first input
			Y : in  std_logic_vector(23 downto 0); -- second input
			P : out std_logic_vector(47 downto 0)  -- product
		);
	end component MATRIX_MULTIPLIER;
	
	-- NORMALIZE AND ROUND OFF
	component NORM_AND_ROUND is
		port(
			MANTISSA                : in  std_logic_vector(47 downto 0); -- input mantissa
			EXPONENT                : in  std_logic_vector(7 downto 0);  -- input exponent
			ADJUSTED_MANTISSA       : out std_logic_vector(22 downto 0); -- mantissa after normalization and round off
			ADJUSTED_EXPONENT       : out std_logic_vector(7 downto 0);  -- exponent after normalization and round off of the mantissa
			INEXACT                 : out std_logic;                     -- inexact flag is set to 1 if there was a round off
			NORM_AND_ROUND_OVERFLOW : out std_logic                      -- raised if the exponent overflows
		);
	end component NORM_AND_ROUND;
	
	-- RCA
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
	-- X decomposition in sign, exponent, mantissa
	X_SIGN_S1                  <= X(31);
	X_MANTISSA_S1(22 downto 0) <= X(22 downto 0);
	
	-- Y decomposition in sign, exponent, mantissa
	Y_SIGN_S1                  <= Y(31);
	Y_MANTISSA_S1(22 downto 0) <= Y(22 downto 0);
	
	-- handling of subnormal floats
	-- for subnormal numbers, the leading digit of the mantisa should be 0
	with X(30 downto 23) select
		X_MANTISSA_S1(23) <= '0' when "00000000",
								   '1' when others;
	
	-- for subnormal number the exponent is interpreted as -126 = 00000001
	with X(30 downto 23) select
	X_EXPONENT_S1 <= "00000001" when "00000000",
					     X(30 downto 23) when others;
	
	with Y(30 downto 23) select
		Y_MANTISSA_S1(23) <= '0' when "00000000",
							   	'1' when others;
	
	with Y(30 downto 23) select
	Y_EXPONENT_S1 <= "00000001" when "00000000",
					     Y(30 downto 23) when others;
	
	-- special cases
	-- if X = ±0 and Y = ±INF or X = ±INF and Y = ±0 signal invalid exception
	INVALID_S1 <= '1' when X(30 downto 0) = "0000000000000000000000000000000" and Y(30 downto 0) = "1111111100000000000000000000000" else
			        '1' when X(30 downto 0) = "1111111100000000000000000000000" and Y(30 downto 0) = "0000000000000000000000000000000" else
			        '0';
	
	NAN_S1 <= '1' when X(30 downto 23) = "11111111" and not (X(22 downto 0) = "00000000000000000000000") else
				 '1' when Y(30 downto 23) = "11111111" and not (Y(22 downto 0) = "00000000000000000000000") else
				 '0';
	
	-- sign calculation
	P_SIGN_S1 <= X_SIGN_S1 xor Y_SIGN_S1;
	
	-- exponent sum
	RCA_EXPONENT:
	RCA_N
	generic map(N => 8)
	port map(
		X    => X_EXPONENT_S1,
		Y    => Y_EXPONENT_S1,
		CIN  => '0',
		S    => EXPONENT_SUM_S1(7 downto 0),
		COUT => EXPONENT_SUM_S1(8)
	);
	
	-- handling of register that link stage 1 and 2
	STAGE_1_2_REGISTERS:
	process(CLK)
	begin
		if(CLK'event and CLK = '0') then
			if(RESET = '1') then
				X_MANTISSA_S2   <= "000000000000000000000000";
				Y_MANTISSA_S2   <= "000000000000000000000000";
				EXPONENT_SUM_S2 <= "000000000";
				P_SIGN_S2       <= '0';
				INVALID_S2      <= '0';
				NAN_S2          <= '0';
			else
				X_MANTISSA_S2   <= X_MANTISSA_S1;
				Y_MANTISSA_S2   <= Y_MANTISSA_S1;
				EXPONENT_SUM_S2 <= EXPONENT_SUM_S1;
				P_SIGN_S2       <= P_SIGN_S1;
				INVALID_S2      <= INVALID_S1;
				NAN_S2          <= NAN_S1;
			end if;
		end if;
	end process STAGE_1_2_REGISTERS;
	
	-- exponent adjust
	-- with a 9 bit ader subtracting 127 is the same as adding 385
	RCA_EXP_ADJUST:
	RCA_N
	generic map(N => 9)
	port map(
		X    => EXPONENT_SUM_S2,
		Y    => "110000001", --385
		CIN  => '0',
		S    => TEMP_BIASED_EXPONENT_S2,
		COUT => BIASED_EXPONENT_NOT_UNDERFLOW_S2
	);
	
	BIASED_EXPONENT_S2           <= TEMP_BIASED_EXPONENT_S2(7 downto 0);
	BIASED_EXPONENT_OVERFLOW_S2  <= TEMP_BIASED_EXPONENT_S2(8); 
	
	-- mantissa multiplication
	MATRIX_MULTIPLIER_INSTANCE:
	MATRIX_MULTIPLIER port map(
		X => X_MANTISSA_S2,
		Y => Y_MANTISSA_S2,
		P => PRODUCT_S2
	);
	
	-- handling of register that link stage 2 and 3
	STAGE_2_3_REGISTERS:
	process(CLK)
	begin
		if(CLK'event and CLK = '0') then
			if(RESET = '1') then
				P_SIGN_S3                        <= '0';
				PRODUCT_S3                       <= "000000000000000000000000000000000000000000000000";
				BIASED_EXPONENT_S3               <= "00000000";
				BIASED_EXPONENT_NOT_UNDERFLOW_S3 <= '1';
				BIASED_EXPONENT_OVERFLOW_S3      <= '0';
				INVALID                          <= '0';
				NAN_S3                           <= '0';
			else
				P_SIGN_S3                        <= P_SIGN_S2;
				BIASED_EXPONENT_S3               <= BIASED_EXPONENT_S2;
				PRODUCT_S3                       <= PRODUCT_S2;
				BIASED_EXPONENT_NOT_UNDERFLOW_S3 <= BIASED_EXPONENT_NOT_UNDERFLOW_S2;
				BIASED_EXPONENT_OVERFLOW_S3      <= BIASED_EXPONENT_OVERFLOW_S2;
				INVALID                          <= INVALID_S2;
				NAN_S3                           <= NAN_S2;
			end if;
		end if;
	end process STAGE_2_3_REGISTERS;
	
	NORMALIZE_AND_ROUND_OFF:
	NORM_AND_ROUND
	port map(
		MANTISSA                => PRODUCT_S3,
		EXPONENT                => BIASED_EXPONENT_S3,
		ADJUSTED_MANTISSA       => ADJUSTED_MANTISSA_S3,
		ADJUSTED_EXPONENT       => ADJUSTED_EXPONENT_S3,
		INEXACT                 => INEXACT,
		NORM_AND_ROUND_OVERFLOW => NORM_AND_ROUND_OVERFLOW_S3
	);
	
	-- set overflow/underflow flags
	
	-- set the overflow flag
	-- the overflow is set to 1 if during the normalization or the round off the exponent overflows or if during the bias the exponent is greater that 254
	-- if during the bias there was an underflow, then the overflow is 0 even if there was an overflow of the exponent
	OVERFLOW <= '1' when (NORM_AND_ROUND_OVERFLOW_S3 = '1' or BIASED_EXPONENT_OVERFLOW_S3 = '1') and BIASED_EXPONENT_NOT_UNDERFLOW_S3 = '1' else
					'0';
	
	-- if the EXPONENT_SUM is less than 127 there is an undeflow, this is indicated by the
	--	BIASED_EXPONENT_OVERFLOW which is 0, if the EXPONENT_SUM is greater or equal to 127, the overflow is 1.
	-- 126 + 385 = 511 => BIASED_EXPONENT_OVERFLOW = 0,
	-- 127 + 385 = 512 => BIASED_EXPONENT_OVERFLOW = 1
	UNDERFLOW <= not BIASED_EXPONENT_NOT_UNDERFLOW_S3;
	
	P(31) <= P_SIGN_S3;
	
	P(30 downto 23) <= "11111111" when NAN_S3 = '1' else
							 "11111111" when ((NORM_AND_ROUND_OVERFLOW_S3 = '1' or BIASED_EXPONENT_OVERFLOW_S3 = '1') and BIASED_EXPONENT_NOT_UNDERFLOW_S3 = '1') and NAN_S3 = '0' else
							 "00000000" when BIASED_EXPONENT_NOT_UNDERFLOW_S3 = '0' else
							 ADJUSTED_EXPONENT_S3;
	
	P(22 downto 0) <= "00000000000000000000001" when NAN_S3 = '1' else
							"00000000000000000000000" when (NORM_AND_ROUND_OVERFLOW_S3 = '1' or BIASED_EXPONENT_OVERFLOW_S3 = '1') and NAN_S3 = '0' else
							ADJUSTED_MANTISSA_S3;
end RTL;