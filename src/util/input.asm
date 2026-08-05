; from gbdev.io

INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

Section "Input", ROM0

EXPORT ReadInput

ReadInput:  ; returns current inputs [a]

  ld a, JOYP_GET_BUTTONS
  call .readHalf
  ld b, a

  ld a, JOYP_GET_DPAD
  call .readHalf
  swap a
  xor a, b
  ld b, a


  ld a, JOYP_GET_NONE
  ldh [rJOYP], a ; release inputs


  ld a, [INPUT_C]
  xor a, b
  and a, b
  ld [INPUT_N], a ; save new inputs
  ld a, b
  ld [INPUT_C], a ; save current inputs

    ; reset game ir IN_RESET is pressed
  and IN_RESET
  cp IN_RESET
  jr nz, .skip_reset

  jp Reset

  .skip_reset

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

