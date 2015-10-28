; create an old dos-style memory mapped text I/O buffer for writing to the terminal

section .data ; initialized data
    EOL equ 0x0a ; newline
    FILLCHR equ 0x20 ; fill with space
    HBARCHR equ 0x2d ; use dash if it won't display
    STRTROW equ 0x02 ; row where graph begins

    ; dataset = table of byte-length numbers
    Dataset db 9,71,17,52,55,18,29,36,18,68,77,63,58,44,0

    Message db "Data current as of 10/27/2015"
    MSGLEN equ $-Message

    ; this escape sequence will clear the console terminal and place cursor at 1,1
    ClrHome db 0x1b,"[2J",0x1b,"[01;01H"
    CLRLEN equ $-ClrHome

section .bss ; uninitialized data
    COLS equ 81 ; line length +1 char for EOL
    ROWS equ 25 ; number of lines to display
    VidBuff resb COLS*ROWS

section .text

global _start

; clear a linux console terminal and set cursor position to 1,1 using a single escape sequence
%macro ClearTerminal 0

    ; save registers
    push rax
    push rbx
    push rcx
    push rdx

    mov rax,4 ; sys_write
    mov rbx,1 ; specifiy stdout
    mov rcx,ClrHome ; offset of error message
    mov rdx,CLRLEN ; length of message
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax

%endmacro

; write the vidbuffer to stdout
Show: 
    ; save registers
    push rax
    push rbx
    push rcx
    push rdx

    mov rax,4 ; sys_write
    mov rbx,1 ; specifiy stdout
    mov rcx,VidBuff ; offset of error message
    mov rdx,COLS*ROWS ; length of message
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

; Clear the vidbuffer to spaces and EOL at the end of the columns
ClrVid: 
    push rax
    push rcx
    push rdi

    cld ; clear DF, we are counting towards high memory
    mov al,FILLCHR ; put buffer fill char in AL
    mov rdi,VidBuff ; point destination at buffer
    mov rcx,COLS*ROWS ; put count of chars into rcx
    rep stosb ; "blast" chars at the buffer

    ; buffer is reset, now insert EOL char after each line
    mov rdi,VidBuff ; point destination at buffer again
    dec rdi ; start EOL position count at vidbuff char 0
    mov rcx,ROWS ; put number of rows in count register
    PtEOL: add rdi,COLS ; add column count to rdi
    mov byte [rdi],EOL ;store EOL char at end of row
    loop PtEOL

    pop rdi
    pop rcx
    pop rax

    ret

; write a string to the vidbuffer at X,Y position
; :param: :rsi - addr of string
; :param: :rbx - X position ( row # )
; :param: :rax - Y position ( row # )
; :param: :rcx - length of the string
WrtLn: 
    push rax
    push rbx
    push rcx
    push rdi

    cld ; clear df for high-mem counting
    mov rdi,VidBuff ; load VidBuff addr to dest index register
    dec rax ; adjust Y down for addr calculation
    dec rbx ; adjust X down for addr calculation
    mov AH,COLS ; mov screen width to AH
    mul AH ; do 8 bit multiply AL*AH to AX
    add rdi,rax ; add Y offset into vidbuff to rdi
    add rdi,rbx ; add X offset into vidbuff to rdi
    rep movsb ; "blast" the string into the buffer
    
    pop rdi
    pop rcx
    pop rbx
    pop rax

    ret

; generate a horizontal line bar at X,Y in text buffer
; :param: :rax - Y position ( column # )
; :param: :rbx - X position ( row # )
; :param: :rcx - length of the horizontal bar
WrtHB:
    push rax
    push rbx
    push rcx
    push rdi

    cld ; clear df for high-memory counting
    mov rdi,VidBuff ; put vidbuff addr in destination index register
    dec rax; dec Y value for addr calculation
    dec rbx; dec X value for addr calculation
    mov ah,COLS ; mov screen width to AH
    mul ah ; do 8 bit multiply AL*AH to AX
    mov rdi,rax ; add y offset into vidbuff to rdi
    mov rdi,rbx ; add x offset into vidbuff to rdi
    mov al,HBARCHR; put char to use for bar in al
    rep stosb ; blast the bar char into vidbuff

    pop rdi
    pop rcx
    pop rbx
    pop rax

    ret

; generate a 1234567890 style ruler at X,Y in vidbuffer
; :param: :rax - Y position ( column # )
; :param: :rbx - X position ( row # )
; :param: :rcx - length of the horizontal bar
Ruler: 
    push rax
    push rbx
    push rcx
    push rdi

    mov rdi,VidBuff ; load vidbuff into rdi
    dec rax
    dec rbx
    mov ah,COLS ; mov screen width into AH
    mul ah ; do 8bit multiply AL*AH to ax
    add rdi,rbx ; add y offset into vidbuff to rdi
    add rdi,rax ; add X offset into vidbuff to rdi
    ; rdi now contains the memory addr in vidbuffer where teh ruler is to begin. now display the ruler
    mov al,'1' ; start ruler with digit 1
DoChar: stosb ; no rep prefix
    add al,'1' ; increment al by 1
    aaa ; adjust ax to make this bcd addition
    add al,'0' ; make sure we have binary 3 in al's high nybble
    loop DoChar ; go back and do another char until rcx goes to 0

    pop rdi
    pop rcx
    pop rbx
    pop rax

    ret

; Main

_start:
    nop ; keep gdb happy

    ; get the console and vidbuff ready to go
    ClearTerminal ; send terminal clear string to console
    call ClrVid ; init/clear the video buffer

    ; display the top ruler
    mov rax,1 ; load X pos into al
    mov rbx,1 ; load Y pos into bl
    mov rcx,COLS-1 ; load ruler length intio rcx
    call Ruler

    ; loop through dataset and graph the data
    mov rsi,Dataset ; put addr of the dataset in rsi
    mov rbx,1 ; start all bars at left margin (X=1)
    mov rbp,0 ; dataset element index starts at 0

.blast: mov rax,rbp ; add dataset number to element index
    add rax,STRTROW ; bias row value by row # of first bar
    mov cl,byte [rsi+rbp] ; put dataset value in low byte of rcx
    cmp rcx,0 ; see if we pulled 0 from dataset
    je .rule2 ; done
    call WrtHB ; graph data as a horizontal bar
    inc rbp ; increment dataset element index
    jmp .blast

; display bottom ruler
.rule2: mov rax,rbp ; use dataset counter to set the ruler now
    add rax,STRTROW ; bias down by row # of first bar
    mov rbx,1 ; load X position to BL
    mov rcx,COLS-1 ; load ruler length to rcx
    call Ruler

; throw up informative message centered on last line
    mov rsi,Message
    mov rcx,MSGLEN
    mov rbx,COLS
    sub rbx,rcx
    shr rbx,1
    mov rax,24
    call WrtLn

    call Show

Exit:
    mov rax,1
    mov rbx,0
    int 0x80
