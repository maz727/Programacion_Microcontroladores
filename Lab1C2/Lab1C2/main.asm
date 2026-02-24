/*
* PrimerLab1C.asm
*
* Creado:06 de febrero de 2026
* Autor : Dylan Mazariegos Moran
* Descripción: Laboratorio 1 
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
    LDI r16, 0b11111111          ; Dejo los 8 bits como salidas
    OUT DDRD, r16                ; Puerto D como salida

    LDI r16, 0b00011111          ; 5 bits de salida para leds de suma + carry
    OUT DDRC, r16                ; Puerto C (PC0..PC4) como salida (según tu diseño)

    LDI r16, 0b00000000
    OUT DDRB, r16                ; Puerto B como entrada

    ; ===== ARREGLO CLAVE =====
    ; Activo pull-up en TODO PORTB para evitar bits flotantes (B5..B7)
    LDI r16, 0xFF
    OUT PORTB, r16
    ; =========================

    CLR r16
    CLR r18
    RCALL FILTRO_PORTD           ; Actualiza LEDs al iniciar

/****************************************/
// Loop Infinito
MAIN_LOOP:

CICLO:
    IN  r17, PINB                ; Leo el puerto B completo

    ; Con pull-up completo, reposo = 0xFF
    ; Botón presionado = bit en 0

    CPI r17, 0xFE                ; B0 presionado (11111110)
    BREQ boton_1

    CPI r17, 0xFD                ; B1 presionado (11111101)
    BREQ boton_2

    CPI r17, 0xFB                ; B2 presionado (11111011)
    BREQ boton_3

    CPI r17, 0xF7                ; B3 presionado (11110111)
    BREQ boton_4

    CPI r17, 0xEF                ; B4 presionado (11101111)
    BREQ boton_5                 ; suma

    RJMP CICLO                   ; seguir leyendo

;================= BOTON 1 =================
boton_1:
    IN  r17, PINB
    CPI r17, 0xFF                ; Antirrebote: esperar a que suelte (reposo)
    BRNE boton_1

    INC r16
    ANDI r16, 0x0F               ; solo 4 bits
    RCALL FILTRO_PORTD
    RJMP CICLO

;================= BOTON 2 =================
boton_2:
    IN  r17, PINB
    CPI r17, 0xFF
    BRNE boton_2

    DEC r16
    ANDI r16, 0x0F
    RCALL FILTRO_PORTD
    RJMP CICLO

;================= BOTON 3 =================
boton_3:
    IN  r17, PINB
    CPI r17, 0xFF
    BRNE boton_3

    INC r18
    ANDI r18, 0x0F
    RCALL FILTRO_PORTD
    RJMP CICLO

;================= BOTON 4 =================
boton_4:
    IN  r17, PINB
    CPI r17, 0xFF
    BRNE boton_4

    DEC r18
    ANDI r18, 0x0F
    RCALL FILTRO_PORTD
    RJMP CICLO

;================= BOTON 5 (SUMA) =================
boton_5:
    IN  r17, PINB
    CPI r17, 0xFF
    BRNE boton_5

    RCALL SUMADOR_PORTC
    RJMP CICLO

;==================================================
; SUBRUTINA FILTRO_PORTD
; r16 -> nibble bajo (PD0..PD3)
; r18 -> nibble bajo, swap a nibble alto (PD4..PD7)
;==================================================
FILTRO_PORTD:
    MOV r19, r16
    ANDI r19, 0x0F

    MOV r20, r18
    ANDI r20, 0x0F
    SWAP r20

    OR  r19, r20
    OUT PORTD, r19
    RET

;==================================================
; SUBRUTINA SUMADOR_PORTC
; Muestra suma (bits bajos) en PC0..PC3
; y carry en PC4 (bit 4)
;==================================================
SUMADOR_PORTC:
    MOV r21, r16
    ADD r21, r18

    MOV r22, r21
    ANDI r22, 0x0F               ; bits bajos

    BRCC SIN_ACARREO
    ORI r22, 0b00010000          ; prende bit 4 (PC4) carry/overflow

SIN_ACARREO:
    OUT PORTC, r22
    RET


