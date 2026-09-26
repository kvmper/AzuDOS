global error16
global error32

extern evga_newline
extern _evga_print

%include "include/evga_macros.asm"

BITS 16
; Blink on Caps Lock LED to indicate error
; And please clean this mess oh my god
; I should have commented this along the way i don't undrstand this
; 16 bit version
error16:
    ; Turn on Caps Lock LED
    mov bl, 0x04
    call .blink_leds
    call .err_wait ; Wait 100000000 cycles (works for now)
    ; Disable LEDs
    mov bl, 0x00
    call .blink_leds
    call .err_wait
    jmp error16
.blink_leds:
.wait_0:
    in al, 0x64
    test al, 2
    jnz .wait_0
.send_cmd:
    mov al, 0xED
    out 0x60, al
.wait_1:
    in al, 0x64
    test al, 1
    jz .wait_1
    in al, 0x60
.enable_led:
    in al, 0x64
    test al, 2
    jnz .enable_led
    mov al, bl
    out 0x60, al
    ret
.err_wait:
    mov ecx, 100000000
.spin:
    cmp ecx, 0
    je .return
    dec ecx
    jmp .spin
.return:
    ret

BITS 32
error32:
    call evga_newline
    evga_print("Encountered a critical error! (PM)")
.main_loop:
    ; Turn on Caps Lock LED
    mov bl, 0x04
    call .blink_leds
    call .err_wait ; Wait 100000000 cycles (works for now)
    ; Disable LEDs
    mov bl, 0x00
    call .blink_leds
    call .err_wait
    jmp .main_loop
.blink_leds:
.wait_0:
    in al, 0x64
    test al, 2
    jnz .wait_0
.send_cmd:
    mov al, 0xED
    out 0x60, al
.wait_1:
    in al, 0x64
    test al, 1
    jz .wait_1
    in al, 0x60
.enable_led:
    in al, 0x64
    test al, 2
    jnz .enable_led
    mov al, bl
    out 0x60, al
    ret
.err_wait:
    mov ecx, 1000000000 ; FIXXXX (change)
.spin:
    cmp ecx, 0
    je .return
    dec ecx
    jmp .spin
.return:
    ret