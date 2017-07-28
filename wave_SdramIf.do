onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Vme Interface}
add wave -noupdate -label VME_AM -radix hexadecimal /_a_TestBench/Dut/VmeIf/VME_AM
add wave -noupdate -label VME_A -radix hexadecimal /_a_TestBench/Dut/VmeIf/VME_A
add wave -noupdate -label VME_LWORDb /_a_TestBench/Dut/VmeIf/VME_LWORDb
add wave -noupdate -label VME_D -radix hexadecimal /_a_TestBench/Dut/VmeIf/VME_D
add wave -noupdate -label VME_WRITEb /_a_TestBench/Dut/VmeIf/VME_WRITEb
add wave -noupdate -label VME_ASb /_a_TestBench/Dut/VmeIf/VME_ASb
add wave -noupdate -label VME_DS1b /_a_TestBench/Dut/VmeIf/VME_DS1b
add wave -noupdate -label VME_DS0 /_a_TestBench/Dut/VmeIf/DataCycleController/DS0b
add wave -noupdate -label VME_DTACK /_a_TestBench/Dut/VmeIf/VME_DTACK
add wave -noupdate -label VME_BERR /_a_TestBench/Dut/VmeIf/VME_BERR
add wave -noupdate -label VME_RETRY /_a_TestBench/Dut/VME_RETRYb
add wave -noupdate -label module_selected /_a_TestBench/Dut/VmeIf/module_selected
add wave -noupdate -label OBUF_CEb /_a_TestBench/Dut/VmeIf/OBUF_CEb
add wave -noupdate -divider Sdram
add wave -noupdate -label SdramInitialized /_a_TestBench/Dut/SdramInitialized
add wave -noupdate -label MemReadReq /_a_TestBench/Dut/mem_local_read_req
add wave -noupdate -label MemWriteReq /_a_TestBench/Dut/mem_local_write_req
add wave -noupdate -label MemAddr -radix hexadecimal /_a_TestBench/Dut/mem_local_addr
add wave -noupdate -label MemWdata -radix hexadecimal /_a_TestBench/Dut/mem_local_wdata
add wave -noupdate -label MemRdata -radix hexadecimal /_a_TestBench/Dut/mem_local_rdata
add wave -noupdate -label MemReady /_a_TestBench/Dut/mem_local_ready
add wave -noupdate -label MemValid /_a_TestBench/Dut/mem_local_rdata_valid
add wave -noupdate -divider SdramFifoIf
add wave -noupdate -label Clk /_a_TestBench/Dut/SdramFifoHandler/CLK
add wave -noupdate -label RdEvb /_a_TestBench/Dut/SdramFifoHandler/RD_EVB
add wave -noupdate -label EmptyEvb /_a_TestBench/Dut/SdramFifoHandler/EMPTY_EVB
add wave -noupdate -label SdramAddr -radix hexadecimal /_a_TestBench/Dut/SdramFifoHandler/SDRAM_ADDR
add wave -noupdate -label SdramWrAddr -radix hexadecimal /_a_TestBench/Dut/SdramFifoHandler/SDRAM_WRITE_ADDRESS
add wave -noupdate -label SdramRdAddr -radix hexadecimal /_a_TestBench/Dut/SdramFifoHandler/SDRAM_READ_ADDRESS
add wave -noupdate -label SdramWordCount -radix unsigned /_a_TestBench/Dut/SdramFifoHandler/SDRAM_WORD_COUNT
add wave -noupdate -label SdramWriteReq /_a_TestBench/Dut/SdramFifoHandler/SDRAM_WRITE_REQ
add wave -noupdate -label SdramReadReq /_a_TestBench/Dut/SdramFifoHandler/SDRAM_READ_REQ
add wave -noupdate -label SdramReady /_a_TestBench/Dut/SdramFifoHandler/SDRAM_READY
add wave -noupdate -label SdramDataValid /_a_TestBench/Dut/SdramFifoHandler/SDRAM_DATA_VALID
add wave -noupdate -label ReadFsmIdle /_a_TestBench/Dut/SdramFifoHandler/ReadFsmIdle
add wave -noupdate -label WriteFsmIdle /_a_TestBench/Dut/SdramFifoHandler/WriteFsmIdle
add wave -noupdate -color Orange -label fsmWRstatus -radix unsigned /_a_TestBench/Dut/SdramFifoHandler/WriteHandler/fsm_status
add wave -noupdate -color Firebrick -label fsmReqStatus -radix unsigned /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/fsm_req_status
add wave -noupdate -color Gold -label fsmRdStatus -radix unsigned /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/fsm_rd_status
add wave -noupdate -label Flushing /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/Flushing
add wave -noupdate -label DataInside /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/DataInside
add wave -noupdate -label LoadLSB /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/LOAD_LSB
add wave -noupdate -label LoadMSB /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/LOAD_MSB
add wave -noupdate -label OddData /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/odd_data
add wave -noupdate -label LoadSdramBurstCnt /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/LoadSdramBurstCount
add wave -noupdate -label SdramBurstCount -radix unsigned /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/SdramBurstCount
add wave -noupdate -label OutBurstSize -radix hexadecimal /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/OutBurstSize
add wave -noupdate -label BurstSize -radix unsigned /_a_TestBench/Dut/SdramFifoHandler/ReadHandler/BurstSize
add wave -noupdate -label Data64Bit -radix hexadecimal /_a_TestBench/Dut/SdramFifoHandler/Data64Bit
add wave -noupdate -label OutputFifoWr /_a_TestBench/Dut/SdramFifoHandler/OutputFifoWr
add wave -noupdate -label OutputFifoEmpty /_a_TestBench/Dut/SdramFifoHandler/OUTPUT_FIFO_EMPTY
add wave -noupdate -label OutputFifoFull /_a_TestBench/Dut/SdramFifoHandler/OUTPUT_FIFO_FULL
add wave -noupdate -label OutputFifoWc -radix hexadecimal /_a_TestBench/Dut/SdramFifoHandler/OUTPUT_FIFO_WC
add wave -noupdate -label UserRe /_a_TestBench/Dut/SdramFifoHandler/USER_RE
add wave -noupdate -divider TheBuilder
add wave -noupdate -label APV_TRIGGER /_a_TestBench/Dut/APV_TRIGGER
add wave -noupdate -label adc0 -radix hexadecimal /_a_TestBench/Dut/adc0
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {302875200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 138
configure wave -valuecolwidth 89
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
WaveRestoreZoom {302321136 ps} {302639288 ps}
