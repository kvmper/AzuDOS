global evga_setup
global _evga_print_char
global _evga_print
global _evga_println
global _evga_printhex_func
global _evga_printhex
global _evga_printdec
global evga_newline
global evga_cursor_disable
global evga_cursor_enable
global evga_cursor_move
global cursor_x_pos
global cursor_y_pos

section .rodata
hex_values db "0123456789ABCDEF", 0
hex_prefix db "0x", 0

section .text
evga_setup:
    mov edi, 0xB8000
    mov [cursor_x_pos], 0
    mov [cursor_y_pos], 0
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

_evga_printhex_func: ; Only 2 digits for now
    ; Upper 4 bits
    mov edx, ebx
    shr edx, 4
    mov al, [hex_values + edx]
    call _evga_print_char

    ; Lower 4 bits
    mov edx, ebx
    and edx, 0x0F
    mov al, [hex_values + edx]
    call _evga_print_char
    ret

; Just prints the hex prefix
_evga_printhex:
    ; Print hex prefix
    mov si, hex_prefix
    call _evga_print
    ; Actually print hex
    call _evga_printhex_func
    ret

_evga_printdec:
    add al, '0'
    call _evga_print_char
    ret

evga_newline:
    mov byte [cursor_x_pos], 0
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
    pushad
    pushfd
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
    popfd
    popad
    ret

section .data
cursor_x_pos db 0
cursor_y_pos db 0 
