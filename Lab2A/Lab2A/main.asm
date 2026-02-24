/*
* Lab2A.asm
*
* Creado: 08 de febrero 2026
* Autor : Dylan Mazariegos Moran 
* Descripción: Prelab del Laboratorio no.2
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
/* TABLA 7 SEGMENTOS (CATODO COMUN)
   Bits: PD0=a, PD1=b, PD2=c, PD3=d, PD4=e, PD5=f, PD6=g, PD7=dp
*/
  
TABLA_7SEG:
    .db 0b00111111 ; 0
    .db 0b00000110 ; 1
    .db 0b01011011 ; 2
    .db 0b01001111 ; 3
    .db 0b01100110 ; 4
    .db 0b01101101 ; 5
    .db 0b01111101 ; 6
    .db 0b00000111 ; 7
    .db 0b01111111 ; 8
    .db 0b01101111 ; 9
    .db 0b01110111 ; A
    .db 0b01111100 ; b 
    .db 0b00111001 ; C
    .db 0b01011110 ; d
    .db 0b01111001 ; E
    .db 0b01110001 ; F

 /****************************************/
// Configuración de la pila
LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16
/****************************************/
// Configuracion MCU
SETUP:
	LDI r16, 0b11111111//Dejo todos los bits del puerto D
	OUT DDRD, r16 ;Aqui ira conectado mi display de 7 segmmentos

	LDI r16, 0b00011111; Dejo 5 bits como salidas en el puerto C para leds del contador y alarmar 
	OUT DDRC, r16; Aqui ira conectado el contador y la luz de alarma

	LDI r16, 0b00000000; Configuro el puerto B como entradas 
	OUT DDRB, r16;Aqui iran conectados los botones  

	LDI r16, 0b00000011;Pongo en pull up los bits b0 y b1 que es donde iran mis botones
	OUT PORTB, r16
	CLR r16
	CLR r20

	//Configuracion del modo del TIMER_0
	LDI r18, 0x00
	OUT TCCR0A, r18
	OUT TCCR0B, r18

	//Configuracion del la velocidad del contador(Prescaler) TIMER_0
	LDI r18, 0b00000101;Prescaler CPU/1024
	OUT TCCR0B, r18

	LDI r18, (1<<TOV0)
	OUT TIFR0, r18;Limpio la bandera de overflow y poder arrancar en un estado conocido 

	LDI R16, 0x00
	STS UCSR0B, R16

	//El Timer_0 tiene un registro llamado TIF0 y dentro de este registro esta la bandera llamada TOV_0 esta bandera 
	//se enciene si el TIMER_0 hace overflow en mi caso el prescaler divide la frecuencia (16MHz) y de ahi obtengo
	//cuantas veces por segundo incrementa el TIMER_0 de ahi obtengo el tiempo que dura cada  incremento y el valor
	//de ese tiempo lo multiplico por el el numero de incrementos que el timer tiene que hacer para que suceda overflow
	//esto me da como resultado el tiempo en que el TIMER_0 da un overflow (16.384 ms), necesito aproximadamente 6 
	//overflows para llegar a 100ms


/****************************************/
// Loop Infinito
MAIN_LOOP:

	RCALL CONT_C100MS 

	INC r20; Incrementa el registro 20, este llevara la cuenta del TIMER_0
	ANDI r20, 0X0F;Enmascara los primeros 4 bits del r20

	//Utilizare el registro 21 temporalmente para guardar el estado de el puerto C con la intencion
	// de conservar el estado en el que el Bit C4 se encuentre que sera la alarma 

	IN r21, PORTC
	ANDI r21, 0xF0
	OR r21,r20
	OUT PORTC, r21

	 
	IN r17, PINB; Aqui va estar leyendo si se esta oprimiendo alguno de los 2 botones 
	ANDI r17, 0b00000011

	CPI r17, 0b00000010;Aqui va a revisar si se esta presionanto el boton 1
	BREQ boton_1
	
	CPI r17, 0b00000001;Aqui va a revisar si se esta presionanto el boton 2
	BREQ boton_2


RJMP    MAIN_LOOP

	
boton_1:
		IN r17, PINB 
		ANDI r17, 0b00000011
		CPI r17, 0b00000011; Antirrebote, queda en loop si el boton 1 aun no se suelta 
	BRNE boton_1

	INC r16
	ANDI r16, 0x0F; Aqui indico que quiero solo los primeros 4 bits para el contador que tendra r16
	RCALL MUESTRA_R16_DISPLAY

	RJMP MAIN_LOOP

boton_2:
		IN r17, PINB 
		ANDI r17, 0b00000011
		CPI r17, 0b00000011;Antirrebote, queda en loop si el boton 2 aun no se suelta
	BRNE boton_2

	DEC r16
	ANDI r16, 0x0F; Aqui indico que quiero solo los primeros 4 bits para el contador que tendra r16
	RCALL MUESTRA_R16_DISPLAY
	

RJMP MAIN_LOOP

/****************************************/
// NON-Interrupt subroutines

CONT_C100MS:

	LDI r18,(1<<TOV0)
	OUT TIFR0, r18;Limpio de nuevo la bandera de overflow por si es que viniera encendida

	LDI r19,6

CONTOVERFLOWS:

	YAHUBOOVERFLOW:

	IN r18, TIFR0
	SBRS r18, TOV0

	rjmp YAHUBOOVERFLOW


	LDI r18, (1<<TOV0)
	OUT TIFR0, r18

	DEC r19

	BRNE CONTOVERFLOWS

RET


MUESTRA_R16_DISPLAY:
    LDI  ZH, HIGH(TABLA_7SEG<<1)
    LDI  ZL, LOW(TABLA_7SEG<<1)

    ADD  ZL, r16
    ADC  ZH, r1          

    LPM  r18, Z
    OUT  PORTD, r18
    RET

	


/****************************************/
// Interrupt routines

/****************************************/
