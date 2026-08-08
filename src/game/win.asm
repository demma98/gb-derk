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
  ld de, _SCRN0 + $140
  ld b, T_Press_StartEnd - T_Press_Start
  call CopyDataT
  
  ld hl, T_TotalMoves
  ld de, _SCRN0 + $C0
  ld b, T_TotalMovesEnd - T_TotalMoves
  call CopyDataT

  halt
  ld hl, _SCRN0 + $E0
  ld b, $0D
  call ClearData
  ld hl, _SCRN0 + $E5
  call MovesDrawTextToHl
  
  call WinSetGraphics

    ; set scroll
  ld a, $E4
  ldh [BOARD_X_OFF], a
  ld a, $E8
  ldh [BOARD_Y_OFF], a
  call WinSetOffsets

  
  ; setup fade animation
  ld a, FADE_C_SET
  ldh [FADE_C], a
  ld a, FADE_T_SET
  ldh [FADE_T], a
  ld a, $02
  ldh [FADE_T_L], a

WinFadeInLoop:
  halt

  call Win_manageInputs
    
  ld hl, P_FadeInW
  call Fading

  ldh a, [FADE_C]
  or $00
  jr nz, WinFadeInLoop

  .loopEnd

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
  db " WIN \n"
  db "     "
T_You_WonEnd:

T_Press_Start:
  db " PRESS START \n"
  db "  TO RESET   "
T_Press_StartEnd:

T_TotalMoves:
  db " TOTAL MOVES "
T_TotalMovesEnd:
