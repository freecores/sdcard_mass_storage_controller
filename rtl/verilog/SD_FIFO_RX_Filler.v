`include "SD_defines.v"
module SD_FIFO_RX_FILLER
( 
input clk,
input rst,
//WB Signals
output  [31:0]  m_wb_adr_o,

output  reg        m_wb_we_o,

output reg [31:0]  m_wb_dat_o,
output    reg      m_wb_cyc_o,
output   reg       m_wb_stb_o,
input           m_wb_ack_i,
//output  	[2:0] m_wb_cti_o,
//output	[1:0]	 m_wb_bte_o,

//Data Master Control signals
input en,
input [31:0] adr,

//Data Serial signals 
input sd_clk,
input [`SD_BUS_W-1:0] dat_i, 
input wr,
output full
//

);
 wire [31:0] dat_o;
reg rd;
reg reset_rx_fifo;
sd_rx_fifo Rx_Fifo (
.d ( dat_i ),
.wr  (  wr ),
.wclk  (sd_clk),
.q ( dat_o),
.rd (rd),
.full (full),
.empty (empty),
.mem_empt (),
.rclk (clk),
.rst  (rst | reset_rx_fifo)
);

//reg [31:0] tmp_dat;
reg [8:0] offset;
assign  m_wb_adr_o = adr+offset;
//assign  m_wb_dat_o = dat_o;
reg ackd;
always @(posedge clk or posedge rst )begin

 if (rst) begin
  offset<=0;
  m_wb_we_o <=0;
	m_wb_cyc_o <= 0;
	m_wb_stb_o <= 0;
	ackd<=1;
	m_wb_dat_o<=0;
	rd<=0;
	reset_rx_fifo<=1;
 end
 else if (en)  begin//Start filling the TX buffer
    rd<=0;
    reset_rx_fifo<=0;
  if (!empty & ackd) begin
    rd<=1;
    
    m_wb_dat_o<=dat_o;
    m_wb_we_o <=1;
		m_wb_cyc_o <= 1;
		m_wb_stb_o <= 1; 
    ackd<=0;
   
  end
  if(  !ackd & m_wb_ack_i) begin
    m_wb_we_o <=0;
		m_wb_cyc_o <= 0;
		m_wb_stb_o <= 0;
		offset<=offset+`MEM_OFFSET;
		ackd<=1;
	end	 
end
else begin
   reset_rx_fifo<=1;
    rd<=0;
   offset<=0;
    	m_wb_cyc_o <= 0;
			m_wb_stb_o <= 0; 
			m_wb_we_o <=0; 
			ackd<=1;
  end

end  
endmodule


