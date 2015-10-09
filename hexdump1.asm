; text filter that converts a file to hex chars

section .bss
    buff: resb bufflen
    bufflen equ 16

section .data
    hexstr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
    hexlen equ $-hexstr

    digits: db "0123456789ABCDEF"

section .text

global _start

_start:
    nop

; read buffer of text from stdin

read:
    mov rax,0x3
    mov rbx,0x0
    mov rcx,buff
    mov rdx,bufflen
    int 0x80

    mov rbp,rax ; save # bytes read
    cmp eax,0
    je exit
    jl error

    ; set up r for scan:
    mov rsi,buff 
    mov rdi,hexstr
    xor rcx,rcx

scan:
    xor rax,rax

    ; calculate the offset into hexstr, value of rcx * 3
    mov rdx,rcx ; copy char counter into rdx
    shl rdx,1 ; multiply pointer by 2 using left shift
    add rdx,rcx ; complete * 3

    ; get char from buffer and put it in rax and rbx
    mov al,byte [rsi+rcx] ; put byte from input buffer into al
    mov rbx,rax ; duplicate the byte in b1 for second nybble

    ; look up low nybble char and insert it into str
    and al,0x0f ; mask out all but low nybble
    mov al,byte [digits+rax]
    mov byte [hexstr+rdx+2],al ; write lsb char digit to line str

    ; look up high nybble char and insert it into str
    shr bl,4 ; shift high 4 bits of char into low 4 bits
    mov bl,byte [digits+rbx] ; look up char eq. of nybble
    mov byte [hexstr+rdx+1],bl ; write msb char digit to line str

    ; inc *buff to point to next char
    inc rcx
    cmp rcx,rbp
    jna scan

; write line of output
    mov rax,4 ; sys_write
    mov rbx,1 ; stdout
    mov rcx,hexstr
    mov rdx,hexlen
    int 0x80
    jmp read

exit:
    mov rax,0x1 ; sys_exit
    mov rax,0x0
    int 0x80

error:
    ; todo make this write an error msg out
    mov rax,0x1 ; sys_exit
    mov rax,0x1
    int 0x80

