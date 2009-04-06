/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   :  
// File Name                      : spi.h
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


/*$$DEFINES*/
/******************************************************************************/
/*                                                                            */
/*                          S P I   D E F I N E S                             */
/*                                                                            */
/******************************************************************************/

      
#define SPI2_BASE     0xb1000000 
#define SPI2_DR0      SPI2_BASE               // Data Receive bit 0 - 31
#define SPI2_DR1      SPI2_BASE + 0x00000004  // Data Receive bit 32 - 63
#define SPI2_DR2      SPI2_BASE + 0x00000008  // Data Receive bit 64 - 95
#define SPI2_DR3      SPI2_BASE + 0x0000000C  // Data Receive bit 96 - 127
#define SPI2_TX0      SPI2_BASE               // Data Transmit bit 0 - 31
#define SPI2_TX1      SPI2_BASE + 0x00000004  // Data Transmit bit 32 - 63
#define SPI2_TX2      SPI2_BASE + 0x00000008  // Data Transmit bit 64 - 95
#define SPI2_TX3      SPI2_BASE + 0x0000000C  // Data Transmit bit 96 - 127

#define SPI2_CTRL     SPI2_BASE + 0x00000010  // Control and Status Reg
#define SPI2_DIVIDER  SPI2_BASE + 0x00000014  // Clock Divider Register
#define SPI2_SS       SPI2_BASE + 0x00000018  // Slave Select Register



#define SPI3_BASE     0xb2000000 
#define SPI3_DR0      SPI3_BASE               // Data Receive bit 0 - 31
#define SPI3_DR1      SPI3_BASE + 0x00000004  // Data Receive bit 32 - 63
#define SPI3_DR2      SPI3_BASE + 0x00000008  // Data Receive bit 64 - 95
#define SPI3_DR3      SPI3_BASE + 0x0000000C  // Data Receive bit 96 - 127
#define SPI3_TX0      SPI3_BASE               // Data Transmit bit 0 - 31
#define SPI3_TX1      SPI3_BASE + 0x00000004  // Data Transmit bit 32 - 63
#define SPI3_TX2      SPI3_BASE + 0x00000008  // Data Transmit bit 64 - 95
#define SPI3_TX3      SPI3_BASE + 0x0000000C  // Data Transmit bit 96 - 127

#define SPI3_CTRL     SPI3_BASE + 0x00000010  // Control and Status Reg
#define SPI3_DIVIDER  SPI3_BASE + 0x00000014  // Clock Divider Register
#define SPI3_SS       SPI3_BASE + 0x00000018  // Slave Select Register



/******************************************************************************/
/*              C O N T R O L   A N D   S T A T U S   R E G I S T E R S       */
/******************************************************************************/

#define SPI_CTRL_GO       1 << 8    
#define SPI_CTRL_BSY      1 << 8
#define CTRL_Rx_NEG       1 << 9
#define CTRL_Tx_NEG       1 << 10
#define CTRL_CHAR_LEN(a)  (a & 0x0000007f)
#define CTRL_LSB          1 << 11
#define CTRL_IE           1 << 12
#define CTRL_ASS          1 << 13 

#define SPI2_DIV_BIT      3       //
#define SPI3_DIV_BIT      4       //
#define MAX_SPI_WAIT      10000   // 
#define SPI2_REG_LEN      16      // 16 bits
#define SPI3_REG_LEN      16      // 16 bits

/*$$PUBLIC FUNCTIONS*/
/******************************************************************************/
/*                                                                            */
/*                     P U B L I C   F U N C T I O N S                        */
/*                                                                            */
/******************************************************************************/

void    vSPI_Config (unsigned char);
unsigned char uwire_access  (unsigned char, unsigned char);


