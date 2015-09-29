all: skelly

skelly: skelly.o
	ld -o skelly skelly.o

uppercaser: uppercaser.o
	ld -o uppercaser uppercaser.o

skelly.o:
	nasm -f elf64 -g -F stabs skelly.asm

uppercaser.o:
	nasm -f elf64 -g -F stabs uppercaser.asm

clean:
	rm -f skelly
	rm -f skelly.o
	rm -f uppercaser
	rm -f uppercaser.o
