EXPORT TilesGame
EXPORT TilesGameEnd

TilesGame:
    dw `12222222    ; brick
    dw `20000000
    dw `20000111
    dw `22221111
    dw `00002222
    dw `00120000
    dw `11120001
    dw `11120111

    ; darker brick
    ;dw `23333333    ; brick $80
    ;dw `31111111
    ;dw `31111222
    ;dw `33332222
    ;dw `11113333
    ;dw `11231111
    ;dw `22231112
    ;dw `22231222

TilesShip:
    dw `03333000    ; ship body
    dw `32221100
    dw `32221110
    dw `32222113
    dw `31222223
    dw `32121223
    dw `33211230
    dw `03333300

    dw `00000000    ; ship fire 0
    dw `00000000
    dw `00000002
    dw `00000002
    dw `00000000
    dw `00000002
    dw `00000002
    dw `00000000

    dw `00000000    ; ship fire 1
    dw `00000002
    dw `00000021
    dw `00000021
    dw `00000002
    dw `00000021
    dw `00000002
    dw `00000000

    dw `00000000    ; ship fire 2
    dw `00000022
    dw `00000200
    dw `00000022
    dw `00000221
    dw `00000211
    dw `00000022
    dw `00000000
TilesShipEnd:

TilesGameEnd:
