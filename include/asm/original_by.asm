OriginalBySetupBG:
    halt    ; wait vblank

    ld a, LCDCF_OFF
    ldh [rLCDC], a    ; lcd off

    ld hl, T_OriginalBy
    ld de, _SCRN0
    ld b, T_OriginalByEnd - T_OriginalBy
    call CopyDataT
    
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
    ldh [rLCDC], a   ; background on, objects on; BG uses $9000

    ld a, $F0
    ldh [rSCX], a
    ld a, $C4
    ldh [rSCY], a
    
    ; setup fade animation
    ld a, FADE_C_SET
    ldh [FADE_C], a
    ld a, FADE_T_SET
    ldh [FADE_T], a
    ld a, $08
    ldh [FADE_T_L], a

OriginalByFadeInLoop:
    halt

    call OriginalBy_manageInputs
    
    ld hl, P_FadeInW
    call Fading


    ldh a, [FADE_C]
    or $00
    jr nz, OriginalByFadeInLoop

    .loopEnd
    ld a, $16
    ldh [WAIT_T], a

OriginalByWait:
    halt

    call OriginalBy_manageInputs

    ldh a, [WAIT_T]
    dec a
    ldh [WAIT_T], a

    jr nz, OriginalByWait

    .loopEnd
    ; setup fade animation
    ld a, FADE_C_SET
    ldh [FADE_C], a
    ld a, FADE_T_SET
    ldh [FADE_T], a
    

OriginalByFadeOutLoop:
    halt

    call OriginalBy_manageInputs
    
    ld hl, P_OriginalByFadeOut
    call Fading


    ldh a, [FADE_C]
    or $00
    jr nz, OriginalByFadeOutLoop

    .loopEnd

    call OriginalByClear
    jp OriginalByEnd


OriginalBy_manageInputs:
    call ReadInput

    ldh a, [INPUT_N]
    cp IN_START
    jp nz, .skip

    call OriginalByClear
    pop bc
    jp TitleCardJump

    .skip
    ret

OriginalByClear:
    ld hl, _SCRN0
    ld b, T_OriginalByEnd - T_OriginalBy
    call ClearData
    
    ld hl, _SCRN0 + $40
    ld b, T_OriginalByEnd - T_OriginalBy
    call ClearData

    ret

P_OriginalByFadeOut:
    db %00000000
    db %01000000
    db %10010000
    db %11100100
F_OriginalByFadeOutEnd:

T_OriginalBy:
  db "ORIGINAL GAME BY\n\n"
  db "  JIMMY DANSBO"
T_OriginalByEnd:


OriginalByEnd:

