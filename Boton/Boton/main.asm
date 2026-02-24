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
	CBI DDRD, DDD5 //pongo en 0 el bit no 5 del DDRD
	CBI PORTD, PORTD5  // Deshabilito los pull-up para PD5
	//Output---PB0
	SBI		DDRB, DDB0
	CBI		PORTB, PORTB0
/****************************************/
// Loop Infinito
MAIN_LOOP:
	LDI		R17, PIND		//Lee el PinD
	ANDI	R17,0b00100000
	BRNE	MAIN_LOOP
	CALL	DELAY 
	IN		R18, R17 b b  
	BRNE	MAIN_LOOP
	SBI		PINB, PINB0 // Toglear
    RJMP    MAIN_LOOP	
	  	

/****************************************/
// NON-Interrupt subroutines
DELAY 
	LDI R19,255
LOOP_DELAY:

/****************************************/
// Interrupt routines

/****************************************/