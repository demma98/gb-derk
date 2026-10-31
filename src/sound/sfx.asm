INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Sfx", ROM0

EXPORT SFX_Set
EXPORT SFX_Tick
EXPORT SFX_Stop


SFX_Set:    ; adress of sf [hl]
    ld a, [hl+]
    ldh [SFX_LENGTH], a
    ld a, [hl+]
    ld b, a
    and %00000011
    ldh [SFX_CHANNEL], a
    ld a, b
    and %11110000
    rrca
    rrca
    rrca
    rrca
    ldh [SFX_SPEED], a

    ld a, h
    ldh [SFX_ADDR_H], a
    ld a, l
    ldh [SFX_ADDR_L], a

    xor a; ld a, 0
    ldh [SFX_TIMER], a

    ret


SFX_Tick:
    ldh a, [SFX_CHANNEL]
    cp $0f
    jr nz, .in_use
    ret
    .in_use:
    ld c, a

    ldh a, [SFX_LENGTH]
    ld b, a
    cp $00
    jr nz, .not_skip

    ldh a, [SFX_SPEED]
    cp $00
    jr z, .not_skip
    call SFX_Stop
    ret

    .not_skip:
    ld a, b
    dec a   ; decrement remaining lenght
    ldh [SFX_LENGTH], a

    ldh a, [SFX_ADDR_H]
    ld h, a
    ldh a, [SFX_ADDR_L]
    ld l, a

    ld a, c

    cp $03
    jr nz, .skip_noise
    ld b, $04
    ld de, rNR41
    call CopyData
    jr .save_hl

    .skip_noise:

    cp $00
    jr nz, .skip_square_0
    .skip_square_0:

    cp $01
    jr nz, .skip_square_1
    .skip_square_1:

        ; triangle

    .save_hl
        
    ld a, h
    ldh [SFX_ADDR_H], a
    ld a, l
    ldh [SFX_ADDR_L], a        
    ret


SFX_Stop:
    xor a ; ld a, $00
    ldh [SFX_LENGTH], a

    ldh a, [SFX_CHANNEL]
    ld b, a
    ld a, $0f
    ldh [SFX_CHANNEL], a
    ld a, b

    cp $03
    jr nz, .skip_noise
    xor a; ld a, $00
    ldh [rNR42], a
    ret
    .skip_noise:

    cp $00
    jr nz, .skip_square_0
    xor a; ld a, $00
    ldh [rNR12], a
    ret
    .skip_square_0:

    cp $01
    jr nz, .skip_square_1
    xor a; ld a, $00
    ldh [rNR22], a
    ret
    .skip_square_1:

        ; triangle
    xor a; ld a, $00
    ldh [rNR32], a
    ret