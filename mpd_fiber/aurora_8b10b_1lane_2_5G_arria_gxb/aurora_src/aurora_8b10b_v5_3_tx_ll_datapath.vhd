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
--  TX_LL_DATAPATH
--
--
--  Description: This module pipelines the data path while handling the PAD
--               character placement and valid data flags.
--
--               This module supports 1 2-byte lane designs
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity aurora_8b10b_v5_3_TX_LL_DATAPATH is

    port (

    -- LocalLink PDU Interface

            TX_D         : in std_logic_vector(0 to 15);
            TX_REM       : in std_logic;
            TX_SRC_RDY_N : in std_logic;
            TX_SOF_N     : in std_logic;
            TX_EOF_N     : in std_logic;

    -- Aurora Lane Interface

            TX_PE_DATA_V : out std_logic;
            GEN_PAD      : out std_logic;
            TX_PE_DATA   : out std_logic_vector(0 to 15);

    -- TX_LL Control Module Interface

            HALT_C       : in std_logic;
            TX_DST_RDY_N : in std_logic;

    -- System Interface

            CHANNEL_UP   : in std_logic;
            USER_CLK     : in std_logic

         );

end aurora_8b10b_v5_3_TX_LL_DATAPATH;

architecture RTL of aurora_8b10b_v5_3_TX_LL_DATAPATH is

-- Parameter Declarations --

    constant DLY : time := 1 ns;

-- External Register Declarations --

    signal TX_PE_DATA_V_Buffer : std_logic;
    signal GEN_PAD_Buffer      : std_logic;
    signal TX_PE_DATA_Buffer   : std_logic_vector(0 to 15);

-- Internal Register Declarations --

    signal in_frame_r              : std_logic;
    signal storage_r               : std_logic_vector(0 to 15);
    signal storage_v_r             : std_logic;
    signal storage_pad_r           : std_logic;
    signal tx_pe_data_r            : std_logic_vector(0 to 15);
    signal valid_c                 : std_logic;
    signal tx_pe_data_v_r          : std_logic;
    signal gen_pad_c               : std_logic;
    signal gen_pad_r               : std_logic;

-- Internal Wire Declarations --
    
    signal ll_valid_c              : std_logic;
    signal in_frame_c              : std_logic;

begin

    TX_PE_DATA_V <= TX_PE_DATA_V_Buffer;
    GEN_PAD      <= GEN_PAD_Buffer;
    TX_PE_DATA   <= TX_PE_DATA_Buffer;

-- Main Body of Code --



    -- LocalLink input is only valid when TX_SRC_RDY_N and TX_DST_RDY_N are both asserted
    ll_valid_c    <=   not TX_SRC_RDY_N and not TX_DST_RDY_N;


    -- Data must only be read if it is within a frame. If a frame will last multiple cycles
    -- we assert in_frame_r as long as the frame is open.
    process(USER_CLK)
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if(CHANNEL_UP = '0') then
                in_frame_r  <=  '0' after DLY;
            elsif(ll_valid_c = '1') then
                if( (TX_SOF_N = '0') and (TX_EOF_N = '1') ) then
                    in_frame_r  <=  '1' after DLY;
                elsif( TX_EOF_N = '0') then
                    in_frame_r  <=  '0' after DLY;
                end if;
            end if;
        end if;
    end process;
    
        
    in_frame_c   <=   ll_valid_c and (in_frame_r  or not TX_SOF_N);





    -- The data from the LocalLink interface must be delayed one cycle to
    -- make room for the SCP code group in the channel.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            if (HALT_C = '0') then

                storage_r <= TX_D after DLY;

            end if;

        end if;

    end process;


    -- This pipeline register aligns the data with the control path.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            if (HALT_C = '0') then

                tx_pe_data_r <= storage_r after DLY;

            end if;

        end if;

    end process;


    -- We generate the valid_c signal based on the REM signal and the EOF signal.

    process (TX_EOF_N, TX_REM)

    begin

        if (TX_EOF_N = '1') then

            valid_c <= '1';

        else

            case TX_REM is

                when '0' => valid_c <= '1';
                when '1' => valid_c <= '1';
                when others => valid_c <= '1';

            end case;

        end if;

    end process;


    -- If the word is valid, it is placed in the storage register and storage_v_r is
    -- asserted to indicate the data is valid.  Note that data is only moved to storage
    -- if the PDU datapath is not halted, the data is valid and both TX_SRC_RDY_N and
    -- TX_DST_RDY_N are asserted.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            if (HALT_C = '0') then

                storage_v_r <= valid_c and in_frame_c after DLY;

            end if;

        end if;

    end process;


    -- Register the tx_pe_data_valid signal.  All data is moved from the storage register
    -- to the tx_pe_data register for transmission when the datapath is not halted.  If the
    -- storage register contains valid PDU data, the tx_pe_data register is marked as
    -- containing valid PDU data

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            if (HALT_C = '0') then

                tx_pe_data_v_r <= storage_v_r after DLY;

            end if;

        end if;

    end process;


    -- We generate the gen_pad_c signal based on the REM signal and the EOF signal.

    process (TX_EOF_N, TX_REM)

    begin

        if (TX_EOF_N = '1') then

            gen_pad_c <= '0';

        else

            case TX_REM is

                when '0' => gen_pad_c <= '1';
                when '1' => gen_pad_c <= '0';
                when others => gen_pad_c <= '0';

            end case;

        end if;

    end process;


    -- Store padded data when padded and TX_SRC_RDY_N and TX_DST_RDY_N are both asserted.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            if (HALT_C = '0') then

                storage_pad_r <= gen_pad_c and in_frame_c after DLY;

            end if;

        end if;

    end process;


    -- Register the gen_pad signal.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            if (HALT_C = '0') then

                gen_pad_r <= storage_pad_r after DLY;

            end if;

        end if;

    end process;


    -- Implement the data out register.

    process (USER_CLK)

    begin

        if (USER_CLK 'event and USER_CLK = '1') then

            TX_PE_DATA_Buffer   <= tx_pe_data_r after DLY;
            TX_PE_DATA_V_Buffer <= tx_pe_data_v_r and not HALT_C after DLY;
            GEN_PAD_Buffer      <= gen_pad_r and not HALT_C after DLY;

        end if;

    end process;


end RTL;
