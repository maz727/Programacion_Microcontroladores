/*
* Ejercicioencasa1.asm
*
* Creado: 31/01/2026 12:33:35
* Autor : Dylan Mazariegos M
* Descripción: 
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
	LDI	R16, 0x00
	OUT DDRB, R16
	LDI R16, 0xFF
	OUT DDRC, R16   
/****************************************/
// Loop Infinito
MAIN_LOOP:
	IN r16, PINB
	OUT PORTC, R16
    RJMP    MAIN_LOOP

/****************************************/
// NON-Interrupt subroutines

/****************************************/
// Interrupt routines

/****************************************/