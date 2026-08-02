INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Fades", ROMX

EXPORT Fading
EXPORT P_FadeInB
EXPORT P_FadeOutB
EXPORT P_FadeInW
EXPORT P_FadeOutW

Fading:
  ldh a, [FADE_T]
  dec a
  ldh [FADE_T], a
  jr nz, .fadeEnd

  ldh a, [FADE_C]
  dec a
  ldh [FADE_C], a

  add l
  ld l, a
  ld a, [hl]
  ldh [rBGP], a   ; set background palette

  ld a, [FADE_T_L]
  ldh [FADE_T], a

  .fadeEnd

  ret

P_FadeInB:
db %00011011
db %00000110
db %00000001
db %00000000
P_FadeInBEnd:

P_FadeOutB:
db %00000000
db %00000001
db %00000110
db %00011011
P_FadeOutBEnd:

P_FadeInW:
db %11100100
db %10010000
db %01000000
db %00000000
P_FadeInWEnd:

P_FadeOutW:
db %11111111
db %10111111
db %01101111
db %00011011
P_FadeOutWEnd:
