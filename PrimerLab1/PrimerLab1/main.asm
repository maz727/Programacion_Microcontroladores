/*
* PrimerLab1.asm
*
* Creado:03 de febrero de 2026
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

	CBI DDRD, DDD2
	SBI PORTD, PORTD2	;Configuro como entrada el bit 2 del puerto D y pongo pull up 

	CBI DDRD, DDD3
	SBI PORTD, PORTD3	;Configuro como entrada el bit 3 del puerto D y pongo pull up

	SBI DDRC, DDC0		;Configuro el como salida bit0, puerto C
	CBI PORTC, PORTC0	; Limpio el bit 0 para que empiece apagado

	SBI DDRC, DDC1		;Configuro el como salida bit1, puerto C
	CBI PORTC, PORTC1	; Limpio el bit 0 para que empiece apagado

	SBI DDRC, DDC2		;Configuro el como salida bit2, puerto C
	CBI PORTC, PORTC2	; Limpio el bit 2 para que empiece apagado

	SBI DDRC, DDC3		;Configuro el como salida bit3, puerto C
	CBI PORTC, PORTC3	; Limpio el bit 3 para que empiece apagado

 	CLR r16				;Limpio el r16 que se mi contador binario 
    
/****************************************/
// Loop Infinito
MAIN_LOOP:
    
	IN r17, PIND			;Aqui leera y guardara en el r17 lo que lea del puerto D 
	ANDI r17, 0b00001100	; Filtra el valor para los bit 2 y 3 que son los de interes, el estado de los botones 

	CPI r17, 0b00000000		;Aqui por si se presionan los 2
	BREQ MAIN_LOOP			;Regresa al Main Loop

	SBRS r17, 2				; Si PD2=1 (No presionado) salta 
	RJMP boton_1			; Ve a la subrutina del boton 1

	SBRS r17, 3				; Si PD3=1 (No presionado) salta 
	RJMP boton_2			; Ve a la subrutina del boton 2
 
RJMP MAIN_LOOP

boton_1:
	rcall Delay
	
	SBIC PIND, PIND2	;Salta si el bit D2 es 0(Boton oprimido) si es 1 (No oprimido) la siguiente linea
	RJMP Exit_1			;Si despues del delay D2=1 no se oprimio el boton

	Soltar_1:
	SBIS PIND, PIND2	;Salta si el bit D2 es 1(Boton ya no presionado) si es 0(El boton aun esta oprimido) la sig linea
	RJMP Soltar_1

	INC r16				;Incremento 
	CPI r16, 16			;Comparo el valor de r16 con 16
	BRLO COMFIRM_INC	;Si el valor de r16 es menor de 16 confirma el incremento si el valor es mayor ejecuta la sig linea
	CLR r16				;Vuelve a 0 r16/ Overflow

	COMFIRM_INC:		;Hay incremento
	rcall MOSTRAR_LEDS	;Ve a la rutina encargada de controlar los leds 

	Exit_1:
	
rjmp MAIN_LOOP

boton_2:
	rcall Delay
	
	SBIC PIND, PIND3	;Salta si el bit D2 es 0(Boton oprimido) si es 1 (No oprimido) la siguiente linea
	RJMP Exit_2			;Si despues del delay D2=1 no se oprimio el boton

	Soltar_2:
	SBIS PIND, PIND3	;Salta si el bit D2 es 1(Boton ya no presionado) si es 0(El boton aun esta oprimido) la sig linea
	RJMP Soltar_2
	
	DEC r16				;Decrementa r16
	CPI r16, 255		;Compara el valor de r16 con 255( 255 es el numero mas alto al que puede contar)
	BRNE COMFIRM_DEC	;Si el valor es diferente de 255 salta,confirma el decremento (0 al 16) si es igual osea viene de 0, decrementa y pum 255, ejecuta la siguiente linea
	LDI r16, 15			;Vuelve a poner 15 /Underflow

	COMFIRM_DEC:		;Hay decremento
	rcall MOSTRAR_LEDS	;Ve a la rutina encargada de controlar los leds 

	Exit_2:	

rjmp MAIN_LOOP

Delay:
	LDI r18, 80
	D1:
	LDI r19, 120
	D2:
	DEC r19
	BRNE D2
	DEC r18
	BRNE D1
	
Ret

MOSTRAR_LEDS:
	MOV r20, r16
	ANDI r20, 0b00001111
	OUT PORTC, r20
RET