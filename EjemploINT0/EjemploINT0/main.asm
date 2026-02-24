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
.cseg
.org 0x0000
	


 /****************************************/
// Configuración de la pila
START:
LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16
/****************************************/
// Configuracion MCU
SETUP:
    
/****************************************/
// Loop Infinito
MAIN_LOOP:
    RJMP    MAIN_LOOP
/****************************************/
// NON-Interrupt subroutines
/****************************************/
// Interrupt routines
/****************************************/

