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

func0:
    mov rax,0xDEAD
    mov rbx,0xDEAD
    ret

func1:
    mov rax,0xBEEF
    mov rbx,0xBEEF
    ret

global _start: ; linker needs to find entry point

_start: ; label required by linux
    nop
    nop
    nop

    mov rax,0xff
    mov rbx,0xff
    mov rcx,0xff
    mov rdx,0xff

    call func0
    call func1

    nop

