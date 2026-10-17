extern evga_println

extern error32

global kernel_entry
kernel_entry:
    ;sti
    call error32 ; placeholder
.done:
    cli
    hlt
    jmp .done