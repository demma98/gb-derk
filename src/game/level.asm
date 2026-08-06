INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Level", ROM0

INCLUDE "include/asm/blocks.inc"

EXPORT LoadLevel
EXPORT LevelGetHeader
EXPORT LevelDrawBackdrop
EXPORT LevelClearBoard
EXPORT FillBlock
EXPORT FillBlock_G

; what graphics to use
DEF BLOCK_EMPTY_G  EQU $00
DEF BLOCK_SOLID_G  EQU $80
DEF BLOCK_FILLED_G EQU $81
DEF DARKER_BRICK_G EQU $82


LoadLevel:  ; number of the level and store it on b
  ldh a, [BOARD_LEVEL]
  ld b, a

  call LevelGetHeader

  ld a, d
  ldh [BOARD_LEVEL_1], a
  ld a, e
  ldh [BOARD_LEVEL_0], a
  
  call LevelStoreInfo
  call LevelStoreData
  call LevelCalcEmptyBlocks
  call LevelCalcOffsets
  call LevelDrawBoard
  
  ret


LevelGetHeader:  ; number of the level [b], return address in [hl], return decimal representation in [de]
  inc b
  ld hl, LevelData

  ld d, $00
  ld e, $00

  .levelLoop

  ld a, [hl]
  add a, l
  ld l, a
  ld a, $00
  adc a, h
  ld h, a

    ; calculate decimal representation here
  inc e
  ld a, e
  cp $0A
  jr nz, .skip_2nd_digit

  inc d
  ld e, $00

  .skip_2nd_digit

  dec b
  jp nz, .levelLoop

  ret


LevelStoreInfo:  ; level data from [hl]
  inc hl  ; skip level byte size
  ld a, [hl+]
  ldh [BOARD_WIDTH], a
  
  ld a, [hl+]
  ldh [BOARD_HEIGHT], a
  ldh [BOARD_TEMP], a

    ; load spawn coordinates
  ld a, [hl+]
  ldh [SHIP_X_R], a
  
  ld a, [hl+]
  ldh [SHIP_Y_R], a

  ret


LevelStoreData:  ; level data from [hl]
  ldh a, [BOARD_WIDTH]
  dec a
  and %11111000
  jr nz, .load_large

  call LevelStoreData_Simple
  ret

  .load_large
  call LevelStoreData_Large
  ret


LevelStoreData_Simple:  ; level data from [hl], width <= 8
  ld de, wBOARD_DATA

  ; load level data into work ram and vram

  .loop_h

  ldh a, [BOARD_WIDTH]
  ld b, a
  ld a, [hl+]
  ld c, a
    
    .loop_w ; loop to load row
    ld a, c
    rl a
    ld c, a
    jp C, .load_solid_block
    
    .load_empty_block
    ld a, BLOCK_EMPTY
    jp .skip
    
    .load_solid_block
    ld a, BLOCK_SOLID
    
    .skip

    ld [de], a
    
    inc de
    dec b
    jp nz, .loop_w
  ld a, e
  and %11110000
  add $10
  ld e, a

  ldh a, [BOARD_TEMP]
  dec a
  ldh [BOARD_TEMP], a
  jp nz, .loop_h
  ret


LevelStoreData_Large:  ; level data from [hl], width > 8
  ld de, wBOARD_DATA
  
  ; load level data into work ram and vram

  .loop_h
    ; first byte
  ld b, $08
  ld a, [hl+]
  ld c, a
    .loop_w ; loop to load row
    ld a, c
    rl a
    ld c, a
    jp C, .load_solid_block
    
    .load_empty_block
    ld a, BLOCK_EMPTY
    jp .skip
    
    .load_solid_block
    ld a, BLOCK_SOLID
    
    .skip

    ld [de], a

    inc de
    dec b
    jp nz, .loop_w
    ; second byte
  ldh a, [BOARD_WIDTH]
  sub $08
  ld b, a
  ld a, [hl+]
  ld c, a
    .loop_w_1 ; loop to load row
    ld a, c
    rl a
    ld c, a
    jp C, .load_solid_block_1
    
    .load_empty_block_1
    ld a, BLOCK_EMPTY
    jp .skip_1
    
    .load_solid_block_1
    ld a, BLOCK_SOLID
    
    .skip_1

    ld [de], a

    inc de
    dec b
    jp nz, .loop_w_1
  ld a, e
  and %11110000
  add $10
  ld e, a

  ldh a, [BOARD_TEMP]
  dec a
  ldh [BOARD_TEMP], a
  jp nz, .loop_h
  ret


LevelCalcEmptyBlocks:
  ldh a, [BOARD_WIDTH]
  ld d, a
  ldh a, [BOARD_HEIGHT]
  ld c, a
  ;inc c

  ld e, $00

  ld hl, wBOARD_DATA

  .loop_h
  ld b, d
    .loop_w
    ld a, [hl+]
    cp $00
    jr nz, .skip_count
    inc e
    
    .skip_count
    
    dec b
    jr nz, .loop_w

  ld a, l
  and %11110000
  add $10
  ld l, a
  ld a, $00
  adc h
  ld h, a
  
  dec c
  jr nz, .loop_h

  ld a, e
  ldh [EMPTY_BLOCKS_R], a
  ret


LevelCalcOffsets:
  ldh a, [BOARD_WIDTH]
  xor $FF  ; negate bits
  add $14  ; width in tiles of gb screen

  rlc a  ; mutiply by 4
  rlc a
  xor %11111100  ; negate bytes
  ldh [BOARD_X_OFF], a

  
  ldh a, [BOARD_HEIGHT]
  xor $FF  ; negate bits
  add $10  ; height in tiles of gb screen minus space for status bar
  ld b, a

  rlc a  ; mutiply by 4
  rlc a
  xor %11111100  ; negate bytes
  ldh [BOARD_Y_OFF], a
  
  ret


LevelDrawBackdrop:  ; fill everything with bricks
  ld b, BLOCK_SOLID_G
  ld hl, _SCRN0

  .loop_h
  halt
  ld a, b
  ld c, $80
    .loop_w_0
    ld [hl+], a
    dec c
    jp nz, .loop_w_0
  ld a, h
  cp $9C
  jp nz, .loop_h
  
  ret


LevelClearBoard:
  ld hl, _SCRN0
  ldh a, [BOARD_WIDTH]
  add $02
  ld d, a
  ldh a, [BOARD_HEIGHT]
  add $01
  ld c, a

  .loop_h
  halt
  ld a, BLOCK_SOLID_G
  ld b, d
    .loop_w
    ld [hl+], a
    dec b
    jr nz, .loop_w
    
  ld a, l
  and %11100000
  add $20
  ld l, a
  ld a, h
  adc $00
  ld h, a
  
  dec c
  jr nz, .loop_h
  
  ret


LevelDrawBoard:  ; set vram tiles from wBOARD_DATA
  ld hl, wBOARD_DATA
  ld de, _SCRN0

  ld a, [BOARD_HEIGHT]
  ld c, a

  halt  ; wait for vblank

  .loop_h
  
  ldh a, [BOARD_WIDTH]
  ld b, a
    .loop_w
    ld a, [hl+]
    cp $00
    jr nz, .skip_empty
    ld a, BLOCK_EMPTY_G
    jr .skip_to_draw
    .skip_empty
    ld a, DARKER_BRICK_G
    
    .skip_to_draw
    ld [de], a

    inc de
    dec b
    jp nz, .loop_w
  ld a, l
  and %11110000
  add $10
  ld l, a
  ld a, $00
  adc h
  ld h, a
  
  ld a, e
  and %11100000
  add $20
  ld e, a
  ld a, d
  adc $00
  ld d, a

  
    ; wait for vblank every 2 rows
  ld a, c
  and $01
  jp nz, .skip_halt
  halt

  .skip_halt
  
  dec c
  jp nz, .loop_h
  
  ret


FillBlock:  ; note block at (d, e) to be updated
  ld a, d
  ldh [FILL_BLOCK_H], a
  ld a, e
  ldh [FILL_BLOCK_L], a
  ld a, $01
  ld [FILL_BLOCK], a

  ldh a, [FILLED_BLOCKS]
  inc a
  ldh [FILLED_BLOCKS], a
  ret


FillBlock_G: ; set vram for the filled block if necessary
  ldh a, [FILL_BLOCK]
  cp $00
  jp z, .skip_fill
  
  ld hl, _SCRN0
  ld a, [FILL_BLOCK_H]
  and %00000111
  rlc a
  rlc a
  rlc a
  rlc a
  rlc a
  ld b, a
  ldh a, [FILL_BLOCK_L]
  add b
  adc l
  ld l, a
  ld a, [FILL_BLOCK_H]
  and %11111000
  rrc a
  rrc a
  rrc a
  adc h
  ld h, a
  ld a, BLOCK_FILLED_G
  ld [hl], a

  xor a ; ld a, $00
  ldh [FILL_BLOCK], a
  .skip_fill
  
  ret

