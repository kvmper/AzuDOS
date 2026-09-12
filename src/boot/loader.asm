BITS 16 ; Still executing in real mode
ORG 0X1000 ; Loader is located at address 0x1000
CPU 386 ; Intel 80386 CPU

loader_start:
    mov [BOOT_DEVICE], dl ; Save boot device number for later
.a20: ; A20 related code
    ; Check if A20 is enabled
    call check_a20
    cmp ax, 1
    je .a20_enabled ; A20 is enabled yippiee
.a20_disabled: ; A20 is disabled
    call bios_a20 ; Attempt enabling A20 line with BIOS
    ; Check if BIOS enabled the A20 Line
    call check_a20
    cmp ax, 1
    je .a20_enabled

    call fast_a20 ; Attempt enabling A20 line with fast A20
    ; Check if fast A20 enabled the A20 line
    call check_a20
    cmp ax, 1
    je .a20_enabled
    jmp error ; Failed to enable A20 line, error
.a20_enabled:
    mov [A20_ENABLED], 1
pm_setup:
    ; Disable NMI
    in al, 0x70
    or al, 0x80
    out 0x70, al
    lgdt[gdt_desc]
    ; Set protection enable bit in CR0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:pm_main ; Jump to Protected Mode

gdt:
    dq 0x00000000 ; Null descriptor
gdt_code_seg:
    dw 0xFFFF ; Limit
    dw 0x0000 ; Base (bits 0-15)
    db 0x00 ; Base (bits 16-23)
    db 10011010b ; Access byte
    db 11001111b ; Flags
    db 0x00 ; Base (bits 24-31)
gdt_data_seg:
    dw 0xFFFF ; Limit
    dw 0x0000 ; Base (bits 0-15)
    db 0x00 ; Base (bits 16-23)
    db 10010010b ; Access byte
    db 11001111b ; Flags
    db 0x00 ; Base (bits 24-31)
gdt_end:

gdt_desc:
    dw (gdt_end - gdt - 1) ; GDT limit
    dd gdt ; GDT base

error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    hlt

BITS 32 ; Now we're in Protected Mode
pm_main:
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax

    cli
    hlt

BOOT_DEVICE db 0
A20_ENABLED db 0

%include "src/boot/a20.asm"