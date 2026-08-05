INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

EXPORT Reset

SECTION "VBlank Interrupt", ROM0[$0040]
VBlankInterrupt:
    reti

SECTION "Header", ROM0[$100]

	jp Setup

	ds $150 - @, 0 ; make room for the header

Reset:
    ld sp, SP_INIT

INCLUDE "include/asm/setup.asm"

INCLUDE "include/asm/demma.asm"

INCLUDE "include/asm/titleCard.asm"

MainLoop:    ; just to catch code
    halt    ; wait for vblank
    jr MainLoop

