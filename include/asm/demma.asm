DemmaSetupBG:
    halt    ; wait vblank

    ld a, LCDCF_OFF
    ldh [rLCDC], a    ; lcd off

    ld hl, T_Demma
    ld de, _SCRN0
    ld b, T_DemmaEnd - T_Demma
    call CopyDataT
    
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8800
    ldh [rLCDC], a   ; background on, objects on; BG uses $9000

    ld a, $D0
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

DemmaFadeInLoop:
    halt

    call Demma_manageInputs
    
    ld hl, P_FadeInB
    call Fading


    ldh a, [FADE_C]
    or $00
    jr nz, DemmaFadeInLoop

    .loopEnd
    ld a, $16
    ldh [WAIT_T], a

DemmaWait:
    halt

    call Demma_manageInputs

    ldh a, [WAIT_T]
    dec a
    ldh [WAIT_T], a

    jr nz, DemmaWait

    .loopEnd
    ; setup fade animation
    ld a, FADE_C_SET
    ldh [FADE_C], a
    ld a, FADE_T_SET
    ldh [FADE_T], a
    

DemmaFadeOutLoop:
    halt

    call Demma_manageInputs
    
    ld hl, P_FadeOutB
    call Fading


    ldh a, [FADE_C]
    or $00
    jr nz, DemmaFadeOutLoop

    .loopEnd

    call DemmaClear
    jp DemmaEnd


Demma_manageInputs:
    call ReadInput

    cp IN_START
    jp nz, .skip

    call DemmaClear
    pop bc
    jp TitleCardJump

    .skip
    ret

DemmaClear:
    ld hl, _SCRN0
    ld b, T_DemmaEnd - T_Demma
    call ClearData
    
    ld hl, _SCRN0 + $40
    ld b, T_DemmaEnd - T_Demma
    call ClearData

    ret
    

T_Demma:
db "DEMMA 98\n\n"
db "PRESENTS"
T_DemmaEnd:


DemmaEnd:
