OBJS = socklib
CC = nasm
CCFLAGS = -felf64
DBFLAGS = $(CCFLAGS) -g -F dwarf
LNK = ld -o


all: clean $(OBJS)

socklib: socklib.o
	$(LNK) $@ -g $^

%.o: %.asm
	$(CC) $(DBFLAGS) $< -o $@

clean::
	rm -fr *.o
