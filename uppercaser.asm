; reads from stdin 1 byte at a time and uppercases it if lowercase ascii, then write byte to stdout

section .bss
    buff resb 1

section .data

section .text
    global _start

_start:
    nop

read:
    mov rax,0x3 ; use sys_read
    mov rbx,0x0 ; read from stdin
    mov rcx,buff ; store in *buff
    mov rdx,0x1 ; read 1 byte
    int 0x80

    cmp rax,0 ; cmp rax against EOF
    jle exit ; if EOF, exit

    cmp byte [buff],0x61 ; check buff for a
    jb write ; jmp if byte < 'a'
    cmp byte [buff],0x7a ; check buff for z
    ja write ; jmp if byte > 'z'
    sub byte [buff],0x20 ; otherwise byte is lowercase char, uppercase by sub 0x20
    jmp write ; write uppercased byte

write:
    mov rax,0x4 ; use sys_write
    mov rbx,0x1 ; write to stdout
    mov rcx,buff ; write from *buf
    mov rdx,0x1 ; write 1 byte
    int 0x80

    cmp rax,1 ; check to make sure we wrote 1 byte
    jne exit ; if 1 byte not written, error, exit

    jmp read ; loop until EOF

exit:
    mov rax,0x1 ; sys_exit
    mov rbx,0x0 ; return 0
    int 0x80
