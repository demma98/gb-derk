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

    ;dw `20202020    ; filled block
    ;dw `20202020
    ;dw `02020202
    ;dw `02020202
    ;dw `20202020
    ;dw `20202020
    ;dw `02020202
    ;dw `02020202
    
    dw `22222222    ; filled block
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    
    dw `23333333    ; darker brick
    dw `31111111
    dw `31111222
    dw `33332222
    dw `11113333
    dw `11231111
    dw `22231112
    dw `22231222

TilesShip:
    dw `00111100    ; ship body
    dw `01130000
    dw `31223000
    dw `03112111
    dw `31223000
    dw `01130000
    dw `00111100
    dw `00000000

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

    dw `00010000    ; ship body rotated
    dw `10010010
    dw `10010010
    dw `10323010
    dw `13212310
    dw `11212110
    dw `01131100
    dw `00303000
TilesShipEnd:

TilesGameEnd:
