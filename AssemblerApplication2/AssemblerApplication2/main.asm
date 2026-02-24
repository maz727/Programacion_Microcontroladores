/*
* Test_PORTC.asm
*
* Prueba simple: encender LEDs en PC0 a PC5
*/

.include "M328PDEF.inc"

.cseg
.org 0x0000
    rjmp START

;----------------------------
; Inicialización
;----------------------------
START:
    ; Inicializar Stack Pointer
    ldi r16, LOW(RAMEND)
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16

    ; Configurar PC0–PC5 como salida
    ldi r16, 0b00111111     ; PC0 a PC5 = salidas
    out DDRC, r16

    ; Encender LEDs PC0–PC5
    ldi r16, 0b00111111
    out PORTC, r16

;----------------------------
; Loop infinito
;----------------------------
LOOP:
    rjmp LOOP


