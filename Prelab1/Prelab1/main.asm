/* 
* NombreProgra.asm
*
* Creado: 
* Autor : 
* Descripción: Contador binario 4 bits con 2 botones (+ y -) y antirebote simple
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
// Configuración de la pila
LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16
/****************************************/
// Configuracion MCU
SETUP:

    ; ---- Configuración simple (propuesta) ----
    ; Suposición típica:
    ; LEDs (contador 4 bits) en PORTD (PD0-PD3)
    ; Botón + en PB0
    ; Botón - en PB1

    ; PORTD como salida (todos los pines) para simplificar
    LDI     R16, 0b11111111
    OUT     DDRD, R16

    ; PORTB como entrada (todos los pines)
    LDI     R16, 0b00000000
    OUT     DDRB, R16

    ; Activar pull-ups en PB0 y PB1 (para que en reposo sea 1 y presionado sea 0)
    LDI     R16, 0b00000011
    OUT     PORTB, R16

    ; R17 = contador (solo usaremos 4 bits)
    CLR     R17

    RJMP    MAIN_LOOP

/****************************************/
// Loop Infinito
MAIN_LOOP:

    ; Mostrar contador en LEDs (PORTD)
    OUT     PORTD, R17

    ; Leer botones (PORTB)
    IN      R18, PINB

    ; ---- Botón + (PB0) ----
    ; Si PB0 está presionado, ese bit se vuelve 0
    ; Entonces el puerto leído tendrá el bit0 en 0
    ; Comparación simple: si el valor es 0b00000010 significa:
    ; PB0 = 0 (presionado) y PB1 = 1 (no presionado)
    CPI     R18, 0b00000010
    BREQ    BTN_INC

    ; ---- Botón - (PB1) ----
    ; Si PB1 está presionado y PB0 no:
    ; PB1 = 0 y PB0 = 1  => 0b00000001
    CPI     R18, 0b00000001
    BREQ    BTN_DEC

    RJMP    MAIN_LOOP


BTN_INC:
    ; Antirebote simple (delay corto)
    LDI     R20, 200
DLY1:
    DEC     R20
    BRNE    DLY1

    INC     R17
    ANDI    R17, 0b00001111      ; Mantener solo 4 bits (0-15)

    ; Esperar a soltar botón (PB0 vuelva a 1)
WAIT_INC:
    IN      R18, PINB
    CPI     R18, 0b00000011      ; PB0=1 y PB1=1 (ningún botón)
    BREQ    MAIN_LOOP
    RJMP    WAIT_INC


BTN_DEC:
    ; Antirebote simple (delay corto)
    LDI     R20, 200
DLY2:
    DEC     R20
    BRNE    DLY2

    DEC     R17
    ANDI    R17, 0b00001111      ; Mantener solo 4 bits (0-15)

    ; Esperar a soltar botón (PB1 vuelva a 1)
WAIT_DEC:
    IN      R18, PINB
    CPI     R18, 0b00000011
    BREQ    MAIN_LOOP
    RJMP    WAIT_DEC


/****************************************/
// NON-Interrupt subroutines

/****************************************/
// Interrupt routines

/****************************************/

