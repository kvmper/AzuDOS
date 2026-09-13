BITS 32

PIC1            equ 0x20
PIC2            equ 0xA0
PIC1_COMMAND    equ PIC1
PIC1_DATA       equ PIC1 + 1
PIC2_COMMAND    equ PIC2
PIC2_DATA       equ PIC2 + 1

ICW1_ICW4       equ 0x01
ICW1_SINGLE     equ	0x02
ICW1_INTERVAL4  equ 0x04
ICW1_LEVEL      equ	0x08
ICW1_INIT       equ	0x10

ICW4_8086       equ	0x01
ICW4_AUTO	    equ 0x02
ICW4_BUF_SLAVE  equ	0x08
CW4_BUF_MASTER  equ	0x0C
ICW4_SFNM	    equ 0x10

pic_remap:
    mov al, ICW1_INIT | ICW1_ICW4
    out PIC1_COMMAND, al
    call io_wait
    out PIC2_COMMAND, al
    call io_wait

    mov al, 0x20
    out PIC1_DATA, al
    call io_wait
    mov al, 0x28 
    out PIC2_DATA, al
    call io_wait

    mov al, 4
    out PIC1_DATA, al
    call io_wait
    mov al, 2
    out PIC2_DATA, al
    call io_wait

    mov al, ICW4_8086
    out PIC1_DATA, al
    call io_wait
    out PIC2_DATA, al
    call io_wait

    mov al, 0x00
    out PIC1_DATA, al
    out PIC2_DATA, al
    ret
io_wait:
    out 0x80, al
    ret