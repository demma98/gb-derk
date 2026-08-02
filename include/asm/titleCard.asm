
TitleCardSetup:
  call TitleCardSetupTiles

TitleCardFadeInLoop:
  halt

    
  ld hl, P_FadeInW
  call Fading


  ldh a, [FADE_C]
  or $00
  jr nz, TitleCardFadeInLoop

  .loopEnd

  jp TitleCardLoop

TitleCardJump:
  ld a, %11100100
  ld [rBGP], a

  call TitleCardSetupTiles


TitleCardLoop:
  halt

  jp TitleCardLoop


TitleCardSetupTiles:
  halt  ; wait for vblank
  
  ld a, LCDCF_OFF
  ldh [rLCDC], a    ; lcd off


  ld hl, T_Derk
  ld de, _SCRN0 + $C0 + $08
  ld b, T_DerkEnd - T_Derk
  call CopyDataT
  
  ld hl, T_Copyright
  ld de, _SCRN0 + $1C0 + $02
  ld b, T_CopyrightEnd - T_Copyright
  call CopyDataT


  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
  ldh [rLCDC], a   ; background on, objects on; BG uses $9000

  ld a, $00
  ldh [rSCX], a
  ldh [rSCY], a
  
  ; setup fade animation
  ld a, FADE_C_SET
  ldh [FADE_C], a
  ld a, FADE_T_SET
  ldh [FADE_T], a
  ld a, $02
  ldh [FADE_T_L], a

  ret

T_Derk:
db "DERK"
T_DerkEnd:

T_Copyright:
db "DEMMA 98 STUDIOS\n"
db "MADE IN 2026"
T_CopyrightEnd:


TitleCardEnd:

