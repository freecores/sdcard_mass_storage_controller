module sd_controller_fifo_wba
( 
  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 
  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o, 
  sd_cmd_dat_i,sd_cmd_out_o,  sd_cmd_oe_o, 
  sd_dat_dat_i, sd_dat_out_o , sd_dat_oe_o, sd_clk_o_pad
);
input           wb_clk_i;     
input           wb_rst_i;     
input   [7:0]  wb_dat_i;     
output  [7:0]  wb_dat_o;     
input   [2:0]  wb_adr_i;     
input    [3:0]  wb_sel_i;     
input           wb_we_i;      
input           wb_cyc_i;     
input           wb_stb_i;     
output reg          wb_ack_o;     
input wire [3:0] sd_dat_dat_i;
output wire [3:0] sd_dat_out_o;
output wire sd_dat_oe_o;
input wire sd_cmd_dat_i;
output wire sd_cmd_out_o;
output wire sd_cmd_oe_o;
output sd_clk_o_pad;
wire sd_clk_i;
input sd_clk_i_pad;
reg [7:0] controll_reg;
reg [7:0] status_reg;
reg [7:0] command_timeout_reg;
  assign sd_clk_i = wb_clk_i;
assign sd_clk_o=sd_clk_i;
reg [1:0] wb_fifo_adr_i_writer;
reg [1:0] wb_fifo_adr_i_reader;
wire [1:0] wb_fifo_adr_i;
reg add_token_read;
wire [7:0] wb_fifo_dat_i;
wire [7:0] wb_fifo_dat_o;
reg [7:0]  wb_dat_i_storage;
reg [7:0] wb_dat_o_i;
reg time_enable;
assign sd_clk_o_pad  = sd_clk_i ;
assign wb_fifo_adr_i = add_token_read ? wb_fifo_adr_i_reader : wb_fifo_adr_i_writer;
assign wb_fifo_dat_i =wb_dat_i_storage;
assign wb_dat_o = wb_adr_i[0] ? wb_fifo_dat_o :   wb_dat_o_i ;
wire [1:4]fifo_full ;
wire [1:4]fifo_empty;
reg wb_fifo_we_i;
reg wb_fifo_re_i;
wire [1:0] sd_adr_o;
wire [7:0] sd_dat_o;
wire [7:0] sd_dat_i;
sd_fifo sd_fifo_0
( 
   .wb_adr_i  (wb_fifo_adr_i ),
   .wb_dat_i  (wb_fifo_dat_i),
   .wb_dat_o  (wb_fifo_dat_o ),
   .wb_we_i   (wb_fifo_we_i),
   .wb_re_i   (wb_fifo_re_i),
   .wb_clk  (wb_clk_i),
   .sd_adr_i (sd_adr_o ),
   .sd_dat_i (sd_dat_o),
   .sd_dat_o (sd_dat_i ),
   .sd_we_i (sd_we_o),
   .sd_re_i (sd_re_o),
   .sd_clk (sd_clk_o),
   .fifo_full ( fifo_full ),
   .fifo_empty (fifo_empty    ),
   .rst (wb_rst_i) 
  ) ; 
wire [1:0] sd_adr_o_cmd;
wire [7:0] sd_dat_i_cmd;
wire [7:0] sd_dat_o_cmd;
wire [1:0] sd_adr_o_dat;
wire [7:0] sd_dat_i_dat;
wire [7:0] sd_dat_o_dat;
wire [1:0] st_dat_t;
sd_cmd_phy sdc_cmd_phy_0
(
  .sd_clk (sd_clk_o),
  .rst (wb_rst_i ),
  .cmd_dat_i ( sd_cmd_dat_i  ),
  .cmd_dat_o (sd_cmd_out_o   ),
  .cmd_oe_o (sd_cmd_oe_o   ),  
  .sd_adr_o (sd_adr_o_cmd),
  .sd_dat_i (sd_dat_i_cmd),
  .sd_dat_o (sd_dat_o_cmd),
  .sd_we_o (sd_we_o_cmd),
  .sd_re_o (sd_re_o_cmd),
  .fifo_full ( fifo_full[1:2] ),
  .fifo_empty ( fifo_empty [1:2]),
  .start_dat_t (st_dat_t),
  .fifo_acces_token (fifo_acces_token)
  ); 
  sd_data_phy sd_data_phy_0 (
  .sd_clk (sd_clk_o),
  .rst (wb_rst_i | controll_reg[0]),
  .DAT_oe_o ( sd_dat_oe_o  ),
  .DAT_dat_o (sd_dat_out_o),
  .DAT_dat_i  (sd_dat_dat_i ),
  .sd_adr_o (sd_adr_o_dat   ),
  .sd_dat_i (sd_dat_i_dat  ),
  .sd_dat_o (sd_dat_o_dat  ),
  .sd_we_o  (sd_we_o_dat),
  .sd_re_o (sd_re_o_dat),
  .fifo_full ( fifo_full[3:4] ),
  .fifo_empty ( fifo_empty [3:4]),
  .start_dat (st_dat_t),
  .fifo_acces (~fifo_acces_token)  
  ); 
  assign sd_adr_o =  fifo_acces_token ? sd_adr_o_cmd : sd_adr_o_dat; 
  assign sd_dat_o =  fifo_acces_token ? sd_dat_o_cmd : sd_dat_o_dat;
  assign sd_we_o  = fifo_acces_token ? sd_we_o_cmd : sd_we_o_dat;
  assign sd_re_o  =  fifo_acces_token ? sd_re_o_cmd : sd_re_o_dat;
 assign sd_dat_i_dat = sd_dat_i;
 assign sd_dat_i_cmd = sd_dat_i;
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin
	if (wb_rst_i)
	    status_reg<=0;
	  else begin	
      status_reg[0] <= fifo_full[1];
      status_reg[1] <= fifo_empty[2];
      status_reg[2] <=  fifo_full[3];
      status_reg[3] <=  fifo_empty[4];
    end
  end
  reg delayed_ack;
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin	
	  if (wb_rst_i) 
	    wb_ack_o <=0; 
	   else 
	     wb_ack_o <=wb_stb_i & wb_cyc_i &  ~wb_ack_o & delayed_ack;
	end
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin	
    if ( wb_rst_i )begin
	    command_timeout_reg<=255;
	    wb_dat_i_storage<=0;
	    controll_reg<=0;
	    wb_fifo_we_i<=0;
	    wb_fifo_adr_i_writer<=0;
	    time_enable<=0;
	  end
	  else if (wb_stb_i  & wb_cyc_i & (~wb_ack_o))begin 
	    if (wb_we_i) begin
	      case (wb_adr_i) 
	      4'h0 : begin
	        wb_fifo_adr_i_writer<=0;
	        wb_fifo_we_i<=1&!delayed_ack;
	        wb_dat_i_storage<=wb_dat_i;	       
	        command_timeout_reg<=255;
	        time_enable<=1;
	      end       
        4'h2 : begin
	        wb_fifo_adr_i_writer<=2;
	        wb_fifo_we_i<=1&!delayed_ack;
	        wb_dat_i_storage<=wb_dat_i;
	        command_timeout_reg<=255;
	        time_enable<=0;
	      end        
        4'h5 : controll_reg <= wb_dat_i;
  	      endcase
	    end  	  
	   end
	   else begin
	      wb_fifo_we_i<=0;
	     if (!status_reg[1])
	       time_enable<=0; 
	     if ((command_timeout_reg!=0) && (time_enable))
	         command_timeout_reg<=command_timeout_reg-1;   
	   end   
end
always @(posedge wb_clk_i or posedge wb_rst_i )begin
   if ( wb_rst_i) begin
     add_token_read<=0;
     delayed_ack<=0;
     wb_fifo_re_i<=0;
      wb_fifo_adr_i_reader<=0;
      wb_dat_o_i<=0;
  end 
 else begin  
    delayed_ack<=0;
    wb_fifo_re_i<=0;
   if (wb_stb_i  & wb_cyc_i & (~wb_ack_o)) begin 
   delayed_ack<=delayed_ack+1;
    add_token_read<=0;
    if (!wb_we_i) begin
      case (wb_adr_i)
      4'h1 : begin
         add_token_read<=1;
         wb_fifo_adr_i_reader<=1;
	      wb_fifo_re_i<=1&delayed_ack; 
      end
      4'h3 :begin
         add_token_read<=1;
         wb_fifo_adr_i_reader<=3;
	       wb_fifo_re_i<=1 & delayed_ack;
     end 
      4'h4 : wb_dat_o_i <= status_reg;
      4'h6 : wb_dat_o_i <= command_timeout_reg;
     endcase
    end
  end  
end
end
 assign m_wb_adr_o =0;
 assign m_wb_sel_o =0; 
 assign m_wb_we_o=0;
 assign m_wb_dat_o =0;
 assign m_wb_cyc_o=0;
 assign m_wb_stb_o=0;
 assign m_wb_cti_o=0;
 assign m_wb_bte_o=0;
endmodule
module sd_counter
  (
    output reg [9:1] q,
    output [9:1]    q_bin,
    input cke,
    input clk,
    input rst
   );
   reg [9:1] qi;
   wire [9:1] q_next;   
   assign q_next =
   qi + 9'd1;
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= 9'd0;
     else
   if (cke)
     qi <= q_next;
   always @ (posedge clk or posedge rst)
     if (rst)
       q <= 9'd0;
     else
       if (cke)
	 q <= (q_next>>1) ^ q_next;
   assign q_bin = qi;
endmodule
module CRC_7(BITVAL, Enable, CLK, RST, CRC);
   input        BITVAL;
   input Enable;
   input        CLK;                           
   input        RST;                             
   output [6:0] CRC;                               
   reg    [6:0] CRC;   
   wire         inv;
   assign inv = BITVAL ^ CRC[6];                   
    always @(posedge CLK or posedge RST) begin
		if (RST) begin
			CRC = 0;   
        end
		else begin
			if (Enable==1) begin
				CRC[6] = CRC[5];
				CRC[5] = CRC[4];
				CRC[4] = CRC[3];
				CRC[3] = CRC[2] ^ inv;
				CRC[2] = CRC[1];
				CRC[1] = CRC[0];
				CRC[0] = inv;
			end
		end
     end
endmodule
module CRC_16(BITVAL, Enable, CLK, RST, CRC);
 input        BITVAL;
   input Enable;
   input        CLK;                           
   input        RST;                             
   output reg [15:0] CRC;                               
   wire         inv;
   assign inv = BITVAL ^ CRC[15];                   
  always @(posedge CLK or posedge RST) begin
		if (RST) begin
			CRC = 0;   
        end
      else begin
        if (Enable==1) begin
         CRC[15] = CRC[14];
         CRC[14] = CRC[13];
         CRC[13] = CRC[12];
         CRC[12] = CRC[11] ^ inv;
         CRC[11] = CRC[10];
         CRC[10] = CRC[9];
         CRC[9] = CRC[8];
         CRC[8] = CRC[7];
         CRC[7] = CRC[6];
         CRC[6] = CRC[5];
         CRC[5] = CRC[4] ^ inv;
         CRC[4] = CRC[3];
         CRC[3] = CRC[2];
         CRC[2] = CRC[1];
         CRC[1] = CRC[0];
         CRC[0] = inv;
        end
         end
      end
endmodule
module sd_data_phy(
input sd_clk,
input rst,
output reg DAT_oe_o,
output reg[3:0] DAT_dat_o,
input  [3:0] DAT_dat_i,
output  [1:0] sd_adr_o,
input [7:0] sd_dat_i,
output reg [7:0] sd_dat_o,
output reg sd_we_o,
output reg sd_re_o,
input  [3:4] fifo_full,
input [3:4] fifo_empty,
input  [1:0] start_dat,
input fifo_acces
);
 reg [5:0] in_buff_ptr_read;
 reg [5:0] out_buff_ptr_read;
 reg crc_ok;
 reg [3:0] last_din_read;
reg [7:0] tmp_crc_token ;  
reg[2:0] crc_read_count;
reg [3:0] crc_in_write;
reg crc_en_write;
reg crc_rst_write;
wire [15:0] crc_out_write [3:0];
reg [3:0] crc_in_read;
reg crc_en_read;
reg crc_rst_read;
wire [15:0] crc_out_read [3:0];  
  reg[7:0] next_out;
    reg data_read_index;  
reg [10:0] transf_cnt_write;
reg [10:0] transf_cnt_read;
parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE        = 6'b000001;
parameter WRITE_DAT   = 6'b000010;
parameter READ_CRC   = 6'b000100;
parameter WRITE_CRC  = 6'b001000;   
parameter  READ_WAIT = 6'b010000;
parameter  READ_DAT  = 6'b100000;
reg in_dat_buffer_empty;
reg [2:0] crc_status_token; 
reg busy_int;
reg add_token;   
genvar i;
generate
for(i=0; i<4; i=i+1) begin:CRC_16_gen_write
  CRC_16 CRC_16_i (crc_in_write[i],crc_en_write, sd_clk, crc_rst_write, crc_out_write[i]);
end
endgenerate
generate
for(i=0; i<4; i=i+1) begin:CRC_16_gen_read
  CRC_16 CRC_16_i (crc_in_read[i],crc_en_read, sd_clk, crc_rst_read, crc_out_read[i]);
end
endgenerate
reg q_start_bit;
always @ (state or start_dat or DAT_dat_i[0] or  transf_cnt_write or transf_cnt_read or busy_int or crc_read_count or sd_we_o or  in_dat_buffer_empty )
begin : FSM_COMBO
 next_state  = 0;   
case(state)
  IDLE: begin
   if (start_dat == 2'b01) 
      next_state=WRITE_DAT;
    else if  (start_dat == 2'b10)
      next_state=READ_WAIT;
    else 
      next_state=IDLE;
    end
  WRITE_DAT: begin
    if (transf_cnt_write >= 1044+2) 
       next_state= READ_CRC;
   else if (start_dat == 2'b11)
        next_state=IDLE;
    else 
       next_state=WRITE_DAT;
  end
  READ_WAIT: begin
    if (DAT_dat_i[0]== 0 ) 
       next_state= READ_DAT;
    else 
       next_state=READ_WAIT;
  end
  READ_CRC: begin
    if ( (crc_read_count == 3'b111) &&(busy_int ==1) ) 
       next_state= WRITE_CRC;
    else 
       next_state=READ_CRC;    
  end
  WRITE_CRC: begin
       next_state= IDLE;
  end
  READ_DAT: begin
    if ((transf_cnt_read >= 1044-3)  && (in_dat_buffer_empty)) 
       next_state= IDLE;
    else if (start_dat == 2'b11)
        next_state=IDLE;   
    else 
       next_state=READ_DAT;
    end  
 endcase
end 
always @ (posedge sd_clk or posedge rst   )
 begin 
  if (rst ) begin
    q_start_bit<=1;
 end 
 else begin
    q_start_bit <= DAT_dat_i[0];
 end
end
always @ (posedge sd_clk or posedge rst   )
begin : FSM_SEQ
  if (rst ) begin
    state <= #1 IDLE;
 end 
 else begin
    state <= #1 next_state;
 end
end
reg [4:0] crc_cnt_write;
reg [4:0]crc_cnt_read;
reg [3:0] last_din;
reg [2:0] crc_s ;
reg [7:0] write_buf_0,write_buf_1, sd_data_out;
reg out_buff_ptr,in_buff_ptr;
reg data_send_index;
reg [1:0] sd_adr_o_read;  
reg [1:0] sd_adr_o_write;
reg read_byte_cnt;       
assign sd_adr_o = add_token ? sd_adr_o_read : sd_adr_o_write;
assign sd_adr_o = add_token ? sd_adr_o_read : sd_adr_o_write;         
reg [3:0] in_dat_buffer [63:0];
always @ (negedge sd_clk or posedge rst   )
begin
if (rst) begin
  DAT_oe_o<=0;
  crc_en_write<=0;
  crc_rst_write<=1;
  transf_cnt_write<=0;
  crc_cnt_write<=15;
  crc_status_token<=7;       
  data_send_index<=0;
  out_buff_ptr<=0;
  in_buff_ptr<=0;  
  read_byte_cnt<=0;
   write_buf_0<=0;
    write_buf_1<=0;
    sd_re_o<=0; 
    sd_data_out<=0;
    sd_adr_o_write<=0;
    crc_in_write<=0;
    DAT_dat_o<=0;
     last_din<=0;    
end  
else begin
 case(state)
   IDLE: begin
      DAT_oe_o<=0;    
      crc_en_write<=0;
      crc_rst_write<=1;     
      crc_cnt_write<=16;
      read_byte_cnt<=0;
      crc_status_token<=7;
      data_send_index<=0;
      out_buff_ptr<=0;
      in_buff_ptr<=0;  
        sd_re_o<=0;
        transf_cnt_write<=0;
   end     
   WRITE_DAT: begin     
      transf_cnt_write<=transf_cnt_write+1; 
      if ( (in_buff_ptr != out_buff_ptr) ||  (transf_cnt_write<2) ) begin
       read_byte_cnt<=read_byte_cnt+1;
       sd_re_o<=0;
        case (read_byte_cnt)
        0:begin
           sd_adr_o_write <=2;
           sd_re_o<=1; 
        end 
        1:begin
          if (!in_buff_ptr)
             write_buf_0<=sd_dat_i;         
          else
            write_buf_1 <=sd_dat_i;
          in_buff_ptr<=in_buff_ptr+1;     
        end    
     endcase
     end
      if (!out_buff_ptr)
        sd_data_out<=write_buf_0;
      else
       sd_data_out<=write_buf_1;
        if (transf_cnt_write==1+2) begin
          crc_rst_write<=0;
          crc_en_write<=1;
          last_din <=write_buf_0[3:0]; 
          DAT_oe_o<=1;  
          DAT_dat_o<=0;
          crc_in_write<= write_buf_0[3:0]; 
          data_send_index<=1;  
          out_buff_ptr<=out_buff_ptr+1;  
        end
        else if ( (transf_cnt_write>=2+2) && (transf_cnt_write<=1044-19+2 )) begin                 
          DAT_oe_o<=1;    
        case (data_send_index) 
           0:begin 
              last_din <=sd_data_out[3:0];
              crc_in_write <=sd_data_out[3:0];
               out_buff_ptr<=out_buff_ptr+1;
           end
           1:begin 
              last_din <=sd_data_out[7:4];
              crc_in_write <=sd_data_out[7:4];
           end
         endcase 
          data_send_index<=data_send_index+1;
          DAT_dat_o<= last_din; 
        if ( transf_cnt_write >=1044-19 +2) begin
             crc_en_write<=0;             
         end
       end
       else if (transf_cnt_write>1044-19 +2 & crc_cnt_write!=0) begin
         crc_en_write<=0;
         crc_cnt_write<=crc_cnt_write-1;      
         DAT_oe_o<=1; 
         DAT_dat_o[0]<=crc_out_write[0][crc_cnt_write-1];
         DAT_dat_o[1]<=crc_out_write[1][crc_cnt_write-1];
         DAT_dat_o[2]<=crc_out_write[2][crc_cnt_write-1];
         DAT_dat_o[3]<=crc_out_write[3][crc_cnt_write-1];         
       end
       else if (transf_cnt_write==1044-2+2) begin
          DAT_oe_o<=1; 
          DAT_dat_o<=4'b1111;
      end   
      else if (transf_cnt_write !=0) begin
         DAT_oe_o<=0;          
      end
   end
 endcase
end
end
always @ (posedge sd_clk or posedge rst   )
begin
  if (rst) begin
    add_token<=0;   
    sd_adr_o_read<=0;
    crc_read_count<=0;
    sd_we_o<=0; 
    tmp_crc_token<=0;
    crc_rst_read<=0;
    crc_en_read<=0;
    in_buff_ptr_read<=0;
    out_buff_ptr_read<=0;
    crc_cnt_read<=0;
    transf_cnt_read<=0;
    data_read_index<=0;
    in_dat_buffer_empty<=0;
    next_out<=0; 
    busy_int<=0;
    sd_dat_o<=0;
  end  
  else begin
   case(state)
   IDLE: begin          
     add_token<=0;
     crc_read_count<=0;
     sd_we_o<=0; 
     tmp_crc_token<=0;
      crc_rst_read<=1;
      crc_en_read<=0;
      in_buff_ptr_read<=0;
     out_buff_ptr_read<=0;
      crc_cnt_read<=15;
      transf_cnt_read<=0;
      data_read_index<=0;
      in_dat_buffer_empty<=0;
    end
    READ_DAT: begin  
     add_token<=1; 
      crc_rst_read<=0;
      crc_en_read<=1;
      if (fifo_acces) begin
        if ( (in_buff_ptr_read - out_buff_ptr_read) >=2) begin
          data_read_index<=~data_read_index;
          case(data_read_index)
            0: begin
             sd_adr_o_read<=3;
             sd_we_o<=0; 
             next_out[3:0]<=in_dat_buffer[out_buff_ptr_read ];
             next_out[7:4]<=in_dat_buffer[out_buff_ptr_read+1 ];
           end
           1: begin
              out_buff_ptr_read<=out_buff_ptr_read+2;
            sd_dat_o<=next_out; 
            sd_we_o<=1;  
            end
          endcase    
          end  
        else
           in_dat_buffer_empty<=1;
      end
     if (transf_cnt_read<1024) begin
       in_dat_buffer[in_buff_ptr_read]<=DAT_dat_i;
       crc_in_read<=DAT_dat_i;
       crc_ok<=1;
       transf_cnt_read<=transf_cnt_read+1; 
       in_buff_ptr_read<=in_buff_ptr_read+1;        
     end  
     else if  ( transf_cnt_read <= (1024 +16)) begin
       transf_cnt_read<=transf_cnt_read+1; 
       crc_en_read<=0;  
       last_din_read <=DAT_dat_i; 
       if (transf_cnt_read> 1024) begin       
         crc_cnt_read <=crc_cnt_read-1;
          if  (crc_out_read[0][crc_cnt_read] != last_din[0])
           crc_ok<=0;
          if  (crc_out_read[1][crc_cnt_read] != last_din[1])
           crc_ok<=0;
          if  (crc_out_read[2][crc_cnt_read] != last_din[2])
           crc_ok<=0;
          if  (crc_out_read[3][crc_cnt_read] != last_din[3])
           crc_ok<=0;  
         if (crc_cnt_read==0) begin
         end
      end
    end  
    end
    READ_CRC: begin
       if (crc_read_count<3'b111) begin
         crc_read_count<=crc_read_count+1;
         tmp_crc_token[crc_read_count]  <= DAT_dat_i[0];     
        end
      busy_int <=DAT_dat_i[0];  
    end
    WRITE_CRC: begin
      add_token<=1;
      sd_adr_o_read<=3;
      sd_we_o<=1; 
      sd_dat_o<=tmp_crc_token;      
    end
  endcase
end
end
endmodule
