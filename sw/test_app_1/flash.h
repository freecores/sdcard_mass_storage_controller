/*****************************************************************************
* COPYRIGHT(C)    FLEXTRONICS INTERNATIONAL
******************************************************************************
*
* PROJECT:     Arnold
*
* FILENAME:    flash.h
*
* $Revision:: 1                                                              $ 
*
* DESCRIPTION:    
*
* PREPARED BY: Jonas Rosén  
*
* DATE:        2004-04-23                                 
*
******************************************************************************
*
* The flash memory map looks like following:
* = SECTOR =  ======= RANGE =========  === SIZE  ===  ===  COMMENT ===
* SECTOR_SA0  0xF0000000 - 0xF0003FFF  16 384  bytes  Boot code
* SECTOR_SA1  0xF0004000 - 0xF0007FFF  16 384  bytes  Strings, parameters etc.
* SECTOR_SA3  0xF0008000 - 0xF007FFFF  425 984 bytes  Application code
*
******************************************************************************
* REVISION HISTORY: 
*****************************************************************************/
/* $Log:: /ELUD_ELUA/FPGA2/flash.h                                           $            
 * 
 * 1     06-11-27 14:02 Knansand
 * LCA test ver 10
 * 
 * 7     04-06-08 12:32 Knajrose
 * Info added.
 * 
 * 6     04-05-17 13:41 Knajrose
 * Sectors updated!
 * 
 * 5     04-05-17 10:20 Knajrose
 * Boot and appl. sectors changed.
 * 
 * 4     04-04-27 10:50 Jolsson
 * struct changed.
 * 
 * 3     04-04-26 12:15 Jolsson
 * Macro ARNOLD_ID removed.
 * 
 * 2     04-04-23 15:19 Jolsson
 * Definitions for flash.
*/

#ifndef _FLASH_H
#define _FLASH_H


typedef struct FWDL_PROG_STR
{
  unsigned long ID;
  unsigned long decompressed_crc;
  unsigned long compressed_crc;
  unsigned long decompressed_size;
  unsigned long compressed_size;
  unsigned char str[240];
  void          (*prog_start)(); //Shall be at 0x?0000100 !

}fwdl_prog_str;


#define FLASH_AUTOSELECT  0x90
#define WRITE         0xA0
#define ERASE         0x80
#define ERASE_CHIP    0x10
#define FMODE_ENABLE  0x20
#define ERASE_SECTOR  0x30
#define AUTO_SELECT   0x90
#define READ_RESET    0xF0

#define VERIFY_OFF    0x00
#define VERIFY_ON     0x01

#define BOOT_START  SECTOR_SA0
#define BOOT_END    SECTOR_SA1
#define APPL_START  SECTOR_SA3
#define APPL_END    SECTOR_SA10

/* The flash AM29LV400B is bottom boot */
/*                  Sector base   Sector range  Size kB  */
/*                  ----------    ------------  -----    */
#define SECTOR_SA0  0x00000000 /* 00000h-03FFFh 16/8     */
#define SECTOR_SA1  0x00004000 /* 04000h-05FFFh  8/4     */
#define SECTOR_SA2  0x00006000 /* 06000h-07FFFh  8/4     */
#define SECTOR_SA3  0x00008000 /* 08000h-0FFFFh 32/16    */
#define SECTOR_SA4  0x00010000 /* 10000h-1FFFFh 64/32    */
#define SECTOR_SA5  0x00020000 /* 20000h-2FFFFh 64/32    */
#define SECTOR_SA6  0x00030000 /* 30000h-3FFFFh 64/32    */
#define SECTOR_SA7  0x00040000 /* 40000h-4FFFFh 64/32    */
#define SECTOR_SA8  0x00050000 /* 50000h-5FFFFh 64/32    */
#define SECTOR_SA9  0x00060000 /* 60000h-6FFFFh 64/32    */
#define SECTOR_SA10 0x00070000 /* 70000h-7FFFFh 64/32    */

#endif /* _FLASH_H */
