-- (c) Copyright 2008 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- 

--
--  IDLE_AND_VER_GEN
--
--
--  Description: the IDLE_AND_VER_GEN module generates idle sequences and
--               verification sequences for the Aurora channel.  The idle sequences
--               are constantly generated by a pseudorandom generator and a counter
--               to make the sequence Aurora compliant.  If the gen_ver signal is high,
--               verification symbols are added to the mix at appropriate intervals
--
--               This module supports 1 2-byte lane designs
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use WORK.AURORA_PKG.all;


entity aurora_8b10b_v5_3_IDLE_AND_VER_GEN is

    port (

    -- Channel Init SM Interface

            GEN_VER  : in std_logic;
            DID_VER  : out std_logic;

    -- Aurora Lane Interface

            GEN_A    : out std_logic;
            GEN_K    : out std_logic_vector(0 to 1);
            GEN_R    : out std_logic_vector(0 to 1);
            GEN_V    : out std_logic_vector(0 to 1);

    -- System Interface

            RESET    : in std_logic;
            USER_CLK : in std_logic

         );

end aurora_8b10b_v5_3_IDLE_AND_VER_GEN;

architecture RTL of aurora_8b10b_v5_3_IDLE_AND_VER_GEN is

-- Parameter Declarations --

    constant DLY : time := 1 ns;

-- External Register Declarations --

    signal DID_VER_Buffer : std_logic;
    signal GEN_A_Buffer   : std_logic;
    signal GEN_K_Buffer   : std_logic_vector(0 to 1);
    signal GEN_R_Buffer   : std_logic_vector(0 to 1);
    signal GEN_V_Buffer   : std_logic_vector(0 to 1);

-- Internal Register Declarations --

    signal lfsr_shift_register_r : std_logic_vector(0 to 3) := "0000";
    signal downcounter_r         : std_logic_vector(0 to 3) := "0001";
    signal gen_ver_word_2_r      : std_logic;
    signal prev_cycle_gen_ver_r  : std_logic;

-- Wire Declarations --

    signal lfsr_last_flop_r   : std_logic;
    signal lfsr_taps_c        : std_logic;
    signal lfsr_taps_r        : std_logic;
    signal lfsr_r             : std_logic_vector(0 to 2);
    signal gen_k_r            : std_logic_vector(0 to 1);
    signal gen_r_r            : std_logic_vector(0 to 1);
    signal ver_counter_r      : std_logic_vector(0 to 1);
    signal gen_ver_word_1_r   : std_logic;
    signal gen_k_flop_c       : std_logic_vector(0 to 1);
    signal gen_r_flop_c       : std_logic_vector(0 to 1);
    signal gen_v_flop_c       : std_logic_vector(0 to 1);
    signal gen_a_flop_c       : std_logic;
    signal downcounter_done_c : std_logic;
    signal gen_ver_edge_c     : std_logic;
    signal recycle_gen_ver_c  : std_logic;
    signal insert_ver_c       : std_logic;

    signal tied_to_gnd        : std_logic;
    signal tied_to_vcc        : std_logic;

-- Component Declaration --

    component FD

    -- synthesis translate_off
        generic (INIT : bit := '0');
    -- synthesis translate_on

        port (

                Q : out std_ulogic;
                C : in  std_ulogic;
                D : in  std_ulogic

             );

    end component;

    component FDR

    -- synthesis translate_off
        generic (INIT : bit := '0');
    -- synthesis translate_on

        port (

                Q : out std_ulogic;
                C : in  std_ulogic;
                D : in  std_ulogic;
                R : in  std_ulogic

             );

    end component;

    component SRL16

    -- synthesis translate_off
        generic (INIT : bit_vector := X"0000");
    -- synthesis translate_on

        port (

                Q   : out std_ulogic;
                A0  : in  std_ulogic;
                A1  : in  std_ulogic;
                A2  : in  std_ulogic;
                A3  : in  std_ulogic;
                CLK : in  std_ulogic;
                D   : in  std_ulogic

             );

    end component;

begin

    DID_VER <= DID_VER_Buffer;
    GEN_A   <= GEN_A_Buffer;
    GEN_K   <= GEN_K_Buffer;
    GEN_R   <= GEN_R_Buffer;
    GEN_V   <= GEN_V_Buffer;

    tied_to_gnd <= '0';
    tied_to_vcc <= '1';

-- Main Body of Code --


    -- Random Pattern Generation --

  -- Use an LFSR to create pseudorandom patterns.  This is a 6 bit LFSR based
    -- on XAPP210.  Taps on bits 5 and 6 are XNORed to make the input of the
    -- register.  The lfsr must never be initialized to 1.  The entire structure
    -- should cost a maximum of 2 LUTS and 2 Flops.  The output of the input
    -- register and each of the tap registers is passed to the rest of the logic
    -- as the LFSR output.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            lfsr_shift_register_r <= lfsr_taps_r & lfsr_shift_register_r(0 to 2) after DLY;

        end if;

    end process;


    lfsr_last_flop_i : FDR

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    Q => lfsr_last_flop_r,
                    C => USER_CLK,
                    D => lfsr_shift_register_r(3),
                    R => RESET

                 );


    lfsr_taps_c <= not (lfsr_shift_register_r(3) xor lfsr_last_flop_r);

    lfsr_taps_i : FDR

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    Q => lfsr_taps_r,
                    C => USER_CLK,
                    D => lfsr_taps_c,
                    R => RESET

                 );

    lfsr_r <= lfsr_taps_r & lfsr_shift_register_r(3) & lfsr_last_flop_r;


    -- Use a downcounter to determine when A's should be added to the idle pattern.
    -- Load the 3 least significant bits with the output of the lfsr whenever the
    -- counter reaches 0.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            if (RESET = '1') then

                downcounter_r <= "0000" after DLY;

            else

                if (downcounter_done_c = '1') then

                    downcounter_r <= "1" & lfsr_r after DLY;

                else

                    downcounter_r <= downcounter_r - "0001" after DLY;

                end if;

            end if;

        end if;

    end process;


    downcounter_done_c <= std_bool(downcounter_r = "0000");


    -- The LFSR's pseudoRandom patterns are also used to generate the sequence of
    -- K and R characters that make up the rest of the idle sequence.  Note that
    -- R characters are used whenever a K character is not used.

    gen_k_r <= lfsr_r(0 to 1);
    gen_r_r <= not lfsr_r(0 to 1);

    -- Verification Sequence Generation --


    -- Use a counter to generate the verification sequence every 64 bytes
    -- (32 clocks), starting from when verification is enabled.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            prev_cycle_gen_ver_r <= GEN_VER after DLY;

        end if;

    end process;


    -- Detect the positive edge of the GEN_VER signal.

    gen_ver_edge_c <= GEN_VER and not prev_cycle_gen_ver_r;


    -- If GEN_VER is still high after generating a verification sequence,
    -- indicate that the gen_ver signal can be generated again.

    recycle_gen_ver_c <= gen_ver_word_2_r and GEN_VER;


    -- Prime the verification counter SRL16 with a 1.  When this 1 reaches the end
    -- of the register, it will become the gen_ver_word signal.  Prime the counter
    -- only if there was a positive edge on GEN_VER to start the sequence, or if
    -- the sequence has just ended and another must be generated.

    insert_ver_c <= gen_ver_edge_c or recycle_gen_ver_c;


    -- Main Body of the verification counter.  It is implemented as a shift register
    -- made from 2 SRL16s.  The register is 31 cycles long, and operates by
    -- taking the 1 from the insert ver signal and passing it though its stages.

    ver_counter_0_i : SRL16

    -- synthesis translate_off
        generic map (INIT => X"0000")
    -- synthesis translate_on

        port map (

                    Q   => ver_counter_r(0),
                    A0  => tied_to_vcc,
                    A1  => tied_to_vcc,
                    A2  => tied_to_vcc,
                    A3  => tied_to_vcc,
                    CLK => USER_CLK,
                    D   => insert_ver_c

                 );


    ver_counter_1_i : SRL16

    -- synthesis translate_off
        generic map (INIT => X"0000")
    -- synthesis translate_on

        port map (

                    Q   => ver_counter_r(1),
                    A0  => tied_to_gnd,
                    A1  => tied_to_vcc,
                    A2  => tied_to_vcc,
                    A3  => tied_to_vcc,
                    CLK => USER_CLK,
                    D   => ver_counter_r(0)

                 );


    -- Generate the first 2 bytes of the verification sequence when the verification
    -- counter reaches '31'.

    gen_ver_word_1_r <= ver_counter_r(1);


    -- Generate the second 2 bytes of the verification sequence on the cycle after
    -- the first verification sequence.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            gen_ver_word_2_r <= gen_ver_word_1_r after DLY;

        end if;

    end process;

    -- Output Signals --

    -- Signal that the verification sequence has been generated.  Signaling off of
    -- the second byte allows the counter to be primed for one count too many, but
    -- is neccessary to allow GEN_V to be used as a qualifier for the output.  The
    -- extra gen_ver_word_1_r and gen_ver_word_2_r assertion is ok, because GEN_VER
    -- will be low when they are asserted.

    DID_VER_Buffer <= gen_ver_word_2_r;

    -- Assert GEN_V in the MSByte of each lane when gen_ver_word_2_r is asserted.
    -- Assert GEN_V in the LSByte of each lane if either gen_ver_word signal is
    -- asserted.  We use a seperate register for each output to provide enough slack
    -- to allow the Global logic to communicate with all lanes without causing
    -- timing problems.

    gen_v_flop_c(0) <= GEN_VER and gen_ver_word_2_r;


    gen_v_flop_0_i : FD

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    D => gen_v_flop_c(0),
                    C => USER_CLK,
                    Q => GEN_V_Buffer(0)

                 );


    gen_v_flop_c(1) <= GEN_VER and (gen_ver_word_1_r or gen_ver_word_2_r);


    gen_v_flop_1_i : FD

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    D => gen_v_flop_c(1),
                    C => USER_CLK,
                    Q => GEN_V_Buffer(1)

                 );


    -- Assert GEN_A in the MSByte of each lane when the GEN_A downcounter reaches 0.
    -- Note that the signal has a register for each lane for the same reason as the
    -- GEN_V signal.  GEN_A is ignored when it collides with other non-idle
    -- generation requests at the Aurora Lane, but we qualify the signal with
    -- the gen_ver_word_1_r signal so it does not overwrite the K used in the
    -- MSByte of the first word of the Verification sequence.

    gen_a_flop_c <= downcounter_done_c and not gen_ver_word_1_r;


    gen_a_flop_0_i : FD

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    D => gen_a_flop_c,
                    C => USER_CLK,
                    Q => GEN_A_Buffer
                 );


    -- Assert GEN_K in the MSByte when the lfsr dictates. Turn off the assertion if an
    -- A symbol is being generated on the byte.  Assert the signal without qualifications
    -- if gen_ver_word_1_r is asserted.  Assert GEN_K in the LSByte when the lfsr dictates.
    -- There are no qualifications because only the GEN_R signal can collide with it, and
    -- this is prevented by the way the gen_k_r signal is generated.  All other GEN signals
    -- will override this signal at the AURORA_LANE.

    gen_k_flop_c(0) <= (gen_k_r(0) and not downcounter_done_c) or gen_ver_word_1_r;


    gen_k_flop_0_i : FD

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    D => gen_k_flop_c(0),
                    C => USER_CLK,
                    Q => GEN_K_Buffer(0)

                 );


    gen_k_flop_c(1) <= gen_k_r(1);

    gen_k_flop_1_i : FD

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    D => gen_k_flop_c(1),
                    C => USER_CLK,
                    Q => GEN_K_Buffer(1)

                 );


    -- Assert GEN_R in the MSByte when the lfsr dictates.  Turn off the assertion if an
    -- A symbol, or the first verification word is being generated.  Assert GEN_R in the
    -- LSByte when the lfsr dictates, with no qualifications (same reason as the GEN_K LSByte).

    gen_r_flop_c(0) <= gen_r_r(0) and not downcounter_done_c and not gen_ver_word_1_r;


    gen_r_flop_0_i : FD

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    D => gen_r_flop_c(0),
                    C => USER_CLK,
                    Q => GEN_R_Buffer(0)

                 );


    gen_r_flop_c(1) <= gen_r_r(1);


    gen_r_flop_1_i : FD

    -- synthesis translate_off
        generic map (INIT => '0')
    -- synthesis translate_on

        port map (

                    D => gen_r_flop_c(1),
                    C => USER_CLK,
                    Q => GEN_R_Buffer(1)

                 );


end RTL;
