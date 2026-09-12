BITS 16
ORG 0X1000
CPU 386

loader_start:
    mov ah, 0x0E
    mov al, 'L'
    int 0x10
    cli
    hlt