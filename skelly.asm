; Executable name: sandbox
; Author: bmoar
; Description: put instructions in

SECTION .data ; init data
    ; data that has a value before the program starts running
    snip db "KANGAROO"
    sniplen equ 16

SECTION .bss ; uninit data
    ; data buffers, basically pointers to memory to later
    ; be filled up by things like disk / network IO

SECTION .text ; code section
    ; where symbols and instructions go
global_start: ; linker needs to find entry point

_start: ; label required by linux
    nop

    mov rax,0xDEADBEEF
    push rax
    mov ebx,1
    mov ecx,snip
    mov edx,sniplen

    int 0x80

    nop

