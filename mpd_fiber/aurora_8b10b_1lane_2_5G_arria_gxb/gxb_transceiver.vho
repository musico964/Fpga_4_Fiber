--IP Functional Simulation Model
--VERSION_BEGIN 13.0 cbx_mgl 2013:06:12:18:33:59:SJ cbx_simgen 2013:06:12:18:03:33:SJ  VERSION_END


-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Altera disclaims all warranties of any kind).


--synopsys translate_off

 LIBRARY arriagx_hssi;
 USE arriagx_hssi.arriagx_hssi_components.all;

--synthesis_resources = arriagx_hssi_calibration_block 1 arriagx_hssi_central_management_unit 1 arriagx_hssi_cmu_pll 1 arriagx_hssi_receiver 1 arriagx_hssi_transmitter 1 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  gxb_transceiver IS 
	 PORT 
	 ( 
		 cal_blk_clk	:	IN  STD_LOGIC;
		 pll_inclk	:	IN  STD_LOGIC;
		 pll_locked	:	OUT  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 rx_analogreset	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 rx_clkout	:	OUT  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 rx_ctrldetect	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 rx_datain	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 rx_dataout	:	OUT  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 rx_digitalreset	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 rx_disperr	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 rx_enapatternalign	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 rx_errdetect	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 rx_freqlocked	:	OUT  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 rx_patterndetect	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 rx_syncstatus	:	OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 tx_clkout	:	OUT  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 tx_ctrlenable	:	IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		 tx_datain	:	IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 tx_dataout	:	OUT  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 tx_digitalreset	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0)
	 ); 
 END gxb_transceiver;

 ARCHITECTURE RTL OF gxb_transceiver IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL  wire_vcc	:	STD_LOGIC;
	 SIGNAL  wire_n00i_adet	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_cmudividerdprioin	:	STD_LOGIC_VECTOR (29 DOWNTO 0);
	 SIGNAL  wire_n00i_cmuplldprioin	:	STD_LOGIC_VECTOR (119 DOWNTO 0);
	 SIGNAL  wire_n00i_cmuplldprioout	:	STD_LOGIC_VECTOR (119 DOWNTO 0);
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_n00i_dpriodisableout	:	STD_LOGIC;
	 SIGNAL  wire_n00i_fixedclk	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_pllpowerdn	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00i_pllresetout	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_n00i_quadresetout	:	STD_LOGIC;
	 SIGNAL  wire_n00i_rdalign	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_refclkdividerdprioin	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n00i_rxadcepowerdn	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxadceresetout	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxanalogreset	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxanalogresetout	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxcrupowerdn	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxcruresetout	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxctrl	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxdatain	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n00i_rxdatavalid	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxdigitalreset	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxdigitalresetout	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxdprioin	:	STD_LOGIC_VECTOR (1199 DOWNTO 0);
	 SIGNAL  wire_n00i_rxibpowerdn	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxpowerdown	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_rxrunningdisp	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_syncstatus	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txanalogresetout	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txctrl	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txctrlout	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txdatain	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n00i_txdataout	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  wire_n00i_txdetectrxpowerdn	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txdigitalreset	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txdigitalresetout	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txdividerpowerdn	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n00i_txdprioin	:	STD_LOGIC_VECTOR (599 DOWNTO 0);
	 SIGNAL  wire_n00i_txobpowerdn	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n01O_clk	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n01O_clkout	:	STD_LOGIC;
	 SIGNAL  wire_n01O_dprioin	:	STD_LOGIC_VECTOR (39 DOWNTO 0);
	 SIGNAL  wire_n01O_locked	:	STD_LOGIC;
	 SIGNAL  wire_n01i_clkout	:	STD_LOGIC;
	 SIGNAL  wire_n01i_cruclk	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
	 SIGNAL  wire_n01i_ctrldetect	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01i_dataout	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_n01i_disperr	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01i_dprioin	:	STD_LOGIC_VECTOR (299 DOWNTO 0);
	 SIGNAL  wire_n01i_errdetect	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01i_freqlock	:	STD_LOGIC;
	 SIGNAL  wire_n01i_parallelfdbk	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_n01i_patterndetect	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01i_pipepowerdown	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01i_pipepowerstate	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n01i_rxfound	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01i_syncstatus	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01i_testsel	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_n01i_xgmdatain	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_n01l_clkout	:	STD_LOGIC;
	 SIGNAL  wire_n01l_ctrlenable	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01l_datain	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_n01l_datainfull	:	STD_LOGIC_VECTOR (43 DOWNTO 0);
	 SIGNAL  wire_n01l_dataout	:	STD_LOGIC;
	 SIGNAL  wire_n01l_dispval	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01l_dprioin	:	STD_LOGIC_VECTOR (149 DOWNTO 0);
	 SIGNAL  wire_n01l_forcedisp	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01l_pllfastclk	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01l_powerdn	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_n01l_revparallelfdbk	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_n01l_xgmdatain	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
 BEGIN

	wire_gnd <= '0';
	wire_vcc <= '1';
	pll_locked(0) <= ( wire_n01O_locked);
	rx_clkout(0) <= ( wire_n01i_clkout);
	rx_ctrldetect <= ( wire_n01i_ctrldetect(1 DOWNTO 0));
	rx_dataout <= ( wire_n01i_dataout(15 DOWNTO 0));
	rx_disperr <= ( wire_n01i_disperr(1 DOWNTO 0));
	rx_errdetect <= ( wire_n01i_errdetect(1 DOWNTO 0));
	rx_freqlocked(0) <= ( wire_n01i_freqlock);
	rx_patterndetect <= ( wire_n01i_patterndetect(1 DOWNTO 0));
	rx_syncstatus <= ( wire_n01i_syncstatus(1 DOWNTO 0));
	tx_clkout(0) <= ( wire_n01l_clkout);
	tx_dataout(0) <= ( wire_n01l_dataout);
	n1OO :  arriagx_hssi_calibration_block
	  PORT MAP ( 
		clk => cal_blk_clk,
		powerdn => wire_vcc
	  );
	wire_n00i_adet <= ( "0" & "0" & "0" & "0");
	wire_n00i_cmudividerdprioin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00i_cmuplldprioin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00i_fixedclk <= ( "0" & "0" & "0" & "0");
	wire_n00i_rdalign <= ( "0" & "0" & "0" & "0");
	wire_n00i_refclkdividerdprioin <= ( "0" & "0");
	wire_n00i_rxanalogreset <= ( "0" & "0" & "0" & rx_analogreset(0));
	wire_n00i_rxctrl <= ( "0" & "0" & "0" & "0");
	wire_n00i_rxdatain <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00i_rxdatavalid <= ( "0" & "0" & "0" & "0");
	wire_n00i_rxdigitalreset <= ( "0" & "0" & "0" & rx_digitalreset(0));
	wire_n00i_rxdprioin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0"
 & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" &
 "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0"
 & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00i_rxpowerdown <= ( "0" & "0" & "0" & "0");
	wire_n00i_rxrunningdisp <= ( "0" & "0" & "0" & "0");
	wire_n00i_syncstatus <= ( "0" & "0" & "0" & "0");
	wire_n00i_txctrl <= ( "0" & "0" & "0" & "0");
	wire_n00i_txdatain <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n00i_txdigitalreset <= ( "0" & "0" & "0" & tx_digitalreset(0));
	wire_n00i_txdprioin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0"
 & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	n00i :  arriagx_hssi_central_management_unit
	  GENERIC MAP (
		analog_test_bus_enable => "false",
		bonded_quad_mode => "none",
		devaddr => 1,
		dprio_config_mode => 0,
		in_xaui_mode => "false",
		lpm_type => "stratixiigx_hssi_central_management_unit",
		offset_all_errors_align => "false",
		pll0_inclk0_logical_to_physical_mapping => "iq0",
		pll0_inclk1_logical_to_physical_mapping => "iq1",
		pll0_inclk2_logical_to_physical_mapping => "iq2",
		pll0_inclk3_logical_to_physical_mapping => "iq3",
		pll0_inclk4_logical_to_physical_mapping => "iq4",
		pll0_inclk5_logical_to_physical_mapping => "pld_clk",
		pll0_inclk6_logical_to_physical_mapping => "clkrefclk0",
		pll0_inclk7_logical_to_physical_mapping => "clkrefclk1",
		pll1_inclk0_logical_to_physical_mapping => "iq0",
		pll1_inclk1_logical_to_physical_mapping => "iq1",
		pll1_inclk2_logical_to_physical_mapping => "iq2",
		pll1_inclk3_logical_to_physical_mapping => "iq3",
		pll1_inclk4_logical_to_physical_mapping => "iq4",
		pll1_inclk5_logical_to_physical_mapping => "pld_clk",
		pll1_inclk6_logical_to_physical_mapping => "clkrefclk0",
		pll1_inclk7_logical_to_physical_mapping => "clkrefclk1",
		portaddr => 1,
		rx0_cru_clock0_physical_mapping => "iq0",
		rx0_cru_clock1_physical_mapping => "iq1",
		rx0_cru_clock2_physical_mapping => "iq2",
		rx0_cru_clock3_physical_mapping => "iq3",
		rx0_cru_clock4_physical_mapping => "iq4",
		rx0_cru_clock5_physical_mapping => "pld_cru_clk",
		rx0_cru_clock6_physical_mapping => "refclk0",
		rx0_cru_clock7_physical_mapping => "refclk1",
		rx0_cru_clock8_physical_mapping => "cmu_div_clk",
		rx1_cru_clock0_physical_mapping => "iq0",
		rx1_cru_clock1_physical_mapping => "iq1",
		rx1_cru_clock2_physical_mapping => "iq2",
		rx1_cru_clock3_physical_mapping => "iq3",
		rx1_cru_clock4_physical_mapping => "iq4",
		rx1_cru_clock5_physical_mapping => "pld_cru_clk",
		rx1_cru_clock6_physical_mapping => "refclk0",
		rx1_cru_clock7_physical_mapping => "refclk1",
		rx1_cru_clock8_physical_mapping => "cmu_div_clk",
		rx2_cru_clock0_physical_mapping => "iq0",
		rx2_cru_clock1_physical_mapping => "iq1",
		rx2_cru_clock2_physical_mapping => "iq2",
		rx2_cru_clock3_physical_mapping => "iq3",
		rx2_cru_clock4_physical_mapping => "iq4",
		rx2_cru_clock5_physical_mapping => "pld_cru_clk",
		rx2_cru_clock6_physical_mapping => "refclk0",
		rx2_cru_clock7_physical_mapping => "refclk1",
		rx2_cru_clock8_physical_mapping => "cmu_div_clk",
		rx3_cru_clock0_physical_mapping => "iq0",
		rx3_cru_clock1_physical_mapping => "iq1",
		rx3_cru_clock2_physical_mapping => "iq2",
		rx3_cru_clock3_physical_mapping => "iq3",
		rx3_cru_clock4_physical_mapping => "iq4",
		rx3_cru_clock5_physical_mapping => "pld_cru_clk",
		rx3_cru_clock6_physical_mapping => "refclk0",
		rx3_cru_clock7_physical_mapping => "refclk1",
		rx3_cru_clock8_physical_mapping => "cmu_div_clk",
		rx_dprio_width => 1200,
		sim_dump_dprio_internal_reg_at_time => 0,
		sim_dump_filename => "sim_dprio_dump.txt",
		tx0_pll_fast_clk0_physical_mapping => "pll0",
		tx0_pll_fast_clk1_physical_mapping => "pll1",
		tx1_pll_fast_clk0_physical_mapping => "pll0",
		tx1_pll_fast_clk1_physical_mapping => "pll1",
		tx2_pll_fast_clk0_physical_mapping => "pll0",
		tx2_pll_fast_clk1_physical_mapping => "pll1",
		tx3_pll_fast_clk0_physical_mapping => "pll0",
		tx3_pll_fast_clk1_physical_mapping => "pll1",
		tx_dprio_width => 600,
		use_deskew_fifo => "false"
	  )
	  PORT MAP ( 
		adet => wire_n00i_adet,
		cmudividerdprioin => wire_n00i_cmudividerdprioin,
		cmuplldprioin => wire_n00i_cmuplldprioin,
		cmuplldprioout => wire_n00i_cmuplldprioout,
		dpclk => wire_gnd,
		dpriodisable => wire_vcc,
		dpriodisableout => wire_n00i_dpriodisableout,
		dprioin => wire_gnd,
		dprioload => wire_gnd,
		fixedclk => wire_n00i_fixedclk,
		pllpowerdn => wire_n00i_pllpowerdn,
		pllresetout => wire_n00i_pllresetout,
		quadenable => wire_vcc,
		quadreset => wire_gnd,
		quadresetout => wire_n00i_quadresetout,
		rdalign => wire_n00i_rdalign,
		rdenablesync => wire_gnd,
		recovclk => wire_gnd,
		refclkdividerdprioin => wire_n00i_refclkdividerdprioin,
		rxadcepowerdn => wire_n00i_rxadcepowerdn,
		rxadceresetout => wire_n00i_rxadceresetout,
		rxanalogreset => wire_n00i_rxanalogreset,
		rxanalogresetout => wire_n00i_rxanalogresetout,
		rxclk => wire_gnd,
		rxcrupowerdn => wire_n00i_rxcrupowerdn,
		rxcruresetout => wire_n00i_rxcruresetout,
		rxctrl => wire_n00i_rxctrl,
		rxdatain => wire_n00i_rxdatain,
		rxdatavalid => wire_n00i_rxdatavalid,
		rxdigitalreset => wire_n00i_rxdigitalreset,
		rxdigitalresetout => wire_n00i_rxdigitalresetout,
		rxdprioin => wire_n00i_rxdprioin,
		rxibpowerdn => wire_n00i_rxibpowerdn,
		rxpowerdown => wire_n00i_rxpowerdown,
		rxrunningdisp => wire_n00i_rxrunningdisp,
		syncstatus => wire_n00i_syncstatus,
		txanalogresetout => wire_n00i_txanalogresetout,
		txclk => wire_gnd,
		txctrl => wire_n00i_txctrl,
		txctrlout => wire_n00i_txctrlout,
		txdatain => wire_n00i_txdatain,
		txdataout => wire_n00i_txdataout,
		txdetectrxpowerdn => wire_n00i_txdetectrxpowerdn,
		txdigitalreset => wire_n00i_txdigitalreset,
		txdigitalresetout => wire_n00i_txdigitalresetout,
		txdividerpowerdn => wire_n00i_txdividerpowerdn,
		txdprioin => wire_n00i_txdprioin,
		txobpowerdn => wire_n00i_txobpowerdn
	  );
	wire_n01O_clk <= ( "0" & "0" & "0" & "0" & "0" & pll_inclk & "0" & "0");
	wire_n01O_dprioin <= ( wire_n00i_cmuplldprioout(39 DOWNTO 0));
	n01O :  arriagx_hssi_cmu_pll
	  GENERIC MAP (
		charge_pump_current_control => 2,
		divide_by => 1,
		dprio_config_mode => 0,
		enable_pll_cascade => "false",
		inclk0_period => 0,
		inclk1_period => 16000,
		inclk2_period => 16000,
		inclk3_period => 0,
		inclk4_period => 0,
		inclk5_period => 0,
		inclk6_period => 0,
		loop_filter_resistor_control => 3,
		low_speed_test_sel => 0,
		multiply_by => 20,
		pfd_clk_select => 2,
		pll_number => 0,
		pll_type => "normal",
		protocol_hint => "basic",
		remapped_to_new_loop_filter_charge_pump_settings => "false",
		sim_clkout_phase_shift => 0,
		vco_range => "low"
	  )
	  PORT MAP ( 
		clk => wire_n01O_clk,
		clkout => wire_n01O_clkout,
		dpriodisable => wire_n00i_dpriodisableout,
		dprioin => wire_n01O_dprioin,
		locked => wire_n01O_locked,
		pllpowerdn => wire_n00i_pllpowerdn(0),
		pllreset => wire_n00i_pllresetout(0)
	  );
	wire_n01i_cruclk <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & pll_inclk);
	wire_n01i_dprioin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01i_parallelfdbk <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01i_pipepowerdown <= ( "0" & "0");
	wire_n01i_pipepowerstate <= ( "0" & "0" & "0" & "0");
	wire_n01i_rxfound <= ( "0" & "0");
	wire_n01i_testsel <= ( "0" & "0" & "0" & "0");
	wire_n01i_xgmdatain <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	n01i :  arriagx_hssi_receiver
	  GENERIC MAP (
		adaptive_equalization_mode => "none",
		align_loss_sync_error_num => 1,
		align_pattern => "0101111100",
		align_pattern_length => 10,
		align_to_deskew_pattern_pos_disp_only => "false",
		allow_align_polarity_inversion => "false",
		allow_pipe_polarity_inversion => "false",
		allow_serial_loopback => "false",
		bandwidth_mode => 1,
		bit_slip_enable => "false",
		byte_order_pad_pattern => "0",
		byte_order_pattern => "0",
		byte_ordering_mode => "none",
		channel_bonding => "none",
		channel_number => 0,
		channel_width => 16,
		clk1_mux_select => "recvd_clk",
		clk2_mux_select => "recvd_clk",
		common_mode => "0.9v",
		cru_clock_select => 0,
		cru_divide_by => 1,
		cru_multiply_by => 20,
		cru_pre_divide_by => 1,
		cruclk0_period => 16000,
		cruclk1_period => 16000,
		cruclk2_period => 16000,
		cruclk3_period => 16000,
		cruclk4_period => 16000,
		cruclk5_period => 16000,
		cruclk6_period => 16000,
		datapath_protocol => "basic",
		dec_8b_10b_compatibility_mode => "true",
		dec_8b_10b_mode => "normal",
		deskew_pattern => "0",
		disable_auto_idle_insertion => "false",
		disable_ph_low_latency_mode => "false",
		disable_running_disp_in_word_align => "false",
		disallow_kchar_after_pattern_ordered_set => "false",
		dprio_config_mode => 0,
		dprio_mode => "none",
		dprio_width => 300,
		enable_bit_reversal => "false",
		enable_dc_coupling => "false",
		enable_deep_align => "false",
		enable_deep_align_byte_swap => "false",
		enable_lock_to_data_sig => "false",
		enable_lock_to_refclk_sig => "false",
		enable_self_test_mode => "false",
		enable_true_complement_match_in_word_align => "false",
		eq_adapt_seq_control => 3,
		eq_max_gradient_control => 7,
		equalizer_ctrl_a => 0,
		equalizer_ctrl_b => 0,
		equalizer_ctrl_c => 0,
		equalizer_ctrl_d => 0,
		equalizer_ctrl_v => 0,
		equalizer_dc_gain => 0,
		force_freq_det_high => "false",
		force_freq_det_low => "false",
		force_signal_detect => "true",
		force_signal_detect_dig => "true",
		ignore_lock_detect => "false",
		infiniband_invalid_code => 0,
		insert_pad_on_underflow => "false",
		num_align_code_groups_in_ordered_set => 0,
		num_align_cons_good_data => 1,
		num_align_cons_pat => 1,
		ppmselect => 1,
		protocol_hint => "basic",
		rate_match_almost_empty_threshold => 11,
		rate_match_almost_full_threshold => 13,
		rate_match_back_to_back => "false",
		rate_match_fifo_mode => "none",
		rate_match_ordered_set_based => "false",
		rate_match_pattern1 => "0",
		rate_match_pattern2 => "0",
		rate_match_pattern_size => 10,
		rate_match_skip_set_based => "false",
		rd_clk_mux_select => "core_clk",
		recovered_clk_mux_select => "recvd_clk",
		run_length => 200,
		run_length_enable => "false",
		rx_detect_bypass => "false",
		self_test_mode => "incremental",
		send_direct_reverse_serial_loopback => "true",
		signal_detect_threshold => 2,
		sim_rxpll_clkout_phase_shift => 0,
		termination => "oct_100_ohms",
		use_align_state_machine => "false",
		use_deserializer_double_data_mode => "false",
		use_deskew_fifo => "false",
		use_double_data_mode => "true",
		use_parallel_loopback => "false",
		use_rate_match_pattern1_only => "false",
		use_rising_edge_triggered_pattern_align => "false",
		use_termvoltage_signal => "false"
	  )
	  PORT MAP ( 
		a1a2size => wire_gnd,
		adcepowerdn => wire_n00i_rxadcepowerdn(0),
		adcereset => wire_n00i_rxadceresetout(0),
		alignstatus => wire_gnd,
		alignstatussync => wire_gnd,
		analogreset => wire_n00i_rxanalogresetout(0),
		bitslip => wire_gnd,
		clkout => wire_n01i_clkout,
		coreclk => wire_n01i_clkout,
		cruclk => wire_n01i_cruclk,
		crupowerdn => wire_n00i_rxcrupowerdn(0),
		crureset => wire_n00i_rxcruresetout(0),
		ctrldetect => wire_n01i_ctrldetect,
		datain => rx_datain(0),
		dataout => wire_n01i_dataout,
		digitalreset => wire_n00i_rxdigitalresetout(0),
		disablefifordin => wire_gnd,
		disablefifowrin => wire_gnd,
		disperr => wire_n01i_disperr,
		dpriodisable => wire_vcc,
		dprioin => wire_n01i_dprioin,
		enabledeskew => wire_gnd,
		enabyteord => wire_gnd,
		enapatternalign => rx_enapatternalign(0),
		errdetect => wire_n01i_errdetect,
		fifordin => wire_gnd,
		fiforesetrd => wire_gnd,
		freqlock => wire_n01i_freqlock,
		ibpowerdn => wire_n00i_rxibpowerdn(0),
		invpol => wire_gnd,
		localrefclk => wire_gnd,
		locktodata => wire_gnd,
		locktorefclk => wire_gnd,
		masterclk => wire_gnd,
		parallelfdbk => wire_n01i_parallelfdbk,
		patterndetect => wire_n01i_patterndetect,
		phfifordenable => wire_vcc,
		phfiforeset => wire_gnd,
		phfifowrdisable => wire_gnd,
		phfifox4bytesel => wire_gnd,
		phfifox4rdenable => wire_vcc,
		phfifox4wrclk => wire_vcc,
		phfifox4wrenable => wire_vcc,
		phfifox8bytesel => wire_gnd,
		phfifox8rdenable => wire_vcc,
		phfifox8wrclk => wire_vcc,
		phfifox8wrenable => wire_vcc,
		pipe8b10binvpolarity => wire_gnd,
		pipepowerdown => wire_n01i_pipepowerdown,
		pipepowerstate => wire_n01i_pipepowerstate,
		quadreset => wire_n00i_quadresetout,
		refclk => wire_gnd,
		revbitorderwa => wire_gnd,
		revbyteorderwa => wire_gnd,
		rmfifordena => wire_gnd,
		rmfiforeset => wire_gnd,
		rmfifowrena => wire_gnd,
		rxdetectvalid => wire_gnd,
		rxfound => wire_n01i_rxfound,
		serialfdbk => wire_gnd,
		seriallpbken => wire_gnd,
		syncstatus => wire_n01i_syncstatus,
		testsel => wire_n01i_testsel,
		xgmctrlin => wire_gnd,
		xgmdatain => wire_n01i_xgmdatain
	  );
	wire_n01l_ctrlenable <= ( tx_ctrlenable(1 DOWNTO 0));
	wire_n01l_datain <= ( tx_datain(15 DOWNTO 0));
	wire_n01l_datainfull <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01l_dispval <= ( "0" & "0");
	wire_n01l_dprioin <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01l_forcedisp <= ( "0" & "0");
	wire_n01l_pllfastclk <= ( "0" & wire_n01O_clkout);
	wire_n01l_powerdn <= ( "0" & "0");
	wire_n01l_revparallelfdbk <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_n01l_xgmdatain <= ( wire_n00i_txdataout(7 DOWNTO 0));
	n01l :  arriagx_hssi_transmitter
	  GENERIC MAP (
		allow_polarity_inversion => "false",
		analog_power => "1.5v",
		channel_bonding => "none",
		channel_number => 0,
		channel_width => 16,
		common_mode => "0.6v",
		disable_ph_low_latency_mode => "false",
		disparity_mode => "none",
		divider_refclk_select_pll_fast_clk0 => "true",
		dprio_config_mode => 0,
		dprio_mode => "none",
		dprio_width => 150,
		enable_bit_reversal => "false",
		enable_idle_selection => "false",
		enable_reverse_parallel_loopback => "false",
		enable_reverse_serial_loopback => "false",
		enable_self_test_mode => "false",
		enable_slew_rate => "false",
		enable_symbol_swap => "false",
		enc_8b_10b_compatibility_mode => "true",
		enc_8b_10b_mode => "normal",
		force_echar => "false",
		force_kchar => "false",
		low_speed_test_select => 0,
		preemp_pretap => 0,
		preemp_pretap_inv => "false",
		preemp_tap_1 => 0,
		preemp_tap_2 => 0,
		preemp_tap_2_inv => "false",
		protocol_hint => "basic",
		refclk_divide_by => 1,
		refclk_select => "local",
		rxdetect_ctrl => 0,
		self_test_mode => "incremental",
		serializer_clk_select => "local",
		termination => "oct_100_ohms",
		transmit_protocol => "basic",
		use_double_data_mode => "true",
		use_serializer_double_data_mode => "false",
		use_termvoltage_signal => "false",
		vod_selection => 3,
		wr_clk_mux_select => "core_clk"
	  )
	  PORT MAP ( 
		analogreset => wire_n00i_txanalogresetout(0),
		analogx4fastrefclk => wire_gnd,
		analogx4refclk => wire_gnd,
		analogx8fastrefclk => wire_gnd,
		analogx8refclk => wire_gnd,
		clkout => wire_n01l_clkout,
		coreclk => wire_n01l_clkout,
		ctrlenable => wire_n01l_ctrlenable,
		datain => wire_n01l_datain,
		datainfull => wire_n01l_datainfull,
		dataout => wire_n01l_dataout,
		detectrxloop => wire_gnd,
		detectrxpowerdn => wire_n00i_txdetectrxpowerdn(0),
		digitalreset => wire_n00i_txdigitalresetout(0),
		dispval => wire_n01l_dispval,
		dividerpowerdn => wire_n00i_txdividerpowerdn(0),
		dpriodisable => wire_vcc,
		dprioin => wire_n01l_dprioin,
		enrevparallellpbk => wire_gnd,
		forcedisp => wire_n01l_forcedisp,
		forcedispcompliance => wire_gnd,
		forceelecidle => wire_gnd,
		invpol => wire_gnd,
		obpowerdn => wire_n00i_txobpowerdn(0),
		phfiforddisable => wire_gnd,
		phfiforeset => wire_gnd,
		phfifowrenable => wire_vcc,
		phfifox4bytesel => wire_gnd,
		phfifox4rdclk => wire_vcc,
		phfifox4rdenable => wire_vcc,
		phfifox4wrenable => wire_vcc,
		phfifox8bytesel => wire_gnd,
		phfifox8rdclk => wire_vcc,
		phfifox8rdenable => wire_vcc,
		phfifox8wrenable => wire_vcc,
		pipestatetransdone => wire_gnd,
		pllfastclk => wire_n01l_pllfastclk,
		powerdn => wire_n01l_powerdn,
		quadreset => wire_n00i_quadresetout,
		refclk => wire_gnd,
		revparallelfdbk => wire_n01l_revparallelfdbk,
		revserialfdbk => wire_gnd,
		xgmctrl => wire_n00i_txctrlout(0),
		xgmdatain => wire_n01l_xgmdatain
	  );

 END RTL; --gxb_transceiver
--synopsys translate_on
--VALID FILE
