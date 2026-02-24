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
	//Desactiva las interrupciones globales 
	CLI
	//Botones de interaccion y configuracion 

	CBI DDRC, DDC0
	SBI PORTC, PORTC0	;Configuro como entrada el bit 0 del puerto C y pongo pull up 

	CBI DDRC, DDC1
	SBI PORTC, PORTC1	;Configuro como entrada el bit 1 del puerto C y pongo pull up

	CBI DDRC, DDC2
	SBI PORTC, PORTC2	;Configuro como entrada el bit 2 del puerto C y pongo pull up 

	CBI DDRC, DDC3
	SBI PORTC, PORTC3	;Configuro como entrada el bit 3 del puerto C y pongo pull up

	CBI DDRC, DDC4
	SBI PORTC, PORTC4	;Configuro como entrada el bit 4 del puerto C y pongo pull up

	//Salidas de los display 7 segmentos multiplexados 

	SBI DDRD, DDD0		;Configuro el como salida bit0, puerto D
	CBI PORTD, PORTD0	; Limpio el bit 0 para que empiece apagado

	SBI DDRD, DDD2		;Configuro el como salida bit2, puerto D
	CBI PORTD, PORTD2	; Limpio el bit 2 para que empiece apagado

	SBI DDRD, DDD3		;Configuro el como salida bit3, puerto D
	CBI PORTD, PORTD3	; Limpio el bit 3 para que empiece apagado

	SBI DDRD, DDD4		;Configuro el como salida bit4, puerto D
	CBI PORTD, PORTD4	; Limpio el bit 4 para que empiece apagado

	SBI DDRD, DDD5		;Configuro el como salida bit5, puerto D
	CBI PORTD, PORTD5	; Limpio el bit 5 para que empiece apagado

	SBI DDRD, DDD6		;Configuro el como salida bit6, puerto D
	CBI PORTD, PORTD6	; Limpio el bit 6 para que empiece apagado

	SBI DDRD, DDD7		;Configuro el como salida bit6, puerto D
	CBI PORTD, PORTD7	; Limpio el bit 7 para que empiece apagado

	//Salidas de los leds indicadores y buzzer 
	
	SBI DDRB, DDB0		;Configuro el como salida bit0, puerto B
	CBI PORTB, PORTB0	; Limpio el bit 0 para que empiece apagado

	SBI DDRB, DDB1		;Configuro el como salida bit1, puerto B
	CBI PORTB, PORTB1	; Limpio el bit 1 para que empiece apagado

	SBI DDRB, DDB2		;Configuro el como salida bit2, puerto B
	CBI PORTB, PORTB2	; Limpio el bit 2 para que empiece apagado

	SBI DDRB, DDB3		;Configuro el como salida bit3, puerto B
	CBI PORTB, PORTB3	; Limpio el bit 3 para que empiece apagado

	SBI DDRB, DDB4		;Configuro el como salida bit4, puerto B
	CBI PORTB, PORTB4	; Limpio el bit 4 para que empiece apagado

	//Congifuracion de habilitacion de interrupciones por Pin-Change 

	LDI r17, (1<<PCIE1)
	STS PCICR, r17																	;Habilito las interrupciones Pin Change del puerto C

	LDI R17, (1<<PCINT12) | (1<<PCINT11) | (1<<PCINT10) | (1<<PCINT9) | (1<<PCINT8)	;Habilito las interrupciones de Pin Change PC0-PC4
	STS	PCMSK1, R17	
	
																	

	RCALL INICIO			;Subrutina encargada de que el reloj empiece a contar al nomas conectarlo




	//Activo las interrupciones globales 
	SEI
	//C0nfiuracion de interrupciones por pinchange 



    
/****************************************/
// Loop Infinito
MAIN_LOOP:
    RJMP    MAIN_LOOP

/****************************************/
// NON-Interrupt subroutines

INICIO:
	
RET 



/****************************************/
// Interrupt routines//


/****************************************/



