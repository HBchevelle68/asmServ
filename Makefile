OBJS = server client
CC = nasm
CCFLAGS = -felf64
DBFLAGS = $(CCFLAGS) -g -F dwarf
LNK = ld -o


all: clean $(OBJS)

server: server.o socklib.o
	$(LNK) $@ -g $^

client: client.0 socklib.o
	$(LNK) $@ -g $^

%.o: %.asm
	$(CC) $(DBFLAGS) $< -o $@

clean::
	rm -fr *.o
