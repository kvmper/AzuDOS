BITS 16
ORG 0x7C00

flush_cs:
    jmp 0:boot_start
boot_start:
    cli
    cld
    xor ax, ax
    mov ds, ax
    mov es, ax
.stack_setup:
    mov ss, ax
    mov sp, 0x0600
.ver:
    mov ah, 0x0E
    mov al, 'V'
    int 0x10
    jmp .ver

times 510 - ($-$$) db 0
db 0x55, 0xAA