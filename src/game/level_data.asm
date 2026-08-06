Section "LevelData", ROMX

EXPORT LevelData

LevelData:

Level_0:  ; just to make the algorithms easier
  db $01
Level_0End:

Level_1:
  db 25  ; size in bytes of the level, including this byte
  db 10, 10 ; width and height of level
  db 00, 01 ; coordinates to spawn on
  ; 0 is empty tile, 1 is solid tile
  db %00000000, %00111111
  db %00000000, %01111111
  db %10000000, %01111111
  db %10000000, %11111111
  db %11000000, %11111111
  db %11000001, %11111111
  db %11100001, %11111111
  db %11100011, %11111111
  db %11110011, %11111111
  db %11110111, %11111111
Level_1End:

Level_2:
  db 15
  db 8, 10
  db 0, 9

  db %00000000
  db %01111010
  db %01100010
  db %01000000
  db %01000011
  db %01000000
  db %01000010
  db %01000110
  db %01101110
  db %00000000
Level_2End:

Level_3:
  db $0E
  db $07, $09
  db $00, $08

  db %00000001
  db %01111101
  db %00000001
  db %01111111
  db %00000001
  db %11111101
  db %00000001
  db %01111101
  db %00000001
Level_3End:

Level_4:
  db 12, 7, 7  ; size, width, height
  db 0, 6      ; start coordinates
  db %00000011
  db %01111001
  db %01000001
  db %01011001
  db %01000001
  db %01111101
  db %00000001
Level_4End:

Level_5:
  db 12, 7, 7  ; size, width, height
  db 0, 6      ; start coordinates
  db %00000001
  db %01111101
  db %01111101
  db %00000001
  db %01010101
  db %01010101
  db %00010001
Level_5End:

Level_6:
  db 25, 10, 10  ; size, width, height
  db 0, 9        ; start coordinates
  db %00000000, %01111111
  db %01000000, %00111111
  db %01011111, %10111111
  db %01010000, %10111111
  db %01010010, %10111111
  db %01010010, %10111111
  db %01011110, %10111111
  db %01000000, %10111111
  db %01111111, %10111111
  db %00000000, %00111111
Level_6End:

Level_7:
  db 15, 7, 10   ; size, width, height
  db 0, 8        ; start coordinates
  db %10000011
  db %00111001
  db %00000001
  db %00010001
  db %01010101
  db %01010101
  db %01000101
  db %01111101
  db %00010001
  db %10000011
Level_7End:

Level_8:
  db 23, 10, 9   ; size, width, height
  db 0, 8        ; start coordinates
  db %11000000, %01111111
  db %11011111, %00111111
  db %00000001, %00111111
  db %01010000, %00111111
  db %01010111, %11111111
  db %01000000, %01111111
  db %01100000, %01111111
  db %01111111, %01111111
  db %00000000, %01111111
Level_8End:

Level_9:
  db 29, 13, 12  ; size, width, height
  db 0, 11       ; start coordinates
  db %11110000, %00000111
  db %00000011, %11110111
  db %01110010, %00000111
  db %00000000, %00100111
  db %11110011, %11100111
  db %00000010, %01100111
  db %01111010, %01100111
  db %01111010, %01100111
  db %00011000, %01100111
  db %11011111, %01100111
  db %00010000, %01100111
  db %00010000, %01100111
Level_9End:

Level_10:
  db 27, 11, 11  ; size, width, height
  db 0, 10       ; start coordinates
  db %00000000, %11111111
  db %01110000, %00111111
  db %01100000, %00011111
  db %00001110, %01011111
  db %01001000, %01011111
  db %01011010, %11011111
  db %01011010, %11011111
  db %01011010, %11011111
  db %00000010, %11011111
  db %00000010, %01011111
  db %00111111, %00011111
Level_10End:

LevelDataEnd:

