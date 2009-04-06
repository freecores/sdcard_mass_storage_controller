/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : 
// File Name                      : revision.c
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

// Date		Version	Description
//------------------------------------------------------------------------
// 080701	1.0	First version				marcus

/*$$DEFINES*/
/******************************************************************************/
/*                                                                            */
/*                            D E F I N E S                                   */
/*                                                                            */
/******************************************************************************/


/*$$TYPEDEFS*/
/******************************************************************************/
/*                                                                            */
/*                                 T Y P E D E F S                            */
/*                                                                            */
/******************************************************************************/


typedef struct load_info
{
  unsigned long boardtype;         // BOOT_ID
  unsigned long decompressed_crc;  // Filled in by ext. program for generating SRecord file
  unsigned long compressed_crc;    // Filled in by ext. program for generating SRecord file
  unsigned long decompressed_size; // Filled in by ext. program for generating SRecord file
  unsigned long compressed_size;   // Filled in by ext. program for generating SRecord file
  unsigned long extra_pad[23];     // Extra padding
  unsigned char boardName[12];     //
  unsigned char caaName[20];       //
  unsigned char caaRev[8];         //
  unsigned char addInfo[16];       //

} LOAD_INFO;


/*$$PUBLIC VARIABLES*/
/******************************************************************************/
/*                                                                            */
/*                          P U B L I C   V A R I A B L E S                   */
/*                                                                            */
/******************************************************************************/


LOAD_INFO load_info_values = {
    
  0x00000D90,
  0x930000E8,
  0x40000000,
  0x930000E4,
  0x00000001,
  0x930000E8,
  0x50000000,
  0x930000E4,
  0x00000001,
  0x930000E8,
  0x60000000,
  0x930000E4,
  0x00000001,
  0x930000E4,
  0x00000001,
  0x930000E8,
  0x7E000023,
  0x930000E4,
  0x00000001,
  0x930000A0,
  0xC03E0310,
  0x00000000,
  0xDEADBEEF,
  0xDEADBEEF,
  0xDEADBEEF,
  0xDEADBEEF,
  0xDEADBEEF,
  0xDEADBEEF,
  
  "BOOT        ",              // Boardname, must be fixed 12 bytes
  "                    ",      // Add. info, must be fixed 20 bytes
  "R1A     ",                  // Revision , must be fixed 8 bytes
  "                "           // Add. info, must be fixed 16 bytes

};

