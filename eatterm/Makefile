all: eatterm

eatterm: eatterm.o
	ld -o eatterm eatterm.o

eatterm.o:
	nasm -f elf64 -g -F stabs eatterm.asm

clean:
	rm -f eatterm
	rm -f eatterm.o
