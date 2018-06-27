OBJS = server client
CC = nasm
CCFLAGS = -felf64
DBFLAGS = $(CCFLAGS) -g -F dwarf
LNK = ld -o

all: clean $(OBJS)

client: client.o socklib.o filelib.o
	$(LNK) $@ -g $^

server: server.o socklib.o filelib.o
	$(LNK) $@ -g $^

test: test.o
	$(LNK) $@ -g $^

%.o: %.asm
	$(CC) $(DBFLAGS) $< -o $@

socklib.o: socklib.inc
	$(CC) $(DBFLAGS) $< -o $@

filelib.o: filelib.inc
	$(CC) $(DBFLAGS) $< -o $@

clean:
	rm -fr *.o $(OBJS) file test testfile.txt
