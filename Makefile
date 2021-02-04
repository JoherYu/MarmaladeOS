CFLAGS = -m32 -c -fno-stack-protector
ASMKFLAGS = -f elf

MARMALADEBOOT = boot.bin
MARMALADECORE = core.bin
OBJS = core.o start.o i8259.o global.o protect.o lib.o

.PHONY : everything clean all realclean

everything : $(MARMALADEBOOT) $(MARMALADECORE)
realclean : # command must be on next line,preceded by a tab
	rm -f $(OBJS) $(MARMALADEBOOT) $(MARMALADECORE) 
clean : 
	rm -f $(OBJS)
all : realclean everything

boot.bin : boot.asm
	nasm -o $@ $<
$(MARMALADECORE) : $(OBJS)
	ld -m elf_i386 -s -Ttext 0x80040000 -o $(MARMALADECORE) $(OBJS)

core.o : core.asm
	nasm $(ASMKFLAGS) -o $@ $<
start.o : start.c type.h const.h protect.h proto.h
	gcc $(CFLAGS) -o $@ $<
i8259.o : i8259.c type.h const.h protect.h proto.h
	gcc $(CFLAGS) -o $@ $<
global.o : global.c
	gcc $(CFLAGS) -o $@ $<
protect.o : protect.c
	gcc $(CFLAGS) -o $@ $<
lib.o : lib.asm
	nasm $(ASMKFLAGS) -o $@ $<
