onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Vme Interface}
add wave -noupdate -label vme_data -radix hexadecimal /_a_TestBench/vme_data
add wave -noupdate -label vme_addr -radix hexadecimal /_a_TestBench/vme_addr
add wave -noupdate -label vme_dtackB /_a_TestBench/vme_dtackB
add wave -noupdate -label vme_berrB /_a_TestBench/vme_berrB
add wave -noupdate -label vme_retryB /_a_TestBench/vme_retryB
add wave -noupdate -label VME_AM -radix hexadecimal /_a_TestBench/Dut/VmeIf/VME_AM
add wave -noupdate -label VME_A -radix hexadecimal /_a_TestBench/Dut/VmeIf/VME_A
add wave -noupdate -label VME_LWORDb /_a_TestBench/Dut/VmeIf/VME_LWORDb
add wave -noupdate -label VME_D -radix hexadecimal /_a_TestBench/Dut/VmeIf/VME_D
add wave -noupdate -label VME_WRITEb /_a_TestBench/Dut/VmeIf/VME_WRITEb
add wave -noupdate -label VME_ASb /_a_TestBench/Dut/VmeIf/VME_ASb
add wave -noupdate -label VME_DS1b /_a_TestBench/Dut/VmeIf/VME_DS1b
add wave -noupdate -label VME_DTACK /_a_TestBench/Dut/VmeIf/VME_DTACK
add wave -noupdate -label VME_BERR /_a_TestBench/Dut/VmeIf/VME_BERR
add wave -noupdate -label VME_RETRY /_a_TestBench/Dut/VmeIf/VME_RETRY
add wave -noupdate -label VME_ADIR /_a_TestBench/Dut/VME_ADIR
add wave -noupdate -label VME_AOEb /_a_TestBench/Dut/VME_AOEb
add wave -noupdate -label VME_DDIR /_a_TestBench/Dut/VME_DDIR
add wave -noupdate -label VME_DOEb /_a_TestBench/Dut/VME_DOEb
add wave -noupdate -color Magenta -label fsm_status -radix unsigned /_a_TestBench/Dut/VmeIf/DataCycleController/status
add wave -noupdate -label ld_addr_counter /_a_TestBench/Dut/VmeIf/ld_addr_counter
add wave -noupdate -label incr_addr_counter /_a_TestBench/Dut/VmeIf/incr_addr_counter
add wave -noupdate -label addr_counter -radix hexadecimal /_a_TestBench/Dut/VmeIf/addr_counter
add wave -noupdate -label module_selected /_a_TestBench/Dut/VmeIf/module_selected
add wave -noupdate -label data_enable /_a_TestBench/Dut/VmeIf/data_enable
add wave -noupdate -label addr_dir /_a_TestBench/Dut/VmeIf/addr_dir
add wave -noupdate -label data_dir /_a_TestBench/Dut/VmeIf/data_dir
add wave -noupdate -label a24_cycle /_a_TestBench/Dut/VmeIf/a24_cycle
add wave -noupdate -label a32_cycle /_a_TestBench/Dut/VmeIf/a32_cycle
add wave -noupdate -label single_cycle /_a_TestBench/Dut/VmeIf/single_cycle
add wave -noupdate -label blt_cycle /_a_TestBench/Dut/VmeIf/blt_cycle
add wave -noupdate -label mblt_cycle /_a_TestBench/Dut/VmeIf/mblt_cycle
add wave -noupdate -label 2evme_cycle /_a_TestBench/Dut/VmeIf/a32d64_2evme_cycle
add wave -noupdate -label 2esst_cycle /_a_TestBench/Dut/VmeIf/a32d64_2esst_cycle
add wave -noupdate -label 2e_cycle /_a_TestBench/Dut/VmeIf/d64_2e_cycle
add wave -noupdate -label bad_cycle /_a_TestBench/Dut/VmeIf/bad_cycle
add wave -noupdate -label internal_data -radix hexadecimal /_a_TestBench/Dut/VmeIf/internal_data
add wave -noupdate -label USER_ADDR -radix hexadecimal /_a_TestBench/Dut/VmeIf/USER_ADDR
add wave -noupdate -label USER_WAITb /_a_TestBench/Dut/VmeIf/USER_WAITb
add wave -noupdate -label USER_WEb /_a_TestBench/Dut/VmeIf/USER_WEb
add wave -noupdate -label USER_REb /_a_TestBench/Dut/VmeIf/USER_REb
add wave -noupdate -label USER_OEb /_a_TestBench/Dut/VmeIf/USER_OEb
add wave -noupdate -label USER_CEb -radix hexadecimal /_a_TestBench/Dut/VmeIf/USER_CEb
add wave -noupdate -label CONFIG_CEb /_a_TestBench/Dut/VmeIf/CONFIG_CEb
add wave -noupdate -label SDRAM_CEb /_a_TestBench/Dut/VmeIf/SDRAM_CEb
add wave -noupdate -label OBUF_CEb /_a_TestBench/Dut/VmeIf/OBUF_CEb
add wave -noupdate -divider FiberInterface
add wave -noupdate -label Fiber_enabled /_a_TestBench/Dut/Fiber_enabled
add wave -noupdate -label FIBER_UP /_a_TestBench/Dut/FiberInterface_Instance/FIBER_CHANNEL_UP
add wave -noupdate -label FIBER_BUS_ADDR -radix hexadecimal /_a_TestBench/Dut/FiberInterface_Instance/FIBER_BUS_ADDR
add wave -noupdate -label FIBER_BUS_DOUT -radix hexadecimal /_a_TestBench/Dut/FiberInterface_Instance/FIBER_BUS_DOUT
add wave -noupdate -label FIBER_BUS_DIN -radix hexadecimal /_a_TestBench/Dut/FiberInterface_Instance/FIBER_BUS_DIN
add wave -noupdate -label FIBER_BUS_WR /_a_TestBench/Dut/FiberInterface_Instance/FIBER_BUS_WR
add wave -noupdate -label FIBER_BUS_RD /_a_TestBench/Dut/FiberInterface_Instance/FIBER_BUS_RD
add wave -noupdate -label FIBER_BUS_ACK /_a_TestBench/Dut/FiberInterface_Instance/FIBER_BUS_ACK
add wave -noupdate -divider Sdram
add wave -noupdate -label SdramInitialized /_a_TestBench/Dut/SdramInitialized
add wave -noupdate -label mem_local_write_req /_a_TestBench/Dut/mem_local_write_req
add wave -noupdate -label mem_local_read_req /_a_TestBench/Dut/mem_local_read_req
add wave -noupdate -label mem_local_ready /_a_TestBench/Dut/mem_local_ready
add wave -noupdate -label mem_local_rdata_valid /_a_TestBench/Dut/mem_local_rdata_valid
add wave -noupdate -divider APV
add wave -noupdate -label APV_CLOCK /_a_TestBench/Dut/APV_CLOCK
add wave -noupdate -label APV_TRIGGER /_a_TestBench/Dut/APV_TRIGGER
add wave -noupdate -label APV_RESET /_a_TestBench/Dut/APV_RESET
add wave -noupdate -divider ConfigRegisters
add wave -noupdate -label ADDR -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/ADDR
add wave -noupdate -label CEb /_a_TestBench/Dut/ConfigRegisters_and_Rom/CEb
add wave -noupdate -label SAMPLE_PER_EVENT -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/SAMPLE_PER_EVENT
add wave -noupdate -label EVENT_PER_BLOCK -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/EVENT_PER_BLOCK
add wave -noupdate -label BUSY_THRESHOLD -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/BUSY_THRESHOLD
add wave -noupdate -label BUSY_THRESHOLD_LOCAL -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/BUSY_THRESHOLD_LOCAL
add wave -noupdate -label IO_CONFIG -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/IO_CONFIG
add wave -noupdate -label READOUT_CONFIG -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/READOUT_CONFIG
add wave -noupdate -label TRIGGER_CONFIG -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/TRIGGER_CONFIG
add wave -noupdate -label TRIGGER_DELAY -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/TRIGGER_DELAY
add wave -noupdate -label SYNC_PERIOD -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/SYNC_PERIOD
add wave -noupdate -label MARKER_CHANNEL -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/MARKER_CHANNEL
add wave -noupdate -label CHANNEL_ENABLE -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/CHANNEL_ENABLE
add wave -noupdate -label ZERO_THRESHOLD -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/ZERO_THRESHOLD
add wave -noupdate -label ONE_THRESHOLD -radix hexadecimal /_a_TestBench/Dut/ConfigRegisters_and_Rom/ONE_THRESHOLD
add wave -noupdate -divider AdcConfigurator
add wave -noupdate -label CEb /_a_TestBench/Dut/AdcConfigurator/CEb
add wave -noupdate -label ADC_CS1b /_a_TestBench/Dut/AdcConfigurator/ADC_CS1b
add wave -noupdate -label ADC_CS2b /_a_TestBench/Dut/AdcConfigurator/ADC_CS2b
add wave -noupdate -label ADC_SCLK /_a_TestBench/Dut/AdcConfigurator/ADC_SCLK
add wave -noupdate -label ADC_SDA /_a_TestBench/Dut/AdcConfigurator/ADC_SDA
add wave -noupdate -divider AdcHisto0
add wave -noupdate -label CEb /_a_TestBench/Dut/AdcHisto0/CEb
add wave -noupdate -label CtrlRegister -radix hexadecimal /_a_TestBench/Dut/AdcHisto0/CtrlRegister
add wave -noupdate -label StatusRegister -radix hexadecimal /_a_TestBench/Dut/AdcHisto0/StatusRegister
add wave -noupdate -label WriteCounter -radix hexadecimal /_a_TestBench/Dut/AdcHisto0/WriteCounter
add wave -noupdate -divider AdcHisto1
add wave -noupdate -label CEb /_a_TestBench/Dut/AdcHisto1/CEb
add wave -noupdate -label CtrlRegister -radix hexadecimal /_a_TestBench/Dut/AdcHisto1/CtrlRegister
add wave -noupdate -label StatusRegister -radix hexadecimal /_a_TestBench/Dut/AdcHisto1/StatusRegister
add wave -noupdate -label WriteCounter -radix hexadecimal /_a_TestBench/Dut/AdcHisto1/WriteCounter
add wave -noupdate -divider I2C_Controller
add wave -noupdate -label CEb /_a_TestBench/Dut/I2C_Controller/ceB
add wave -noupdate -label SCL /_a_TestBench/Dut/I2C_SCL
add wave -noupdate -label SDA /_a_TestBench/Dut/I2C_SDA_OUT
add wave -noupdate -divider TheBuilder
add wave -noupdate -label DATA_RD -radix hexadecimal /_a_TestBench/Dut/TheBuilder/DATA_RD
add wave -noupdate -label EVENT_PRESENT -radix hexadecimal /_a_TestBench/Dut/TheBuilder/EVENT_PRESENT
add wave -noupdate -label EV_CNT -radix hexadecimal /_a_TestBench/Dut/TheBuilder/EV_CNT
add wave -noupdate -label BLOCK_CNT -radix hexadecimal /_a_TestBench/Dut/TheBuilder/BLOCK_CNT
add wave -noupdate -label DATA_OUT -radix hexadecimal /_a_TestBench/Dut/TheBuilder/DATA_OUT
add wave -noupdate -label DATA_OUT_CNT -radix hexadecimal /_a_TestBench/Dut/TheBuilder/DATA_OUT_CNT
add wave -noupdate -label EventCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/EventCounter
add wave -noupdate -label BlockWordCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/BlockWordCounter
add wave -noupdate -label TimeCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/TimeCounter
add wave -noupdate -label AsyncTimeCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/AsyncTimeCounter
add wave -noupdate -label ChCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/ChCounter
add wave -noupdate -label LoopDataCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/LoopDataCounter
add wave -noupdate -label LoopEventCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/LoopEventCounter
add wave -noupdate -label LoopSampleCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/LoopSampleCounter
add wave -noupdate -color Magenta -height 30 -itemcolor Magenta -label fsm_status -radix unsigned /_a_TestBench/Dut/TheBuilder/fsm_status
add wave -noupdate -label data_bus -radix hexadecimal /_a_TestBench/Dut/TheBuilder/data_bus
add wave -noupdate -label DataWordCount -radix hexadecimal /_a_TestBench/Dut/TheBuilder/DataWordCount
add wave -noupdate -label ChannelData -radix hexadecimal /_a_TestBench/Dut/TheBuilder/ChannelData_a
add wave -noupdate -label EventCounterFifo_Data -radix hexadecimal /_a_TestBench/Dut/TheBuilder/EventCounterFifo_Data
add wave -noupdate -label TimeCounterFifo_Data -radix hexadecimal /_a_TestBench/Dut/TheBuilder/TimeCounterFifo_Data
add wave -noupdate -label NumberFillerWords -radix hexadecimal /_a_TestBench/Dut/TheBuilder/NumberFillerWords
add wave -noupdate -label FillerWordsCounter -radix hexadecimal /_a_TestBench/Dut/TheBuilder/FillerWordsCounter
add wave -noupdate -label AllEnabledChannelsHaveEvent /_a_TestBench/Dut/TheBuilder/AllEnabledChannelsHaveEvent
add wave -noupdate -label DECREMENT_EVENT_COUNT /_a_TestBench/Dut/TheBuilder/DECREMENT_EVENT_COUNT
add wave -noupdate -label EventCounterFifo_Read /_a_TestBench/Dut/TheBuilder/EventCounterFifo_Read
add wave -noupdate -label TimeCounterFifo_Read /_a_TestBench/Dut/TheBuilder/TimeCounterFifo_Read
add wave -noupdate -label OutputFifo_Write /_a_TestBench/Dut/TheBuilder/OutputFifo_Write
add wave -noupdate -label EventCounterFifo_Empty /_a_TestBench/Dut/TheBuilder/EventCounterFifo_Empty
add wave -noupdate -label TimeCounterFifo_Empty /_a_TestBench/Dut/TheBuilder/TimeCounterFifo_Empty
add wave -noupdate -label trigger_pulse /_a_TestBench/Dut/TheBuilder/trigger_pulse
add wave -noupdate -label clear_time_counter /_a_TestBench/Dut/TheBuilder/clear_time_counter
add wave -noupdate -label ClearLoopDataCounter /_a_TestBench/Dut/TheBuilder/ClearLoopDataCounter
add wave -noupdate -label IncrementBlockCounter /_a_TestBench/Dut/TheBuilder/IncrementBlockCounter
add wave -noupdate -label ClearBlockWordCounter /_a_TestBench/Dut/TheBuilder/ClearBlockWordCounter
add wave -noupdate -divider CH1
add wave -noupdate -label DATA_OUT -radix hexadecimal /_a_TestBench/Dut/ApvProcessor_0_7/Ch1/DATA_OUT
add wave -noupdate -label decoded_frame_data -radix hexadecimal /_a_TestBench/Dut/ApvProcessor_0_7/Ch1/decoded_frame_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5334983 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {356830 ps} {7425430 ps}
