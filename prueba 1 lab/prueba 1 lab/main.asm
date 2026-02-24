;
; prueba 1 lab.asm
;
; Created: 19/01/2026 17:05:37
; Author : Dylan Mazariegos M
;
.include "m328pdef.inc"

.org 0x0000
    rjmp START

START : 
       ;inicializar el stack point 
	   LDI r16, LOW(RAMEND)//ldi es cargar un registro a un dato, configuracion default 
	   OUT SPL, r16
	   LDI r16, HIGH(RAMEND)
	   OUT SPH, r16 
	   // esta es una configuracion default que se hace siempre que se va a programamr en aseembler 

	   ;Inicializar PORTB 
	   ldi R16, 0b0001111//ejemplo quiero 4 pines del puerto como entrada y 4 pines como salida del puerto b 
       OUT DDRB, R16 

MAIN_LOOP:
       SBI PINB, PINB0 ; cambia el estado del pin 
	   rcall DELAY 
	   rjmp MAIN_LOOP 

	   DELAY:
	   ldi r18,1

	   D1: ; label 1 
	     ldi r19, 5
	   D2: ; label 2
	   dec r19
       brne D2
       dec r18
       brne D1
       ret
; Replace with your application code
