; text filter that converts a file to hex chars

section .bss
    buff: resb bufflen
    bufflen equ 16

section .data
    dumpline: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    ; hexstr is a table with entries 3 bytes long, \s[0-9a-f][0-9a-f]
    dumplen equ $-dumpline
    ascline: db "|................|",10
    acclen equ $-ascline
    fulllen equ $-dumpline

    hexdigits: db "0123456789ABCDEF" ; simple lookup table, index into it
    ; by doing byte [digits+<val>]

    ; This table is used for ASCII character translation, into the ASCII
    ; portion of the hex dump line, via XLAT or ordinary memory lookup.
    ; All printable characters “play through“ as themselves. The high 128
    ; characters are translated to ASCII period (2Eh). The non-printable
    ; characters in the low 128 are also translated to ASCII period, as is
    ; char 127.
    DotXlat:
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
        db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
        db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
        db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
        db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
        db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

section .text

clearline:
    ; dumpline str is cleared to 0x00 by calling dumpchar 16 times, passing in 0
    push rax
    push rdx

    mov rdx,15
    .poke: mov rax,0
    call dumpchar
    sub rdx,1
    jae .poke

    pop rdx
    pop rax
    ret

dumpchar:
    ; put a value into hex dump portion and ascii dump portion
    ; in: 
    ;   rax - 8-bit value to be put
    ;   rdx - position in dumpline 0-15
    ; out: none

    push rbx ; save caller's rbx
    push rdi ; save caller's rdi

    ; insert the input char into ascii portion of dump line
    mov bl,byte [DotXlat+rax]
    mov byte [ascline+rdx+1],bl

    ; insert the hex equivalent of input char into hex portion
    mov rbx,rax ; save second copy of input char
    lea rdi,[rdx*2+rdx] ; calc offset into line

    ; look up low nybble char and insert it
    and rax,0x000000000000000f
    mov al,byte [hexdigits+rax]
    mov byte [dumpline+rdi+2],al

    ; look up high nybble char
    and rbx,0x00000000000000f0
    shr rbx,4
    mov bl,byte [hexdigits+rbx]
    mov byte [dumpline+rdi+1],bl

    ; go home
    pop rdi
    pop rbx
    ret

printline:
    ; print out the dumpline
    push rax
    push rbx
    push rcx
    push rdx

    mov rax,4 ; sys_write
    mov rbx,1 ; stdout
    mov rcx,dumpline
    mov rdx,fulllen
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

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

