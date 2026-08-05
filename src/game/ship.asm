INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

INCLUDE "include/tiles/definitions/ship.inc"

Section "Ship", ROM0

EXPORT ShipSetup
EXPORT ShipDraw
EXPORT ShipLogic


ShipSetup:
  ld a, $00  ; just for testing now
  ldh [SHIP_X_R], a
  ldh [SHIP_Y_R], a
  ldh [SHIP_F], a
  ld a, G_SHIP_BODY
  ldh [SHIP_T], a

  ldh a, [SHIP_X_R]
  ldh [SHIP_X_T], a
  rlc a
  rlc a
  rlc a
  ldh [SHIP_X], a
  
  ldh a, [SHIP_Y_R]
  ldh [SHIP_Y_T], a
  ret


ShipDraw:
  ld hl, wSHIP_DATA
  ld de, _OAMRAM
  ld b, sizeof_OAM_ATTRS
  call CopyData
  
  ret


ShipLogic:
  call ShipMove
  call ShipUpdateOffset
  
  ret


ShipMove:
  ldh a, [INPUT_N]
  ld b, a

  and IN_UP
  jr z, .skip_up
  ld hl, SHIP_Y_T
  dec [hl]
  .skip_up

  ld a, b
  and IN_DOWN
  jr z, .skip_down
  ld hl, SHIP_Y_T
  inc [hl]
  .skip_down
  
  ld a, b
  and IN_LEFT
  jr z, .skip_left
  ld hl, SHIP_X_T
  dec [hl]
  .skip_left
  
  ld a, b
  and IN_RIGHT
  jr z, .skip_right
  ld hl, SHIP_X_T
  inc [hl]
  .skip_right
  ret


ShipUpdateOffset:
  ldh a, [SHIP_X_T]
  inc a
  rlc a  ; times 8
  rlc a
  rlc a
  
  ld b, a
  ld a, [BOARD_X_OFF]
  xor $FF
  add b
  inc a
  ldh [SHIP_X], a


  ldh a, [SHIP_Y_T]
  add $02
  rlc a  ; times 8
  rlc a
  rlc a
  
  ld b, a
  ld a, [BOARD_Y_OFF]
  xor $FF
  add b
  inc a
  ldh [SHIP_Y], a
  ret
