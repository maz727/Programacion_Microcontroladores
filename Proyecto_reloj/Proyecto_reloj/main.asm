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
//variable_name:	.byte   1   // Memory alocation for variable_name:     .byte   (byte size)

hora:		.byte 1		;Variable en la ram para el valor de la hora 
mins:		.byte 1		;Variable en la ram para el valor de los minutos
secs:		.byte 1		;Variable en la ram para el valor de los segundos 
flag_1s:	.byte 1		;Variable en la ram para la flag del conteo 1s

sec_dec:	.byte 1		;Variable en la ram para decenas de segundo
sec_unid:	.byte 1		;Variable en la ram para unidades de segundo
min_dec:	.byte 1		;Variable en la ram para decenas de minuto 
min_unid:	.byte 1		;Variable en la ram para unidades de minuto 
hora_dec:	.byte 1		;Variable en la ram para decenas de hora
hora_unid:	.byte 1		;Variable en la ram para unidades de hora 

estado:			.byte 1		;Variable en la ram para el estado del reloj
hh_inc_ev:		.byte 1		;PC0
hh_dec_ev:		.byte 1		;PC1
mm_inc_ev:		.byte 1		;PC2
mm_dec_ev:		.byte 1		;PC3
cambio_modo_ev:	.byte 1		;PC4
ultimo_pinc:	.byte 1
.cseg

//=========Tabla de vectores=============//
.org 0x0000
	RJMP SETUP				;Vector de reset 
.org 0x0008
	RJMP ISR_PCINT1			;Vector de interrupcion por pin change puerto C
.org 0x0016
	RJMP ISR_TM1_COMPA		;Vector de interrupcion Timer_1/Compare Match A
.org 0x0100
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
	
//==================Configuraciones de entradas y salidas==============================//

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

	SBI DDRB, DDB4		;Configuro el como salida bit0, puerto B
	CBI PORTB, PORTB4	; Limpio el bit 0 para que empiece apagado

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

	//Salidas de los transistores para controlar el multiplexado de los displays 
	
	SBI DDRB, DDB0		;Configuro el como salida bit0, puerto B
	CBI PORTB, PORTB0	; Limpio el bit 0 para que empiece apagado

	SBI DDRB, DDB1		;Configuro el como salida bit1, puerto B
	CBI PORTB, PORTB1	; Limpio el bit 1 para que empiece apagado

	SBI DDRB, DDB2		;Configuro el como salida bit2, puerto B
	CBI PORTB, PORTB2	; Limpio el bit 2 para que empiece apagado

	SBI DDRB, DDB3		;Configuro el como salida bit3, puerto B
	CBI PORTB, PORTB3	; Limpio el bit 3 para que empiece apagado


	//Salida leds indicadores 

	

	//Salida- Buzzer
	SBI DDRC, DDC5		;Configuro el como salida bit5, puerto C
	CBI PORTC, PORTC5	; Limpio el bit 5 para que empiece apagado

	;


//==================Configuracion inicializacion de variables============================//

	LDI r16, 0
	STS hora,    r16
	STS mins,    r16
	STS secs,	 r16
	STS flag_1s, r16

	STS estado,	 r16

	//Limpiar eventos
	STS hh_inc_ev, r16		
	STS hh_dec_ev, r16
	STS mm_inc_ev, r16
	STS mm_dec_ev, r16
	STS	cambio_modo_ev, r16

	IN r16, PINC
	STS ultimo_pinc, r16

	RCALL UPDATE_MIN_DIGITS
	RCALL UPDATE_HORA_DIGITS

//==================Configuracion Timer_1| Modo CTC======================================//

	LDI r16, 0
	STS TCCR1A, r16

	LDI r16, (1<<WGM12) | (1<<CS12) | (1<<CS10)		; Prescaler de 1024
	STS TCCR1B, r16

	LDI R16, HIGH(15624)		;Cargar el valor 15624 a OCR1A
	STS OCR1AH, R16

	LDI R16, LOW(15624)			;Cargar el valor 15624 a OCR1A
	STS OCR1AL, R16

	LDI r16, 0x00				;Inicia en 0
	STS TCNT1H, r16
	STS TCNT1L, r16

	LDI r16, (1<<OCIE1A)		;Habilitar interrupciones por compare match A
	STS TIMSK1, r16

	//Congifuracion de habilitacion de interrupciones por Pin-Change 

	LDI r17, (1<<PCIE1)
	STS PCICR, r17																		;Habilito las interrupciones Pin Change del puerto C

	LDI R17, (1<<PCINT12) | (1<<PCINT11) | (1<<PCINT10) | (1<<PCINT9) | (1<<PCINT8)		;Habilito las interrupciones de Pin Change PC0-PC4
	STS	PCMSK1, R17	
														

	//Activo las interrupciones globales 
	SEI
	//C0nfiuracion de interrupciones por pinchange 



    
/****************************************/
// Loop Infinito
MAIN_LOOP:

	rcall REFRESH_HHMM
	
//=============Flag de de modos del reloj============//
	LDS R16, cambio_modo_ev	;Leer evento 
	CPI R16, 1
	BRNE NO_MODO

	LDI R16, 0
	STS cambio_modo_ev, R16	;Limpiar evento

	LDS R16, estado
	INC R16

	CPI R16, 5
	BRLO GUARDAR_ESTADO
	LDI R16, 0

	GUARDAR_ESTADO:
	STS estado, R16

	rcall DELAY_PEQUE

	NO_MODO:

//==============Enrutador de modos del reloj==============//

	LDS r16, estado

	CPI r16, 0
	BREQ IR_ESTADO_0	;Mostrar la hora

	CPI r16, 1
	BREQ IR_ESTADO_1	;Mosrar la fecha  

	CPI r16, 2
	BREQ IR_ESTADO_2	;Configurar la hora

	CPI r16, 3
	BREQ IR_ESTADO_3	;Configurar la fecha

	CPI r16, 4
	BREQ IR_ESTADO_4	;Configurar la alarma 

	RJMP MAIN_LOOP

	//Utilizo estas etiquetas ya que el codigo al ser muy largo instrucciones como BREQ no funcionan y es necesario hace un RJMP 
	IR_ESTADO_0:  RJMP ESTADO_0
	IR_ESTADO_1:  RJMP ESTADO_1
	IR_ESTADO_2:  RJMP ESTADO_2
	IR_ESTADO_3:  RJMP ESTADO_3
	IR_ESTADO_4:  RJMP ESTADO_4

//=============Estado 0 | Mostrar Hora====================//
	
	//Corazon | Este lee la flag y inicia el conteo de los segundos
	ESTADO_0:

	LDI R16, 0
    STS hh_inc_ev, R16
    STS hh_dec_ev, R16
    STS mm_inc_ev, R16
    STS mm_dec_ev, R16

	LDS r16, flag_1s	;Carga el valor de flag_1s a r16
	CPI r16, 1			;Compara el valor de la flag con 1
	BRNE MAIN_LOOP		;Si no regresa a al Main

	LDI r16,0
	STS flag_1s, r16	;Carga 0 limpia la flag ya atendimos la ISR

	//Segundos
	LDS  R16, secs		
    INC  R16
    CPI  R16, 60
    BRLO GUARDAR_SEC
    LDI  R16, 0			
	STS secs, r16	
	
	//Minutos 
	LDS  R16, mins
	INC  R16
	CPI  R16, 60
	BRLO GUARDAR_MIN
	LDI  R16, 0
	STS mins, r16

	//Hora 
	LDS  R16, hora
    INC  R16
    CPI  R16, 24
    BRLO GUARDAR_HORA
    LDI  R16, 0

	GUARDAR_HORA:
	STS  hora, R16
    RCALL UPDATE_HORA_DIGITS
    RCALL UPDATE_MIN_DIGITS
    RJMP MAIN_LOOP

	GUARDAR_MIN:
	STS mins, r16

	RCALL UPDATE_MIN_DIGITS   
	RJMP MAIN_LOOP

	GUARDAR_SEC:
	STS secs, r16
	
	RJMP MAIN_LOOP

//=============Estado 1 | Mostrar Fecha====================//
	ESTADO_1:

    RJMP MAIN_LOOP

//=============Estado 2 | Configurar Hora====================//
	ESTADO_2:

	//Incremento y decremento de horas 
	
	;Incremento 
	LDS  r16, hh_inc_ev			;Hay flag de incremento horas?
    CPI  r16, 1
    BRNE REVISAR_HH_DEC			;No? okay ,revisar el siguiente

    LDI  r16, 0
    STS  hh_inc_ev, r16          ;Si?limpiar evento

	LDS  r16, hora
    INC  r16
    CPI  r16, 24
    BRLO GUARDAR_HH_INC
    LDI  r16, 0
	
	GUARDAR_HH_INC:
    STS  hora, r16
    RCALL UPDATE_HORA_DIGITS

	;Decremento 
	REVISAR_HH_DEC:				
	LDS r16, hh_dec_ev			;Hay flag de decremento de horas?
	CPI r16, 1
	BRNE REVISAR_MM_INC			; No?, OKay ,revisa el siguiente

	LDI r16, 0
	STS hh_dec_ev, r16				;Si?Limpiar evento 

	LDS  R16, hora
    CPI  R16, 0					;La hora es cero?
    BRNE HH_DEC_NORMAL			;No es igual a 0 decremento normal
    LDI  R16, 23				;Si es 0? carga 23
    RJMP GUARDAR_HH_DEC
	
	HH_DEC_NORMAL:				
    DEC  R16
	
	GUARDAR_HH_DEC:
    STS  hora, R16
    RCALL UPDATE_HORA_DIGITS

	//Incremennto y decrementos de minutos 

	;Incremento 
	REVISAR_MM_INC:
	LDS r16, mm_inc_ev			;Hay flag de incremento de minutos?
	CPI r16, 1
	BRNE REVISAR_MM_DEC			;No? OKay revisa el siguiente 

	LDI r16, 0
	STS mm_inc_ev, r16				;Si? Limpiar el evento 

	LDS  R16, mins
    INC  R16
    CPI  R16, 60
    BRLO GUARDAR_MM_INC
    LDI  R16, 0
	
	GUARDAR_MM_INC:
    STS  mins, R16
    RCALL UPDATE_MIN_DIGITS

	;Decremento 
	REVISAR_MM_DEC:
	LDS r16, mm_dec_ev			;Hay flag de decremento de minutos?
	CPI r16, 1
	BRNE FINAL_ESTADO_2			;No? OKay regresa a al incio de la funcion modo 2

	LDI r16, 0
	STS mm_dec_ev, r16				;Si? Limpiar evento 

	LDS  R16, mins
    CPI  R16, 0					;Los minutos estan en 0
    BRNE MM_DEC_NORMAL			;No es igual a 0? Okay decremento normal 
    LDI  R16, 59				;Carga 59
    RJMP GUARDAR_MM_DEC
	
	MM_DEC_NORMAL:
    DEC  R16
	
	GUARDAR_MM_DEC:
    STS  mins, R16
    RCALL UPDATE_MIN_DIGITS

	FINAL_ESTADO_2:

    RJMP MAIN_LOOP


//=============Estado 3 | Configurar Fecha====================//
	ESTADO_3:

    RJMP MAIN_LOOP

//=============Estado 4 | Configurar Alarma ====================//
	ESTADO_4:

    RJMP MAIN_LOOP

/****************************************/
// NON-Interrupt subroutines

	//=============Estado 0 | Mostrar Hora ====================//

	//Convertir min----> Decenas/Unidades 

	UPDATE_MIN_DIGITS:	;Sb1

    LDS R16, mins     
    CLR R17           

	 MIN_LOOP:
		CPI R16, 10
		BRLO MIN_DONE
		SUBI R16, 10
		INC R17
		RJMP MIN_LOOP

	 MIN_DONE:
		STS min_dec, R17
		STS min_unid, R16
		RET

	//Convertir hora----->> Decenas/Unidades

	UPDATE_HORA_DIGITS:
    LDS R16, hora      
    CLR R17            

	 H_LOOP:
		CPI R16, 10
		BRLO H_DONE
		SUBI R16, 10
		INC R17
		RJMP H_LOOP

	H_DONE:
		STS hora_dec, R17
		STS hora_unid, R16
		RET

	//Rutina para dibujar un digito 0 a 9 

	LIMPIAR_SEG:		;Sb3

	CBI PORTB, PORTB4     ; A
    CBI PORTD, PORTD2     ; B
    CBI PORTD, PORTD3     ; C
    CBI PORTD, PORTD4     ; D
    CBI PORTD, PORTD5     ; E
    CBI PORTD, PORTD6     ; F
    CBI PORTD, PORTD7     ; G
    RET

	MOSTRAR_DIGITO:		;SB4
	rcall LIMPIAR_SEG

	CPI R16, 0
    BREQ D0
    CPI R16, 1
    BREQ D1
    CPI R16, 2
    BREQ D2
    CPI R16, 3
    BREQ D3
    CPI R16, 4
    BREQ D4
    CPI R16, 5
    BREQ D5
    CPI R16, 6
    BREQ D6
    CPI R16, 7
    BREQ D7
    CPI R16, 8
    BREQ D8
    CPI R16, 9
    BREQ D9
    RET

	D0: ; A B C D E F
    SBI PORTB, PORTB4
    SBI PORTD, PORTD2
    SBI PORTD, PORTD3
    SBI PORTD, PORTD4
    SBI PORTD, PORTD5
    SBI PORTD, PORTD6
    RET

	D1: ; B C
    SBI PORTD, PORTD2
    SBI PORTD, PORTD3
    RET

	D2: ; A B D E G
    SBI PORTB, PORTB4
    SBI PORTD, PORTD2
    SBI PORTD, PORTD4
    SBI PORTD, PORTD5
    SBI PORTD, PORTD7
    RET

	D3: ; A B C D G
    SBI PORTB, PORTB4
    SBI PORTD, PORTD2
    SBI PORTD, PORTD3
    SBI PORTD, PORTD4
    SBI PORTD, PORTD7
    RET

	D4: ; B C F G
    SBI PORTD, PORTD2
    SBI PORTD, PORTD3
    SBI PORTD, PORTD6
    SBI PORTD, PORTD7
    RET

	D5: ; A C D F G
    SBI PORTB, PORTB4
    SBI PORTD, PORTD3
    SBI PORTD, PORTD4
    SBI PORTD, PORTD6
    SBI PORTD, PORTD7
    RET

	D6: ; A C D E F G
    SBI PORTB, PORTB4
    SBI PORTD, PORTD3
    SBI PORTD, PORTD4
    SBI PORTD, PORTD5
    SBI PORTD, PORTD6
    SBI PORTD, PORTD7
    RET

	D7: ; A B C
    SBI PORTB, PORTB4
    SBI PORTD, PORTD2
    SBI PORTD, PORTD3
    RET

	D8: ; A B C D E F G
    SBI PORTB, PORTB4
    SBI PORTD, PORTD2
    SBI PORTD, PORTD3
    SBI PORTD, PORTD4
    SBI PORTD, PORTD5
    SBI PORTD, PORTD6
    SBI PORTD, PORTD7
    RET

	D9: ; A B C D F G
    SBI PORTB, PORTB4
    SBI PORTD, PORTD2
    SBI PORTD, PORTD3
    SBI PORTD, PORTD4
    SBI PORTD, PORTD6
    SBI PORTD, PORTD7
    RET

	REFRESH_HHMM:	;Sb5

	LDS R16, hora_dec
    RCALL MOSTRAR_DIGITO
    SBI PORTB, PORTB0
    RCALL DELAY_PEQUE
    CBI PORTB, PORTB0	;PB0 a las decenas de Horas 

	LDS R16, hora_unid
    RCALL MOSTRAR_DIGITO
    SBI PORTB, PORTB1
    RCALL DELAY_PEQUE
    CBI PORTB, PORTB1	;PB1 a las unidades de horas 

	LDS r16, min_dec
	rcall MOSTRAR_DIGITO 
	SBI PORTB, PORTB2
	rcall DELAY_PEQUE
	CBI PORTB, PORTB2	;PB2 a las decenas de Minutos 

	LDS r16, min_unid
	rcall MOSTRAR_DIGITO
	SBI PORTB, PORTB3
	rcall DELAY_PEQUE
	CBI PORTB, PORTB3	;PB3 a las unidades de Minutos
	RET

	DELAY_PEQUE:	;SB6

	LDI R20, 200
SD1:
    DEC R20
    BRNE SD1
    RET

/****************************************/
// Interrupt routines//

;Interrupcion del timer 1 cada para indicar que ya paso 1 segundo.
ISR_TM1_COMPA:
	
	PUSH r16			;Guarda el valor de r16
	LDI r16, 1
	STS flag_1s, r16	; Pone en 1 la flag de 1 segundo, avisa que paso 1 segundo
	POP r16			

RETI

; Interrupcion de pinchange para el puerto C y clasificacion del boton de que interrumpe
ISR_PCINT1:
	PUSH R16
    PUSH R17
    PUSH R18
    PUSH R19
	
	IN r16, PINC
	LDS r17,ultimo_pinc

	MOV r18,r16
	EOR r18, r17
	STS ultimo_pinc,r16

	LDI r19, 1
	
	SBRS r18, 4
	RJMP REVISAR_PC0
	SBRS R16, 4            
    STS  cambio_modo_ev, R19


	REVISAR_PC0:				; Evento de incremento para el display la izquierda 
	
	SBRS r18, 0					;PC0 correspondiente a incremento de horas	
    RJMP REVISAR_PC1
    SBRS r16, 0
    STS  hh_inc_ev, r19		

	REVISAR_PC1:

	SBRS r18, 1					;PC1 correspondiente al decremento de horas 
	RJMP REVISAR_PC2
	SBRS r16, 1
	STS hh_dec_ev, r19

	REVISAR_PC2:		

	SBRS R18, 2					;PC2 correspondiente al incrmento de minutos 
    RJMP REVISAR_PC3
    SBRS R16, 2
    STS  mm_inc_ev, R19		

	REVISAR_PC3:

	SBRS R18, 3					;PC3 correspondiente al decremento de minutos 
    RJMP PCINT_YA
    SBRS R16, 3
    STS  mm_dec_ev, R19

	PCINT_YA:	
    POP  R19
    POP  R18
    POP  R17
    POP  R16
RETI
/****************************************/



