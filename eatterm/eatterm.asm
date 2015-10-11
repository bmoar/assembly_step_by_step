section .data
    screenwidth: equ 80
    posterm: db 27,"[01;01H" ; <ESC>[<Y>;<X>H
    poslen: equ $-posterm
    clearterm: db 27,"[2J" ; <ESC>[2J
    clearlen: equ $-clearterm
    admsg: db "Eat at Joe's!"
    adlen: equ $-admsg
    prompt: db "press enter: "
    promptlen: equ $-prompt

    ; This table gives us pairs of ASCII digits from 0-80. Rather than
    ; calculate ASCII digits to insert in the terminal control string,
    ; we look them up in the table and read back two digits at once to
    ; a 16-bit register like DX, which we then poke into the terminal
    ; control string PosTerm at the appropriate place. See GotoXY.
    ; If you intend to work on a larger console than 80 X 80, you must
    ; add additional ASCII digit encoding to the end of Digits. Keep in
    ; mind that the code shown here will only work up to 99 X 99.
    digits: db "0001020304050607080910111213141516171819"
            db "2021222324252627282930313233343536373839"
            db "4041424344454647484950515253545556575859"
            db "606162636465666768697071727374757677787980"

section .bss

section .text

clear_screen:
    push rax
    push rbx
    push rcx
    push rdx

    mov rcx,clearterm ; pass offset of term control str
    mov rdx,clearlen ; pass length of term control str
    call write_str ; send control string to console

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

goto_XY:
    ; takes coordinates X,Y and calls sys_write to write the terminal
    ; control sequences to position the cursor at X,y
    ; :param: :ah - X coord
    ; :param: :al - Y coord
    push rbx
    push rcx
    push rdx

    xor rbx,rbx
    xor rcx,rcx

    ; put Y digits
    mov bl,al
    mov cx,word [digits+rbx*2] ; fetch decimal digits to CX
    mov word [posterm+2],cx
    
    ; put X digits
    mov bl,ah
    mov cx,word [digits+rbx*2]
    mov word [posterm+5],cx

    ; send control sequence to stdout
    mov rcx,posterm
    mov rdx,poslen
    call write_str

    pop rdx
    pop rcx
    pop rbx
    ret

write_control:
    ; send a string centered to 80 char wide linux console
    ; :param: :al - Y value
    ; :param: :rcx - str addr
    ; :param: :rdx - str len

    push rbx
    xor rbx,rbx

    mov bl,screenwidth
    sub bl,dl ; screen width - str length
    shr bl,1 ; divide difference by two for X value
    mov ah,bl ; goto_XY requires X value in ah
    call goto_XY
    call write_str

    pop rbx
    ret

write_str:
    ; calls sys_write to display str
    ; :param: :rcx - str addr
    ; :param: :rdx - str len
    push rax
    push rbx

    mov rax,4
    mov rbx,1
    int 0x80

    pop rbx
    pop rax

    ret

global _start

_start:
    nop

    call clear_screen

    mov al,12
    mov rcx,admsg
    mov rdx,adlen
    call write_control

    mov ax,0x0117
    call goto_XY

    mov rcx,prompt
    mov rdx,promptlen
    call write_str

    mov rax,3
    mov rbx,0
    int 0x80

exit: 
    mov rax,1
    mov rbx,0
    int 0x80
    
