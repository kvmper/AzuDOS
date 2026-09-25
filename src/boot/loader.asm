BITS 16 ; Still executing in real mode

section .text

%include "include/evga_macros.asm"

loader_start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov [BOOT_DEVICE], dl ; Save boot device number for later
.stack_setup:
    xor ax, ax
    mov sp, 0xFFFF
.a20: ; A20 related code
    ; Check if A20 is enabled
    call check_a20
    cmp ax, 1
    je .a20_enabled_firmware ; A20 is enabled yippiee
.a20_disabled: ; A20 is disabled
    call bios_a20 ; Attempt enabling A20 line with BIOS
    ; Check if BIOS enabled the A20 Line
    call check_a20
    cmp ax, 1
    je .a20_enabled_bios

    call fast_a20 ; Attempt enabling A20 line with fast A20
    ; Check if fast A20 enabled the A20 line
    call check_a20
    cmp ax, 1
    je .a20_enabled_fast
    jmp error16 ; Failed to enable A20 line, error
.a20_enabled_firmware:
    ; A20 was already enabled
    mov [A20_FIRM], 1
    jmp .a20_enabled
.a20_enabled_fast:
    mov [A20_FAST], 1
    jmp .a20_enabled
.a20_enabled_bios:
    mov [A20_BIOS], 1
.a20_enabled: 
    mov [A20_ENABLED], 1

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

; Blink on Caps Lock LED to indicate error
; And please clean this mess oh my god
; I should have commented this along the way i don't undrstand this
; 16 bit version
error16:
    ; Turn on Caps Lock LED
    mov bl, 0x04
    call .blink_leds
    call .err_wait ; Wait 100000000 cycles (works for now)
    ; Disable LEDs
    mov bl, 0x00
    call .blink_leds
    call .err_wait
    jmp error16
.blink_leds:
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
.err_wait:
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
.setup_stack:
    mov ss, eax
    mov esp, 0x90000
    ; Enable NMI
    mov al, 0
    out 0x70, al
    in al, 0x71

    call pic_remap
.is_lm_available:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .lm_unavailable
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jb .lm_unavailable
    jmp .lm_available
.lm_unavailable:

.lm_available:
    mov [LM_SUPPORT], 1
.video_setup:
    call evga_setup
    call evga_cursor_disable
.display_info:
.boot_device:
.a20_info:
    mov si, a20_enabled_msg
    call _evga_print
    cmp [A20_FIRM], 1 ; Was A20 already enabled by firmware
    je .a20_firm
    cmp [A20_BIOS], 1 ; Was A20 enabled by BIOS
    je .a20_bios
    cmp [A20_FAST], 1 ; Was A20 enabled by Fast A20
    je .a20_fast
.a20_firm:
    evga_println(firmware_msg)
    jmp .lm_info
.a20_bios:
    evga_println(bios_msg)
    jmp .lm_info
.a20_fast:
    evga_println(fast_a20_msg)
    call _evga_print
    jmp .lm_info
.lm_info:
    cmp [LM_SUPPORT], 1
    je .lm_supported
    evga_print(lm_unsuppored_msg)
    jmp error32
.lm_supported:
    evga_print(lm_supported_msg)
    jmp error32
    

; 32 bit version
error32:
    call evga_newline
    evga_print("Encountered a critical error! (PM)")
    call evga_cursor_enable
.main_loop:
    ; Turn on Caps Lock LED
    mov bl, 0x04
    call .blink_leds
    call .err_wait ; Wait 100000000 cycles (works for now)
    ; Disable LEDs
    mov bl, 0x00
    call .blink_leds
    call .err_wait
    jmp .main_loop
.blink_leds:
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
.err_wait:
    mov ecx, 1000000000
.spin:
    cmp ecx, 0
    je .return
    dec ecx
    jmp .spin
.return:
    ret

%include "src/boot/a20.asm"
%include "src/boot/pic.asm"
%include "src/boot/evga.asm"

section .data
BOOT_DEVICE db 0
A20_ENABLED db 0
A20_FIRM    db 0
A20_BIOS    db 0
A20_FAST    db 0
LM_SUPPORT  db 0

boot_device_msg: db "Boot device -> ", 0
a20_enabled_msg: db "A20 enabled using ", 0
fast_a20_msg: db "Fast A20", 0
bios_msg: db "BIOS", 0
firmware_msg: db "Firmware", 0

lm_supported_msg: db "Long Mode is supported", 0
lm_unsuppored_msg: db "Long Mode is not supported", 0