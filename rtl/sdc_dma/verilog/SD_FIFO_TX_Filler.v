`include "SD_defines.v"
module SD_FIFO_TX_FILLER
( 
input clk,
input rst,
//WB Signals
output  [31:0]  m_wb_adr_o,

output  reg        m_wb_we_o,
input   [31:0]  m_wb_dat_i,

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
output [`SD_BUS_W-1:0] dat_o, 
input rd,
output empty
//

);
reg reset_tx_fifo;

reg [3:0] din;
reg wr_tx;
reg [8:0] we;
reg [8:0] offset;
wire [5:0]mem_empt;
sd_tx_fifo Tx_Fifo (
.d ( din ),
.wr  (  wr_tx ),
.wclk  (clk),
.q ( dat_o),
.rd (rd),
.full (fe),
.empty (empty),
.mem_empt (mem_empt),
.rclk (sd_clk),
.rst  (rst | reset_tx_fifo)
);

reg [3:0] t_c_buffer_0;
reg [3:0] t_c_buffer_1;
assign  m_wb_adr_o = adr+offset;

reg write_ptr;
reg read_ptr;
reg first;
reg [31:0] tmp_dat_buffer_0;
reg [31:0] tmp_dat_buffer_1;


always @(posedge clk or posedge rst )begin
 if (rst) begin
     offset <=0;
	  we <= 8'h1;
	  m_wb_we_o <=0;
		m_wb_cyc_o <= 0;
		m_wb_stb_o <= 0;
		wr_tx<=0;
		tmp_dat_buffer_0<=0;
		tmp_dat_buffer_1<=0;
		t_c_buffer_0<=0;
		t_c_buffer_1<=0;
		reset_tx_fifo<=1;
		write_ptr<=0;
		read_ptr<=0;
		first<=1;
		din<=0;
			
 end
 else if (en) begin //Start filling the TX buffer
    reset_tx_fifo<=0;
		 if (m_wb_ack_i) begin 
		  
		  write_ptr<=write_ptr+1;
		  offset<=offset+`MEM_OFFSET;
			if (!write_ptr) begin
		   	tmp_dat_buffer_0  <= m_wb_dat_i;
		   	t_c_buffer_0<=9;
		  end 	
			else begin
			  tmp_dat_buffer_1  <= m_wb_dat_i;		
			  t_c_buffer_1<=9;
			 end	
			
			m_wb_cyc_o <= 0;
			m_wb_stb_o <= 0;      
		end 
	 	if  ((t_c_buffer_0>0 ) &&  (read_ptr==0)) begin
			if (!fe) begin		 
				we <= {we[9-1:0],we[9-1]};
				wr_tx <=1;
				t_c_buffer_0<=t_c_buffer_0-1;
				if (we[0]) 
					din <= tmp_dat_buffer_0 [3:0];
				else if (we[1]) 
					din <= tmp_dat_buffer_0 [7:4];
				 else if (we[2]) 
					din <= tmp_dat_buffer_0 [11:8] ; 
				 else if (we[3])   
					din <= tmp_dat_buffer_0 [15:12];
				 else if (we[4]) 
					din <= tmp_dat_buffer_0 [19:16] ; 
				 else if (we[5]) 
					din <= tmp_dat_buffer_0 [23:20] ; 
				 else if (we[6])  
					din <= tmp_dat_buffer_0 [27:24];        
				 else if (we[7]) 
					din <= tmp_dat_buffer_0 [31:28]  ; 
			   else if (we[8])  begin
					wr_tx <=0;
					read_ptr<=read_ptr+1;
			   end	
			 end   
			end 
			else if  ((t_c_buffer_1>0 ) &&  (read_ptr==1)) begin
			if (!fe) begin		 
				we <= {we[9-1:0],we[9-1]};
				wr_tx <=1;
				t_c_buffer_1<=t_c_buffer_1-1;
				if (we[0]) 
					din <= tmp_dat_buffer_1 [3:0];
				else if (we[1]) 
					din <= tmp_dat_buffer_1 [7:4];
				 else if (we[2]) 
					din <= tmp_dat_buffer_1 [11:8] ; 
				 else if (we[3])   
					din <= tmp_dat_buffer_1 [15:12];
				 else if (we[4]) 
					din <= tmp_dat_buffer_1 [19:16] ; 
				 else if (we[5]) 
					din <= tmp_dat_buffer_1 [23:20] ; 
				 else if (we[6])  
					din <= tmp_dat_buffer_1 [27:24];        
			   else if (we[7]) 
					din <= tmp_dat_buffer_1 [31:28]  ; 
			   else if (we[8])  begin
					wr_tx <=0;
					read_ptr<=read_ptr+1;
				 end	
			  end   
			  
		end  
		else begin
			wr_tx <=0;
			we <=1;
		end
	 
	
		if ((!m_wb_ack_i) & ( first || (write_ptr != read_ptr) )  ) begin //If not full And no Ack  
			  m_wb_we_o <=0;
				m_wb_cyc_o <= 1;
				m_wb_stb_o <= 1;      
		    first<=0;
		    
		end 

 end 
 else begin
   offset <=0;
   reset_tx_fifo<=1;
   	m_wb_cyc_o <= 0;
		m_wb_stb_o <= 0; 
		m_wb_we_o <=0; 
		first<=1;			
	 	t_c_buffer_0<=0;
		t_c_buffer_1<=0;		
		write_ptr<=0;
		read_ptr<=0;
		first<=1;
		din<=0;
		
 end 
end 
  
endmodule

