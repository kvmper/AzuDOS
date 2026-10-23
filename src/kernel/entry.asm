; entry.asm
; From here we just uhhh jump to the kernel
; and wait till ir returns (if it ever will).
; Once it does we just print the exit code
; and if exit code is non 0 then its an error

extern evga_println
extern evga_newline

extern error32
extern init_main

%include "include/evga_macros.asm"

global kernel_entry
kernel_entry:
    sti
    call init_main
    ; Task ended
    mov byte [EXIT_CODE], al
    call evga_newline ; Temporary new line 
    evga_print("Task exited with exit code ")
    evga_printdec(EXIT_CODE)
    cmp byte [EXIT_CODE], 0
    jne error32
.done: ; Halt
    cli
    hlt
.spin: jmp .spin

EXIT_CODE dw 0