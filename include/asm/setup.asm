
Setup:
    xor a ; ld a, $00
    ldh [rAUDENA], a   ; disable sound

    ld a, IEF_VBLANK
    ldh [rIE], a    ; enable vblank interrupt
    ld a, $00
    ldh [rIF], a    ; clean garbage from interrupts
    ei  ; enable interrupts

        ; reset stack
    ld sp, SP_INIT

    xor a ; ld a, %00000000
    ldh [rNR52], a ; turn off audio
    
SetupTileData:
    halt    ; wait vblank

    ld a, LCDCF_OFF
    ldh [rLCDC], a    ; lcd off
    
    ld a, %00000000
    ldh [rBGP], a   ; set background palette
    ldh [rOBP0], a  ; set object palette 0
    ldh [rOBP1], a  ; set object palette 1
    
    ld hl, TilesBG
    ld de, _VRAM9000
    ld bc, TilesBGEnd - TilesBG
    call CopyDataL   ; copy tile data to vram

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
    ldh [rLCDC], a   ; background on, objects on; BG uses $9000
    
        ; fill shared tile data
    halt ; wait for vblank
    
    ld a, LCDCF_OFF
    ldh [rLCDC], a    ; lcd off
    
    ld hl, TilesShared
    ld de, _VRAM8800
    ld bc, TilesSharedEnd - TilesShared
    call CopyDataL   ; copy tile data to shared tiles
    
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
    ldh [rLCDC], a   ; background on, objects on; BG uses $9000


ClearMaps:
    halt
    
    ld a, LCDCF_OFF
    ldh [rLCDC], a    ; lcd off

    ld a, $00
    ld hl, _SCRN0

    ld b, $04
    .clear_map_loop_0
    ld c, $00
    .clear_map_loop_1
    ld [hl+], a
    dec c
    jr nz, .clear_map_loop_1
    dec b
    jr nz, .clear_map_loop_0

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
    ldh [rLCDC], a   ; background on, objects on; BG uses $9000

    halt

    ld a, LCDCF_OFF
    ldh [rLCDC], a    ; lcd off

    ld a, $00
    ld hl, _SCRN1

    ld b, $04
    .clear_map_loop_2
    ld c, $00
    .clear_map_loop_3
    ld [hl+], a
    dec c
    jr nz, .clear_map_loop_3
    dec b
    jr nz, .clear_map_loop_2

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
    ldh [rLCDC], a   ; background on, objects on; BG uses $9000


ClearOAM:
    halt

    ld hl, _OAMRAM
    ld b, $A0
    call ClearData


SetupEnd:
