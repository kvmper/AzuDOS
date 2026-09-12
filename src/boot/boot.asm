BITS 16 ; Execution starts in 16 bits (real mode)
ORG 0x0600 ; Memory addresses start at 0x0600 (this way we don't have to type + 0x0600 if we want to access something)
CPU 386 ; Intel 80386 CPU

boot_start:
    cli ; Clear interrupts
    cld ; Clear direction flag
    xor ax, ax ; Zero AX
    mov ds, ax ; Data seg = 0
    mov es, ax ; Extra seg = 0
.stack_setup: ; Setup stack
    mov ss, ax ; Stack seg = 0
    mov sp, ax ; Stack ptr = 0
.relocate: ; Copies the MBR to the target address
    mov cx, 512 ; 512 bytes
    mov si, 0x7C00 ; Curent address
    mov di, 0x0600 ; Target address
    rep movsb ; Copy entire sector from 0x7C00 - 0x7E00
              ; To 0x0600 - 0x0800
    jmp 0:relocated_start ; Start executing code at relocated position and flush CS

; Located at 0x0600
relocated_start:
.stack_setup: ; Setup stack
    mov sp, 0x0600 ; Set stack at 0x0600
.vga_setup:
    mov ax, 0x0003
    int 0x10
.check_if_floppy:
    cmp dl, 0x80
    jae .disk_setup ; It's a hard disk!
.floppy: ; It's a floppy! floppys are not supported
    ; Implement more functionality later
    jmp error
.disk_setup:
    sti ; Enable interrupts
; First we need to check if we can read sectors using LBA
.lba_check_extensions: ; Check if LBA extensions are available
    mov ah, 0x41
    mov bx, 0x55AA ; If available, BIOS should have reversed this value
    int 0x13 ; Invoke BIOS interrupt
    jc error ; Error!
    cmp bx, 0xAA55 ; This should be the value in the BX register if successfull
    jne error ; Not supported
    ; Supported? Continue
; Okay now we need to read some more sectors, let's read 4KB
; Each sector is 512 bytes so to read 4KB we need to read 8 sectors
; We declared this in the Disk Address Packet, and to read from it we need to move our Source Index to it
.lba_read:
    mov ah, 0x42 ; LBA Read sectors
    mov si, dap ; Move SI to point at the DAP
    int 0x13 ; Invoke BIOS interrupt
    jc error ; Uh oh, error! Theres likely something wrong with the DAP
    jmp 0:0x1000 ; Jump to loader

; General error handler
error:
; We might want to improve this function by:
; - printing registers (AX, BX, etc..)
; - printing the error code (i forgot, i think its stored in dh? dl? or dx?), nevermind, AH register...

; Show E and stop
    cli
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    hlt
.loop: jmp .loop

dap:
    .packet: db 0x10
    .reserved: db 0
    .sectors: dw 8
    .offset: dw 0x1000
    .segment: dw 0
    .lba: dq 1

BOOT_DRIVE db 0 ; Where we store the boot drive number
; 0x80 and more for hard disk
; 0x7F and less for floppy

times 510 - ($-$$) db 0 ; Pad to 510 bytes
db 0x55, 0xAA ; Signature (now the binary file is exactly 512 bytes, 1 sector)
; The BIOS searches for the signature 0xAA55, little endian (or 0x55, 0xAA)
; and if it finds that signature in the correct spot it executes the sector with that signature
; 0x55 (Byte 511, Offset 510)
; 0xAA (Byte 512, Offset 511)