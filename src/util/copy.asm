INCLUDE "include/memory.inc"

Section "Copy", ROM0

EXPORT CopyData
EXPORT CopyDataL
EXPORT CopyDataT
EXPORT ClearData
EXPORT FillData

CopyData:   ; data from [hl], data to [de], length [b]
    .copy_data_loop
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .copy_data_loop
    ret

CopyDataL:   ; data from [hl], data to [de], length [bc]
    .copy_data_loop
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc

    ld a, b
    or c    ; to update the zero flag
    
    jr nz, .copy_data_loop
    ret

CopyDataT:   ; data from [hl], data to [de], length [b]
    ld a, e
    dec a
    ld [COPY_LOW], a
    
    .copy_data_loop
    ld a, [hl+]
    ld c, a

    and %11100000
    cp %01000000
    jr z, .letter

    ld a, c
    and %11110000
    cp %00110000
    jr z, .number

    ld a, c
    cp $0A
    jr z, .new_line

    xor a; ld a, $00
    jp .skip_t

    .new_line
    ld a, [COPY_LOW]
    add $20
    ld e, a
    ld a, $00
    add d
    ld a, e
    ld [COPY_LOW], a
    jp .skip_write

    .number
    ld a, c
    sub $30 - $1B ; from ascii digit to tiles
    jp .skip_t


    .letter
    ld a, c
    sub $40 ; from ascii to tiles

    
    .skip_t
    
    ld [de], a

    .skip_write
    
    inc de
    dec b
    jr nz, .copy_data_loop
    ret

ClearData:    ; data at [hl], length [b]
    ld a, $00
FillData:     ; data at [hl], length [b]
    .clear_data_loop
    ld [hl+], a
    dec b
    jr nz, .clear_data_loop
    ret
    
