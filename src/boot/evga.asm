section .text
; Really basic version, improvement def needed
evga_print:
    pushad
.print:
    mov al, [si]
    mov ah, 0x0F
    or al, al
    jz .done
    mov word [edi], ax
    inc esi
    add edi, 2
    jmp .print
.done: 
    popad 
    ret