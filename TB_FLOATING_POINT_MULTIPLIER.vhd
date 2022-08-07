library ieee;
use ieee.std_logic_1164.all;
 
entity TB_FLOATING_POINT_MULTIPLIER_PIPE is
end TB_FLOATING_POINT_MULTIPLIER_PIPE;

architecture behavior of TB_FLOATING_POINT_MULTIPLIER_PIPE is
	-- Component Declaration for the Unit Under Test (UUT)
	component FLOATING_POINT_MULTIPLIER
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
	end component;
   
   -- input signals
   signal CLK   : std_logic;
   signal RESET : std_logic;
   signal X     : std_logic_vector(31 downto 0);
   signal Y     : std_logic_vector(31 downto 0);

 	-- output signals
   signal P         : std_logic_vector(31 downto 0);
   signal OVERFLOW  : std_logic;
   signal UNDERFLOW : std_logic;
	signal INVALID   : std_logic;
	signal INEXACT   : std_logic;
	
	-- test signals
	signal EXP_P       : std_logic_vector(31 downto 0);
	signal EXP_INVALID : std_logic;
	signal TEST        : std_logic;

   -- Clock period definitions
   constant CLK_PERIOD : time := 50 ns;

begin
	-- Instantiate the Unit Under Test (UUT)
   uut: FLOATING_POINT_MULTIPLIER port map(
		CLK       => CLK,
      RESET     => RESET,
      X         => X,
      Y         => Y,
      P         => P,
      OVERFLOW  => OVERFLOW,
      UNDERFLOW => UNDERFLOW,
		INVALID   => INVALID,
		INEXACT   => INEXACT
	);

   -- Clock process definitions
   CLK_PROCESS: process
   begin
		CLK <= '0';
		wait for CLK_PERIOD/2;
		CLK <= '1';
		wait for CLK_PERIOD/2;
   end process;
	
	TEST_PROCESS: process
	begin
		-- wait to start
		EXP_P       <= "00000000000000000000000000000000";
		EXP_INVALID <= '0';
		wait for 12.5*CLK_PERIOD;
		
		-- test 1
		EXP_P       <= "00111111101000000000000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 2
		EXP_P       <= "11000111010000110101000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 3
		EXP_P       <= "01000000011111111111111111111111";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 4
		EXP_P       <= "01000000111111111111111111111111";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 5
		EXP_P       <= "00000000000000000000000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 6
		EXP_P       <= "00001110000100000111111010100111";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 7
		EXP_P       <= "00110101100000000000000000000000";
		EXP_INVALID <= '1';
		wait for CLK_PERIOD/2;
		
		if EXP_INVALID = INVALID then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 8
		EXP_P       <= "01111111100000000000000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 9
		EXP_P       <= "01111111100000000000000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 10
		EXP_P       <= "00000000000000000000000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 11
		EXP_P       <= "01111111100000000000000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 12
		EXP_P       <= "01111111100000000000000000000000";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 13
		EXP_P       <= "01111111100000000000000000000001";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		
		-- test 14
		EXP_P       <= "10100110101101000111001111010011";
		EXP_INVALID <= '0';
		wait for CLK_PERIOD/2;
		
		if (EXP_P = P) and (EXP_INVALID = INVALID) then
			TEST <= '1';
		else
			TEST <= '0';
		end if;
		wait for CLK_PERIOD/2;
		wait;
	end process;
 
   -- Stimulus process
   STIM_PROCESS: process
   begin		
      -- hold reset state for 500 ns.
		RESET <= '1';
      wait for 10*CLK_PERIOD;
		
		RESET <= '0';
		wait for CLK_PERIOD/2;
		-- test 1: positive normal times a positive normal
		-- X = 0.25, Y = 5
		-- EXP_P = 1.25
		X <= "00111110100000000000000000000000";
		Y <= "01000000101000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 2: negative normal times a positive normal
		-- X = -200000.0, Y = 0.25
		-- EXP_P = 50000.0
		X <= "11001000010000110101000000000000";
		Y <= "00111110100000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 3: biggest times smallest normal
		-- X = 340282346638528859811704183484516925440.0 (biggest non infinity float)
		-- Y = 1.1754943508222875079687365372222456778186655567720875215087517062784172594547271728515625E-38 (smallest normalized float)
		-- EXP_P = 3.9999997615814208984375
		X <= "01111111011111111111111111111111";
		Y <= "00000000100000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 4: mantissas multiply to all 1's
		-- X = 3.9999997615814208984375.0
		-- Y = 2.0
		-- EXP_P = 7.999999523162841796875
		X <= "01000000011111111111111111111111";
		Y <= "01000000000000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 5: multiplication by zero
		-- X = 5.09155217987000696666655130684375762939453125E-13
		-- Y = 0.0
		-- EXP_P = 0.0
		X <= "00101011000011110101000010000000";
		Y <= "00000000000000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 6: non zero subnormal times a normal
		-- X = 1.6546532266747439973467398919487329678157333009677898232907462296170653104354641982354223728179931640625E-39
		-- Y = 1076379648.0
		-- EXP_P = 1.7810351E-30
		X <= "00000000000100100000010010000000";
		Y <= "01001110100000000101000010000000";
		wait for CLK_PERIOD;
		
		-- test 7: invalid exception
		-- X = +INFINITY
		-- Y = 0.0
		-- EXP_INVALID = 1
		X <= "01111111100000000000000000000000";
		Y <= "00000000000000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 8:
		-- special case in which during the norm and round, the sum of EXPONENT and NEG_FIRST_ONE is 11111110
		-- exponent before norm and round = 11111110, first one = 00000010
		-- X = 1.8446744E19
		-- Y = 2.305843E19
		-- EXP_P = INFINITY
		X <= "01011111100000000000000000000000";
		Y <= "01011111101000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 9:
		-- special case in which during the norm and round, the sum of EXPONENT and NEG_FIRST_ONE is 11111111
		-- exponent before norm and round = 11111110, first one = 00000001
		-- X = 2.7670116E19
		-- Y = 2.7670116E19
		-- EXP_P = INFINITY
		X <= "01011111110000000000000000000000";
		Y <= "01011111110000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 10:
		-- multiply by zero but the exponent is lower than 23 to see it works during round off of the mantissa
		-- X = 5.09155217987000696666655130684375762939453125E-13
		-- Y = 0.0
		-- EXP_P = 0.0
		X <= "00000010100011110101000010000000";
		Y <= "00000000000000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 11: 2 big numbers (exponent sum is bigger than 255 even after bias)
		-- X = 5.09155217987000696666655130684375762939453125E-13
		-- Y = 147573952589676412928
		-- EXP_P = +INFINITY
		X <= "01100001000011110101000010000000";
		Y <= "01100001000000000000000000000000";
		wait for CLK_PERIOD;
		
		-- test 12: infinity times something != 0
		-- X = +INFINITY
		-- Y = 
		-- EXP_P = 0.0
		X <= "01111111100000000000000000000000";
		Y <= "01000000011111111111111111111111";
		wait for CLK_PERIOD;
		
		-- test 13: nan times something != 0
		-- X = nan
		-- Y = 
		-- EXP_P = 0.0
		X <= "01111111100000000100000000000000";
		Y <= "01000000011111111111111111111111";
		wait for CLK_PERIOD;
		
		-- test 14: other normal test
		-- X = 586723.1875
		-- Y = -2.13412456674806924511507912772291517544687167173833586275577545166015625E-21
		
		X <= "01001001000011110011111000110011";
		Y <= "10011101001000010011111111111001";
		wait for CLK_PERIOD;
      wait;
   end process;
end;
