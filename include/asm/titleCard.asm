DEF LOGO_Y_START  EQU $30
DEF LOGO_Y_END  EQU $F8

DEF LOGO_SHIP_Y        EQU $40
DEF LOGO_SHIP_X_START  EQU $00
DEF LOGO_SHIP_X_END    EQU $48

EXPORT TitleCardJump

TitleCardSetup:
  call TitleCardSetupTiles

  ; setup fade animation
  ld a, FADE_C_SET
  ldh [FADE_C], a
  ld a, FADE_T_SET
  ldh [FADE_T], a
  ld a, $02
  ldh [FADE_T_L], a

TitleCardFadeInLoop:
  halt

  call TitleCard_manageInputsAnimation

  ld hl, P_FadeInW
  call Fading


  ldh a, [FADE_C]
  or $00
  jr nz, TitleCardFadeInLoop

  .loopEnd

  xor a ;ld a, $00
  ldh [BOARD_X_OFF], a
  ld a, LOGO_Y_START
  ldh [BOARD_Y_OFF], a

TitleCardLogoLoop:
  halt

  call TitleCard_manageInputsAnimation

  call TitleCardSetOffsets

  ldh a, [BOARD_Y_OFF]
  dec a
  ldh [BOARD_Y_OFF], a

  cp LOGO_Y_END - $01
  jr nz, TitleCardLogoLoop

  ld a, %11111100
  ld [rOBP0], a

TitleCardShipLoop:
  
  call TitleCardShipTrail
  
  halt

  call TitleCard_manageInputs

  call TitleCardDrawObj

  ld a, [wBOARD_DATA + OAMA_X]
  inc a
  ld [wBOARD_DATA + OAMA_X], a
  cp LOGO_SHIP_X_END
  jr nz, TitleCardShipLoop

  
  jp TitleCardLoop

TitleCardJump:
  ld a, %0000000
  ld [rBGP], a
  ld [rOBP0], a

  call TitleCardSetupTiles

  halt
  ld a, %11100100
  ld [rBGP], a
  ld a, %11111100
  ld [rOBP0], a

  ld a, LOGO_SHIP_X_END
  ld [wBOARD_DATA + OAMA_X], a

  call TitleCardShipTrail

  xor a ; ld a, $00
  ldh [rSCX], a
  ld a, LOGO_Y_END
  ldh [rSCY], a

TitleCardLoop:
  call TitleCardShipTrail
  
  halt

  call TitleCard_manageInputs
  call TitleCardDrawObj

  jp TitleCardLoop


TitleCardSetupTiles:
  halt  ; wait for vblank
  
  ld a, LCDCF_OFF
  ldh [rLCDC], a    ; lcd off

  ld hl, T_PressStart
  ld de, _SCRN1 + $45
  ld b, T_PressStartEnd - T_PressStart
  call CopyDataT
  
  ld hl, T_Copyright
  ld de, _SCRN1 + $A2
  ld b, T_CopyrightEnd - T_Copyright
  call CopyDataT

  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800 | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_OBJON
  ldh [rLCDC], a   ; background on, BG uses $9000; window layer on; objects on

  halt
  
  ld hl, T_CX16_Maze
  ld de, _SCRN0 + $26
  ld b, T_CX16_MazeEnd - T_CX16_Maze
  call CopyDataT

  ld hl, D_Logo_0
  ld de, _SCRN0 + $64
  ld b, D_Logo_0End - D_Logo_0
  call CopyData
  ld hl, D_Logo_1
  ld de, _SCRN0 + $84
  ld b, D_Logo_1End - D_Logo_1
  call CopyData

  halt
  
  ld hl, D_Logo_2
  ld de, _SCRN0 + $A4
  ld b, D_Logo_2End - D_Logo_2
  call CopyData
  ld hl, D_Logo_3
  ld de, _SCRN0 + $C4
  ld b, D_Logo_3End - D_Logo_3
  call CopyData
  ld hl, D_Logo_4
  ld de, _SCRN0 + $E4
  ld b, D_Logo_4End - D_Logo_4
  call CopyData

  ld a, $08
  ldh [rWX], a
  ld a, $50
  ldh [rWY], a

    ; hide bg
  ld a, $40
  ldh [rSCY], a

    ; use board data space for OAM
  ld hl, wBOARD_DATA
  ld b, $08
  call ClearData

  ld a, LOGO_SHIP_Y
  ld [wBOARD_DATA + OAMA_Y], a
  ld a, LOGO_SHIP_X_START
  ld [wBOARD_DATA + OAMA_X], a
  ld a, $83 ; G_SHIP
  ld [wBOARD_DATA + OAMA_TILEID], a
  
  ld a, LOGO_SHIP_Y
  ld [wBOARD_DATA + OAMA_Y + (sizeof_OAM_ATTRS)], a
  ld a, $84 ; G_SHIP_FIRE_0
  ld [wBOARD_DATA + OAMA_TILEID+ (sizeof_OAM_ATTRS)], a
  ret


TitleCardDrawObj:
  ld hl, wBOARD_DATA
  ld de, _OAMRAM
  ld b, $08
  call CopyData
  ret

TitleCardShipTrail:
  ld a, [wBOARD_DATA + OAMA_X]
  sub $08
  ld [wBOARD_DATA + OAMA_X + (sizeof_OAM_ATTRS)], a
  ret


TitleCardSetOffsets:
  ldh a, [BOARD_X_OFF]
  ldh [rSCX], a
  ldh a, [BOARD_Y_OFF]
  ldh [rSCY], a
  ret


TitleCard_manageInputsAnimation:
  call ReadInput

  ldh a, [INPUT_N]
  cp IN_START
  jp nz, .skip

  call TitleCardClear
  pop bc
  jp TitleCardJump

  .skip
  ret


TitleCard_manageInputs:
  call ReadInput

  ldh a, [INPUT_N]
  cp IN_START
  jp nz, .skip

  call TitleCardClear
  pop bc
  jp GameStartFrom0

  .skip
  ret

TitleCardClear:
  ld a, %00000000
  ldh [rBGP], a

  ; clear copyright text
  ld hl, _SCRN0 + $1C0 + $02
  ld b, $10
  call ClearData
  ld hl, _SCRN0 + $1E0 + $02
  ld b, $10
  call ClearData
  
  ret


T_Derk:
  db "DERK"
T_DerkEnd:

T_CX16_Maze:
  db "CX16 MAZE"
T_CX16_MazeEnd:

T_PressStart:
  db "PRESS START"
T_PressStartEnd:

T_Copyright:
  db "DEMMA 98 STUDIOS\n"
  db "  MADE IN 2026"
T_CopyrightEnd:


D_Logo:
D_Logo_0:
  db $25, $28, $29, $31, $32, $33, $25, $37, $38, $25, $00, $3F
D_Logo_0End:
D_Logo_1:
  db $26, $2A, $2B, $27, $00, $00, $26, $39, $3A, $26, $39, $3A
D_Logo_1End:
D_Logo_2:
  db $26, $00, $2C, $00, $00, $00, $26, $3B, $3C, $26, $3B, $3C
D_Logo_2End:
D_Logo_3:
  db $26, $2D, $2E, $25, $00, $00, $26, $3D, $3E, $26, $3D, $3E
D_Logo_3End:
D_Logo_4:
  db $27, $2F, $30, $34, $35, $36, $27, $00, $27, $27, $00, $27
D_Logo_4End:
D_LogoEnd:


TitleCardEnd:

