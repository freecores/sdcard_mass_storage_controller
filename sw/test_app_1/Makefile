ifndef CROSS_COMPILE
#CROSS_COMPILE = or32-elf-
CROSS_COMPILE = or32-uclinux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
OBJ = $(CROSS_COMPILE)objdump
OBJC = $(CROSS_COMPILE)objcopy
endif

CFLAGS  = -O2 -g -c -Wunknown-pragmas -mhard-mul -msoft-div -msoft-float 
LD_FLAGS= --stats -Tram.ld 
INCL    = board.h spr_defs.h spi.h
OBJECTS = BootReset.o main.o revision.o
LIBS    =

export	CROSS_COMPILE

all: boot.or32 boot.ihex System.map 

boot.or32: $(OBJECTS) Makefile  
	@printf "\r\n\t--- Linking ---\r\n"
	$(LD) -Map System.map -Bstatic $(OBJECTS) $(LIBS) $(LD_FLAGS) -o $@
	@$(NM) $< | \
		grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
		sort >> System.map
		$(OBJ) -x -d -S boot.or32 >> System.map

boot.ihex: boot.or32 Makefile
	@printf "\r\n\t--- Creating Ihex file: $@ ---\r\n"
	$(OBJC) -O ihex boot.or32 boot.ihex
	perl gen_memory_text.pl < boot.ihex > ../../sim/rtl_sim/run/memory.txt
	perl hex2v.pl < boot.ihex > boot.dat
	cp boot.dat '../../sim/rtl_sim/run/.'


%.o:%.S $(INCL) Makefile
	@printf "\r\n\t--- Assembling $(<) ---\r\n"
	$(CC) $(CFLAGS) -o $@ $(<) 

%.o:%.c $(INCL) Makefile
	@printf "\r\n\t--- Compiling $(<) ---\r\n"
	$(CC) $(CFLAGS) -o $@ $(<) 


#########################################################################

clean:
	@rm *.o
	@rm *.exe
	@rm *.BIN
	@rm boot.*
	@rm System.map


distclean: clean
	find . -type f \
		\( -name .depend -o -name '*.srec' -o -name '*.bin' \
		-o -name '*.pdf' \) \
		-print | xargs rm -f
	rm -f $(OBJS) *.bak tags TAGS
	rm -fr *.*~


