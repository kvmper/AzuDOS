OUTPUT_FORMAT(elf32-x86-64)
ENTRY(loader_start)

PHDRS {
    text PT_LOAD FLAGS(5);
    data PT_LOAD FLAGS(6);
}

SECTIONS {
    . = 0x1000;
    __kernel_start = .;

    .text ALIGN(4) : {
        __text_start = .;
        *(.text .text.*)
        __text_end = .;
    } :text

    .rodata ALIGN(4) : {
        __rodata_start = .;
        *(.rodata .rodata.*)
        __rodata_end = .;
    } :text

    .data ALIGN(4) : {
        __data_start = .;
        *(.data .data.*)
        __data_end = .;
    } :data

    .bss ALIGN(4) : {
        __bss_start = .;
        *(.bss .bss.* COMMON)
        __bss_end = .;
    }

    __kernel_end = .;

    /DISCARD/ : {
        *(.interp)
        *(.dynsym)
        *(.dynstr)
        *(.gnu.hash)
        *(.note.gnu.property)
        *(.note.gnu.build-id)
        *(.rel.dyn)
        *(.dynamic)
        *(.debug_info)
        *(.debug_abbrev)
        *(.debug_loclists)
        *(.debug_aranges)
        *(.debug_rnglists)
        *(.debug_line)
        *(.debug_str)
        *(.debug_line_str)
        *(.comment)
        *(.eh_frame)
        *(.eh_frame_hdr)
    }
}