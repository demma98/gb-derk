INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

SECTION "VBlank Interrupt", ROM0[$0040]
VBlankInterrupt:
    reti

SECTION "Header", ROM0[$100]

	jp Setup

	ds $150 - @, 0 ; make room for the header

INCLUDE "include/asm/setup.asm"

INCLUDE "include/asm/demma.asm"

INCLUDE "include/asm/titleCard.asm"

MainLoop:
    halt    ; wait for vblank

    ;call RenderCursor

    jr MainLoop

