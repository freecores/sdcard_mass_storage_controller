//`define TX_ERROR_TEST

module SD_CONTROLLER_TOP_TB(

);

// WISHBONE common

reg           wb_clk_i;     // WISHBONE clock
reg           wb_rst;     // WISHBONE reset
reg   [31:0]  wbs_sds_dat_i;     // WISHBONE data input
wire [31:0]   wbs_sds_dat_o;     // WISHBONE data output
     // WISHBONE error output
// WISHBONE slave
reg   [9:0]  wbs_sds_adr_i;     // WISHBONE address input
reg    [3:0]  wbs_sds_sel_i;     // WISHBONE byte select input
reg           wbs_sds_we_i;      // WISHBONE write enable input
reg           wbs_sds_cyc_i;     // WISHBONE cycle input
reg           wbs_sds_stb_i;     // WISHBONE strobe input
wire          wbs_sds_ack_o;     // WISHBONE acknowledge output
// WISHBONE master
wire  [31:0]  wbm_sdm_adr_o;
wire   [3:0]  wbm_sdm_sel_o;
wire          wbm_sdm_we_o;

wire   [31:0]  wbm_sdm_dat_i;
wire  [31:0]  wbm_sdm_dat_o;
wire          wbm_sdm_cyc_o;
wire          wbm_sdm_stb_o;
reg           wbm_sdm_ack_i;
wire  	[2:0]  wbm_sdm_cti_o;
wire	[1:0]	   wbm_sdm_bte_o;
//SD port




reg  [3:0] sd_dat_pad_i;
wire [3:0] sd_dat_out;
wire sd_dat_oe_o;
reg sd_cmd_dat_i; 
wire sd_cmd_out_o;
wire sd_cmd_oe_o;
wire sd_clk;

wire sd_cmd_oe;
wire sd_cmd_out;
wire sd_dat_oe;
wire [3:0] sd_dat_pad_io;
reg bluff_in;
reg [3:0] data_bluff_in;
assign sd_cmd_pad_io = sd_cmd_oe ? sd_cmd_out : 1'bZ ;
assign sd_dat_pad_io = sd_dat_oe ? sd_dat_out : 4'bzzzz ;

SD_CONTROLLER_TOP sd_controller_top_0
	(
	 .wb_clk_i(wb_clk_i),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_sds_dat_i),
	 .wb_dat_o(wbs_sds_dat_o),
	 .wb_adr_i(wbs_sds_adr_i[7:0]),
	 .wb_sel_i(wbs_sds_sel_i),
	 .wb_we_i(wbs_sds_we_i),
	 .wb_stb_i(wbs_sds_stb_i),
	 .wb_cyc_i(wbs_sds_cyc_i),
	 .wb_ack_o(wbs_sds_ack_o),
	 .m_wb_adr_o(wbm_sdm_adr_o),
	 .m_wb_sel_o(wbm_sdm_sel_o),
	 .m_wb_we_o(wbm_sdm_we_o),
	 .m_wb_dat_o(wbm_sdm_dat_o),
	 .m_wb_dat_i(wbm_sdm_dat_i),
	 .m_wb_cyc_o(wbm_sdm_cyc_o),
	 .m_wb_stb_o(wbm_sdm_stb_o),
	 .m_wb_ack_i(wbm_sdm_ack_i),
	 .m_wb_cti_o(wbm_sdm_cti_o),
	 .m_wb_bte_o(wbm_sdm_bte_o),
	 .sd_cmd_dat_i(bluff_in),
   .sd_cmd_out_o (sd_cmd_out  ),
	 .sd_cmd_oe_o (sd_cmd_oe),
	 .sd_dat_dat_i (data_bluff_in),  //sd_dat_pad_io),
	 .sd_dat_out_o ( sd_dat_out ) ,
   .sd_dat_oe_o ( sd_dat_oe  ),
	 .sd_clk_o  (sd_clk_pad_o)
	 );

reg [31:0] sd_mem [0:256];
reg [3:0] dat_mem [0:1040];
reg [31:0]in_mem [0:512];

// Fill the memory with values taken from a data file
initial $readmemh("data2.txt",sd_mem);
initial $readmemh("data_dat.txt",dat_mem);
// Display the contents of memory
integer k;
initial begin
	$display("Contents of Mem after reading data file:");
	for (k=0; k<256; k=k+1) $display("%d:%h",k,sd_mem[k]);
end

initial begin
	$display("Contents of Mem after reading data file:");
	for (k=1000; k<1040; k=k+1) $display("%d:%h",k,dat_mem[k]);
end


	 reg [13:0] dat_mem_cnt;

  reg [3:0] i2;
reg [24:0] out_cnt;
reg [24:0] out_cnt3;
reg [31:0] reg_out [0:7]; 
reg [31:0] adr_out [0:7];    
reg asd[3:0];
reg [2:0] i;
event reset_trigger; 
event  reset_done_trigger; 
event start_trigger;
event start_done_trigger; 
reg [3:0] cnta;
reg [12:0] in_mem_cnt;
initial 
   begin 
wb_clk_i =0;     // WISHBONE clock
wb_rst =0;     // WISHBONE reset
wbs_sds_dat_i =0;     // WISHBONE data input
wbs_sds_adr_i =0;     // WISHBONE address input
wbs_sds_sel_i =0;     // WISHBONE byte select input
wbs_sds_we_i =0;      // WISHBONE write enable input
wbs_sds_cyc_i =0;     // WISHBONE cycle input
wbs_sds_stb_i =0;     // WISHBONE strobe input
cnta = 5'b01010;
wbm_sdm_ack_i =0 ;
sd_dat_pad_i = 0;
sd_cmd_dat_i = 0;
out_cnt =0;
dat_mem_cnt=0;
i=0;
out_cnt3=0;
i2=0;
in_mem_cnt=0;
asd[0]=1'h1;
asd[1]=1'h1;
asd[2]=1'h0;
asd[3]=1'h1;
asd[4]=1'h0;
asd[5]=1'h0;
asd[6]=1'h0;
asd[7]=1'h1;
sd_cmd_dat_i = 0 ; 
reg_out[0] <=  32'h777F; //Timeout
reg_out[1] <=  32'b0000_0000_0000_0000_0000_0000_0000_0001; //Clock div 
//reg_out[2] <=  32'h211; //cmd_setting_reg
//reg_ou1t3] <=  32'b0000_0000_0000_0000_0000_0000_0000_0001; //argument_reg

reg_out[2] <=  32'h0; //System
reg_out[3] <=  32'h0; //card
reg_out[4] <=  128;
reg_out[5] <=  135248;

adr_out[0] <=  32'b0000_0000_0000_0000_0000_0000_0010_1100;
adr_out[1] <=  32'b0000_0000_0000_0000_0000_0000_0100_1100;
//adr_out[2] <=  32'b0000_0000_0000_0000_0000_0000_0000_0100;
//adr_out[3] <=  32'b0000_0000_0000_0000_0000_0000_0000_0000;

adr_out[2] <=  32'h60;
adr_out[3] <=  32'h60;
adr_out[4] <=  32'h80;
adr_out[5] <=  32'h80;


//adr_out[2] <=  32'h80;
//adr_out[3] <=  32'h80;
//adr_out[4] <=  32'h80;
//adr_out[5] <=  32'h80;

#5 ->reset_trigger;
end

    reg [31:0]tempo;

 initial begin 
    forever begin 
      @ (reset_trigger); 
      @ (posedge wb_clk_i); 
      wb_rst =1 ; 
      @ (posedge wb_clk_i); 
      wb_rst = 0; 
      wbs_sds_dat_i <= reg_out[out_cnt][31:0];
      wbs_sds_we_i <=1;
      wbs_sds_stb_i <=1;
      wbs_sds_cyc_i <=1;
      wbs_sds_adr_i <= adr_out[out_cnt];
      out_cnt = out_cnt +1;
      -> reset_done_trigger; 
    end 
  end

 always begin
 #5 wb_clk_i = !wb_clk_i;
 end
 
always @ (posedge wb_clk_i) begin
 if (out_cnt <=6) begin
  if (wbs_sds_ack_o == 1) begin
    wbs_sds_dat_i <=  reg_out[out_cnt][31:0];
    wbs_sds_we_i <= 1;
    wbs_sds_stb_i <= 1;
    wbs_sds_cyc_i <= 1;
    wbs_sds_adr_i <=adr_out[out_cnt];
     out_cnt = out_cnt +1;
  end  
 end
else begin
  wbs_sds_we_i <=0;
   wbs_sds_stb_i <=0;
   wbs_sds_cyc_i <=0;
   out_cnt = out_cnt +1;
 end
// if (out_cnt==76)
 //  out_cnt=2; 
 
 if (out_cnt==100) begin
   data_bluff_in<=4'b1011;
   bluff_in<=1;
 end  
  if (out_cnt==110) begin
   
   bluff_in<=0;
 end  

  if ((out_cnt>750) && (out_cnt<758)) begin
   tempo <=wbs_sds_dat_i;
    wbs_sds_we_i <= 1;
    wbs_sds_stb_i <= 1;
    wbs_sds_cyc_i <= 1;
    wbs_sds_adr_i <=8'h54;
     out_cnt = out_cnt +1;
 end
 
  
  if (out_cnt==758) begin
   wbs_sds_dat_i <=  0;
    wbs_sds_we_i <= 0;
    wbs_sds_stb_i <= 0;
    wbs_sds_cyc_i <= 0;
    wbs_sds_adr_i <=0;
 
 end
 
   if (out_cnt==4620) begin
     wbs_sds_dat_i <= 32'b0;
    wbs_sds_we_i <= 1;
    wbs_sds_stb_i <= 1;
    wbs_sds_cyc_i <= 1;
    wbs_sds_adr_i <=32'h54;
     out_cnt = out_cnt +1;
 
 end  
   if (out_cnt==4622) begin
     wbs_sds_dat_i <= 32'b0;
    wbs_sds_we_i <= 0;
    wbs_sds_stb_i <= 0;
    wbs_sds_cyc_i <= 0;
    wbs_sds_adr_i <=32'h54;
     out_cnt = out_cnt +1;
 
 end  
 
 
 
 

  
   
end
always @ (posedge sd_clk_pad_o) begin
   out_cnt3<=out_cnt3+1;
  
 if (out_cnt>115) begin
     i=i+1;
     if (i>3)
       i=0;
       bluff_in<=asd[i];
 end  
 
   if (out_cnt3>=104) begin
   
         data_bluff_in<=4'b0000;
 end  
if (out_cnt3>=105) begin
   
       data_bluff_in <= dat_mem[dat_mem_cnt];
        dat_mem_cnt=dat_mem_cnt+1;
 end
 
 if (out_cnt3==1151) 
  data_bluff_in <=4'b1111;
  if (out_cnt3==1152) 
   data_bluff_in <=4'b1111;
 if (out_cnt3==1153) 
   data_bluff_in <=4'b1110;
  if (out_cnt3==1154) 
   data_bluff_in <=4'b1110;
  if (out_cnt3==1155) 
   data_bluff_in <=4'b1111;
   if (out_cnt3==1156) 
   data_bluff_in <=4'b1110;
     if (out_cnt3==1157) 
   data_bluff_in <=4'b1111;
     if (out_cnt3>=1158) 
   data_bluff_in <=4'b1110; 

 
if (out_cnt3>=1185) begin
  data_bluff_in <=4'b1111; 
 out_cnt3<=0;
 dat_mem_cnt<=0;
 end
end

assign wbm_sdm_dat_i = sd_mem[wbm_sdm_adr_o];



always @ (posedge wb_clk_i) begin
 i2<=i2+1;
 if (wbm_sdm_cyc_o & wbm_sdm_stb_o &!wbm_sdm_we_o) begin
    if (cnta[i2]==1) 
      wbm_sdm_ack_i<=1; 

   
 end

 else if (wbm_sdm_cyc_o & wbm_sdm_stb_o &wbm_sdm_we_o) begin
    if (cnta[i2]==1) begin
      wbm_sdm_ack_i<=1; 
    in_mem[in_mem_cnt]<=  wbm_sdm_dat_o; 
    in_mem_cnt<=in_mem_cnt+1;
   end   
   
 end
 else begin
   wbm_sdm_ack_i <=0;
 end 
  `ifdef TX_ERROR_TEST
 if ((out_cnt >3000 ) && (out_cnt <3300 )) begin
   wbm_sdm_ack_i <=0;
  
end
 `endif
 
end

endmodule