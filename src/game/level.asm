INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Level", ROM0

EXPORT LoadLevel
EXPORT LevelGetHeader


DEF BLOCK_EMPTY  EQU $00
DEF BLOCK_SOLID  EQU $01
; what graphics to use
DEF BLOCK_EMPTY_G  EQU $00
DEF BLOCK_SOLID_G  EQU $80


LoadLevel:  ; number of the level [b]

  ld a, b
  ldh [BOARD_LEVEL], a

  call LevelGetHeader
  call LevelStoreInfo
  call LevelStoreData
  call LevelCalcOffsets
  call LevelDrawBackdrop
  call LevelDrawBoard
  
  ret


LevelGetHeader:  ; number of the level [b], return address in [hl]
  inc b
  ld hl, LevelData

  .levelLoop

  ld a, [hl]
  add a, l
  ld l, a
  ld a, $00
  add a, h
  ld h, a

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

  ret


LevelStoreData:  ; level data from [hl]
  
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
    jp c, .load_solid_block
    
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

  ldh a, [BOARD_TEMP]
  dec a
  ldh [BOARD_TEMP], a
  jp nz, .loop_h

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


LevelDrawBackdrop:  ; only fill visible area
    ; get starting tile
  ld hl, _SCRN0 + $1F
  ldh a, [BOARD_WIDTH]
  xor $FF
  rrc a
  add l
  ld l, a

  ldh a, [BOARD_HEIGHT]
  and %11111110
  rrc a
  xor $FF
  add $12
  ld d, a
  ld c, $13

  halt  ; wait for vblank

  .loop_h
  ld a, BLOCK_SOLID_G
  ld b, $14  ; width of visible area in tiles
    .loop_w
    ld [hl+], a
    dec b
    jp nz, .loop_w

  ld a, l
  add $20 - $14
  ld l, a

    ; wait for vblank every 2 rows
  ld a, c
  and $01
  jp nz, .skip_halt
  halt

  .skip_halt
  
  dec d
  jp nz, .skip_top_part
    ; move the hl address to fill the tiles that will appear on the top
  ld a, l
  add $80
  ld l, a
  ld a, h
  adc $01
  ld h, a
  .skip_top_part
  
  dec c
  jp nz, .loop_h


  halt  ; wait for vblank to fill missing portions
  ld a, BLOCK_SOLID_G
    ; fill missing top portion
  ld hl, _SCRN0
  ld b, $10
  .loop_missing_top
  ld [hl+], a
  dec b
  jp nz, .loop_missing_top
    ; fill missing bottom portion
  ld hl, _SCRN1 - $10
  ld b, $10
  .loop_missing_bottom
  ld [hl+], a
  dec b
  jp nz, .loop_missing_bottom
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
    xor $00
    jp nz, .skip_draw
    ld [de], a
    .skip_draw

    inc de
    dec b
    jp nz, .loop_w
  ld a, e
  and %11100000
  add $20
  ld e, a
  ld a, d
  adc $00
  ld d, a
  
  dec c
  jp nz, .loop_h
  
  ret


Section "LevelsData", ROMX

LevelData:

Level_0:  ; just to make the algorithms easier
  db $01
Level_0End:

Level_1:
  db $0C  ; size in bytes of the level, including this byte
  db $08, $07 ; width and height of level
  ; 0 is empty tile, 1 is solid tile
  db %00000000
  db %10000000
  db %11000001
  db %11000011
  db %11100011
  db %11100111
  db %11101111
Level_1End:

LevelDataEnd:

