all: skelly uppercaser hexdump xlat vidbuff

skelly: skelly.o
	ld -o skelly skelly.o

skelly.o:
	nasm -f elf64 -g -F stabs skelly.asm

uppercaser: uppercaser.o
	ld -o uppercaser uppercaser.o

uppercaser.o:
	nasm -f elf64 -g -F stabs uppercaser.asm

vidbuff: vidbuff.o
	ld -o vidbuff vidbuff.o

vidbuff.o:
	nasm -f elf64 -g -F stabs vidbuff.asm

hexdump: hexdump.o textlib.o
	ld -o hexdump hexdump.o lib/textlib.o

hexdump.o:
	nasm -f elf64 -g -F stabs hexdump.asm

textlib.o:
	nasm -f elf64 -g -F stabs lib/textlib.asm

xlat: xlat.o
	ld -o xlat xlat.o

xlat.o:
	nasm -f elf64 -g -F stabs xlat.asm

clean:
	rm -f skelly
	rm -f skelly.o
	rm -f uppercaser
	rm -f uppercaser.o
	rm -f vidbuff
	rm -f vidbuff.o
	rm -f hexdump
	rm -f hexdump.o
	rm -f xlat
	rm -f xlat.o
	rm -f lib/textlib.o
