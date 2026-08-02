; from gbdev.io

INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Input", ROM0

EXPORT ReadInput

ReadInput:

  ld a, JOYP_GET_BUTTONS
  call .readHalf
  ld b, a

  ld a, JOYP_GET_DPAD
  call .readHalf
  swap a
  xor a, b

  ld [INPUT_C], a

  ret
  

  .readHalf
  ldh [rJOYP], a ; select if readding buttons or dpad
  call .waste_10 ; wate 10 cycles
  ldh a, [rJOYP] ; wait for inputs to settle
  ldh a, [rJOYP]
  ldh a, [rJOYP]
  or a, $F0

  .waste_10
  ret

