%ifndef EVGA_MACROS_ASM
%define EVGA_MACROS_ASM

%macro __evga_print 1
%ifstr %1
    jmp short %%start
%%text: db %1, 0 
%%start:
    mov si, %%text
    call _evga_print
%else
    mov si, %1
    call _evga_print
%endif
%endmacro

%define evga_print(a) __evga_print a

%macro __evga_println 1
%ifstr %1
    jmp short %%start
%%text: db %1, 0 
%%start:
    mov si, %%text
    call _evga_println
%else
    mov si, %1
    call _evga_println
%endif
%endmacro

%define evga_println(a) __evga_println a

%macro __evga_printhex 1
%ifnum %1
    mov ebx, %1
    call _evga_printhex
%elifstr %1
    jmp short %%start
%%text: db %1, 0 
%%start:
    movzx ebx, byte [%%text]
    call _evga_printhex
%else
    movzx ebx, byte [%1]
    call _evga_printhex
%endif
%endmacro

%define evga_printhex(a) __evga_printhex a

%macro __evga_printdec 1
    mov al, [%1]
    call _evga_printdec
%endmacro

%define evga_printdec(a) __evga_printdec a

%endif