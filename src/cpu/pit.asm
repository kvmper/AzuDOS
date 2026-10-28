global pit_init
global pit_irq0
global ticks

pit_init:
    mov al, 0x36
    out 0x43, al
    mov al, ((1193182 / 100) & 0xFF)
    out 0x40, al
    mov al, (((1193182 / 100) >> 8) & 0xFF)
    out 0x40, al
    ret

pit_irq0:
    inc dword [ticks]
    mov al, 0x20
    out 0x20, al
    iret

section .data
ticks: dd 0