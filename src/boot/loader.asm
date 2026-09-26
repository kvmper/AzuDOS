BITS 16 ; Still executing in real mode

extern check_a20
extern bios_a20
extern check_a20
extern fast_a20

extern pic_remap

extern evga_setup
extern _evga_print_char
extern _evga_print
extern _evga_println
extern _evga_printhex
extern _evga_printdec
extern evga_newline
extern evga_cursor_disable
extern evga_cursor_enable
extern evga_cursor_move
extern cursor_x_pos
extern cursor_y_pos

extern error16
extern error32

section .text
%include "include/evga_macros.asm"

global loader_start
loader_start:
    mov [BOOT_DEVICE], dl ; Save boot device number for later
    mov ah, 0x08 ; How many drives are connected
    int 0x13 ; I think this enables interrupts?
    mov [DRIVE_COUNT], dl
    cli
.stack_setup:
    xor ax, ax ; 0
    mov sp, ax ; 0
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
    cli
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

BITS 32 ; Now we're in Protected Mode
pm_main:
    cli
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
.video_setup:
    call evga_setup
    call evga_cursor_disable
.pic_remap:
    call pic_remap
    evga_println("PIC remapped")
.is_lm_available:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .display_info ; Skip
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .display_info ; Skip
.lm_available:
    mov [LM_SUPPORT], 1
.display_info:
.boot_device:
    evga_print(boot_device_msg)
    evga_printhex(BOOT_DEVICE)
    call evga_newline
.drive_count:
    evga_print("Drives: ")
    evga_printdec(DRIVE_COUNT)
    call evga_newline
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
    jmp .memory
.lm_supported:
    evga_print(lm_supported_msg)
.memory:
    call error32

section .data
BOOT_DEVICE db 0 ; Boot device number
DRIVE_COUNT db 0 ; How many drives has the BIOS found
A20_ENABLED db 0 ; Was A20 enabled
A20_FIRM    db 0 ; Was A20 enabled already by the CPU
A20_BIOS    db 0 ; Was A20 enabled using the BIOS method
A20_FAST    db 0 ; Was A20 enabled using Fast A20 method
LM_SUPPORT  db 0 ; Is Long Mode supported

boot_device_msg: db "Boot device: ", 0
a20_enabled_msg: db "A20 enabled using ", 0
fast_a20_msg: db "Fast A20", 0
bios_msg: db "BIOS", 0
firmware_msg: db "Firmware", 0

lm_supported_msg: db "Long Mode supported", 0 ; Yes
lm_unsuppored_msg: db "Long Mode not supported", 0 ; No