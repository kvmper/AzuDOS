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

_evga_print_char:
    mov ah, 0x0F
.print_char:
    mov word [edi], ax
    add edi, 2
.done:
    inc [cursor_x_pos]
    call evga_cursor_move
    ret

_evga_print:
.print:
    mov al, [esi]
    or al, al
    jz .done
    call _evga_print_char
    inc esi
    jmp .print
.done:
    ret

_evga_println:
    call _evga_print
    call evga_newline
    ret

evga_newline:
    inc byte [cursor_y_pos]
    movzx eax, byte [cursor_y_pos]
    mov ecx, 160
    mul ecx
    mov edi, 0xB8000
    add edi, eax
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
    pushad
    pushfd
    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al
    mov dx, 0x3D5
    in al, dx
    and al, 0xC0
    or al, 14
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0B
    out dx, al
    mov dx, 0x3D5
    in al, dx
    and al, 0xE0
    or al, 0x0F
    out dx, al
    
    popfd
    popad
    ret

evga_cursor_move:
    mov eax, edi
    sub eax, 0xB8000
    shr eax, 1 ; (edi - 0xb8000) / 2

    mov dx, 0x3D4
    mov bl, al
	mov al, 0x0F
	out dx, al

    mov dx, 0x3D5
    mov al, bl
    out dx, al

    mov dx, 0x3D4
    mov bl, ah
	mov al, 0x0E
	out dx, al

    mov dx, 0x3D5
    mov al, bl
    out dx, al
    ret

section .data
cursor_x_pos db 0
cursor_y_pos db 0 
