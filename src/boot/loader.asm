BITS 16 ; Still executing in real mode

; A20
extern check_a20
extern bios_a20
extern check_a20
extern fast_a20

; PIC
extern pic_remap
extern PIC_INIT

; IDT
extern idt_setup
extern IDT_INIT

; EVGA
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

; Error handlers
extern error16
extern error32

; Kernel related
extern kernel_entry

; CPUID
EFLAGS_ID equ 1 << 21 ; If can be flipped, CPUID instruction is available

; For Long Mode
CPUID_EXTENSIONS equ 0x80000000 ; returns the maximum extended requests for cpuid
CPUID_EXT_FEATURES equ 0x80000001 ; returns flags containing long mode support among other things
CPUID_EDX_EXT_FEAT_LM equ 1 << 29   ; if this is set, the CPU supports long mode

section .text
%include "include/evga_macros.asm"

global loader_start
loader_start:
    mov byte [BOOT_DEVICE], dl ; Save boot device number for later
    mov ah, 0x08 ; How many drives are connected
    int 0x13 ; Invoke BIOS disk interrupt
    mov byte [DRIVE_COUNT], dl ; Save how many drives detected for later
    cli ; Clear interrupts
.stack_setup:
    xor ax, ax ; 0
    mov sp, ax ; 0 and then wraps to 0xFFFF
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
.a20_enabled_firmware: ; A20 was already enabled
    mov byte [A20_FIRM], 1
    jmp .a20_enabled
.a20_enabled_fast: ; A20 was enabled by Fast A20
    mov byte [A20_FAST], 1
    jmp .a20_enabled
.a20_enabled_bios: ; A20 was enabled with BIOS interrupts
    mov byte [A20_BIOS], 1
.a20_enabled: ; A20 was enabled with any method
    mov byte [A20_ENABLED], 1
.lower_memory:
    clc ; Clera carry flag
    int 0x12 ; Request low memory size
    jc error16
    mov [LOW_MEMORY], ax
.upper_memory:
    ; Via E820 mem map, gonna implement later

pm_setup:
    cli ; Clear interrupts
    ; Disable NMI
    mov al, 0x80
    out 0x70, al
    in al, 0x71
    
    lgdt[gdt_desc] ; Load GDT Descriptor

    ; Set protection enable bit in CR0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:pm_main ; Jump to Protected Mode
    ; 0x08 - Code Segment selector

; Sources
; https://cdrdv2-public.intel.com/929349/325462-093-sdm-vol-1-2abcd-3abcd-4.pdf
; Starting at page 3246 or 3245, vol. 3A 3-9 to vol. 3A 3-11
; https://wiki.osdev.org/Global_Descriptor_Table
gdt:
    dq 0x00000000 ; Null descriptor
gdt_code_seg:
    dw 0xFFFF ; Limit
    dw 0x0000 ; Base (bits 0-15)
    db 0x00 ; Base (bits 16-23)
    db 10011011b ; Access byte
    ; P = 1 (Must be always 1)
    ; DPL = 00 (Ring 0)
    ; S = 1 (Code or Data segment)
    ; E = 1 (Executable)
    ; DC = 0 (Can only be executed by DPL)
    ; RW = 1 (Readable)
    ; A = 1 (Accessed bit)

    db 11001111b ; Flags
    ; G = 1 (Granularity)
    ; DB = 1 (32-bit segment)
    ; L = 0 (Not Long Mode)
    ; AVL = 0 (Not available for use by system software)
    ; Limit = 1111 (Segment limit)

    db 0x00 ; Base (bits 24-31)
gdt_data_seg:
    dw 0xFFFF ; Limit
    dw 0x0000 ; Base (bits 0-15)
    db 0x00 ; Base (bits 16-23)
    db 10010011b ; Access byte
    ; P = 1 (Must be always 1)
    ; DPL = 00 (Ring 0)
    ; S = 1 (Code or Data segment)
    ; E = 0 (Not executable)
    ; DC = 0 (Segment grows up)
    ; RW = 1 (Writeable)
    ; A = 1 (Accessed bit)

    db 11001111b ; Flags
    ; G = 1 (Granularity)
    ; DB = 1 (32-bit segment)
    ; L = 0 (Not Long Mode)
    ; AVL = 0 (Not available for use by system software)
    ; Limit = 1111 (Segment limit)
    db 0x00 ; Base (bits 24-31)
gdt_end:

gdt_desc:
    dw (gdt_end - gdt - 1) ; GDT limit
    dd gdt ; GDT base

BITS 32 ; Now we're in Protected Mode
pm_main:
    clc ; Clear carry flag
    cli ; Clear interrupts
    mov eax, 0x10 ; Set EAX to Data Segment selector so we can load segments with this value.
    ; Set segments to Data Segment selector
    mov ds, eax ; DS = 0x10
    mov es, eax ; ES = 0x10
    mov fs, eax ; FS = 0x10
    mov gs, eax ; GS = 0x10
.setup_stack:
    mov ss, eax ; SS = 0x10
    mov esp, 0x90000
.enable_nmi: ; Enable Not Maskable Interrupts
    mov al, 0
    out 0x70, al
    in al, 0x71
.cpu_setuo:
    call pic_remap ; Remap using 8259 PIC (Programmable Interrupt Controller)
    call idt_setup ; Setup Interrupt Descriptor Table so no crashes if interrupts are enabled
.video_setup: ; Video setup, so we can print to VGA
    call evga_setup
    call evga_cursor_disable ; Disable the VGA cursor
    evga_println("VGA Text Mode initialized")
.check_cpuid: ; EAX = 1 - CPUID supported
; Probably works, but I have a feeling it doesnt...
    pushfd ; Preserve EFLAGS
    pop eax
    ; Save for later for comparision
    mov ecx, eax
    xor eax, EFLAGS_ID
    ; Check if the bit was flipped
    push eax
    popfd
    pushfd
    pop eax
    ; Restore EFLAGS
    push ecx
    popfd
    ; If flipped, CPUID is supported
    xor eax, ecx
    jnz .supported
.not_supported:
    jmp error32
.supported:
    evga_println("CPUID supported")
.is_lm_available: ; Check if Long Mode is available 
    mov eax, CPUID_EXTENSIONS
    cpuid
    cmp eax, CPUID_EXT_FEATURES
    jb .display_info ; Skip, this machine does not support Long Mode
    mov eax, CPUID_EXT_FEATURES
    cpuid
    test edx, CPUID_EDX_EXT_FEAT_LM
    jz .display_info ; Skip, not set, Long Mode not supported
.lm_available:
    mov byte [LM_SUPPORT], 1 ; Long Mode is supported
.display_info:
    cmp byte [IDT_INIT], 0
    je .boot_device
    cmp byte [PIC_INIT], 0
    je .boot_device
    evga_println("IDT initialized")
    evga_println("PIC remapped")
.boot_device:
    evga_print(boot_device_msg)
    evga_printhex(BOOT_DEVICE) ; Print boot device number in hex
    call evga_newline ; Create a new line
.drive_count:
    evga_print("Drives: ")
    evga_printdec(DRIVE_COUNT) ; Print drive number in decimal
    call evga_newline ; Create a new line
.a20_info:
    evga_print(a20_enabled_msg)
    cmp byte [A20_FIRM], 1 ; Was A20 already enabled by firmware
    je .a20_firm
    cmp byte [A20_BIOS], 1 ; Was A20 enabled by BIOS
    je .a20_bios
    cmp byte [A20_FAST], 1 ; Was A20 enabled by Fast A20
    je .a20_fast
.a20_firm: ; Print that A20 was already enabled
    evga_println(firmware_msg)
    jmp .lm_info
.a20_bios: ; Print that we enabled A20 using the BIOS method
    evga_println(bios_msg)
    jmp .lm_info
.a20_fast: ; Print that we enabled A20 using Fast A20 method
    evga_println(fast_a20_msg)
    jmp .lm_info
.lm_info: ; Check if Long Mode (64 bit mode) is supported
    cmp byte [LM_SUPPORT], 1 ; Check if LM_SUPPORT = 1
    je .lm_supported ; Yes it does
    ; Else
    evga_println(lm_unsuppored_msg) ; Print LM is unsupported
    jmp .memory ; Jump to next step
.lm_supported: ; LM_SUPPORT = 1
    evga_println(lm_supported_msg) ; Print LM is supported
.memory:
.lower_memory: ; Up to 640 KB
    evga_print("Lower Memory: ")
    evga_printdec(LOW_MEMORY) ; Low mem is in KB
    evga_print(" KB")
    call evga_newline
.upper_memory:
    evga_print("Upper Memory: ")
    evga_print("No data") ; Placeholder
    call evga_newline
    
loader_done:
    jmp kernel_entry

section .data
BOOT_DEVICE db 0 ; Boot device number
DRIVE_COUNT dw 0 ; How many drives has the BIOS found
A20_ENABLED db 0 ; Was A20 enabled
A20_FIRM    db 0 ; Was A20 enabled already by the CPU
A20_BIOS    db 0 ; Was A20 enabled using the BIOS method
A20_FAST    db 0 ; Was A20 enabled using Fast A20 method
LM_SUPPORT  db 0 ; Is Long Mode supported

LOW_MEMORY dw 0 ; Low memory (up to 640 kb)

; Some messages we used
boot_device_msg: db "Boot device: ", 0
a20_enabled_msg: db "A20 enabled using ", 0
fast_a20_msg: db "Fast A20", 0
bios_msg: db "BIOS", 0
firmware_msg: db "Firmware", 0
lm_supported_msg: db "Long Mode supported", 0 ; Yes
lm_unsuppored_msg: db "Long Mode not supported", 0 ; No