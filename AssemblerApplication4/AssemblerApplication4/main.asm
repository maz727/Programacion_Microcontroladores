/*
* Lab2A.asm
*
* Creado: 08 de febrero 2026
* Autor : Dylan Mazariegos Moran 
* Descripción: Prelab del Laboratorio no.2
*/
/****************************************/
// Encabezado (Definición de Registros, Variables y Constantes)
.include "M328PDEF.inc"     // Include definitions specific to ATMega328P
.dseg
.org    SRAM_START
//variable_name:     .byte   1   // Memory alocation for variable_name:     .byte   (byte size)

.cseg
.org 0x0000

/****************************************/
/* TABLA 7 SEGMENTOS (CATODO COMUN)
   Bits: PD0=a, PD1=b, PD2=c, PD3=d, PD4=e, PD5=f, PD6=g, PD7=dp
*/
TABLA_7SEG:
    .db 0b00111111 ; 0
    .db 0b00000110 ; 1
    .db 0b01011011 ; 2
    .db 0b01001111 ; 3
    .db 0b01100110 ; 4
    .db 0b01101101 ; 5
    .db 0b01111101 ; 6
    .db 0b00000111 ; 7
    .db 0b01111111 ; 8
    .db 0b01101111 ; 9
    .db 0b01110111 ; A
    .db 0b01111100 ; b
    .db 0b00111001 ; C
    .db 0b01011110 ; d
    .db 0b01111001 ; E
    .db 0b01110001 ; F

/****************************************/
// Vector de Reset
RJMP SETUP

/****************************************/
// Configuración de la pila
SETUP_STACK:
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    RET

/****************************************/
// Configuracion MCU
SETUP:
    RCALL   SETUP_STACK

    CLR r1              ; IMPORTANTE: r1 debe ser 0 para ADC ZH, r1 en LPM

    LDI r16, 0b11111111 ; Puerto D salida (display 7 segmentos)
    OUT DDRD, r16

    LDI r16, 0b00011111 ; PC0-PC3 LEDs contador, PC4 alarma (se conserva), PC5..PC7 entradas/no usados
    OUT DDRC, r16

    LDI r16, 0b00000000 ; Puerto B entradas (botones)
    OUT DDRB, r16

    LDI r16, 0b00000011 ; Pull-up en PB0 y PB1
    OUT PORTB, r16

    CLR r16             ; r16 lo usamos como "registro temporal / indice tabla"
    CLR r20             ; r20 = contador hexadecimal (0..F) por Timer0

    ;-------------------------
    ; Config Timer0 (Normal mode, sin interrupciones)
    ;-------------------------
    LDI r18, 0x00
    OUT TCCR0A, r18
    OUT TCCR0B, r18

    ; Prescaler CPU/1024
    LDI r18, 0b00000101
    OUT TCCR0B, r18

    ; Limpio bandera de overflow
    LDI r18, (1<<TOV0)
    OUT TIFR0, r18

    ; Deshabilito UART (opcional, como ya tenías)
    LDI r16, 0x00
    STS UCSR0B, r16

/****************************************/
// Loop Infinito
MAIN_LOOP:

    RCALL CONT_C100MS       ; Espera ~100ms (por polling de overflow)

    INC  r20                ; contador principal (hex)
    ANDI r20, 0x0F

    ; Mostrar r20 en display hexadecimal usando la tabla 0-F
    MOV  r16, r20
    RCALL MUESTRA_R16_DISPLAY

    ; Actualiza LEDs PC0-PC3 con r20, conservando PC4 (alarma) y PC5..PC7
    IN   r21, PORTC
    ANDI r21, 0xF0
    OR   r21, r20
    OUT  PORTC, r21

    ; Lectura botones (PB0/PB1 con pull-up)
    IN   r17, PINB
    ANDI r17, 0b00000011

    CPI  r17, 0b00000010    ; Botón 1 presionado (PB0=0, PB1=1)
    BREQ boton_1

    CPI  r17, 0b00000001    ; Botón 2 presionado (PB0=1, PB1=0)
    BREQ boton_2

    RJMP MAIN_LOOP


;---------------------------------------
; Botón 1: incrementa PC4 (alarma) toggle (ejemplo) o deja tu lógica
; Si solo querías que los botones incrementen/decrementen OTRO contador,
; aquí puedes cambiarlo. Yo te dejo lo original: inc/dec r16 NO sirve porque
; r16 se usa para mostrar r20. Entonces mejor uso r22 como contador manual.
;---------------------------------------
boton_1:
    ; Antirrebote: esperar a soltar (volver a 11)
B1_WAIT_RELEASE:
    IN   r17, PINB
    ANDI r17, 0b00000011
    CPI  r17, 0b00000011
    BRNE B1_WAIT_RELEASE

    ; Ejemplo simple: togglear PC4 (alarma) al presionar botón 1
    IN   r21, PORTC
    LDI  r18, (1<<PC4)
    EOR  r21, r18
    OUT  PORTC, r21

    RJMP MAIN_LOOP


boton_2:
    ; Antirrebote: esperar a soltar (volver a 11)
B2_WAIT_RELEASE:
    IN   r17, PINB
    ANDI r17, 0b00000011
    CPI  r17, 0b00000011
    BRNE B2_WAIT_RELEASE

    ; Ejemplo simple: limpiar PC4 (alarma) al presionar botón 2
    IN   r21, PORTC
    ANDI r21, 0b11101111     ; PC4 = 0
    OUT  PORTC, r21

    RJMP MAIN_LOOP


/****************************************/
// NON-Interrupt subroutines

;---------------------------------------
; CONT_C100MS:
; Espera ~100ms usando Timer0 overflow sin interrupciones.
; Con prescaler 1024 y 16MHz: overflow ? 16.384ms, 6 overflows ? 98.3ms
;---------------------------------------
CONT_C100MS:

    LDI r18, (1<<TOV0)
    OUT TIFR0, r18          ; limpia bandera por si estaba encendida

    LDI r19, 6              ; 6 overflows ~ 100ms

CONTOVERFLOWS:

YAHUBOOVERFLOW:
    IN   r18, TIFR0
    SBRS r18, TOV0
    RJMP YAHUBOOVERFLOW

    ; limpia bandera para esperar el siguiente overflow
    LDI  r18, (1<<TOV0)
    OUT  TIFR0, r18

    DEC  r19
    BRNE CONTOVERFLOWS

    RET


;---------------------------------------
; MUESTRA_R16_DISPLAY:
; r16 = valor 0..15 (hex) -> saca patrón de TABLA_7SEG hacia PORTD
;---------------------------------------
MUESTRA_R16_DISPLAY:
    LDI  ZH, HIGH(TABLA_7SEG<<1)
    LDI  ZL, LOW(TABLA_7SEG<<1)

    ADD  ZL, r16
    ADC  ZH, r1             ; r1 debe ser 0

    LPM  r18, Z
    OUT  PORTD, r18
    RET


/****************************************/
// Interrupt routines
; (No se usan)

