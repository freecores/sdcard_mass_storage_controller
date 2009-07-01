sd_generic: 
	cat SD_controller_top.v SD_clock_divider.v SD_cmd_master.v SD_cmd_serial_host.v SD_crc_7.v SD_data_master.v SD_data_host.v SD_crc_16.v 		SD_Bd.v SD_FIFO_TX_Filler.v SD_FIFO_RX_Filler.v ./fifo/smii_rx_fifo.v ./fifo/smii_tx_fifo.v > SD_controller_ff.v
	
	vppp --simple SD_defines.v SD_controller_ff.v > SD_controller_fin.v
 	
all: sd_generic

