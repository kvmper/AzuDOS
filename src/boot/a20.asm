BITS 16

; Some, if not most of the code is from https://wiki.osdev.org/A20_Line

; Check if A20 Line was already enabled by BIOS
; 1 in ax = enabled
; 0 in ax = disabled
check_a20:
    pushf
    push ds
    push es
    push di
    push si

    cli

    xor ax, ax ; ax = 0
    mov es, ax

    not ax ; ax = 0xFFFF
    mov ds, ax

    mov di, 0x0500
    mov si, 0x0510

    mov al, byte [es:di]
    push ax

    mov al, byte [ds:si]
    push ax

    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF

    cmp byte [es:di], 0xFF

    pop ax
    mov byte [ds:si], al

    pop ax
    mov byte [es:di], al

    mov ax, 0
    je check_a20__exit

    mov ax, 1

check_a20__exit:
    pop si
    pop di
    pop es
    pop ds
    popf

    ret

; Enable the A20 line using AX = 0x2401, INT = 0x15
bios_a20: ; Extremely simplified version but it works
.query:
    mov ax, 0x2403
    int 0x15
    jc .failed
.activate:
    mov ax, 0x2401
    int 0x15
    jc .failed
.failed:
    ret

fast_a20:
    in al, 0x92
    test al, 2
    jnz .done
    or al, 2
    and al, 0xFE
    out 0x92, al
.done:
    ret