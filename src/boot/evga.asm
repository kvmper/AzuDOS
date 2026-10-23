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
evga_setup: ; Setup VGA Text mode
    mov edi, 0xB8000 ; VGA Text Mode address
    ; Set cursor position
    mov byte [cursor_x_pos], 0
    mov byte [cursor_y_pos], 0
    ret

_evga_print_char: ; Print single characters
    push ax
    mov ah, 0x0F
.print_char:
    mov word [edi], ax
    add edi, 2
.done:
    pop ax
    inc byte [cursor_x_pos]
    call evga_cursor_move
    ret

_evga_print: ; Print strings
.print:
    mov al, [esi]
    or al, al
    jz .done
    call _evga_print_char
    inc esi
    jmp .print
.done:
    ret

_evga_println: ; Print a string and a new line
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

; Spent about an hour trying to fix this, however the issue had to do with something else....
_evga_printdec: ; Print numbers
    mov cx, 0 ; How many nubmers
    cmp ax, 0 ; If 0
    je .zero
.extract:
    cmp ax, 0 ; Check if no more numbers
    je .print
    xor dx, dx
    mov bx, 10 ; Divisor
    div bx ; Divide
    add dx, '0'
    push dx ; Push remainder onto the stack
    inc cx ; Increment number counter
    jmp .extract
.print:
    cmp cx, 0
    je .done
    pop dx
    mov al, dl
    call _evga_print_char
    dec cx
    jmp .print
.zero:
    mov al, '0'
    call _evga_print_char
.done:
    ret

evga_newline: ; Create a new line
    mov byte [cursor_x_pos], 0 ; Set cursor to start at the beginning of the line
    inc byte [cursor_y_pos] ; Move onto the next line
    ; Some math for calculating where in memory we should start printing
    ; We might want uhh to revamp this later cause i do not wanna rely on EDI
    ; for cursor position, we might want to replace this with X and Y cursor system instead
    movzx eax, byte [cursor_y_pos]
    mov ecx, 160
    mul ecx
    mov edi, 0xB8000
    add edi, eax
    ret

evga_cursor_disable: ; Disables the VGA Text Mode cursor
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

evga_cursor_enable: ; Enables the VGA Text Mode Cursor
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

evga_cursor_move: ; Moves the VGA Text Mode Cursor to the position of the cursor
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
cursor_x_pos db 0 ; Column
cursor_y_pos db 0 ; Line
