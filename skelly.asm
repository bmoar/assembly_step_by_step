; Executable name: sandbox
; Author: bmoar
; Description: put instructions in

SECTION .data ; init data
    snip db "kangaroo"

SECTION .bss ; unit data

SECTION .text ; code section
global_start: ; linker needs to find entry point

_start:
    nop

    mov eax,1
    mov ebx,0
    div ebx

    nop
