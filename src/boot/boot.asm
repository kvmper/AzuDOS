BITS 16 ; Execution starts in 16 bits (real mode)
ORG 0x0600 ; Memory addresses start at 0x0600 (this way we don't have to type + 0x0600 if we want to access something)
CPU 386 ; Intel 80386 CPU

; For now, the loader is at a fixed address, we probably want to change that later
; Other improvements include error handling and code safety (idk if code is even unsafe)

; TO FIX:
;   - Boot device on asus vivobook X512UA showing 0x00 even though it's not a floppy
;     it passes check if floppy and doesn't give an error
;     could be a loader issue..

boot_start:
    cli ; Clear interrupts
    cld ; Clear direction flag
    xor ax, ax ; Zero AX
    mov ds, ax ; Data seg = 0
    mov es, ax ; Extra seg = 0
    ;mov byte [BOOT_DEVICE + 0x7600], dl ; Preserve boot device
.stack_setup: ; Setup stack
    mov ss, ax ; Stack seg = 0
    mov sp, 0x0600 ; Stack ptr = 0x0600
.relocate: ; Copies the MBR to the target address
    mov cx, 512 ; 512 bytes
    mov si, 0x7C00 ; Curent address
    mov di, 0x0600 ; Target address
    rep movsb ; Copy entire sector from 0x7C00 - 0x7E00
              ; To 0x0600 - 0x0800
    jmp 0:relocated_start ; Start executing code at relocated position and flush CS

; Located at 0x0600
relocated_start:
.vga_setup:
    mov ax, 0x0003 ; Set video mode and set it to mode 3 (AH = 0, AL = 0x03)
    int 0x10 ; Invoke BIOS video interrupt
.check_if_floppy:
    cmp dl, 0x80 ; The BIOS stores the boot device number in the DL register
    ; If the value is 0x7F or less, it's a floppy
    ; If the value is 0x80 or more, it's a hard disk
    jae .disk_setup ; It's a hard disk!
.floppy: ; It's a floppy! floppys are not supported
    push ax
    mov si, floppy_msg
    call print_msg
    pop ax
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
; Okay now we need to read some more sectors, let's read 32KB
; Each sector is 512 bytes so to read 32KB we need to read 64 sectors
; We declared this in the Disk Address Packet, and to read from it we need to move our Source Index to it
.lba_read:
    mov ah, 0x42 ; LBA Read sectors
    mov si, dap ; Move SI to point at the DAP
    int 0x13 ; Invoke BIOS interrupt
    jc error ; Uh oh, error! Theres likely something wrong with the DAP
.jump_loader:
    cli ; Clear interrupts before jumping to loader
    ;mov dl, [BOOT_DEVICE] ; Pass boot device number to loader
    jmp 0:0x1000 ; Jump to loader (0x1000), CS = 0

print_msg:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_msg
.done:
    ret

print_hex:
    mov si, hex_prefix ; Print hex prefix (0x)
    call print_msg
    push bx
    call .get_nibble ; Get high and low nibble n print them
    pop bx
    ret
.get_nibble:
    ; High
    mov al, bl
    shr al, 4
    call .convert ; Convert to ascii
    call .print

    ; Low
    mov al, bl
    and al, 0x0F
    call .convert ; Convert to ascii
    call .print
    ret
.convert:
    cmp al, 10
    jl .digit
    add al, 7 ; Letter
.digit:
    add al, '0' ; Turn into ascii (48 decimal)
    ret
.print:
    mov ah, 0x0E ; BIOS Teletype mode (or whatever it is called)
    int 0x10 ; Invoke BIOS interrupt
    ret


; General error handler
error:
    cli
    mov byte [ERROR_CODE], ah ; Preserve error code (so it wont get overwritten)
    mov si, error_msg
    call print_msg
    mov si, error_code_msg
    call print_msg
    mov bx, [ERROR_CODE]
    call print_hex
    hlt
.loop: jmp .loop

dap:
    .packet: db 0x10 ; Size of packet (16 bytes, 0x10)
    .reserved: db 0 ; Always 0 
    .sectors: dw 32 ; Number of sectors to transfer (max 127 on some BIOSes), 32 KB
    ; Transfer buffer (16 bit segment:16 bit offset)
    .offset: dw 0x1000
    .segment: dw 0
    .lba: dq 1 ; LBA address of sector to read from disk 

BOOT_DEVICE db 0
ERROR_CODE db 0

error_msg: db "Error (MBR)", 0x0A, 0x0D, 0
error_code_msg: db "Error code: ", 0
floppy_msg: db "Floppy drives are not supported", 0x0A, 0x0D, 0
hex_values db "0123456789ABCDEF", 0
hex_prefix db "0x", 0

times 510 - ($-$$) db 0 ; Pad to 510 bytes
db 0x55, 0xAA ; Signature (now the binary file is exactly 512 bytes, 1 sector)
; The BIOS searches for the signature 0xAA55, little endian (or 0x55, 0xAA)
; and if it finds that signature in the correct spot it executes the sector with that signature
; 0x55 (Byte 511, Offset 510)
; 0xAA (Byte 512, Offset 511)