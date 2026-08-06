INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

INCLUDE "include/tiles/definitions/dialogue_box.inc"
INCLUDE "include/tiles/definitions/digits.inc"

Section "Game", ROM0

DEF MAX_LEVEL  EQU  $08

EXPORT GameStartFrom0
EXPORT GameSetup

GameStartFrom0:
  xor a ; ld a, $00
  ld a, $00
  ldh [BOARD_LEVEL], a

GameStartFromX:
  call LevelDrawBackdrop

GameSetup:

  call LoadLevel
  
  halt  ; wait for vblank
  
  ld a, %00000000
  ld [rBGP], a
  ld [rOBP0], a
  ld [rOBP1], a
  
  call GameDrawDialogueBox
  call GameSetOffsets

  ld a, $07
  ldh [WIN_X_OFF], a
  ld a, $7C
  ldh [WIN_Y_OFF], a

  call GameSetGraphics

  call ShipSetup

  ld a, %11100100
  ld [rBGP], a
  ld a, %11010000
  ld [rOBP0], a

GameLoop:
  halt

  call Game_manageInputs
  call GameSetOffsets

  call FillBlock_G
  call ShipDraw
  
  call ShipLogic

  call GameCheckWin

  jp GameLoop


GameDrawDialogueBox:
    ;draw left margin
  ld a, G_D_UP_LEFT
  ld [_SCRN1], a
  ld a, G_D_LEFT
  ld [_SCRN1 + $20], a
  ld a, G_D_DOWN_LEFT
  ld [_SCRN1 + $40], a

    ;draw right margin
  ld a, G_D_UP_RIGHT
  ld [_SCRN1 + $13], a
  ld a, G_D_RIGHT
  ld [_SCRN1 + $33], a
  ld a, G_D_DOWN_RIGHT
  ld [_SCRN1 + $53], a

    ;draw top margin
  ld a, G_D_UP
  ld b, $12
  ld hl, _SCRN1 + $01
  call FillData
  
    ;draw bottom margin
  ld a, G_D_DOWN
  ld b, $12
  ld hl, _SCRN1 + $41
  call FillData

    ; draw "LEVEL" text
  ld hl, T_Level
  ld de, _SCRN1 + $21
  ld b, T_LevelEnd - T_Level
  call CopyDataT

    ; draw level digits
  ldh a, [BOARD_LEVEL]
  add G_DIGITS
  ld [_SCRN1 + $22 + T_LevelEnd - T_Level], a
  ret


GameSetGraphics:
  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800 | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_OBJON | LCDCF_OBJ8
  ldh [rLCDC], a   ; everything on
  ret


GameSetOffsets:
  ldh a, [BOARD_X_OFF]
  ldh [rSCX], a
  ldh a, [BOARD_Y_OFF]
  ldh [rSCY], a
  ldh a, [WIN_X_OFF]
  ldh [rWX], a
  ldh a, [WIN_Y_OFF]
  ldh [rWY], a
  ret


Game_manageInputs:
  call ReadInput
  ret


GameCheckWin:
  ldh a, [EMPTY_BLOCKS_R]
  ld b, a
  ldh a, [FILLED_BLOCKS]
  cp b
  jp nz, .skip_win

  call ShipLogic
  call ShipDraw
  call FillBlock_G
  call LevelClearBoard

  ldh a, [BOARD_LEVEL]
  inc a
  ldh [BOARD_LEVEL], a
  cp MAX_LEVEL

  jr nz, .jump_to_next_level

  pop bc
  jp WinJump

  .jump_to_next_level
  pop bc
  jp GameFadeOutSetup

  .skip_win
  ret


GameFadeOutSetup:
    ; setup fade animation
  ld a, FADE_C_SET - 1
  ldh [FADE_C], a
  ld a, FADE_T_SET
  ldh [FADE_T], a
  ld a, $08
  ldh [FADE_T_L], a

  xor a ; ld a, $00
  ld [_OAMRAM], a ; hide ship
  

GameFadeOutLoop:
  halt

  call ReadInput
  
  ld hl, P_FadeOutB
  call Fading

  ldh a, [FADE_C]
  or $00
  jr nz, GameFadeOutLoop

  jp GameSetup


T_Level:
db "LEVEL"
T_LevelEnd:
