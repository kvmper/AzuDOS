extern evga_println

extern error32
extern init_main

%include "include/evga_macros.asm"

global kernel_entry
kernel_entry:
    ;sti
    call init_main ; placeholder
    mov byte [EXIT_CODE], al
    evga_print("Task exited with exit code ")
    evga_printdec(EXIT_CODE)
    cmp byte [EXIT_CODE], 1
    je error32
.done:
    cli
    hlt
.spin: jmp .spin

EXIT_CODE db 0