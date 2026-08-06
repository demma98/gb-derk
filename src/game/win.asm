INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Win", ROMX

EXPORT WinJump

WinJump:
  halt

  ld hl, _SCRN1 + $21
  ld b, $08
  call ClearData

  ld hl, T_You_Won
  ld de, _SCRN0
  ld b, T_You_WonEnd - T_You_Won
  call CopyDataT
  
  call WinSetGraphics

  ld a, $C4
  ldh [BOARD_X_OFF], a
  ld a, $D0
  ldh [BOARD_Y_OFF], a


WinLoop:
  halt

  call ReadInput
  call WinSetOffsets

  jp WinLoop



WinSetGraphics:
  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
  ldh [rLCDC], a   ; bg and window layer on
  ret


WinSetOffsets:
  ldh a, [BOARD_X_OFF]
  ldh [rSCX], a
  ldh a, [BOARD_Y_OFF]
  ldh [rSCY], a
  ret


T_You_Won:
  db "     \n"
  db " YOU \n"
  db " WON \n"
  db "     "
T_You_WonEnd:

