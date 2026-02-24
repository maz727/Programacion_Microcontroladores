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

	CBI DDRC, DDC4
	SBI PORTC, PORTC4	;Configuro como entrada el bit 4 del puerto C y pongo pull up 

	CBI DDRC, DDC5
	SBI PORTC, PORTC5	;Configuro como entrada el bit 5 del puerto C y pongo pull up

	CBI DDRB, DDB4
	SBI PORTB, PORTB4	;Configuro como entrada el bit 5 del puerto B y pongo pull up

	//Leds contador no.1
	SBI DDRC, DDC0		;Configuro el como salida bit0, puerto C
	CBI PORTC, PORTC0	; Limpio el bit 0 para que empiece apagado

	SBI DDRC, DDC1		;Configuro el como salida bit1, puerto C
	CBI PORTC, PORTC1	; Limpio el bit 1 para que empiece apagado

	SBI DDRC, DDC2		;Configuro el como salida bit2, puerto C
	CBI PORTC, PORTC2	; Limpio el bit 2 para que empiece apagado

	SBI DDRC, DDC3		;Configuro el como salida bit3, puerto C
	CBI PORTC, PORTC3	; Limpio el bit 3 para que empiece apagado

	//Leds contador no.2
	SBI DDRD, DDD4		;Configuro el como salida bit4, puerto D
	CBI PORTD, PORTD4	; Limpio el bit 4 para que empiece apagado

	SBI DDRD, DDD5		;Configuro el como salida bit5, puerto D
	CBI PORTD, PORTD5	; Limpio el bit 5 para que empiece apagado

	SBI DDRD, DDD6		;Configuro el como salida bit6, puerto D
	CBI PORTD, PORTD6	; Limpio el bit 6 para que empiece apagado

	SBI DDRD, DDD7		;Configuro el como salida bit7, puerto D
	CBI PORTD, PORTD7	; Limpio el bit 7 para que empiece apagado

	//Leds resultado suma 
	SBI DDRB, DDB0		;Configuro el como salida bit0, puerto B
	CBI PORTB, PORTB0	; Limpio el bit 0 para que empiece apagado

	SBI DDRB, DDB1		;Configuro el como salida bit1, puerto B
	CBI PORTB, PORTB1	; Limpio el bit 1 para que empiece apagado

	SBI DDRB, DDB2		;Configuro el como salida bit2, puerto B
	CBI PORTB, PORTB2	; Limpio el bit 2 para que empiece apagado

	SBI DDRB, DDB3		;Configuro el como salida bit7, puerto D
	CBI PORTB, PORTB3	; Limpio el bit 3 para que empiece apagado 

	//Led Overflow/Carry 
	SBI DDRD, DDD0		;Configuro el como salida bit5, puerto B
	CBI PORTD, PORTD0	; Limpio el bit 5 para que empiece apagado

 	CLR r16				;Limpio el r16 que sera mi contador binario 1
	CLR r21				;Limpio el r21 que sera mi contador binario 2

	//Leds resultado suma 

    
/****************************************/
// Loop Infinito
MAIN_LOOP:

    //Contador 1
	IN r17, PIND			;Aqui guardara en el r17 lo que lea del puerto D 
	ANDI r17, 0b00001100	; Filtra el valor para los bit 2 y 3 que son los de interes, el estado de los botones/CONT1

	CPI r17, 0b00000000		;Aqui por si se presionan los 2
	BREQ MAIN_LOOP			;Regresa al Main Loop

	SBRS r17, 2				; Si PD2=1 (No presionado) salta 
	RJMP boton_1			; Ve a la subrutina del boton 1

	SBRS r17, 3				; Si PD3=1 (No presionado) salta 
	RJMP boton_2			; Ve a la subrutina del boton 2

	//Contador 2
	IN r22, PINC			;Aqui guardara en el r22 lo que lea del puerto C
	ANDI r22, 0b00110000	; Filtra el valor para los bit 4 y 5 que son los de interes, el estado de los botones/CONT2

	CPI r22, 0b00000000		;Aqui por si se presionan los 2
	BREQ MAIN_LOOP			;Regresa al Main Loop

	SBRS r22, 4				; Si PC4=1 (No presionado) salta 
	RJMP boton_3			; Ve a la subrutina del boton 3

	SBRS r22, 5				; Si PC5=1 (No presionado) salta 
	RJMP boton_4			; Ve a la subrutina del boton 4

	//Suma
	IN r25, PINB			;Aqui guardara en r25 lo que lea del puerto B
	ANDI r25, 0b00010000	;Filtra el valor para el bit 5 que es el de interes Boton de Suma

	SBRS r25, 4			; Si PB5=1 (No presionado) salta
	RJMP boton_5			; Ve a la subrutina del boton 5
 
RJMP MAIN_LOOP

boton_1:
	rcall Delay
	
	SBIC PIND, PIND2	;Salta si el bit D2 es 0(Boton oprimido) si es 1 (No oprimido) la siguiente linea
	RJMP Exit_1			;Si despues del delay D2=1 no se oprimio el boton

	Soltar_1:
	SBIS PIND, PIND2	;Salta si el bit D2 es 1(Boton ya no presionado) si es 0(El boton aun esta oprimido) la sig linea
	RJMP Soltar_1

	INC r16					;Incremento 
	CPI r16, 16				;Comparo el valor de r16 con 16
	BRLO COMFIRM_INC_CT1	;Si el valor de r16 es menor de 16 confirma el incremento si el valor es mayor ejecuta la sig linea
	CLR r16					;Vuelve a 0 r16/ Overflow

	COMFIRM_INC_CT1:		;Hay incremento
	rcall MOSTRAR_LEDS_CT1	;Ve a la rutina encargada de controlar los leds 

	Exit_1:
	
rjmp MAIN_LOOP

boton_2:
	rcall Delay
	
	SBIC PIND, PIND3	;Salta si el bit D2 es 0(Boton oprimido) si es 1 (No oprimido) la siguiente linea
	RJMP Exit_2			;Si despues del delay D3=1 no se oprimio el boton

	Soltar_2:
	SBIS PIND, PIND3	;Salta si el bit D2 es 1(Boton ya no presionado) si es 0(El boton aun esta oprimido) la sig linea
	RJMP Soltar_2
	
	DEC r16					;Decrementa r16
	CPI r16, 255			;Compara el valor de r16 con 255( 255 es el numero mas alto al que puede contar)
	BRNE COMFIRM_DEC_CT1	;Si el valor es diferente de 255 salta,confirma el decremento (0 al 16) si es igual osea viene de 0, decrementa y pum 255, ejecuta la siguiente linea
	LDI r16, 15				;Vuelve a poner 15 /Underflow

	COMFIRM_DEC_CT1:		;Hay decremento
	rcall MOSTRAR_LEDS_CT1	;Ve a la rutina encargada de controlar los leds 

	Exit_2:	

rjmp MAIN_LOOP

boton_3:
	rcall Delay 

	SBIC PINC, PINC4	;Salta si el bit C4 es 0(Boton oprimido) si es 1 (No oprimido) la siguiente linea
	RJMP Exit_3			;Si despues del delay C4=1 no se oprimio el boton

	Soltar_3:
	SBIS PINC, PINC4	;Salta si el bit C4 es 1(Boton ya no presionado) si es 0(El boton aun esta oprimido) la sig linea
	RJMP Soltar_3

	INC r21					;Incremento 
	CPI r21, 16				;Comparo el valor de r21 con 16
	BRLO COMFIRM_INC_CT2	;Si el valor de r21 es menor de 16 confirma el incremento si el valor es mayor ejecuta la sig linea
	CLR r21					;Vuelve a 0 r16/ Overflow

	COMFIRM_INC_CT2:		;Hay incremento
	rcall MOSTRAR_LEDS_CT2	;Ve a la rutina encargada de controlar los leds 

	Exit_3:

rjmp MAIN_LOOP

boton_4:
	rcall Delay 

	SBIC PINC, PINC5	;Salta si el bit C5 es 0(Boton oprimido) si es 1 (No oprimido) la siguiente linea
	RJMP Exit_4			;Si despues del delay C5=1 no se oprimio el boton

	Soltar_4:
	SBIS PINC, PINC5	;Salta si el bit C5 es 1(Boton ya no presionado) si es 0(El boton aun esta oprimido) la sig linea
	RJMP Soltar_4 

	DEC r21					;Decrementa r21
	CPI r21, 255			;Compara el valor de r21 con 255( 255 es el numero mas alto al que puede contar)
	BRNE COMFIRM_DEC_CT2	;Si el valor es diferente de 255 salta,confirma el decremento (0 al 16) si es igual osea viene de 0, decrementa y pum 255, ejecuta la siguiente linea
	LDI r21, 15				;Vuelve a poner 15 /Underflow

	COMFIRM_DEC_CT2:		;Hay decremento
	rcall MOSTRAR_LEDS_CT2	;Ve a la rutina encargada de controlar los leds 

	Exit_4:
rjmp MAIN_LOOP

boton_5:
	rcall Delay 

	SBIC PINB, PINB4	;Salta si el bit C5 es 0(Boton oprimido) si es 1 (No oprimido) la siguiente linea
	RJMP Exit_5			;Si despues del delay B5=1 no se oprimio el boton

	Soltar_5:
	SBIS PINB, PINB4	;Salta si el bit B5 es 1(Boton ya no presionado) si es 0(El boton aun esta oprimido) la sig linea
	RJMP Soltar_5 

	rcall MOSTRAR_LEDS_SUMA

	Exit_5:
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

MOSTRAR_LEDS_CT1:
	MOV r20, r16			;Mueve el valor de r16 a r20
	ANDI r20, 0b00001111	;Indica que conserve los primeros 4 bits y descarte los segundos 4

	IN   r24, PORTC			;Guarda en r24 el valor del puerto C, ahi en PC4 y PC5 tengo pull up
    ANDI r24, 0b11110000	;Indica que conserve los segundos 4 bits y descarte los primeros 4
    OR   r20, r24			;Junto el valor de de r20(Leds) con el valor de r24(Botones en pull-up)
    OUT  PORTC, r20			;Mando el nuevo valor de r20 al puerto C
RET

MOSTRAR_LEDS_CT2:
	MOV	 r22, r21			;Mueve el valor de r21 a r22
	ANDI r22, 0b00001111	;Indica que conserve los primeros 4 bits y descarte los segundos 4
	SWAP r22				;Pasa los 4 bits bajo a ser los 4 bits altos (Leds cableadas de PD4 a PD7)

	IN r23, PORTD			;Guarda en r23 el valor del puerto D, ahi en PD2 y PD3 tengo pull up
	ANDI r23, 0b00001111	;Indica que conserve los primeros 4 bits y descarte los segundos 4

	OR r22,r23				;Junto el valor de de r22(Leds) con el valor de r23(Botones en pull-up)
	OUT PORTD, r22			;Mando el nuevo valor de r22 al puerto D


RET

MOSTRAR_LEDS_SUMA:

	MOV  r26, r16
    ADD  r26, r21              ; r26 = suma (0..30)

    ; ---- Mostrar resultado (4 bits) en PB0..PB3 ----
    MOV  r27, r26
    ANDI r27, 0b00001111       ; solo nibble bajo

    IN   r28, PORTB
    ANDI r28, 0b11110000       ; conserva PB4..PB7 (pullup del botón y lo demás)
    OR   r27, r28
    OUT  PORTB, r27

    ; ---- Carry de 4 bits (bit4 de r26) a PD0 ----
    SBRS r26, 4                ; si bit4 = 1, NO salta
    RJMP NO_CARRY4
    SBI  PORTD, PORTD0         ; carry4 = 1
    RET

NO_CARRY4:
    CBI  PORTD, PORTD0 
	



	
RET