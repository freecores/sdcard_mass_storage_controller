ifndef CROSS_COMPILE
#CROSS_COMPILE = or32-elf-
#Changed 2007-11-17 svenand
CROSS_COMPILE = or32-uclinux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
OBJ = $(CROSS_COMPILE)objdump
OBJC = $(CROSS_COMPILE)objcopy
endif

#entry point for program
#0 for sdram, 0x93... for internal SRAM
#LD_ENTRY_POINT=0x00000100
LD_ENTRY_POINT=0x01000100

CFLAGS  = -g -c -Wunknown-pragmas -mhard-mul -msoft-div -msoft-float 
LD_FLAGS= --stats -Tram.ld -e ${LD_ENTRY_POINT}
INCL    = board.h spr_defs.h 
OBJECTS = BootReset.o main.o uart.o sd_controller.o
LIBS    =

export CROSS_COMPILE

all: boot.or32 System.map

boot.or32: $(OBJECTS) Makefile  
	@printf "\r\n\t--- Linking ---\r\n"
	$(LD) -Map System.map -Bstatic $(OBJECTS) $(LIBS) $(LD_FLAGS) -o $@
	@$(NM) $< | \
		grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
		sort >> System.map
		$(OBJ) -x -d -S boot.or32 >> System.map

%.o:%.S $(INCL) Makefile
	@printf "\r\n\t--- Assembling $(<) ---\r\n"
	$(CC) $(CFLAGS) -o $@ $(<) 

%.o:%.c $(INCL) Makefile
	@printf "\r\n\t--- Compiling $(<) ---\r\n"
	$(CC) $(CFLAGS) -o $@ $(<) 


#########################################################################

clean:
	@rm -f *.o *.ihex *.BIN boot.* System.map *.vmem *.bin *.asm *~

distclean: clean
	find . -type f \
		\( -name .depend -o -name '*.srec' -o -name '*.bin' \
		-o -name '*.pdf' \) \
		-print | xargs rm -f
	rm -f $(OBJS) *.bak tags TAGS
	rm -fr *.*~


