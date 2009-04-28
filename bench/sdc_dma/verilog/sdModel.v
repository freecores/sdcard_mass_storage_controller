//`include "timescale.v"
`define tTLH 10 //Clock rise time
`define tHL 10 //Clock fall time
`define tISU 6 //Input setup time
`define tIH 0 //Input hold time
`define tODL 14 //Output delay

`define BLOCKSIZE 512
`define MEMSIZE 1000
`define BLOCK_BUFFER_SIZE 1
`define TIME_BUSY 64

module sdModel(
  input sdClk,
  tri cmd,
  tri [3:0] dat
  
);


reg oeCmd;
reg oeDat;
reg cmdOut;
reg datOut;

reg [5:0] lastCMD;
reg cardIdentificationState;

assign cmd = oeCmd ? cmdOut : 1'bz;
assign dat = oeDat ? datOut : 4'bz;


reg [`MEMSIZE:0] FLASHmem [0:`BLOCKSIZE-1];
reg  [`BLOCK_BUFFER_SIZE-1:0] indatabuffer [0:`BLOCKSIZE-1];

reg [46:0]inCmd;
reg [5:0]cmdRead;
reg [7:0] cmdWrite;
reg crcIn;
reg crcEn;
reg crcRst;
reg [31:0] CardStatus;
reg [15:0] RCA;
reg [31:0] OCR;
reg [120:0] CID;
reg Busy; //0 when busy
wire [6:0] crcOut;
 
reg [3 :0]CurrentState; 
 
`define RCASTART 16'h20
`define OCRSTART 32'hff8000
`define STATUSSTART 32'h0
`define CIDSTART 128'h00ffffffddddddddaaaaaaaa99999999  //Just some random data not really usefull anyway 

`define outDelay 4 
reg [2:0] outDelayCnt;
parameter SIZE = 10;
parameter CONTENT_SIZE = 40;
parameter 
    IDLE   =  10'b0000_0000_01,
    READ_CMD   =  10'b0000_0000_10,
    ANALYZE_CMD	    =  10'b0000_0001_00,
    SEND_CMD	    =  10'b0000_0010_00;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;

reg ValidCmd;
reg inValidCmd;

reg [7:0] response_S;
reg [135:0] response_CMD;
integer responseType;
CRC_7 CRC_7( 
crcIn,
crcEn,
sdClk,
crcRst,
crcOut);
reg appendCrc;
reg [5:0] startUppCnt;

//Card initinCMd
initial $readmemh("FLASH.txt",FLASHmem);

integer k;
initial begin
	$display("Contents of Mem after reading data file:");
	for (k=0; k<10; k=k+1) $display("%d:%h",k,FLASHmem[k]);
end
reg qCmd; 
reg [2:0] crcCnt;
initial begin 
  cardIdentificationState<=1;
  state<=IDLE;
  Busy<=0;
  oeCmd<=0;
  crcCnt<=0;
  qCmd<=1;
  oeDat<=0;
  cmdOut<=0;
  cmdWrite<=0;
  datOut<=0;
  inCmd<=0;
  responseType=0;
  crcIn<=0;
  response_S<=0;
  crcEn<=0;
  crcRst<=0;
  cmdRead<=0;
  ValidCmd<=0;
  inValidCmd=0;
  appendCrc<=0;
  RCA<= `RCASTART;
  OCR<= `OCRSTART;
  CardStatus <= `STATUSSTART;
  CID<=`CIDSTART;
  response_CMD<=0;
  outDelayCnt<=0;
end

//CARD logic

always @ (state or cmd or cmdRead or ValidCmd or inValidCmd or cmdWrite or outDelayCnt)
begin : FSM_COMBO
 next_state  = 0;   
case(state)  
IDLE: begin
   if (!cmd) 
     next_state = READ_CMD;
  else
     next_state = IDLE; 
end  
READ_CMD: begin
  if (cmdRead>= 47) 
     next_state = ANALYZE_CMD;
  else
     next_state =  READ_CMD; 
 end
 ANALYZE_CMD: begin
  if ((ValidCmd  )   && (outDelayCnt >= `outDelay ))
     next_state = SEND_CMD;
  else if (inValidCmd)
     next_state =  IDLE; 
 else
    next_state =  ANALYZE_CMD; 
 end 
 SEND_CMD: begin
    if (cmdWrite>= response_S) 
     next_state = IDLE;
  else
     next_state =  SEND_CMD; 
 
 end
 
 
 endcase
end

always @ (posedge sdClk  )
begin : FSM_SEQ
    state <= next_state;
 
end


always @ (posedge sdClk) begin
 startUppCnt<=startUppCnt+1;
 OCR[31]<=Busy;
 if (startUppCnt == `TIME_BUSY)
   Busy <=1;   
end


always @ (posedge sdClk) begin
   qCmd<=cmd;
end

//read data and cmd on rising edge
always @ (posedge sdClk) begin
 case(state)
   IDLE: begin
      
      crcIn<=0;
      crcEn<=0;
      crcRst<=1;
      oeCmd<=0;
      oeDat<=0;
      cmdRead<=0;
      appendCrc<=0;
      ValidCmd<=0;
      inValidCmd=0;
      cmdWrite<=0;
      crcCnt<=0;
      response_CMD<=0;
      response_S<=0;
      outDelayCnt<=0;
      responseType=0;      
    end
   READ_CMD: begin //read cmd
      crcEn<=1;
      crcRst<=0;
      crcIn <= #`tIH qCmd; 
      inCmd[47-cmdRead]  <= #`tIH qCmd;    
      cmdRead <= #1 cmdRead+1;
      if (cmdRead >= 40) 
         crcEn<=0;
         
      if (cmdRead == 46) begin
          oeCmd<=1;
     cmdOut<=1;
      end
   end 
        
   ANALYZE_CMD: begin//check for valid cmd
   //Wrong CRC go idle
    if (inCmd[46] == 0) //start
      inValidCmd=1;
    else if (inCmd[7:1] != crcOut) begin
      inValidCmd=1;
      $fdisplay(sdModel_file_desc, "**sd_Model Commando CRC Error") ;
      $display(sdModel_file_desc, "**sd_Model Commando CRC Error") ;
    end  
    else if  (inCmd[0] != 1)  begin//stop 
      inValidCmd=1;
      $fdisplay(sdModel_file_desc, "**sd_Model Commando No Stop Bit Error") ;
      $display(sdModel_file_desc, "**sd_Model Commando No Stop Bit Error") ;
    end  
    else begin
      
      case(inCmd[45:40])
        0 : response_S <= 0;
        2 : response_S <= 136;
        3 : response_S <= 48;
        7 : response_S <= 48;
        8 : response_S <= 0;
        14 : response_S <= 0;
        17 : response_S <= 48;
        24 : response_S <= 48;
        33 : response_S <= 48;
        55 : response_S <= 48;
        41 : response_S <= 48;        
    endcase
         case(inCmd[45:40])
        0 : begin 
            response_CMD <= 0;
            cardIdentificationState<=1;
            ResetCard;
        end    
        2 : begin
         if (lastCMD != 41 && outDelayCnt==0) begin
               $fdisplay(sdModel_file_desc, "**Error in sequnce, ACMD 41 should precede 2 in Startup state") ;
               $display(sdModel_file_desc, "**Error in sequnce, ACMD 41 should precede 2 in Startup state") ;
               CardStatus[3]<=1;
            end  
        response_CMD[127:8] <= CID;
        appendCrc<=0; 
        CardStatus[12:9] <=2;
        end
        3 :  begin 
           if (lastCMD != 3 && outDelayCnt==0 ) begin
               $fdisplay(sdModel_file_desc, "**Error in sequnce, CMD 2 should precede 3 in Startup state") ;
               $display(sdModel_file_desc, "**Error in sequnce, CMD 2 should precede 3 in Startup state") ;
               CardStatus[3]<=1;
            end  
        response_CMD[127:112] <= RCA[15:0] ;
        response_CMD[111:96] <= CardStatus[15:0] ;
        appendCrc<=1;
        CardStatus[12:9] <=3;
        cardIdentificationState<=0;
        end        
        8 : response_CMD[127:96] <= 0; //V1.0 card
        17 : response_CMD[127:96]<= 48;
        24 : response_CMD[127:96] <= 48;
        33 : response_CMD[127:96] <= 48;
        55 : 
        begin
          response_CMD[127:96] <= CardStatus ;         
          CardStatus[5] <=1;      //Next CMD is AP specific CMD
          appendCrc<=1;         
        end 
        41 : 
        begin  
         if (cardIdentificationState) begin
            if (lastCMD != 55 && outDelayCnt==0) begin
               $fdisplay(sdModel_file_desc, "**Error in sequnce, CMD 55 should precede 41 in Startup state") ;
               $display(sdModel_file_desc, "**Error in sequnce, CMD 55 should precede 41 in Startup state") ;
               CardStatus[3]<=1;
            end
            else begin
             responseType=3; 
             response_CMD[127:96] <= OCR;   
             appendCrc<=0;
             CardStatus[5] <=0;  
            if (Busy==1)
              CardStatus[12:9] <=1;
           end 
        end    
       end   
        
    endcase
     ValidCmd<=1;  
     crcIn<=0;
     
     outDelayCnt<=outDelayCnt+1;
     if (outDelayCnt==`outDelay)       
       crcRst<=1;
     oeCmd<=1;
     cmdOut<=1;
     response_CMD[135:134] <=0;
    
    if (responseType != 3)
       response_CMD[133:128] <=inCmd[45:40];
    if (responseType == 3)
       response_CMD[133:128] <=6'b111111;
       
     lastCMD <=inCmd[45:40];
    end
   end
   
   
   
 endcase    
end 

always @ ( negedge sdClk) begin
 case(state)

SEND_CMD: begin
     crcRst<=0;
     crcEn<=1;
    cmdWrite<=cmdWrite+1;    
    if (response_S!=0)
     cmdOut<=0;   
   else
      cmdOut<=1;  
       
    if ((cmdWrite>0) &&  (cmdWrite < response_S-8)) begin
      cmdOut<=response_CMD[135-cmdWrite];
      crcIn<=response_CMD[134-cmdWrite];
      if (cmdWrite >= response_S-9)
       crcEn<=0;
    end
   else if (cmdWrite!=0) begin
     crcEn<=0;
     cmdOut<=crcOut[6-crcCnt];
     crcCnt<=crcCnt+1; 
      if (responseType == 3)
           cmdOut<=1;
   end
  if (cmdWrite == response_S-1)
    cmdOut<=1;
     
  end
 endcase
end

integer sdModel_file_desc;
initial
begin
  sdModel_file_desc = $fopen("log/sd_model.log");
  if (sdModel_file_desc < 2)
  begin
    $display("*E Could not open/create testbench log file in ../log/ directory!");
    $finish;
  end
end

task ResetCard; //  MAC registers
begin
  cardIdentificationState<=1;
  state<=IDLE;
  Busy<=0;
  oeCmd<=0;
  crcCnt<=0;
  qCmd<=1;
  oeDat<=0;
  cmdOut<=0;
  cmdWrite<=0;
  datOut<=0;
  inCmd<=0;
  responseType=0;
  crcIn<=0;
  response_S<=0;
  crcEn<=0;
  crcRst<=0;
  cmdRead<=0;
  ValidCmd<=0;
  inValidCmd=0;
  appendCrc<=0;
  RCA<= `RCASTART;
  OCR<= `OCRSTART;
  CardStatus <= `STATUSSTART;
  CID<=`CIDSTART;
  response_CMD<=0;
  outDelayCnt<=0;
end
endtask  
  

endmodule
