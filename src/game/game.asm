INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

INCLUDE "include/tiles/definitions/dialogue_box.inc"
INCLUDE "include/tiles/definitions/digits.inc"

Section "Game", ROM0

EXPORT GameSetup

GameSetup:
  ld b, $00

  call LoadLevel

  halt  ; wait for vblank
  call GameDrawDialogueBox
  call GameSetGraphics
  call GameSetOffsets
  
  ld a, %11100100
  ld [rBGP], a
  ld [rOBP0], a

  ld a, $07
  ldh [WIN_X_OFF], a
  ld a, $7C
  ldh [WIN_Y_OFF], a

  call ShipSetup

GameLoop:
  halt

  call Game_manageInputs
  call GameSetOffsets
  
  call ShipDraw
  
  call ShipLogic

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


T_Level:
db "LEVEL"
T_LevelEnd:
