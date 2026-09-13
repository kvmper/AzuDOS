BITS 16 ; Still executing in real mode
CPU 386 ; Intel 80386 CPU

section .text
loader_start:
    jmp error
    mov [BOOT_DEVICE], dl ; Save boot device number for later
.stack_setup:
    xor ax, ax
    mov sp, 0x1000
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
vga_setup:
    
pm_setup:
    ; Disable NMI
    mov al, 0x80
    out 0x70, al
    in al, 0x71
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

; Turn on Caps Lock LED to indicate error
; And please clean this mess oh my god
; I should have commented this along the way i don't undrstand this
error:
    ; Turn on Caps Lock LED
    mov bl, 0x04
    call blink_leds
    call err_wait ; Wait 100000000 cycles (works for now)
    ; Disable LEDs
    mov bl, 0x00
    call blink_leds
    call err_wait
    jmp error
blink_leds:
.wait_0:
    in al, 0x64
    test al, 2
    jnz .wait_0
.send_cmd:
    mov al, 0xED
    out 0x60, al
.wait_1:
    in al, 0x64
    test al, 1
    jz .wait_1
    in al, 0x60
.enable_led:
    in al, 0x64
    test al, 2
    jnz .enable_led
    mov al, bl
    out 0x60, al
    ret
err_wait:
    mov ecx, 100000000
.spin:
    cmp ecx, 0
    je .return
    dec ecx
    jmp .spin
.return:
    ret

BITS 32 ; Now we're in Protected Mode
pm_main:
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    ; Enable NMI
    mov al, 0
    out 0x70, al
    in al, 0x71

    call pic_remap

    cli
    hlt

BOOT_DEVICE db 0
A20_ENABLED db 0

%include "src/boot/a20.asm"
%include "src/boot/pic.asm"