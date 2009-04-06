//-------------------------
//-------------------------




`include "SD_defines.v"


module SD_DATA_SERIAL_HOST(
input sd_clk,
input rst,
//Tx Fifo
input [`SD_BUS_W-1:0] data_in ,

output reg rd,
//Rx Fifo
output  reg  [`SD_BUS_W-1:0] data_out ,
output reg we,
//tristate data
output reg DAT_oe_o,
output reg[`SD_BUS_W-1:0] DAT_dat_o,
input  [`SD_BUS_W-1:0] DAT_dat_i,
//Controll signals
input [1:0] start_dat,
input ack_transfer,

output reg busy_n,
output reg transm_complete,
output reg crc_ok
);

//CRC16 
reg [`SD_BUS_W-1:0] crc_in;
reg crc_en;
reg crc_rst;
wire [15:0] crc_out [`SD_BUS_W-1:0];
reg  [`SD_BUS_W-1:0] temp_in;
  
reg [10:0] transf_cnt;
parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE        = 6'b000001;
parameter WRITE_DAT   = 6'b000010;
parameter WRITE_CRC   = 6'b000100;
parameter WRITE_BUSY  = 6'b001000;
parameter READ_WAIT   = 6'b010000;      
parameter READ_DAT    = 6'b100000;
reg [2:0] crc_status; 
reg busy_int;   
genvar i;
generate
for(i=0; i<`SD_BUS_W; i=i+1) begin:CRC_16_gen
  CRC_16 CRC_16_i (crc_in[i],crc_en, sd_clk, crc_rst, crc_out[i]);
end
endgenerate

reg ack_transfer_int;
always @ (posedge sd_clk or posedge rst   )
begin
if (rst)
  ack_transfer_int <=0;
else
 ack_transfer_int<=ack_transfer;
end
reg q_start_bit;
always @ (state or start_dat or q_start_bit or  transf_cnt or crc_status or busy_int or DAT_dat_i or ack_transfer_int)
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
    if (transf_cnt >= `BIT_BLOCK) 
       next_state= WRITE_CRC;
   else if (start_dat == 2'b11)
        next_state=IDLE;
    else 
       next_state=WRITE_DAT;
  end

  WRITE_CRC: begin
    if (crc_status ==0) 
       next_state= WRITE_BUSY;
    else 
       next_state=WRITE_CRC;
    
  end
  WRITE_BUSY: begin
      if ( (busy_int ==1)  & ack_transfer_int)
       next_state= IDLE;
    else 
       next_state  = WRITE_BUSY;
  end
  
  READ_WAIT: begin
    if (q_start_bit== 0 ) 
       next_state= READ_DAT;
    else 
       next_state=READ_WAIT;
  end
  
  READ_DAT: begin
    if ( ack_transfer_int)  //Startbit consumed...
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


//----------------Seq logic------------
always @ (posedge sd_clk or posedge rst   )
begin : FSM_SEQ
  if (rst ) begin
    state <= #1 IDLE;
 end 
 else begin
    state <= #1 next_state;
 end
end

reg [4:0] crc_c;
reg [3:0] last_din;
reg [2:0] crc_s ;
 
always @ (negedge sd_clk or posedge rst   )
begin  
 if (rst) begin
   DAT_oe_o<=0;
   crc_en<=0;
   crc_rst<=1;
   transf_cnt<=0;
   crc_c<=15;
   rd<=0;
   last_din<=0;
   crc_c<=0;
   crc_in<=0;
   DAT_dat_o<=0;
   crc_status<=7;
   crc_s<=0;
   transm_complete<=0;
   busy_n<=1;
   we<=0;
   data_out<=0;
   crc_ok<=0;
   busy_int<=0;
 end
 else begin
 case(state)
   IDLE: begin
      DAT_oe_o<=0;
      DAT_dat_o<=4'b1111;
      crc_en<=0;
      crc_rst<=1;
      transf_cnt<=0;
      crc_c<=16;
      crc_status<=7;
      crc_s<=0;
      we<=0;
      rd<=0;
      busy_n<=1;
    
   end
   WRITE_DAT: begin    
      transm_complete <=0;  
       busy_n<=0;
      crc_ok<=0;
      transf_cnt<=transf_cnt+1; 
      
        if (transf_cnt==1) begin
          rd<=1;  
          crc_rst<=0;
          crc_en<=1;
          last_din <=data_in; 
          DAT_oe_o<=1;  
          DAT_dat_o<=0;
          crc_in<= data_in;     
        end
        else if ( (transf_cnt>=2) && (transf_cnt<=`BIT_BLOCK-`CRC_OFF )) begin                 
            rd<=1;
          DAT_oe_o<=1;           
          DAT_dat_o<= last_din; 
          last_din <=data_in; 
          crc_in<= data_in;  
                    
          if ( transf_cnt >=`BIT_BLOCK-`CRC_OFF ) begin
             crc_en<=0;             
         end
       end
       else if (transf_cnt>`BIT_BLOCK-`CRC_OFF & crc_c!=0) begin
        rd<=0;
         crc_en<=0;
         crc_c<=crc_c-1;      
         DAT_oe_o<=1; 
         DAT_dat_o[0]<=crc_out[0][crc_c-1];
         DAT_dat_o[1]<=crc_out[1][crc_c-1];
         DAT_dat_o[2]<=crc_out[2][crc_c-1];
         DAT_dat_o[3]<=crc_out[3][crc_c-1];         
       end
       else if (transf_cnt==`BIT_BLOCK-2) begin
          DAT_oe_o<=1; 
          DAT_dat_o<=4'b1111;
           rd<=0;
      end   
       else if (transf_cnt !=0) begin
         DAT_oe_o<=0; 
         rd<=0;
         end
   end
   WRITE_CRC : begin
      rd<=0;
      DAT_oe_o<=0; 
      crc_status<=crc_status-1;
      if  (( crc_status<=4) && ( crc_status>=2) )
      crc_s[crc_status-2] <=DAT_dat_i[0];    
   end
   WRITE_BUSY : begin
       transm_complete <=1;
     if (crc_s == 3'b010) 
       crc_ok<=1;     
     else 
       crc_ok<=0;  
            
       busy_int<=DAT_dat_i[0];
    
        `ifdef SIM
          crc_ok<=1;
       `endif
       /* `ifdef  NO_CRC_CHECK_ON_WRITE_DATA
           crc_ok<=1;
        `endif
        */
   end
   READ_WAIT:begin
      DAT_oe_o<=0;
      crc_rst<=0;
      crc_en<=1;
      crc_in<=0; 
      crc_c<=15;// end 
      busy_n<=0;
      transm_complete<=0; 
   end
   
   READ_DAT: begin
     
       
     if (transf_cnt<`BIT_BLOCK_REC) begin
       we<=1;
     
       data_out<=DAT_dat_i;
       crc_in<=DAT_dat_i;
       crc_ok<=1;
       transf_cnt<=transf_cnt+1; 
              
     end  
     else if  ( transf_cnt <= (`BIT_BLOCK_REC +`BIT_CRC_CYCLE)) begin
       transf_cnt<=transf_cnt+1; 
       crc_en<=0;  
       last_din <=DAT_dat_i; 
       
       if (transf_cnt> `BIT_BLOCK_REC) begin       
        crc_c<=crc_c-1;
          we<=0;
        `ifdef SD_BUS_WIDTH_1
         if  (crc_out[0][crc_status] == last_din[0])
           crc_ok<=0;
        `endif
        
       `ifdef SD_BUS_WIDTH_4
          if  (crc_out[0][crc_c] != last_din[0])
           crc_ok<=0;
          if  (crc_out[1][crc_c] != last_din[1])
           crc_ok<=0;
          if  (crc_out[2][crc_c] != last_din[2])
           crc_ok<=0;
          if  (crc_out[3][crc_c] != last_din[3])
           crc_ok<=0;  
         
        `endif   
         `ifdef SIM
          crc_ok<=1;
       `endif
         if (crc_c==0) begin
          transm_complete <=1;
          busy_n<=0;
           we<=0;
         end
      end
    end  
    
      
        
  end
   
   
  
 endcase 
 
 end

end 
   








//Sync





  
  
endmodule



