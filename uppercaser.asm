; a simple text filter to uppercase ascii input

section .bss
    bufflen equ 4096
    buff resb bufflen

section .data

section .text
    global _start

_start:
    nop

read:
    mov rax,0x3 ; use sys_read
    mov rbx,0x0 ; read from stdin
    mov rcx,buff ; store in *buff
    mov rdx,bufflen ; read bufflen bytes
    int 0x80
    mov rsi,rax ; store return of sys_read

    cmp rax,0 ; cmp rax against EOF
    je exit ; if EOF, exit

    cmp rax,0 ; check for errors
    jl error ; we error now

    ; set up registers for scan
    mov rcx,rsi ; get # bytes read

scan:
    cmp byte [buff-1+rcx],0x61 ; check buff for a
    jb next ; jmp if byte < 'a'
    cmp byte [buff-1+rcx],0x7a ; check buff for z
    ja next ; jmp if byte > 'z'
    sub byte [buff-1+rcx],0x20 ; otherwise byte is lowercase char, uppercase by sub 0x20

next:
    dec rcx
    jnz scan

write:
    mov rax,0x4 ; use sys_write
    mov rbx,0x1 ; write to stdout
    mov rcx,buff ; write from *buf
    mov rdx,rsi ; write bufflen byte
    int 0x80

    cmp rax,bufflen ; check to make sure we wrote bytes
    jne error ; if bufflen bytes not written, error, exit

    jmp read ; loop until EOF

error:
    mov rax,0x1 ; sys_exit
    mov rbx,0x1 ; we error now
    int 0x80

exit:
    mov rax,0x1 ; sys_exit
    mov rbx,0x0 ; return 0
    int 0x80
