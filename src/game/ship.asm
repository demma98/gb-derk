INCLUDE "include/hardware.inc"
INCLUDE "include/memory.inc"

INCLUDE "include/asm/blocks.inc"
INCLUDE "include/tiles/definitions/ship.inc"

Section "Ship", ROM0

EXPORT ShipSetup
EXPORT ShipDraw
EXPORT ShipLogic
EXPORT ShipStopMoving

DEF SHIP_STATIC  EQU $00
DEF SHIP_UP    EQU $01
DEF SHIP_RIGHT EQU $02
DEF SHIP_DOWN  EQU $03
DEF SHIP_LEFT  EQU $04

ShipSetup:
  xor a ; ld a, $00
  ldh [SHIP_F], a
  ldh [SHIP_DIRECTION], a
  ldh [FILLED_BLOCKS], a
  ld a, G_SHIP_BODY
  ldh [SHIP_T], a

  ldh a, [SHIP_X_R]
  ld e, a
  ldh [SHIP_X_T], a
  ldh [SHIP_X_O], a
  rlc a
  rlc a
  rlc a
  ldh [SHIP_X], a
  
  ldh a, [SHIP_Y_R]
  ld d, a
  ldh [SHIP_Y_T], a
  ldh [SHIP_Y_O], a

    ; fill the starting block
  call FillBlock
  call ShipGetBlockAddr
  ld a, BLOCK_FILLED
  ld [hl], a
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
    ; get inputs if not moving
  ldh a, [SHIP_DIRECTION]
  cp $00
  jp nz, .skip_inputs

  ldh a, [INPUT_N]
  ld d, a
  cp $00
  jp z, .skip_inputs

  cp IN_UP
  jr nz, .skip_up
  ld a, SHIP_UP
  ldh [SHIP_DIRECTION], a
  .skip_up

  ld a, d
  cp IN_RIGHT
  jr nz, .skip_right
  ld a, SHIP_RIGHT
  ldh [SHIP_DIRECTION], a
  .skip_right
  
  ld a, d
  cp IN_DOWN
  jr nz, .skip_down
  ld a, SHIP_DOWN
  ldh [SHIP_DIRECTION], a
  .skip_down
  
  ld a, d
  cp IN_LEFT
  jr nz, .skip_left
  ld a, SHIP_LEFT
  ldh [SHIP_DIRECTION], a
  .skip_left
  
  .skip_inputs

    ; move if necessary
  ldh a, [SHIP_DIRECTION]
  ld b, a
  cp SHIP_STATIC
  jp z, .skip_move


  ldh a, [SHIP_X_T]
  ld e, a
  ldh a, [SHIP_Y_T]
  ld d, a


  ld a, b
  cp SHIP_UP
  jr nz, .skip_move_up
    ; update OAM flags
  ldh a, [SHIP_F]
  and ~OAMF_YFLIP
  ldh [SHIP_F], a
    ; update graphic
  ld a, G_SHIP_BODY_R
  ldh [SHIP_T], a
  
  ld a, d
  dec a
  bit 7, a
  jr nz, ShipStopMoving
  ldh [SHIP_Y_T], a
  jp .did_move
  .skip_move_up
  
  ld a, b
  cp SHIP_RIGHT
  jr nz, .skip_move_right
    ; update OAM flags
  ldh a, [SHIP_F]
  and ~(OAMF_XFLIP | OAMF_YFLIP)
  ldh [SHIP_F], a
    ; update graphic
  ld a, G_SHIP_BODY
  ldh [SHIP_T], a
  
  ld a, e
  inc a
  ld hl, BOARD_WIDTH
  cp [hl]
  jr z, ShipStopMoving
  ldh [SHIP_X_T], a
  jp .did_move
  .skip_move_right
  
  ld a, b
  cp SHIP_DOWN
  jr nz, .skip_move_down
    ; update OAM flags
  ldh a, [SHIP_F]
  or OAMF_YFLIP
  ldh [SHIP_F], a
    ; update graphic
  ld a, G_SHIP_BODY_R
  ldh [SHIP_T], a
  
  ld a, d
  inc a
  ld hl, BOARD_HEIGHT
  cp [hl]
  jr z, ShipStopMoving
  ldh [SHIP_Y_T], a
  jp .did_move
  .skip_move_down
  
  ld a, b
  cp SHIP_LEFT
  jr nz, .skip_move_left
    ; update OAM flags
  ldh a, [SHIP_F]
  or OAMF_XFLIP
  and ~OAMF_YFLIP
  ldh [SHIP_F], a
    ; update graphic
  ld a, G_SHIP_BODY
  ldh [SHIP_T], a
  
  ld a, e
  dec a
  bit 7, a
  jr nz, ShipStopMoving
  ldh [SHIP_X_T], a
  jp .did_move
  .skip_move_left


  .did_move
  call ShipGetBlockAddr
  ld a, [hl]
  cp BLOCK_SOLID
  jp nz, .skip_return_to_position

  ld a, e
  ldh [SHIP_X_T], a
  ld a, d
  ldh [SHIP_Y_T], a
  jr ShipStopMoving
  .skip_return_to_position

  cp BLOCK_EMPTY
  jp nz, .skip_fill_block
  ld a, BLOCK_FILLED
  ld [hl], a
  ldh a, [SHIP_X_T]
  ld e, a
  ldh a, [SHIP_Y_T]
  ld d, a
  call FillBlock
  .skip_fill_block
  .skip_move

  ret
  
ShipStopMoving:
  ld a, SHIP_STATIC
  ldh [SHIP_DIRECTION], a

    ; skip moves increse if the ship hasn't moved
  ld hl, SHIP_X_O
  ldh a, [SHIP_X_T]
  cp [hl]  ; cp [SHIP_X_O]
  jr nz, .moves_increse
  ld hl, SHIP_Y_O
  ldh a, [SHIP_Y_T]
  cp [hl]  ; cp [SHIP_Y_O]
  jr nz, .moves_increse

  jr .skip_moves_increse
  
  .moves_increse
  ld hl, SHIP_MOVES_0
  ld b, $00
  call MovesIncrese
  
  ld a, $10
  ldh [MOVES_UPDATE], a
  .skip_moves_increse

    ; update old coordinate values
  ldh a, [SHIP_X_T]
  ldh [SHIP_X_O], a
  ldh a, [SHIP_Y_T]
  ldh [SHIP_Y_O], a
  ret


MovesIncrese:
  ld a, b
  cp $05
  jr z, .skip


  inc b
  ld a, [hl]
  inc a
  cp $0A
  jr nz, .skip_reset_digit

  dec hl
  call MovesIncrese
  inc hl

  ld a, b
  cp $05
  jr nz, .max_not_reached

  ld a, $09
  jr .skip_reset_digit

  .max_not_reached
  xor a ; ld a, $00
  .skip_reset_digit
  ld [hl], a

  .skip
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

ShipGetBlockAddr:  ; get memory direction for the current block, return in [hl]
  ldh a, [SHIP_Y_T]
  rlc a
  rlc a
  rlc a
  rlc a
  ld hl, SHIP_X_T
  add [hl]
  ld l, a
  ld h, wBOARD_DATA_H
  ret
