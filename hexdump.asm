; text filter that converts a file to hex chars

section .bss
    buff: resb bufflen
    bufflen equ 16

section .data

section .text

EXTERN clearline, dumpchar, printline

loadbuff:
    ; use sys_read to fill buffer
    ; returns: # of bytes read in rbp
    ; modiefies rcx, rbp, buff
    push rax
    push rbx
    push rdx
    mov rax,3 ; sys_read
    mov rbx,0 ; stdin
    mov rcx,buff
    mov rdx,bufflen
    int 0x80

    mov rbp,rax ; store # bytes read in rbp
    xor rcx,rcx ; clear buffer pointer rcx to 0
    pop rdx
    pop rbx
    pop rax
    ret

global _start

_start:
    nop
    nop

    ; init for loop scan
    xor rsi,rsi ; clear byte counter to 0
    call loadbuff ; read first buffer from stdin
    cmp rbp,0 ; if rbp=0, EOF on stdin
    jbe exit

    ; go through buffer and convert binary byte values to hex digits

scan:
    ; go through buffer and convert binary byte values to hex digits
    xor rax,rax
    mov al,byte[buff+rcx] ; get byte from buffer into AL
    mov rdx,rsi ; copy total counter into rdx
    and rdx,0x0000000000000000f ; mask lowest 4 bits of char counter
    call dumpchar

    ; bump *buff to next char and see if buffer's done
    inc rsi ; inc total chars processed counter
    inc rcx ; inc *buff
    cmp rcx,rbp
    jb .modTest ; if we have processed all chars in buffer
    call loadbuff ; get another buff full of chars to process
    cmp rbp,0 ; sys_read got EOF
    jbe exit

    ; check if we're at the end of a block of 16 chars and need to display a line
.modTest:
    test rsi,0x0000000000000000f ; test lowest 4 bits for 0
    jnz scan ; if counter is not modulo 16, loop back
    call printline
    call clearline
    jmp scan

exit:
    call printline
    mov rax,0x1 ; sys_exit
    mov rax,0x0
    int 0x80

error:
    ; todo make this write an error msg out
    mov rax,0x1 ; sys_exit
    mov rax,0x1
    int 0x80

