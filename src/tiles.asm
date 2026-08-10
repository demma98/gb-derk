Section "Tile data", ROMX

EXPORT Tiles
EXPORT TilesBG
EXPORT TilesBGEnd
EXPORT TilesShared
EXPORT TilesSharedEnd
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

INCLUDE "include/tiles/logo.asm"

TilesBGEnd:


TilesShared:

INCLUDE "include/tiles/tiles_game.asm"
INCLUDE "include/tiles/dialogue_box.asm"

TilesSharedEnd:

TilesEnd:

