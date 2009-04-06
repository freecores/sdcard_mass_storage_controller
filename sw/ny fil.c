******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : Development Board Debugger Example 
// File Name                      : main.c
// Prepared By                    : jb
// Project Start                  : 2009-01-01


/*$$COPYRIGHT NOTICE*/
/******************************************************************************/
/*                                                                            */
/*                      C O P Y R I G H T   N O T I C E                       */
/*                                                                            */
/******************************************************************************/

// Copyright (c) ORSoC 2009 All rights reserved.

// The information in this document is the property of ORSoC.
// Except as specifically authorized in writing by ORSoC, the receiver of
// this document shall keep the information contained herein confidential and
// shall protect the same in whole or in part thereof from disclosure and
// dissemination to third parties. Disclosure and disseminations to the receiver's
// employees shall only be made on a strict need to know basis.


/*$$DESCRIPTION*/
/******************************************************************************/
/*                                                                            */
/*                           D E S C R I P T I O N                            */
/*                                                                            */
/******************************************************************************/

// Perform some simple functions, used as an example when first using the 
// debug cable and proxy with GDB.

/*$$CHANGE HISTORY*/
/******************************************************************************/
/*                                                                            */
/*                         C H A N G E  H I S T O R Y                         */
/*                                                                            */
/******************************************************************************/

// Date		Version	Description
//------------------------------------------------------------------------
// 090101	1.0	First version				jb

/*$$INCLUDE FILES*/
/******************************************************************************/
/*                                                                            */
/*                      I N C L U D E   F I L E S                             */
/*                                                                            */
/******************************************************************************/

#define INCLUDED_FROM_C_FILE

#include "orsocdef.h"
#include "board.h"
#include "uart.h"
#include "sd_controller.h"
/*$$PRIVATE MACROS*/
/******************************************************************************/
/*                                                                            */
/*                      P R I V A T E   M A C R O S                           */
/*                                                                            */
/******************************************************************************/

/*$$GLOBAL VARIABLES*/
/******************************************************************************/
/*                                                                            */
/*                   G L O B A L   V A R I A B L E S                          */
/*                                                                            */
/******************************************************************************/

/*$$PRIVATE VARIABLES*/
/******************************************************************************/
/*                                                                            */
/*                  P R I V A T E   V A R I A B L E S                         */
/*                                                                            */
/******************************************************************************/


/*$$FUNCTIONS*/
/******************************************************************************/
/*                                                                            */
/*                          F U N C T I O N S                                 */
/*                                                                            */
/******************************************************************************/


/******************************************************************************/
/*                        W R I T E  T O EXTERNAL SDRAM 1                     */
/******************************************************************************/

// Write to External SDRAM  
void Write_External_SDRAM_1(void)
{   
   uint32      i;
   uint32      read;
   uint32      range;
   uint32      adr_offset;

   range      = 0x7ff;        // Max range: 0x7fffff
   adr_offset = 0x00000000;  // External memory offset
   
   for (i=0x0; i < range; i=i+4) {
      REG32(adr_offset + i)   = (adr_offset + i);
   }

   for (i=0x0; i < range; i=i+4) {
     read = REG32(adr_offset + i);
     if (read != (adr_offset + i)) {
       while(TRUE){            //ERROR=HALT PROCESSOR 
       }       
     }
   }
}


/*$$EXTERNAL EXEPTIONS*/
/******************************************************************************/
/*                  E X T E R N A L   E X E P T I O N S                       */
/******************************************************************************/


void external_exeption()
{      
  REG uint8 i;
  REG uint32 PicSr,sr;

}
 
/*$$MAIN*/
/******************************************************************************/
/*                                                                            */
/*                       M A I N   P R O G R A M                              */
/*                                                                            */
/******************************************************************************/
typdef struct {
unsigned int RCA;
unsigned long Voltage_window;
bool HCS;
bool Active;
bool phys_spec_2_0;
sd_card_cid * cid_reg;
sd_card_csd * csd_reg;

} sd_card;


typdef struct {
unsigned short int MID;
unsigned char  OID[2];
unsigned char  PNM[5];
unsigned short int BCD; 
unsigned short int MDT;
unsigned long  PSN;
} sd_card_cid;

typdef struct { 


} sd_card_csd;


typdef struct {
unsigned  int CMDI:6;
unsigned  int CMDT:2;
unsigned  int DPS:1;
unsigned  int CICE:1;
unsigned  int CRCE:1;
unsigned  int  RSVD:1;
unsigned  int RTS:2;
} sd_controller_csr;


sd_card* sd_controller_init ()
{
sd_card dev;

return dev;

}


send_cmd (unsigned long *arg, sd_controller_csr *set)
{


}

void Start()
{
   sd_card *sd_card_0;
   *sd_card_0 = sd_controller_init();
   
   
  volatile unsigned long rtn_reg=0;
   volatile  unsigned long rtn_reg1=0;
  
  unsigned long a=0x80000000;
  unsigned long b=0x0001;
  
  unsigned long test=0x0000F0FF;
  // Send out something  over UART
  uart_init();
  if ( (a & b) == 0x80000000)
      uart_print_str("Hello mask\n");
  

  uart_print_str("Hello World5!\n");
  uart_print_str("Echoing received chars...\n\r");
   uart_print_str("Print long \n");
     
	 uart_print_str("Status Reg \n");
     rtn_reg= REG32(SD_CONTROLLER_BASE+SD_STATUS) ;
    uart_print_long(rtn_reg);
    uart_print_str("\n");
   
    uart_print_str("Normal status Reg \n");
    rtn_reg= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS );
   uart_print_long(rtn_reg);
   uart_print_str("\n");

    REG32(SD_CONTROLLER_BASE+SD_TIMEOUT)=0x0000007F;
	
	/* CMD08
		  REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000081A;
     REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x000001AA;
	 
	 
   
	rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
	 while ( (rtn_reg1 & b) !=1){
	     rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
    }	 
		 


	     uart_print_str("1Response inc");
	     rtn_reg= REG32(SD_CONTROLLER_BASE+SD_RESP1) ;
    uart_print_long(rtn_reg);
    uart_print_str("\n");
	
 */
	 REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000;
       REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x000;
		 REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000;
  
	
    rtn_reg=0;
    while ((rtn_reg & 0x80000000) != 0x80000000)
	{
	
	   REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000371A;
       REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x0000FFFF;
	   REG32(SD_CONTROLLER_BASE+SD_ERROR_INT_STATUS) =0;
	   rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
	  while ( (rtn_reg1 & b) !=1){
	     rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
      }	 
		 //Put some CRC, timeout and indexcheck here
		 
		 
     REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x0000291A;
     REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x00000000;
    	rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
	 while ( (rtn_reg1 & b) !=1){
	     rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
      }	
	  
   
	   rtn_reg= REG32(SD_CONTROLLER_BASE+SD_RESP1) ;
	
	}

	   
    rtn_reg=0;
   
	    REG32(SD_CONTROLLER_BASE+SD_ERROR_INT_STATUS)=0;
	   
    REG32(SD_CONTROLLER_BASE+SD_COMMAND) =0x00000209;
     REG32(SD_CONTROLLER_BASE+SD_ARG)   =0x00000000;
    	rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
	 while ( (rtn_reg1 & b) !=1){
	     rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_NORMAL_INT_STATUS) ;
      }	
	  
  uart_print_str("cid crc");
       rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_ERROR_INT_STATUS) ;
	   uart_print_long(rtn_reg1);
	 uart_print_str("\n");
	 
	   uart_print_str("r1 ");
       rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_RESP1) ;
	   uart_print_long(rtn_reg1);
	 uart_print_str("\n");
	
		   uart_print_str("r2 ");
       rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_RESP2) ;
	   uart_print_long(rtn_reg1);
	 uart_print_str("\n");
	 
	 	   uart_print_str("r3 ");
       rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_RESP3) ;
	   uart_print_long(rtn_reg1);
	 uart_print_str("\n");
	 
	 	   uart_print_str("r4 ");
       rtn_reg1= REG32(SD_CONTROLLER_BASE+SD_RESP4) ;
	   uart_print_long(rtn_reg1);
	 uart_print_str("\n");
	   
	     
 
 
  while(1){
  
  }


}


