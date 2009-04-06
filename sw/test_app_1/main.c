/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   :
// File Name                      : main.c
// Prepared By                    : 
// Project Start                  : 2008-07-01 


/*$$COPYRIGHT NOTICE*/
/******************************************************************************/
/*                                                                            */
/*                      C O P Y R I G H T   N O T I C E                       */
/*                                                                            */
/******************************************************************************/

// Copyright (c) ORSoC 2008 All rights reserved.

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

/*$$CHANGE HISTORY*/
/******************************************************************************/
/*                                                                            */
/*                         C H A N G E  H I S T O R Y                         */
/*                                                                            */
/******************************************************************************/

// Date   Version Description
//------------------------------------------------------------------------
// 080701 1.0 First version       marcus   



/*$$INCLUDE FILES*/
/******************************************************************************/
/*                                                                            */
/*                      I N C L U D E   F I L E S                             */
/*                                                                            */
/******************************************************************************/

#define INCLUDED_FROM_C_FILE

#include "orsocdef.h"
#include "board.h"
#include "spi.h"


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
/*                           C O N F I G U R E   S P I 2                      */
/******************************************************************************/

// Function           : SPI2_Config 
// Description        : Routine used to configure the SPI 2 interface
// Arguments          : None
// Returns            : None
// Globals            : None
// Side Effects       : 
// Configuration Data : spi.h 

void SPI2_Config()
{   
    uint32 ctrl_word; 
    REG32(SPI2_DIVIDER)  =  SPI2_DIV_BIT;   // Set SPI clock divider
    ctrl_word = (0 
                 | CTRL_ASS     // When set will generate a slave select automatically
                 | CTRL_CHAR_LEN(SPI2_REG_LEN)  // Number of bits to transfer
                 | CTRL_Rx_NEG      // Master input slave output signal will change
                                    // on negative SCLK.   
                );
    REG32(SPI2_CTRL)   = ctrl_word; 
    REG32(SPI2_SS)     = 0x1;   // Slave select line 1 set. If the ASS bit is set
          // setting this bit will drive the slave select output
          // to the active state during the duration of the file
          // transfer.
 }



/******************************************************************************/
/*                           C O N F I G U R E   S P I 3                      */
/******************************************************************************/

// Function           : SPI3_Config (Flash communication)
// Description        : Routine used to configure the SPI 3 interface
// Arguments          : None
// Returns            : None
// Globals            : None
// Side Effects       :
// Configuration Data : spi.h 

void SPI3_Config()
{   
    uint32 ctrl_word;
 
    REG32(SPI3_DIVIDER)  =  SPI3_DIV_BIT; // Set SPI clock divider
    ctrl_word = (0 
                 | CTRL_ASS     // When set will generate a slave select automatically
                 | CTRL_CHAR_LEN(SPI3_REG_LEN)  // Number of bits to transfer
                 | CTRL_Tx_NEG      // Master output slave input signal will change
                                    // on negative SCLK.   
                );

    REG32(SPI3_CTRL)   = ctrl_word; 
    REG32(SPI3_SS)     = 0x1;   // Slave select line 1 set. If the ASS bit is set
          // setting this bit will drive the slave select output
          // to the active state during the duration of the file
          // transfer.
}



/******************************************************************************/
/*                S P I 2   S E N D / R E C E I V E  D A T A                  */
/******************************************************************************/

// Function           : SPI2_Send_Receive_Data
// Description        : Routine used to transmit/receive SPI data
// Arguments          : SPI transmitt data
// Returns            : Data from SPI receive register
// Globals            : NONE
// Configuration Data : spi.h 
// Calling            : receive_data  = (uint16)SPI2_Send_Receive_Data(send_data);

uint32 SPI2_Send_Receive_Data(uint32 transmit_data)
{
   uint32 ctrl_word;

   REG unsigned long no_response = 0;
   REG32(SPI2_TX0)   = transmit_data;   // Put your data in tx reg
   REG32(SPI2_CTRL)  |= SPI_CTRL_GO;    // Start the transfer |= or
   while(REG32(SPI2_CTRL) & SPI_CTRL_BSY) // Do the transmit
   {
     if(no_response++ >= MAX_SPI_WAIT) {
     break; }  
   }
   return(REG32(SPI2_DR0));     // Return receive reg

} 



/******************************************************************************/
/*                S P I 3   S E N D / R E C E I V E  D A T A                  */
/******************************************************************************/

// Function             : SPI3_Send_Receive_Data
// Description          : Routine used to transmit/receive data
// Arguments            : SPI transmitt data
// Returns              : Data from SPI receive register
// Globals              : NONE
// Side Effects         :
// Configuration Data   : spi.h 
// Calling              : receive_data  = (uint16)SPI3_Send_Receive_Data(send_data);

uint32 SPI3_Send_Receive_Data(uint32 transmitt_data)
{
   uint32 ctrl_word;

   REG unsigned long no_response = 0;
   REG32(SPI3_TX0)   = transmitt_data;    // Put your data in tx reg
   REG32(SPI3_CTRL)  |= SPI_CTRL_GO;      //Start the transfer |= or
   while(REG32(SPI3_CTRL) & SPI_CTRL_BSY) // Do the transmit
   {
     if(no_response++ >= MAX_SPI_WAIT) {
     break; }  
   }

   return(REG32(SPI3_DR0));     // Return receive reg

 } 



/******************************************************************************/
/*                           G P I O   W  R I T E                             */
/******************************************************************************/

// Write to the GPIO (32 bits)

void GPIO_Write(uint32 GPIO_data)
{   
   REG32(GPIO_BASE + RGPIO_OUT) = GPIO_data;
}



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
   uint32      error_counter;
   uint32      error_report_offset;
   
   error_counter = 0;
   error_report_offset = 0x2000;
   
   range      = 0x100;       //0x100;
   adr_offset = 0x00010000;  // External memory offset
  
   for (i=0x0; i < range; i=i+4) {
      REG32(adr_offset + i)   = (adr_offset + i);
   }

   for (i=0x0; i < range; i=i+4) {
     read = REG32(adr_offset + i);
     if (read != (adr_offset + i)) {
       GPIO_Write(0x55);       
       while(TRUE){} //ERROR                                  
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

void Start()
{
  uint32 i;

  // Configure GPIO
  REG32(GPIO_BASE + RGPIO_OE)   = 0xff;  // bit0-7 = outputs, bit8-31 = inputs
  REG32(GPIO_BASE + RGPIO_INTE) = 0x0;   // Disable interrupts from GPIO

  GPIO_Write(0x1);

  // Setup SPI 2 
  SPI2_Config();

  GPIO_Write(0x2);
  
  // Setup SPI 3 
  SPI3_Config();
  
  GPIO_Write(0x3);

  // Send 0x22 on SPI 2
  SPI2_Send_Receive_Data(0x22);
  
  GPIO_Write(0x4);
  
  // Send 0x33 on SPI 3
  SPI3_Send_Receive_Data(0x33);

  GPIO_Write(0x5);
  
  // Tests a few external SDRAM addresses
  Write_External_SDRAM_1();

  
  while(TRUE) {

    GPIO_Write(0xFF);  // Test finished
   
  }


}
