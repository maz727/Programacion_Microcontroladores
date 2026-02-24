. /*

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

	LDI r16, 0b00001111
	OUT DDRC, r16

	LDI r16, 0b00000000
	OUT PORTC, r16

	LDI r16, 0b00000000
	OUT DDRB, r16
	lDI r16, 0b00001100
	OUT PORTB, r16

	clr r18
	clr r16
	
	
    
/*************************+***************/
// Loop Infinito
MAIN_LOOP:

	IN r17, PINB 
	ANDI r17, 0b00001100

	CPI r17, 0b00001000
	BREQ boton_1

	CPI r17, 0b00000100
	BREQ boton_2


    RJMP    MAIN_LOOP

boton_1:
		
	

	INC r18
	OUT PORTD, r18

rjmp MAIN_LOOP

boton_2:
 
	
	DEC r18
	OUT PORTD, r18

rjmp MAIN_LOOP

/****************************************/
// NON-Interrupt subroutines

/****************************************/
// Interrupt routines

/****************************************/