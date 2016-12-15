    -------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
--
--  RX_LL_PDU_DATAPATH
--
--
--  Description: the RX_LL_PDU_DATAPATH module takes regular PDU data in Aurora format
--               and transforms it to LocalLink formatted data
--
--               This module supports 1 2-byte lane designs
--              
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use WORK.AURORA_PKG.all;

entity aurora_8b10b_v5_3_RX_LL_PDU_DATAPATH is

    port (

    -- Traffic Separator Interface

            PDU_DATA     : in std_logic_vector(0 to 15);
            PDU_DATA_V   : in std_logic;
            PDU_PAD      : in std_logic;
            PDU_SCP      : in std_logic;
            PDU_ECP      : in std_logic;

    -- LocalLink PDU Interface

            RX_D         : out std_logic_vector(0 to 15);
            RX_REM       : out std_logic;
            RX_SRC_RDY_N : out std_logic;
            RX_SOF_N     : out std_logic;
            RX_EOF_N     : out std_logic;

    -- Error Interface

            FRAME_ERR  : out std_logic;

    -- System Interface

            USER_CLK     : in std_logic;
            RESET        : in std_logic

         );

end aurora_8b10b_v5_3_RX_LL_PDU_DATAPATH;


architecture RTL of aurora_8b10b_v5_3_RX_LL_PDU_DATAPATH is

--****************************Parameter Declarations**************************

    constant DLY : time := 1 ns;

    
--****************************External Register Declarations**************************

    signal RX_D_Buffer                      : std_logic_vector(0 to 15);
    signal RX_REM_Buffer                    : std_logic;
    signal RX_SRC_RDY_N_Buffer              : std_logic;
    signal RX_SOF_N_Buffer                  : std_logic;
    signal RX_EOF_N_Buffer                  : std_logic;
    signal FRAME_ERR_Buffer               : std_logic;


--****************************Internal Register Declarations**************************
    signal storage_r                        : std_logic_vector(0 to 15);
    signal storage_v_r                      : std_logic;
    signal in_frame_r                       : std_logic;
    signal sof_in_storage_r                 : std_logic;
    signal pad_in_storage_r                 : std_logic;
    



--*********************************Wire Declarations**********************************
    signal src_rdy_n_c                      : std_logic;
    signal storage_ce_c                     : std_logic;
    
    

begin    
   
--*********************************Main Body of Code**********************************
    
    -- VHDL Helper Logic
    RX_D         <= RX_D_Buffer;
    RX_REM       <= RX_REM_Buffer;
    RX_SRC_RDY_N <= RX_SRC_RDY_N_Buffer;
    RX_SOF_N     <= RX_SOF_N_Buffer;
    RX_EOF_N     <= RX_EOF_N_Buffer;
    FRAME_ERR  <= FRAME_ERR_Buffer;
    
    


    --All input goes into a storage register before it is sent on to the output
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            if(storage_ce_c = '1') then
                storage_r   <=  PDU_DATA after DLY;
            end if;
        end if;
    end process;    
       
    
    --Keep track of whether or not there is data in storage
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            if(RESET= '1') then
                storage_v_r <=  '0' after DLY;
            elsif(storage_ce_c = '1') then
                storage_v_r <=  '1' after DLY;
            elsif(storage_v_r = '1') then
                storage_v_r <=  src_rdy_n_c after DLY;
            end if;
        end if;
    end process;    
    
    
    --Output data is registered
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            RX_D_Buffer    <=  storage_r after DLY;
        end if;
    end process;    
        
        
    --Assert the SRC_RDY_N signal when there is data in storage and incomiming data or the
    -- end of a frame
    src_rdy_n_c <=   not (storage_v_r and (storage_ce_c or PDU_ECP));
    
    
    --Register the SRC_RDY_N signal
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            if(RESET = '1') then
                RX_SRC_RDY_N_Buffer   <=  '1' after DLY;
            else        
                RX_SRC_RDY_N_Buffer   <=  src_rdy_n_c after DLY;
            end if;
        end if;
    end process;    
    
    
    --Load data into storage when there is valid incoming data
    storage_ce_c    <=   in_frame_r and PDU_DATA_V;
    
    
    --Data is in a frame when it is preceded by an SOF followed by any number of non-ecp characters
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            if(RESET = '1') then
                in_frame_r  <=  '0' after DLY;    
            elsif(PDU_SCP = '1') then
                in_frame_r  <=  '1' after DLY;
            elsif(PDU_ECP = '1') then
                in_frame_r  <=  '0' after DLY;
            end if;
        end if;
    end process;    
        
    
    --Hold start of frame until it can be asserted with data
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            if(PDU_SCP = '1') then
                sof_in_storage_r    <=  '1' after DLY;
            elsif(sof_in_storage_r = '1') then
                sof_in_storage_r    <=  src_rdy_n_c after DLY;
            end if;
        end if;
    end process;    
        
        
    --Register sof_in_storage for use on the LocalLink Interface
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            RX_SOF_N_Buffer    <=  not sof_in_storage_r after DLY;
        end if;
    end process;    
        
        
    --Register eof for use on the LocalLink Interface
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            RX_EOF_N_Buffer    <=  not PDU_ECP after DLY;
        end if;
    end process;
    
        
        
    --Store the pad signal for any data that gets moved into storage
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            if(storage_ce_c = '1') then
                pad_in_storage_r    <=   PDU_PAD after DLY;
            end if;
        end if;
    end process;    
        
        
    --Register the pad signal for use on the LocalLink inteface    
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            RX_REM_Buffer  <=  not pad_in_storage_r after DLY;
        end if;
    end process;    
        
        
    --Indicate a frame error when a start arrives inframe, and end arrives out
    -- of frame, or an end arrives with no data in storage, indicating an empty
    -- frame
    process(USER_CLK)
    begin
        if(USER_CLK 'event and USER_CLK = '1') then
            FRAME_ERR_Buffer <=   (PDU_SCP and in_frame_r) or
                                    (PDU_ECP and not in_frame_r) or
                                    (PDU_ECP and not storage_v_r) after DLY;
        end if;
    end process;    




end RTL;


