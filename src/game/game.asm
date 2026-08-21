INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

INCLUDE "include/tiles/definitions/dialogue_box.inc"
INCLUDE "include/tiles/definitions/digits.inc"

Section "Game", ROM0

DEF MAX_LEVEL  EQU  18

DEF NO_WIN    EQU $00
DEF WIN_NEXT   EQU $01
DEF WIN_LAST   EQU $02

EXPORT GameStartFrom0
EXPORT GameSetup
EXPORT MovesDrawText
EXPORT MovesDrawTextToHl

GameStartFrom0:
  halt  ; wait for vblank
  
  xor a ; ld a, 0
    ; uncomment this to control which level to start in
  ;ld a, 13
  
  ldh [BOARD_LEVEL], a
  xor a ; ld a, $00
  ldh [SHIP_MOVES_3], a
  ldh [SHIP_MOVES_2], a
  ldh [SHIP_MOVES_1], a
  ldh [SHIP_MOVES_0], a
  
GameStartFromX:

  ld a, %00000000
  ld [rBGP], a
  ld [rOBP0], a
  ld [rOBP1], a
  ldh [PAUSE], a
  
  call LevelDrawBackdrop

    ; hide objs
  xor a ; ld a, $00
  ld [_OAMRAM + OAMA_Y], a
  ld [_OAMRAM + OAMA_Y + (sizeof_OAM_ATTRS)], a

GameSetup:

  call LoadLevel
  
  halt  ; wait for vblank
  
  call GameDrawDialogueBox

  ld a, $07
  ldh [WIN_X_OFF], a
  ld a, $7C
  ldh [WIN_Y_OFF], a
  
  call GameSetOffsets

  call GameSetGraphics

  call ShipSetup

  ld a, %11100100
  ld [rBGP], a
  ld a, %11000101
  ld [rOBP0], a

  ld a, NO_WIN
  ldh [NEXT_LEVEL], a

  call GameSoundSetup

GameLoop:
  halt

  call Game_manageInputs
  call Game_managePause
  call GameSetOffsets

  ldh a, [MOVES_UPDATE]
  cp $00
  jr z, .skip_moves_update
  call MovesDrawText
  .skip_moves_update

  call FillBlock_G
  call ShipDraw

  ldh a, [PAUSE]
  cp $00
  jr nz, .skip_logic
  
  call ShipLogic

  call GameCheckWin

  ldh a, [NEXT_LEVEL]
  cp NO_WIN
  jr z, .no_win

  jp GameFadeOutSetup
  
  .no_win
  .skip_logic


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

  call GameDrawText
  ret


GameDrawText:
    ; clear space
  ld hl, _SCRN1 + $21
  ld b, $10
  call ClearData
  
    ; draw "LEVEL" text
  ld hl, T_Level
  ld de, _SCRN1 + $21
  ld b, T_LevelEnd - T_Level
  call CopyDataT
  
  ldh a, [BOARD_LEVEL_1]
  add G_DIGITS
  ld [_SCRN1 + $22 + T_LevelEnd - T_Level], a
  ldh a, [BOARD_LEVEL_0]
  add G_DIGITS
  ld [_SCRN1 + $23 + T_LevelEnd - T_Level], a

  
    ; draw ""MOVES text
  ld hl, T_Moves
  ld de, _SCRN1 + $2A
  ld b, T_MovesEnd - T_Moves
  call CopyDataT
  
  call MovesDrawText
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


Game_managePause:
  ldh a, [INPUT_N]
  cp IN_START
  jr nz, .skip_pause

  ldh a, [PAUSE]
  cp $00
  jp nz, .unpause

    ; pause
  ld hl, _SCRN1 + $21
  ld b, $12
  call ClearData
      ; draw "PAUSED" text
  ld hl, T_Paused
  ld de, _SCRN1 + $27
  ld b, T_PausedEnd - T_Paused
  call CopyDataT
  
  ld a, $01
  jr .did_change_pause

  .unpause
  call GameDrawText
  ld a, $00

  .did_change_pause
  ldh [PAUSE], a
  .skip_pause
  ret


GameCheckWin:
  ldh a, [EMPTY_BLOCKS_R]
  ld b, a
  ldh a, [FILLED_BLOCKS]
  cp b
  jp nz, .skip_win

  call ShipLogic

  call ShipStopMoving ; count last move
  halt ; wait for vblank
  call ShipDraw
  call GameDrawText ; redraw the moves counter
  
  call FillBlock_G
  call LevelClearBoard

  ldh a, [BOARD_LEVEL]
  inc a
  ldh [BOARD_LEVEL], a
  cp MAX_LEVEL

  jr nz, .jump_to_next_level

  ld a, WIN_LAST
  ldh [NEXT_LEVEL], a
  jr .skip_win

  .jump_to_next_level
  ld a, WIN_NEXT
  ldh [NEXT_LEVEL], a

  .skip_win
  ret


GameSoundSetup:
    ; general configurations
  ld a, %10000000
  ldh [rNR52], a ; turn on audio
  ld a, %10001000
  ldh [rNR51], a ; channel 4 on both channels
  ld a, %01110111
  ldh [rNR50], a ; configure panning

    ; channel 4 off
  xor a ; ld a, %00000000
  ldh [rNR42], a
  
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
  
  ld hl, P_GameFadeOut
  call Fading

  ldh a, [FADE_C]
  or $00
  jr nz, GameFadeOutLoop

  ldh a, [NEXT_LEVEL]
  cp WIN_NEXT
  jr z, .next_level

  jp WinJump

  .next_level

  jp GameSetup


MovesDrawText:
  ld hl, _SCRN1 + $30
MovesDrawTextToHl:
  ldh a, [SHIP_MOVES_3]
  cp $00
  jr z, .skip_last_digit
  add G_DIGITS
  dec hl
  ld [hl+], a
  .skip_last_digit
  
  ldh a, [SHIP_MOVES_2]
  add G_DIGITS
  ld [hl+], a
  
  ldh a, [SHIP_MOVES_1]
  add G_DIGITS
  ld [hl+], a
  
  ldh a, [SHIP_MOVES_0]
  add G_DIGITS
  ld [hl+], a

  xor a ; ld a, $00
  ldh [MOVES_UPDATE], a
  ret


T_Level:
db "LEVEL"
T_LevelEnd:

T_Paused:
db "PAUSED"
T_PausedEnd:

T_Moves:
db "MOVES"
T_MovesEnd:


P_GameFadeOut:
    db %00000000
    db %01000000
    db %10010001
    db %11100100
F_GameFadeOutEnd:

