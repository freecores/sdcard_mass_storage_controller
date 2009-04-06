/*****************************************************************************
* COPYRIGHT(C)    FLEXTRONICS INTERNATIONAL
******************************************************************************
*
* PROJECT:     Arnold
*
* FILENAME:    spi.c
*
* $Revision:: 1                                                              $ 
*
* DESCRIPTION:    
*
* PREPARED BY: Jonas Rosén  
*
* DATE:        2004-06-28                                 
*
******************************************************************************
* REVISION HISTORY: 
*****************************************************************************/
/* $Log:: /ELUD_ELUA/FPGA2/spi.c                                             $            
 * 
 * 1     06-11-27 14:02 Knansand
 * LCA test ver 10
 * 																   
 * 2     04-06-28 15:01 Knajrose
 * Don't hang forever in while case.
 *
 * 3     05-07-12 10:01 knamsnil
 * TX_Neg enabled, signal is changed on falling edge instead.
 * This creates stable timing when accessing QDASL:s
*/

/*********************************************************************
*   INCLUDE FILES
**********************************************************************/
#include "board.h"
#include "spi.h"	

/*********************************************************************
*   PRIVATE MACROS
**********************************************************************/
#define MAX_SPI_WAIT 10000

/*********************************************************************
*   PUBLIC VARIABLES
**********************************************************************/

/*********************************************************************
*   PRIVATE VARIABLES
**********************************************************************/

/*********************************************************************
*   PRIVATE FUNCTIONS
**********************************************************************/

/*********************************************************************
*   EXTERNAL VARIABLES
**********************************************************************/

/*********************************************************************
*   EXTERNAL FUNCTIONS
**********************************************************************/

/*********************************************************************
*
* Function:		 vSPI_Config
*
* Description:	 Configure the SPI
*
* Arguments:	 SPI number
*
* Returns:		 NONE
*
* Globals:		 NONE
*
* Side Effects:
*
**********************************************************************/

void vSPI_Config(unsigned char u8SpiNum)
{   
  REG32(OR32SPI_DIVIDER(u8SpiNum)) 	=  SPI_DIV_BIT;   /*Set CCKL to 2MHz*/	 // 0x400;//
  REG32(OR32SPI_CTRL(u8SpiNum)) 	=  0x00000608;	//408 here!!!! /*Set charlen = 8 byte and Rx_Neg*/
  //REG32(OR32SPI_SS(u8SpiNum)) 	=  0x00000001;   
}

/*********************************************************************
*
* Function:		 u32uwire_access
*
* Description:	 routine used to transmit read the SPI
*
* Arguments:	 SPI number and data
*
* Returns:		 Data from SPI receive rgister
*
* Globals:		 NONE
*
* Side Effects:
*
**********************************************************************/
unsigned char uwire_access(unsigned char u8SpiNum, unsigned char data)
{
  REG unsigned long error=0;

  REG32(OR32SPI_TX0(u8SpiNum)) = data;	    		   /*Put your data in tx reg*/
  REG32(OR32SPI_CTRL(u8SpiNum)) |= SPI_CTRL_GO;  
   	     
  while(REG32(OR32SPI_CTRL(u8SpiNum)) & SPI_CTRL_BSY) /*Do the transmit*/
  {
    if(error++ >= MAX_SPI_WAIT)
      break;   
  }

  return(REG32(OR32SPI_DR0(u8SpiNum)) & 0x000000FF); 	   /*Return receivereg*/
} 
