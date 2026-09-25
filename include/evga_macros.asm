%ifndef EVGA_MACROS_ASM
%define EVGA_MACROS_ASM

%macro __evga_print 1
%ifstr %1
    jmp short %%start
section .rodata
%%text: db %1, 0 
section .text
%%start:
    mov si, %%text
    call _evga_print
%else:
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

%endif