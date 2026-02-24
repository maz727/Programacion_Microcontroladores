/*
* NombreProgra.asm
*
* Creado: 
* Autor : 
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

	CBI DDRD, DDD2
	SBI PORTD, DDD2;Configuro como entrada el bit 2 del puerto D y pongo pull up 

	CBI DDRD, DDD3
	SBI PORTD, DDD3;Configuro como enrada el bit 3 del puerto D y pongo pull up

	SBI DDRC, DDC0;Configuro el como salida bit0, puerto C
	CBI PORTC, PORTC0; Limpio el bit 0 para que empiece apagado

	SBI DDRC, DDC1;Configuro el como salida bit1, puerto C
	CBI PORTC, PORTC1; Limpio el bit 0 para que empiece apagado

	SBI DDRC, DDC2;Configuro el como salida bit1, puerto C
	CBI PORTC, PORTC2; Limpio el bit 2 para que empiece apagado

	SBI DDRC, DDC3
	CBI PORTC, PORTC3; Limpio el bit 3 para que empiece apagado


	clr r16
	clr r18
	clr r19
    
/****************************************/
// Loop Infinito
MAIN_LOOP:
    RJMP    MAIN_LOOP
/****************************************/
// NON-Interrupt subroutines
/****************************************/
// Interrupt routines
/****************************************/

