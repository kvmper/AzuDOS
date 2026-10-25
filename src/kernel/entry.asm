; entry.asm
; From here we just uhhh jump to the kernel
; and wait till ir returns (if it ever will).
; Once it does we just print the exit code
; and if exit code is non 0 then its an error

extern error32
extern main
extern kprint

global kernel_entry
kernel_entry:
    sti ; Enable interrupts
    call main
    ; Task ended
    mov [EXIT_CODE], eax ; Save exit code
    cmp [EXIT_CODE], 0 ; Is exit code 0?
    jne error32 ; No? That's too bad
.done: ; Halt
    push 0xF ; Color
    push halting_msg ; Message
    call kprint ; Print
    cli
    hlt
.spin: jmp .spin

section .data
EXIT_CODE dd 0
halting_msg: db "Halting forever...", 0