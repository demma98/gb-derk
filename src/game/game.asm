INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Game", ROM0

EXPORT GameSetup

GameSetup:
  ld b, $00

  call LoadLevel

  halt  ; wait for vblank
  call GameSetOffsets
  ld a, %11100100
  ld [rBGP], a

GameLoop:
  halt

  call Game_manageInputs

  call GameSetOffsets

  jp GameLoop


GameSetOffsets:
  ldh a, [BOARD_X_OFF]
  ldh [rSCX], a
  ldh a, [BOARD_Y_OFF]
  ldh [rSCY], a
  ret


Game_manageInputs:
  call ReadInput
  ret
