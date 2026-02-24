/*
* Lab1.asm
*
* Creado:02 de febrero 2026
* Autor :Dylan Mazariegos Moran
* Descripción: Prelab 1
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
	LDI r16, 0b11111111
	OUT DDRD, r16
	LDI r16, 0b00000000
	OUT DDRC, r16
	LDI r16, 0b01111110
	OUT PORTC 

	 

    
/****************************************/
// Loop Infinito
MAIN_LOOP:
    RJMP    MAIN_LOOP

/****************************************/
// NON-Interrupt subroutines

/****************************************/
// Interrupt routines

/****************************************/