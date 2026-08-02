Section "Tile data", ROMX

EXPORT Tiles
EXPORT TilesBG
EXPORT TilesBGEnd
EXPORT TilesGame
EXPORT TilesGameEnd
EXPORT TilesEnd

Tiles:

TilesBG:

    dw `00000000    ; blank $00
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    
INCLUDE "include/tiles/text.asm"
INCLUDE "include/tiles/digits.asm"

TilesBGEnd:


TilesGame:
    dw `00000000    ; blank $00
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
TilesGameEnd:

TilesEnd:

