OBJS = server server-debug client client-debug 
CC = nasm
CCFLAGS = -felf64
DBFLAGS = $(CCFLAGS) -g -F dwarf
LNK = ld -m elf_x86_64

all: clean $(OBJS)

client: client.o socklib.o filelib.o
	$(LNK) $^ -o $@

server: server.o socklib.o filelib.o
	$(LNK) $^ -o $@

test: test.o
	$(LNK) $^ -o $@

client-debug: client-debug.o socklib-debug.o filelib-debug.o
	$(LNK) $^ -o $@

server-debug: server-debug.o socklib-debug.o filelib-debug.o
	$(LNK) $^ -o $@

test-debug: test-debug.o
	$(LNK) $^ -o $@

%.o: %.asm
	$(CC) $(CCFLAGS) $< -o $@

%.o: %.inc
	$(CC) $(CCFLAGS) $< -o $@

%-debug.o: %.asm
	$(CC) $(DBFLAGS) $< -o $@

%-debug.o: %.inc
	$(CC) $(DBFLAGS) $< -o $@

clean:
	rm -fr *.o $(OBJS) file test testfile.txt
