global evga_setup
global evga_print_char
global evga_print
global evga_println
global evga_cursor_disable
global evga_cursor_enable

section .text
evga_setup:
    mov edi, 0xB8000
    ret

evga_print_char:
    mov ah, 0x0F
.print_char:
    mov word [edi], ax
    inc esi
    add edi, 2
.done:
    ret

evga_print:
.print:
    mov al, [si]
    or al, al
    jz .done
    call evga_print_char
    jmp .print
.done:
    ret

evga_println:
    call evga_print
    add edi, 160
    ret

evga_cursor_disable:
    pushad
    pushfd
    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al
    mov dx, 0x3D5
    mov al, 0x20
    out dx, al
    popfd
    popad
    ret

evga_cursor_enable:
