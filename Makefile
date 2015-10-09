all: skelly uppercaser hexdump1

skelly: skelly.o
	ld -o skelly skelly.o

uppercaser: uppercaser.o
	ld -o uppercaser uppercaser.o

skelly.o:
	nasm -f elf64 -g -F stabs skelly.asm

uppercaser.o:
	nasm -f elf64 -g -F stabs uppercaser.asm

hexdump1.o:
	nasm -f elf64 -g -F stabs hexdump1.asm

hexdump1: hexdump1.o
	ld -o hexdump1 hexdump1.o

clean:
	rm -f skelly
	rm -f skelly.o
	rm -f uppercaser
	rm -f uppercaser.o
	rm -f hexdump1
	rm -f hexdump1.o
