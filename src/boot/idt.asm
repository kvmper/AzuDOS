global idt_setup
global IDT_INIT
idt_setup:
    mov edi, idt_entries ; Empty 256 entrys
    mov edx, idt_ignore
    mov eax, 0x00080000 ; CS selector
    mov ax, dx
    and edx, 0xFFFF0000
    or edx, 0x8E00
    mov ecx, 256 ; For 256 entries
.loop:
    mov [edi], eax ; Lower 4 bytes
    mov [edi + 4], edx ; Upper 4 bytes
    add edi, 8 ; Now continue to the next entry
    dec ecx ; Next entry
    jne .loop ; Repeat till no more entries
    lidt [idt_desc] ; Load the IDT
    mov byte [IDT_INIT], 1 ; Let us know IDT has been intialized
    ret ; Done
idt_ignore:
    iret

section .data
IDT_INIT: db 0

idt_desc: ;2048
    dw 2047
    dd idt_entries

section .bss
idt_entries: resq 256 ; 8x256 (8 bytes each entry)