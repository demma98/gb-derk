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
  ld de, _SCRN0 + $04
  ld b, T_You_WonEnd - T_You_Won
  call CopyDataT

  halt
  
  ld hl, T_Press_Start
  ld de, _SCRN0 + $A0
  ld b, T_Press_StartEnd - T_Press_Start
  call CopyDataT
  
  call WinSetGraphics

  ld a, $E4
  ldh [BOARD_X_OFF], a
  ld a, $D0
  ldh [BOARD_Y_OFF], a

WinLoop:
  halt

  call WinSetOffsets

  call Win_manageInputs

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


Win_manageInputs:

  call ReadInput

  and IN_START

  jr z, .skip_title_card

  pop bc
  jp Reset
  
  .skip_title_card

  ret

T_You_Won:
  db "     \n"
  db " YOU \n"
  db " WON \n"
  db "     "
T_You_WonEnd:

T_Press_Start:
  db " PRESS START \n"
  db "  TO RESET   "
T_Press_StartEnd:
