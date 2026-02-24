/*
 * Visor_PINB_PORTD.asm
 * Autor: Dylan Mazariegos Moran
 * Descripción:
 *  Muestra el estado de los botones PB0–PB4 en los LEDs de PORTD
 */

.include "M328PDEF.inc"

.cseg
.org 0x0000

;============================
; Inicializar Stack Pointer
;============================
    ldi r16, LOW(RAMEND)
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16

;============================
; Configuración de puertos
;============================

    ; PORTD todo como salida (LEDs)
    ldi r16, 0b11111111
    out DDRD, r16

    ; PORTB todo como entrada (botones)
    ldi r16, 0b00000000
    out DDRB, r16

    ; Activar pull-up en PB0–PB4
    ldi r16, 0b00011111
    out PORTB, r16

;============================
; Loop principal
;============================
MAIN_LOOP:
    in r17, PINB        ; Leer botones
    out PORTD, r17      ; Mostrar en LEDs
    rjmp MAIN_LOOP

