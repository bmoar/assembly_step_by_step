all: skelly

skelly: skelly.o
	ld -o skelly skelly.o

skelly.o:
	nasm -f elf64 -g -F stabs skelly.asm

clean:
	rm -f skelly
	rm -f skelly.o
