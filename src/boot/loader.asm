BITS 16 ; Still executing in real mode
ORG 0X1000 ; Loader is located at address 0x1000
CPU 386 ; Intel 80386 CPU

loader_start:
    mov [BOOT_DEVICE], dl ; Save boot device number for later
.a20: ; A20 related code
    ; Check if A20 is enabled
    call check_a20
    cmp ax, 1
    je .after ; A20 is enabled yippiee
.a20_disabled: ; A20 is disabled
    call bios_a20 ; Attempt enabling A20 line with BIOS
    ; Check if BIOS enabled the A20 Line
    call check_a20
    cmp ax, 1
    je .after

    call fast_a20 ; Attempt enabling A20 line with fast A20
    ; Check if fast A20 enabled the A20 line
    call check_a20
    cmp ax, 1
    je .after
    jmp error ; Failed to enable A20 line, error
.after:
    mov [A20_ENABLED], 1
    mov ah, 0x0E
    mov al, 'A'
    int 0x10
    cli
    hlt

error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    hlt

BOOT_DEVICE db 0
A20_ENABLED db 0

%include "src/boot/a20.asm"