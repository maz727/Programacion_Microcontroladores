/*
* Prelab3.asm
*
* Creado:15 de febrero 2026 
* Autor : Dylan Mazariegos 22986
* Descripción: Prelab 3
*/
/****************************************/
// Encabezado (Definición de Registros, Variables y Constantes)
.include "M328PDEF.inc"     // Include definitions specific to ATMega328P
.dseg
.org    SRAM_START
sol_inc: .byte 1
sol_dec: .byte 1
//variable_name:     .byte   1   // Memory alocation for variable_name:     .byte   (byte size)
.cseg
.org 0x0000
	RJMP RESET;Defino un vector de reset, asi siempre vendra a esta direccion y empezara a configurar la pila y despues el setup 

.org INT0addr
	RJMP INT_boton1; Defino la etiqueta a la que debe saltar cuando INT0 sea activada 

.org INT1addr 
	RJMP INT_boton2; Defino la etiqueta a la que debe saltar cuando INT1 sea activada
	
.org OC0Aaddr
	RJMP INT_TIMER0; Defino la etiqueta a la que debe salta cuando ocurra la interrupcion por COMP_A
 /****************************************/
// Configuración de la pila

RESET: 

LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16
/****************************************/
// Configuracion MCU
SETUP:

	CLI; Desactivo interrupciones globales 

	SBI DDRC, PC4        ; PC4 como salida (LED debug)
	SBI PORTC, PC4		 ; apaga el led al principio 

	LDI r16, 0x00
	OUT DDRD, r16;Configuro el puerto D como entradas, PD2 y PD3 encargados de interrupciones

	LDI r16, 0b00001100
	OUT PORTD, r16; Pongo en pullup el bit D2 y D3 donde iran mis botones y corresponden a INT0 y INT1

	LDI r16, 0b00001111
	OUT DDRC, r16; Configuro C0-C3 como salidas para las leds del contador de 4 bits
	CLR r16;Limpio r16 osea dejo todo en 0
	OUT PORTC, r16; Configuro que las leds esten apagadas al principio


	LDI r16, 0xFF
	OUT DDRB, r16;Configuro el puerto B como salida (Display_1 y Display_2)

    LDI r17, (1<<ISC00) | (1<<ISC10)
	STS EICRA, r17;Configuro la EICRA de la interrupciones para captar ambos flancos en PD2 y PD3

	LDI r17, (1<<INTF0) | (1<<INTF1)
	OUT EIFR, r17; Configuro para apagar las flags de  interrupcion de INT 0 y 1 antes de cualquier botonaso
	
	LDI r17, (1<<INT0) | (1<<INT1)
	OUT EIMSK, r17; Habilito las INT 0 y 1 en el registro EIMSK 

	CLR r16
	STS sol_inc, r16; Inicializo la flag que va a registrar la solicitud de incremento por la interrupcion
	STS sol_dec, r16; Iniciliazo la flag que va a registrar la solicitud de decremento por la interrupcion 

	CLR r18; Limpio r18 que me servira para llevar la cuenta de el contador de 4 bits(Las leds)
	RCALL MOSTRAR_LEDS 

	//Configuracion del TIMER0
	LDI r21, 0x00
	OUT TCNT0, r21; Aqui configuro el valor incial del contador timer0

	LDI r21, 155
	OUT OCR0A, r21; Aqui configuro el valor COMPARE MATCH A, si el TCNT0 llega a 155 este volvera a 0 y empezara a contar de nuevo 

	LDI r21, (1<<WGM01)
	OUT TCCR0A, r21; Aqui configuro el modo en el que quiero el contado que sera CTC 

	LDI r21, (1<<CS02) | (1<<CS00)
	OUT TCCR0B, r21; Aqui configuro el prescaler que quiero que utilice el timer 0 en este caso sera 1024

	LDI r21, (1<<OCIE0A)
	STS TIMSK0, r21; Aqui configuro las interrupciones del timer 0 por compare match A 

	LDI r21, (1<<OCF0A)
	OUT TIFR0, r21; Aqui limpio la flag del compare match A


	SEI;Activo las interrupciones globales 

/****************************************/
// Loop Infinito
MAIN_LOOP:

	LDS r20, sol_inc			  ; Carga a r20 el valor que tenga sol_inc , ya sea 1 o 0
	TST r20                       ; Verifico si r20 es 0 o distinto de 0
    BREQ DECREMENTO                ; Si es 0 (no hubo solicitud) salto a revisar decremento

    CLR r20                       ; Limpio r20 (lo dejo en 0)
    STS sol_inc, r20              ; Bajo la bandera sol_inc porque ya voy a atender la solicitud 

    INC r18                       ; Incremento el contador de 4 bits
    ANDI r18, 0x0F                ; Limito el contador a 4 bits (0–15)
    RCALL MOSTRAR_LEDS            ; Actualizo los LEDs con el nuevo valor del contador

	DECREMENTO:

	LDS r20, sol_dec              ; Cargo en r20 el valor de la bandera sol_dec desde la SRAM
    TST r20                       ; Verifico si r20 es 0 o distinto de 0
    BREQ FINAL_LOOP                 ; Si es 0 (no hubo solicitud) salto al final del loop

    CLR r20                       ; Limpio r20 (lo dejo en 0)
    STS sol_dec, r20              ; Bajo la bandera sol_dec porque ya voy a atenderla

    DEC r18                       ; Decremento el contador
    ANDI r18, 0x0F                ; Limito el contador a 4 bits (permite que de 0 pase a 15)
    RCALL MOSTRAR_LEDS            ; Actualizo los LEDs con el nuevo valor

	FINAL_LOOP:
    RJMP    MAIN_LOOP
/****************************************/
// NON-Interrupt subroutines
/****************************************/

MOSTRAR_LEDS:
	MOV r19, r18
	ANDI r19, 0x0F
	OUT PORTC, r19
	RET
// Interrupt routines
/****************************************/

INT_boton1:
	SBI PINC, PC4
	LDI r16, 1; Carga el numero 1 en r16
	STS sol_inc, r16; Carga el valor de r16 a sol_inc y lo guarda en la SRAM para indicar que paso la INT0
	RETI
	
INT_boton2:
	SBI PINC, PC4
	LDI r16, 1;Carga el numero 1 en r16
	STS sol_dec, r16; Carga el valor de r16 a sol_dec y lo guarda en la SRAM para indicar que paso la INT1
	RETI

INT_TIMER0:
	RETI 