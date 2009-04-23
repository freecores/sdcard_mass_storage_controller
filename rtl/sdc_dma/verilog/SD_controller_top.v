`include "SD_defines.v"
module SD_CONTROLLER_TOP(
  
  // WISHBONE common
  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 

  // WISHBONE slave
  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o, 

  // WISHBONE master
  m_wb_adr_o, m_wb_sel_o, m_wb_we_o, 
  m_wb_dat_o, m_wb_dat_i, m_wb_cyc_o, 
  m_wb_stb_o, m_wb_ack_i, 
  m_wb_cti_o, m_wb_bte_o,
  //SD BUS
  sd_cmd_dat_i,sd_cmd_out_o,  sd_cmd_oe_o, 
  sd_dat_dat_i, sd_dat_out_o , sd_dat_oe_o, sd_clk_o_pad
  `ifdef IRQ_ENABLE
   ,int_a, int_b, int_c  
  `endif
);



// WISHBONE common
input           wb_clk_i;     // WISHBONE clock
input           wb_rst_i;     // WISHBONE reset
input   [31:0]  wb_dat_i;     // WISHBONE data input
output reg [31:0]  wb_dat_o;     // WISHBONE data output
     // WISHBONE error output

// WISHBONE slave
input   [7:0]  wb_adr_i;     // WISHBONE address input
input    [3:0]  wb_sel_i;     // WISHBONE byte select input
input           wb_we_i;      // WISHBONE write enable input
input           wb_cyc_i;     // WISHBONE cycle input
input           wb_stb_i;     // WISHBONE strobe input

output          wb_ack_o;     // WISHBONE acknowledge output

// WISHBONE master
output  [31:0]  m_wb_adr_o;
output   [3:0]  m_wb_sel_o;
output          m_wb_we_o;

input   [31:0]  m_wb_dat_i;
output  [31:0]  m_wb_dat_o;
output          m_wb_cyc_o;
output          m_wb_stb_o;
input           m_wb_ack_i;
output  	[2:0] m_wb_cti_o;
output	[1:0]	 m_wb_bte_o;
//SD port

input wire [3:0] sd_dat_dat_i;   //Data in from SDcard
output wire [3:0] sd_dat_out_o; //Data out to SDcard
output wire sd_dat_oe_o; //SD Card tristate Data Output enable (Connects on the SoC TopLevel)

input wire sd_cmd_dat_i; //Command in from SDcard
output wire sd_cmd_out_o; //Command out to SDcard
output wire sd_cmd_oe_o; //SD Card tristate CMD Output enable (Connects on the SoC TopLevel)

//IRQ
`ifdef IRQ_ENABLE
   output int_a, int_b, int_c ; 
  `endif
  
reg wb_ack_o;
reg wb_inta_o;
reg new_cmd;


`define SUPPLY_VOLTAGE_3_3
`define SD_CARD_2_0

//Register Addreses 
`define argument 8'h00
`define command 8'h04
`define status 8'h08
`define resp1 8'h0c
`define controller 8'h1c
`define block 8'h20
`define power 8'h24
`define software 8'h28
`define timeout 8'h2c  
`define normal_isr 8'h30   
`define error_isr 8'h34  
`define normal_iser 8'h38
`define error_iser 8'h3c
`define capa 8'h48
`define clock_d 8'h4c
`define bd_status 8'h50
`define bd_isr 8'h54 
`define bd_iser 8'h58 
`define bd_rx 8'h60  
`define bd_tx 8'h80  


assign m_wb_sel_o = 4'b1111;
`ifdef SUPPLY_VOLTAGE_3_3
   parameter power_controll_reg  = 8'b0000_111_1;
`elsif SUPPLY_VOLTAGE_3_0
   parameter power_controll_reg  = 8'b0000_110_1;
`elsif SUPPLY_VOLTAGE_1_8
   parameter power_controll_reg  = 8'b0000_101_1;
`endif 

parameter block_size_reg = `BLOCK_SIZE ; //512-Bytes

`ifdef SD_BUS_WIDTH_4
     parameter controll_setting_reg =16'b0000_0000_0000_0010;
`else  
     parameter controll_setting_reg =16'b0000_0000_0000_0000;
`endif
     parameter capabilies_reg =16'b0000_0000_0000_0000;
   
//Buss accessible registers    
reg [31:0] argument_reg;
reg [15:0] cmd_setting_reg;
reg [15:0] status_reg;
reg [31:0] cmd_resp_1;
reg [7:0] software_reset_reg; 
reg [15:0] time_out_reg;   
reg [15:0]normal_int_status_reg; 
reg [15:0]error_int_status_reg;
reg [15:0]normal_int_signal_enable_reg;
reg [15:0]error_int_signal_enable_reg;
reg [7:0] clock_divider;
reg [15:0] Bd_Status_reg;   
reg [7:0] Bd_isr_reg;
reg [7:0] Bd_isr_enable_reg;

//Register Controll
reg Bd_isr_reset;
reg normal_isr_reset;
reg error_isr_reset;

//Wires from SD_CMD_MASTER Module 
wire [15:0] status_reg_w;
wire [31:0] cmd_resp_1_w;
wire [15:0]normal_int_status_reg_w;
wire [15:0]error_int_status_reg_w; 
 


//Internal Delayed Ack
reg int_ack;
 
//Rx Buffer  Descriptor internal signals
reg we_m_rx_bd;  //Write enable Master side Rx_bd
reg re_m_rx_bd;  //Read enable Master side Rx_bd
reg [`RAM_MEM_WIDTH-1:0] dat_in_m_rx_bd; //Data in to Rx_bd from Master
wire [`RAM_MEM_WIDTH-1:0] dat_out_m_rx_bd; //Data out from Rx_bd to Master
wire [`BD_WIDTH-1 :0] free_bd_rx_bd; //NO free Rx_bd
wire new_rx_bd;  // New Bd writen
reg re_s_rx_bd; // Read enable Slave side Rx_bd
reg a_cmp_rx_bd; //A Completed transmison of a Bd
wire [`RAM_MEM_WIDTH-1:0] dat_out_s_rx_bd; //Data out from Rx_bd to Slave

//Tx Buffer Descriptor internal signals
reg we_m_tx_bd;
reg re_m_tx_bd;
reg [`RAM_MEM_WIDTH-1:0] dat_in_m_tx_bd;
wire [`RAM_MEM_WIDTH-1:0] dat_out_m_tx_bd;
wire [`BD_WIDTH-1 :0] free_bd_tx_bd;
wire new_tx_bd;
reg re_s_tx_bd;
reg a_cmp_tx_bd;
wire [`RAM_MEM_WIDTH-1:0] dat_out_s_tx_bd;
reg [1:0] we;
wire [7:0] bd_int_st_w; //Wire to BD status register

//Wires for connecting Bd registers with the SD_Data_master module
wire re_s_tx_bd_w;
wire a_cmp_tx_bd_w;
wire re_s_rx_bd_w;
wire a_cmp_rx_bd_w;

wire write_req_s; //SD_Data_master want acces to the CMD line.
wire cmd_busy; //CMD line busy no access granted
reg we_ack; //CMD acces granted
wire [31:0] cmd_arg_s; //SD_Data_master CMD Argument
wire [31:0] cmd_set_s; //SD_Data_master Settings Argument
wire [31:0] sys_adr; //System addres the DMA whil Read/Write to/from
wire [1:0]start_dat_t; //Start data transfer

//Signals to Syncronize busy signaling betwen Wishbone access and SD_Data_master access to the CMD line (Also manage the status reg uppdate)
reg int_busy;
assign cmd_busy = int_busy | status_reg[0];
wire status_reg_busy;
reg cmd_int_busy;

//Wires from SD_DATA_SERIAL_HOST_1 to the FIFO
wire [`SD_BUS_W -1 : 0 ]data_in_rx_fifo;
wire [31: 0 ] data_fout_tx_fifo;
wire [31:0] m_wb_dat_o_rx;
wire [3:0] m_wb_sel_o_tx;
wire [31:0] m_wb_adr_o_tx;
wire [31:0] m_wb_adr_o_rx;

//SD clock 
wire sd_clk_i; //Sd_clk provided to the system
wire sd_clk_o; //Sd_clk used in the system 
output sd_clk_o_pad;
//sd_clk_o to be used i set here
`ifdef SD_CLK_BUS_CLK
  assign sd_clk_i = wb_clk_i;
`endif 

`ifdef SD_CLK_STATIC
   assign sd_clk_o = sd_clk_i;
`endif
   
`ifdef SD_CLK_DYNAMIC
  CLOCK_DIVIDER CLOCK_DIVIDER_1 (
 .CLK (sd_clk_i),
 .DIVIDER (clock_divider),
 .RST  (wb_rst_i),
 .SD_CLK  (sd_clk_o)  
);
`endif
assign sd_clk_o_pad  = sd_clk_o ;


SD_CMD_MASTER cmd_master_1
(
.CLK_PAD_IO (wb_clk_i),
.SD_CLK_I (sd_clk_o),
.RST_PAD_I (wb_rst_i | software_reset_reg[0]),
.New_CMD  (new_cmd),
.data_write (d_write),
.data_read (d_read),
.cmd_dat_i  (sd_cmd_dat_i),
.cmd_out_o (sd_cmd_out_o),
.cmd_oe_o ( sd_cmd_oe_o),
.ARG_REG (argument_reg),
.CMD_SET_REG (cmd_setting_reg),
.STATUS_REG (status_reg_w),
.TIMEOUT_REG (time_out_reg),
.RESP_1_REG (cmd_resp_1_w),
.ERR_INT_REG (error_int_status_reg_w),
.NORMAL_INT_REG (normal_int_status_reg_w),
.ERR_INT_RST (error_isr_reset),
.NORMAL_INT_RST (normal_isr_reset),
.CLK_DIVIDER (clock_divider),
.st_dat_t (start_dat_t)
);


SD_DATA_MASTER data_master_1 
(
.clk (wb_clk_i),
.rst (wb_rst_i | software_reset_reg[0]),
.new_tx_bd  (new_tx_bd),
.dat_in_tx (dat_out_s_tx_bd),
.free_tx_bd  (free_bd_tx_bd),
.ack_i_s_tx (  ack_o_s_tx ),
.re_s_tx (re_s_tx_bd_w), 
.a_cmp_tx (a_cmp_tx_bd_w),
.new_rx_bd  (new_rx_bd),
.dat_in_rx (dat_out_s_rx_bd),
.free_rx_bd  (free_bd_rx_bd),
.ack_i_s_rx ( ack_o_s_rx ),
.re_s_rx (re_s_rx_bd_w), 
.a_cmp_rx (a_cmp_rx_bd_w),
.cmd_busy (cmd_busy),
.we_req (write_req_s),
.we_ack (we_ack),
.d_write ( d_write   ),
.d_read (  d_read  ),
.cmd_arg ( cmd_arg_s),
.cmd_set ( cmd_set_s),
.cmd_tsf_err (normal_int_status_reg[15]) ,
.card_status (cmd_resp_1[12:8])   ,
.start_tx_fifo (start_w),
.start_rx_fifo (start_r),
.sys_adr (sys_adr),
.tx_empt (tx_e ),
.tx_full (tx_f ),
.rx_full(full_rx ),
.busy_n       (busy_n),
.transm_complete     (trans_complete ),
.crc_ok         (crc_ok),
.ack_transfer (ack_transfer),
.bd_int_st (bd_int_st_w),
.bd_int_st_rst (Bd_isr_reset),
.CIDAT  (cidat_w)
);
 

SD_DATA_SERIAL_HOST SD_DATA_SERIAL_HOST_1(
.sd_clk     (sd_clk_o),
.rst        (wb_rst_i | software_reset_reg[0]),
.data_in    (data_out_tx_fifo),
.rd         (rd), 
.data_out   (data_in_rx_fifo),
.we         (we_rx),
.DAT_oe_o   (sd_dat_oe_o),
.DAT_dat_o  (sd_dat_out_o),
.DAT_dat_i  (sd_dat_dat_i),
.start_dat  (start_dat_t),
.ack_transfer       (ack_transfer),
.busy_n       (busy_n),
.transm_complete     (trans_complete ),
.crc_ok         (crc_ok)
);


SD_Bd rx_bd
(
.clk (wb_clk_i),
.rst  (wb_rst_i | software_reset_reg[0]),
.we_m (we_m_rx_bd),
.re_m (re_m_rx_bd),
.dat_in_m (dat_in_m_rx_bd),
.dat_out_m (dat_out_m_rx_bd),
.free_bd (free_bd_rx_bd),
.new_bw (new_rx_bd),
.re_s (re_s_rx_bd),
.ack_o_s (ack_o_s_rx),
.a_cmp (a_cmp_rx_bd),
.dat_out_s (dat_out_s_rx_bd)

);

SD_Bd tx_bd
(
.clk (wb_clk_i),
.rst  (wb_rst_i | software_reset_reg[0]),
.we_m (we_m_tx_bd),
.re_m (re_m_tx_bd),
.dat_in_m (dat_in_m_tx_bd),
.dat_out_m (dat_out_m_tx_bd),
.free_bd (free_bd_tx_bd),
.new_bw (new_tx_bd),
.ack_o_s (ack_o_s_tx),
.re_s (re_s_tx_bd),
.a_cmp (a_cmp_tx_bd),
.dat_out_s (dat_out_s_tx_bd)

);


SD_FIFO_TX_FILLER FIFO_filer_tx (
.clk (wb_clk_i),
.rst (wb_rst_i | software_reset_reg[0]),
.m_wb_adr_o (m_wb_adr_o_tx),

.m_wb_we_o  (m_wb_we_o_tx),

.m_wb_dat_i (m_wb_dat_i),
.m_wb_cyc_o (m_wb_cyc_o_tx),
.m_wb_stb_o (m_wb_stb_o_tx),
.m_wb_ack_i ( m_wb_ack_i),
.en (start_w),
.adr (sys_adr),
.sd_clk (sd_clk_o),
.dat_o (data_out_tx_fifo   ),
.rd   ( rd  ),
.empty (tx_e),
.fe (tx_f)
);

SD_FIFO_RX_FILLER FIFO_filer_rx (
.clk (wb_clk_i),
.rst (wb_rst_i | software_reset_reg[0]),
.m_wb_adr_o (m_wb_adr_o_rx),

.m_wb_we_o  (m_wb_we_o_rx),
.m_wb_dat_o (m_wb_dat_o_rx),
.m_wb_cyc_o (m_wb_cyc_o_rx),
.m_wb_stb_o (m_wb_stb_o_rx),
.m_wb_ack_i ( m_wb_ack_i),
.en (start_r),
.adr (sys_adr),
.sd_clk (sd_clk_o),
.dat_i (data_in_rx_fifo   ),
.wr   ( we_rx  ),
.full (full_rx)
);

//MUX For WB master acces granted to RX or TX FIFO filler
assign m_wb_cyc_o = start_w ? m_wb_cyc_o_tx :start_r ?m_wb_cyc_o_rx: 0;
assign m_wb_stb_o = start_w ? m_wb_stb_o_tx :start_r ?m_wb_stb_o_rx: 0;
assign m_wb_dat_o = m_wb_dat_o_rx;
assign m_wb_we_o = start_w ? m_wb_we_o_tx :start_r ?m_wb_we_o_rx: 0;
assign m_wb_adr_o = start_w ? m_wb_adr_o_tx :start_r ?m_wb_adr_o_rx: 0;

`ifdef IRQ_ENABLE
assign int_a =normal_int_status_reg &  normal_int_signal_enable_reg;
assign int_b = error_int_status_reg & error_int_signal_enable_reg;
assign int_c =  Bd_isr_reg & Bd_isr_enable_reg;
`endif

always @ (re_s_tx_bd_w or a_cmp_tx_bd_w or  re_s_rx_bd_w or a_cmp_rx_bd_w or write_req_s) begin
  re_s_tx_bd<=re_s_tx_bd_w;
  a_cmp_tx_bd <=a_cmp_tx_bd_w;
  re_s_rx_bd <=re_s_rx_bd_w; 
  a_cmp_rx_bd<=a_cmp_rx_bd_w;
end

//Set Bd_Status_reg
always @ ( free_bd_tx_bd or free_bd_rx_bd ) begin
  Bd_Status_reg[15:8]=free_bd_rx_bd;
  Bd_Status_reg[7:0]=free_bd_tx_bd;
end

always @( cmd_resp_1_w  or error_int_status_reg_w or normal_int_status_reg_w ) begin
cmd_resp_1<= cmd_resp_1_w;
normal_int_status_reg<= normal_int_status_reg_w  ;
error_int_status_reg<= error_int_status_reg_w  ;
end  

always @ ( cidat_w or cmd_int_busy or status_reg_w or status_reg_busy or bd_int_st_w) begin
 status_reg[0]<= status_reg_busy;
 status_reg[15:1]<=  status_reg_w[15:1]; 
 status_reg[1] <= cidat_w; 
 Bd_isr_reg<=bd_int_st_w;
end
 
//cmd_int_busy is set when an internal access to the CMD buss is granted then immidetly uppdate the status busy bit to prevent buss access to cmd
assign status_reg_busy = cmd_int_busy ? 1'b1: status_reg_w[0];
 
//WB write
always @(posedge wb_clk_i or posedge wb_rst_i)
	begin
	  we_m_rx_bd <= 0;
   	we_m_tx_bd <= 0;
	  new_cmd<= 1'b0 ;
	  we_ack <= 0;
	  int_ack =  1;
	  cmd_int_busy<=0;
     if ( wb_rst_i )begin
	    argument_reg <=0;
      cmd_setting_reg <= 0;
	    software_reset_reg <= 0;
	    time_out_reg <= 0;
	    normal_int_signal_enable_reg <= 0;
	    error_int_signal_enable_reg <= 0;	  
	    clock_divider <=`RESET_CLK_DIV;
	    int_ack=1 ;
	    we<=0;
	    int_busy <=0;
	    we_ack <=0;
	    wb_ack_o=0;
	    cmd_int_busy<=0;
	    Bd_isr_reset<=0;
	    dat_in_m_tx_bd<=0;
	    dat_in_m_rx_bd<=0;
	    Bd_isr_enable_reg<=0;
	    normal_isr_reset<=0;
	    error_isr_reset<=0;
	  end
	  else if ((wb_stb_i  & wb_cyc_i) || wb_ack_o )begin 
	    Bd_isr_reset<=0; 
	     normal_isr_reset<=  0;
	    error_isr_reset<=  0;
	    if (wb_we_i) begin
	      case (wb_adr_i) 
	        `argument: begin  
	            argument_reg  <=  wb_dat_i;
	            new_cmd <=  1'b1 ;	            
	         end
	        `command : begin 
	            cmd_setting_reg  <=  wb_dat_i;
	            int_busy <= 1;
	        end
          `software : software_reset_reg <=  wb_dat_i;
          `timeout : time_out_reg  <=  wb_dat_i;
          `normal_iser : normal_int_signal_enable_reg <=  wb_dat_i;
          `error_iser : error_int_signal_enable_reg  <=  wb_dat_i;
          `normal_isr : normal_isr_reset<=  1;
          `error_isr:  error_isr_reset<=  1;
	        `clock_d: clock_divider  <=  wb_dat_i;
	        `bd_isr: Bd_isr_reset<=  1;	    
	        `bd_iser : Bd_isr_enable_reg <= wb_dat_i ;     
	        `ifdef RAM_MEM_WIDTH_32
	          `bd_rx: begin
	             we <= we+1;	           
	             we_m_rx_bd <= 1;
	             int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_rx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_rx_bd <=  wb_dat_i;	                   
	           else begin
	              int_ack =  1; 
	              we<= 0;
	              we_m_rx_bd <= 0;
	            end
	           
	        end
	        `bd_tx: begin
	           we <= we+1;	           
	           we_m_tx_bd <= 1;
	           int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_tx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_tx_bd <=  wb_dat_i;                   
	           else begin
	             int_ack =  1; 
	              we<= 0;
	              we_m_tx_bd <= 0;
	            end
	        end
	        
	        `endif
	        `ifdef RAM_MEM_WIDTH_16
	        `bd_rx: begin
	             we <= we+1;	           
	             we_m_rx_bd <= 1;
	             int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_rx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_rx_bd <=  wb_dat_i[15:0];	                    
	           else if ( we[1:0]==2'b10) 
	             dat_in_m_rx_bd <=  wb_dat_i[31:16];	            
	           else begin
	             int_ack =  1; 
	              we<= 0;
	              we_m_rx_bd <= 0;
	            end
	           
	        end
	        `bd_tx: begin
	           we <= we+1;	           
	           we_m_tx_bd <= 1;
	           int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_tx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_tx_bd <=  wb_dat_i[15:0];	                    
	           else if ( we[1:0]==2'b10) 
	             dat_in_m_tx_bd <=  wb_dat_i[31:16];	            
	           else begin
	             int_ack =  1; 
	              we<= 0;
	              we_m_tx_bd <= 0;
	            end
	        end
	        `endif
	        
	      endcase
	    end     	     
	wb_ack_o =   wb_cyc_i & wb_stb_i & ~wb_ack_o & int_ack; 
	 end
	    else if (write_req_s) begin
	       new_cmd <=  1'b1 ; 
	       cmd_setting_reg <=   cmd_set_s; 
	       argument_reg  <=  cmd_arg_s ; 
	       cmd_int_busy<=  1; 
	       we_ack <= 1;
	    end  
	 
	 if (status_reg[0])
	    int_busy <=  0; 
	  
	//wb_ack_o =   wb_cyc_i & wb_stb_i & ~wb_ack_o & int_ack; 
end

always @(posedge wb_clk_i )begin
   if (wb_stb_i  & wb_cyc_i) begin //CS
      case (wb_adr_i)
	         `argument:  wb_dat_o  <=   argument_reg ;
	         `command : wb_dat_o <=  cmd_setting_reg ;
	         `status : wb_dat_o <=  status_reg ;
           `resp1 : wb_dat_o <=  cmd_resp_1 ;   
           
           `controller : wb_dat_o <=  controll_setting_reg ;
           `block :  wb_dat_o <=  block_size_reg ;
           `power : wb_dat_o <=  power_controll_reg ;
           `software : wb_dat_o  <=  software_reset_reg ;
           `timeout : wb_dat_o  <=  time_out_reg ;
           `normal_isr : wb_dat_o <=  normal_int_status_reg ;
           `error_isr : wb_dat_o  <=  error_int_status_reg ;
           `normal_iser : wb_dat_o <=  normal_int_signal_enable_reg ;
           `error_iser : wb_dat_o  <=  error_int_signal_enable_reg ;
          
	         `capa  : wb_dat_o  <=  capabilies_reg ; 
	         `bd_status : wb_dat_o  <=  Bd_Status_reg; 
	         `bd_isr : wb_dat_o  <=  Bd_isr_reg ; 
	         `bd_iser : wb_dat_o  <=  Bd_isr_enable_reg ; 
	    endcase
	  end 
end




endmodule