/*
* Proyecto_reloj.asm
*
* Creado: 02/03/2026
* Autor : Dylan Mazariegos 22986
* Descripción: Proyecto de clase en Assembler utilizando Arduino Nano:Reloj
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
ultimo_pinc:	.byte 1		;Variable en la ram para el ultimo estado de pin C 

dia:			.byte 1		;Variable en la Ram para el dia 
mes:			.byte 1		;Variable en la Ram para el mes 
dia_dec:		.byte 1		;Variable en la ram para decenas de dia
dia_unid:		.byte 1		;Variable en la ram para unidades de dia
mes_dec:		.byte 1		;Variable en la ram para decenas de mes
mes_unid:		.byte 1		;Variable en la ram para unidades de mes 

alarm_hora:      .byte 1    ;Variable en la ram para la hora de la alarma
alarm_mins:      .byte 1    ;Variable en la ram para los minutos de la alarma

alarm_hora_dec:  .byte 1    ;Variable en la ram para las decenas de hora alarma
alarm_hora_unid: .byte 1    ;Variable en la ram para las unidades de hora alarma
alarm_min_dec:   .byte 1    ;Variable en la ram para las decenas de min alarma
alarm_min_unid:  .byte 1    ;Variable en la ram para las unidades de min alarma

alarm_on:		 .byte 1	;Variable en la ram para verificar si la alarma esta encendida o no 

parpadeo_led:	 .byte 1	;Variable en la ram para el parpadeo de los leds | Timer 0

.cseg

//=========Tabla de vectores=============//
.org 0x0000
	RJMP SETUP				;Vector de reset 
.org 0x0008
	RJMP ISR_PCINT1			;Vector de interrupcion por pin change puerto C
.org 0x0016
	RJMP ISR_TM1_COMPA		;Vector de interrupcion Timer_1 | Compare Match A
.org 0x001C
	RJMP ISR_TM0_COMPA		;Vector de interrupcion Timer_0 | Compare Match A
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
	
	SBI DDRB, DDB0		;Configuro como salida bit0, puerto B
	CBI PORTB, PORTB0	; Limpio el bit 0 para que empiece apagado

	SBI DDRB, DDB1		;Configuro como salida bit1, puerto B
	CBI PORTB, PORTB1	; Limpio el bit 1 para que empiece apagado

	SBI DDRB, DDB2		;Configuro como salida bit2, puerto B
	CBI PORTB, PORTB2	; Limpio el bit 2 para que empiece apagado

	SBI DDRB, DDB3		;Configuro como salida bit3, puerto B
	CBI PORTB, PORTB3	; Limpio el bit 3 para que empiece apagado


	//Salida- Buzzer

	SBI DDRB,DDB5
	CBI PORTB, PORTB5

	//Salida leds indicadores | Parpadeantes
	SBI DDRC, DDC5		;Configuro el como salida bit5, puerto C
	CBI PORTC, PORTC5	; Limpio el bit 5 para que empiece apagado

	
//==================Configuracion inicializacion de variables============================//
	
	//Variables de tiempo 
	LDI r16, 0
	STS hora,    r16
	STS mins,    r16
	STS secs,	 r16
	STS flag_1s, r16

	STS estado,	 r16

	//Variables de fecha
	LDI r16, 1
	STS dia, r16
	LDI r16, 1
	STS mes, r16
	
	RCALL UPDATE_DIA_DIGITS
	RCALL UPDATE_MES_DIGITS

	//Limpiar eventos
	LDI r16, 0
	STS hh_inc_ev, r16		
	STS hh_dec_ev, r16
	STS mm_inc_ev, r16
	STS mm_dec_ev, r16
	STS	cambio_modo_ev, r16

	IN r16, PINC
	STS ultimo_pinc, r16

	RCALL UPDATE_MIN_DIGITS
	RCALL UPDATE_HORA_DIGITS

	//Variables alarma
	LDI r16, 0
	STS alarm_hora, r16
	STS alarm_mins, r16
	STS alarm_on,	r16

	RCALL UPDATE_ALARMA_HORA_DIGITS
	RCALL UPDATE_ALARMA_MIN_DIGITS

	//Variables leds
	LDI r16, 0
	STS parpadeo_led, r16

//==================Configuracion Timer_0 | Leds parpadeantes======================================//

	LDI r16, (1<<WGM01)				 ; modo CTC
	OUT TCCR0A, r16
	
	LDI r16, (1<<CS02) | (1<<CS00)	; prescaler 1024
	OUT TCCR0B, r16

	LDI r16, 156					; valor para ~10ms aprox
	OUT OCR0A, r16

	LDI r16, (1<<OCIE0A)			; habilitar interrupción compare A
	STS TIMSK0, r16
	
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
	
/****************************************/
// Loop Infinito
MAIN_LOOP:
	
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

	rcall REFRESH_HHMM	;Mostrar la hora estado 0

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
	rcall INCREMENTAR_FECHA


	GUARDAR_HORA:
	STS  hora, R16

    RCALL UPDATE_HORA_DIGITS		;Llama a la rutina para actualizar el valor de la hora en los displays
    RCALL UPDATE_MIN_DIGITS			;Llama a la rutina para actualizar el valor de los minutos en los displays
	RCALL REVISAR_ALARMA			;Llama a la rutina para comparar el valor configurado en modo_0 y modo_4
    RJMP MAIN_LOOP

	GUARDAR_MIN:
	STS mins, r16

	RCALL UPDATE_MIN_DIGITS   
	RCALL REVISAR_ALARMA			;Llama a la rutina para comparar el valor configurado en modo_0 y modo_4
	RJMP MAIN_LOOP

	GUARDAR_SEC:
	STS secs, r16

	RCALL REVISAR_ALARMA			;Llama a la rutina para comparar el valor configurado en modo_0 y modo_4
	
	RJMP MAIN_LOOP

//=============Estado 1 | Mostrar Fecha====================//
	ESTADO_1:

	rcall REFRESH_DDMM		;Llama a la rutina para mostrar la fecha

    RJMP MAIN_LOOP

//=============Estado 2 | Configurar Hora====================//
	ESTADO_2:

	rcall REFRESH_HHMM		;Mostrar la hora mientras se configura 

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

	rcall REFRESH_DDMM		;Mostrar la fecha mientras se configura 

	//Incremento y decremento de dia

	;Incremento 
	LDS  r16, hh_inc_ev
    CPI  r16, 1
    BRNE REVISAR_DIA_DEC

    LDI  r16, 0
    STS  hh_inc_ev, r16        ; limpiar evento

    RCALL INC_DIA              ; Llama la rutina de incrementar dia 
    RCALL UPDATE_DIA_DIGITS


	;Decremento
	REVISAR_DIA_DEC:
	
	LDS  r16, hh_dec_ev
    CPI  r16, 1
    BRNE REVISAR_MES_INC

    LDI  r16, 0
    STS  hh_dec_ev, r16        ; Limpiar evento

    RCALL DEC_DIA              ; Llama la rutina de decrementar dia 
    RCALL UPDATE_DIA_DIGITS

	//Incremento y decremento de meses 

	;Incremento 
	REVISAR_MES_INC:
	LDS  r16, mm_inc_ev
    CPI  r16, 1
    BRNE REVISAR_MES_DEC

    LDI  r16, 0
    STS  mm_inc_ev, r16			; limpiar evento

    RCALL INC_MES				; Llama la rutina de incrementar mes
    RCALL AJUSTAR_DIA_POR_MES	; Llama una rutina que ajusta los dias al mes que toca 
    RCALL UPDATE_MES_DIGITS		; Llama la rutina de actualizar el valor de el mes 
    RCALL UPDATE_DIA_DIGITS		; LLama a la rutina de actualizar el valor de los dias

	;Decremento 
	REVISAR_MES_DEC:
	LDS  r16, mm_dec_ev
    CPI  r16, 1
    BRNE FINAL_ESTADO_3

    LDI  r16, 0
    STS  mm_dec_ev, r16        ; limpiar evento

    RCALL DEC_MES              ; mes--
    RCALL AJUSTAR_DIA_POR_MES
    RCALL UPDATE_MES_DIGITS
    RCALL UPDATE_DIA_DIGITS

	FINAL_ESTADO_3:
    RJMP MAIN_LOOP



    RJMP MAIN_LOOP

//=============Estado 4 | Configurar Alarma ====================//
	ESTADO_4:

	RCALL REFRESH_ALARMA
	LDI r16, 1
	STS alarm_on, r16
	//Incremento y decremento de hora de la alarma
	
	;Incremento 
    LDS  r16, hh_inc_ev
    CPI  r16, 1
    BRNE REVISAR_ALARMA_HH_DEC

    LDI  r16, 0
    STS  hh_inc_ev, r16

    LDS  r16, alarm_hora
    INC  r16
    CPI  r16, 24
    BRLO GUARDAR_ALARMA_HH_INC
    LDI  r16, 0

	GUARDAR_ALARMA_HH_INC:
    STS  alarm_hora, r16
    RCALL UPDATE_ALARMA_HORA_DIGITS


    ;Decremento 
	REVISAR_ALARMA_HH_DEC:
    LDS  r16, hh_dec_ev
    CPI  r16, 1
    BRNE REVISAR_ALARMA_MM_INC

    LDI  r16, 0
    STS  hh_dec_ev, r16

    LDS  r16, alarm_hora
    CPI  r16, 0
    BRNE ALARMA_HH_DEC_NORMAL
    LDI  r16, 23
    RJMP GUARDAR_ALARMA_HH_DEC

	ALARMA_HH_DEC_NORMAL:
    DEC  r16

	GUARDAR_ALARMA_HH_DEC:
    STS  alarm_hora, r16
    RCALL UPDATE_ALARMA_HORA_DIGITS

	//Incremento y decremento de minutos de la alarma 
	
	;Incremento 
	REVISAR_ALARMA_MM_INC:
    LDS  r16, mm_inc_ev
    CPI  r16, 1
    BRNE REVISAR_ALARMA_MM_DEC

    LDI  r16, 0
    STS  mm_inc_ev, r16

    LDS  r16, alarm_mins
    INC  r16
    CPI  r16, 60
    BRLO GUARDAR_ALARMA_MM_INC
    LDI  r16, 0

	GUARDAR_ALARMA_MM_INC:
    STS  alarm_mins, r16
    RCALL UPDATE_ALARMA_MIN_DIGITS


    ;Decremento minutos alarma
	REVISAR_ALARMA_MM_DEC:
    LDS  r16, mm_dec_ev
    CPI  r16, 1
    BRNE FINAL_ESTADO_4

    LDI  r16, 0
    STS  mm_dec_ev, r16

    LDS  r16, alarm_mins
    CPI  r16, 0
    BRNE ALARMA_MM_DEC_NORMAL
    LDI  r16, 59
    RJMP GUARDAR_ALARMA_MM_DEC

	ALARMA_MM_DEC_NORMAL:
    DEC  r16

	GUARDAR_ALARMA_MM_DEC:
    STS  alarm_mins, r16
    RCALL UPDATE_ALARMA_MIN_DIGITS

	FINAL_ESTADO_4:
    RJMP MAIN_LOOP

/****************************************/
// NON-Interrupt subroutines

	//=============Estado 0 | Mostrar Hora ====================//

	//Convertir min----> Decenas/Unidades 

	UPDATE_MIN_DIGITS:	

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

	LIMPIAR_SEG:		

	CBI PORTB, PORTB4     ; A
    CBI PORTD, PORTD2     ; B
    CBI PORTD, PORTD3     ; C
    CBI PORTD, PORTD4     ; D
    CBI PORTD, PORTD5     ; E
    CBI PORTD, PORTD6     ; F
    CBI PORTD, PORTD7     ; G
    RET

	MOSTRAR_DIGITO:		
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

	//=============Estado 1 | Mostrar Fecha ====================//

	//Convertir dia----> Decenas/Unidades 
	UPDATE_DIA_DIGITS:
	LDS R16, dia
    CLR R17

	DIA_LOOP:
    CPI R16, 10
    BRLO DIA_YA
    SUBI R16, 10
    INC R17
    RJMP DIA_LOOP

	DIA_YA:
    STS dia_dec, R17
    STS dia_unid, R16
    RET

	//Convertir mes----> Decenas/Unidades 
	
	UPDATE_MES_DIGITS:
    LDS R16, mes
    CLR R17

	MES_LOOP:
    CPI R16, 10
    BRLO MES_YA
    SUBI R16, 10
    INC R17
    RJMP MES_LOOP

	MES_YA:
    STS mes_dec, R17
    STS mes_unid, R16
    RET

	//Rutina para mostrar el valor de la fecha en los displays 
	REFRESH_DDMM:

    LDS R16, dia_dec
    RCALL MOSTRAR_DIGITO
    SBI  PORTB, PORTB0
    RCALL DELAY_PEQUE
    CBI  PORTB, PORTB0		;PB0 a las decenas de dia 

    LDS R16, dia_unid
    RCALL MOSTRAR_DIGITO
    SBI  PORTB, PORTB1
    RCALL DELAY_PEQUE
    CBI  PORTB, PORTB1		;PB1 a las unidades de dia

    LDS R16, mes_dec
    RCALL MOSTRAR_DIGITO
    SBI  PORTB, PORTB2
    RCALL DELAY_PEQUE
    CBI  PORTB, PORTB2		;PB2 a las decenas de mes

    LDS R16, mes_unid
    RCALL MOSTRAR_DIGITO
    SBI  PORTB, PORTB3
    RCALL DELAY_PEQUE
    CBI  PORTB, PORTB3		;PB3 a las unidades de mes 

    RET

//-----------------------Rutina numeros de meses------------------//
;==================== Configuracion de la fecha dependiendo el mes ====================
; Vuelve en r18 el máximo de días del mes actual basicmaente clasifica en que mes esta para que cuente bien los dias del mes

GET_MAX_DIAS_DEL_MES:

	PUSH r16
	LDS r16, mes
	LDI r18, 31

	CPI r16, 2 ;Si es febrero ve a la cuenta de el mes de febrero
	BREQ _MAX28
	CPI r16, 4 ;Si es abril ve a la cuenta de el mes de abril
	BREQ _MAX30
	CPI r16, 6 ;Si es junio ve a la cuenta de el mes de junio
	BREQ _MAX30
	CPI r16, 9 ;Si es septiembre ve a la cuenta del mes de septiembre
	BREQ _MAX30
	CPI r16, 11 ;Si es noviembre ve a la cuenta del mes de noviembre
	BREQ _MAX30
	RJMP _MAX_FIN
	
	_MAX28:
	LDI r18, 28
	RJMP _MAX_FIN
	_MAX30:
	LDI r18, 30
	_MAX_FIN:
	POP r16
	RET
	
	; Si dia > maxDia(mes) entonces dia = maxDia
	AJUSTAR_DIA_POR_MES:
	PUSH r16
	PUSH r18
	RCALL GET_MAX_DIAS_DEL_MES ; deja max en r18
	LDS r16, dia
	CP r16, r18
	BRLO _AJ_OK
	BREQ _AJ_OK
	
	; dia era mayor => recortar a max	
	STS dia, r18
	_AJ_OK:
	POP r18
	POP r16
	RET
	
	; Incremento de dia (si pasa max => dia=1 y mes++)
	INC_DIA:
	PUSH r16
	PUSH r18
	RCALL GET_MAX_DIAS_DEL_MES
	LDS r16, dia
	INC r16
	CP r16, r18
	BRLO _ID_GUARDAR
	BREQ _ID_GUARDAR
	
	; rollover
	LDI r16, 1
	STS dia, r16
	RCALL INC_MES
	POP r18
	POP r16
	RET

	_ID_GUARDAR:
	STS dia, r16
	POP r18
	POP r16
	RET
	
	; Decremento de dia (si dia=1 => dia=max y mes--)
	DEC_DIA:
	PUSH r16
	PUSH r18
	LDS r16, dia
	CPI r16, 1
	BRNE _DD_NORMAL
	
	; rollover hacia atrás
	RCALL DEC_MES
	RCALL GET_MAX_DIAS_DEL_MES
	STS dia, r18
	POP r18
	POP r16
	RET
	
	_DD_NORMAL:
	DEC r16
	STS dia, r16
	POP r18
	POP r16
	RET

	; Incremento de mes con rollover 12->1
	INC_MES:
	PUSH r16
	LDS r16, mes
	INC r16
	CPI r16, 13
	BRLO _IM_GUARDAR
	LDI r16, 1
	_IM_GUARDAR:
	STS mes, r16
	POP r16
	RET
	
	; Decremento de mes con rollover 1->12
	DEC_MES:
	PUSH r16
	LDS r16, mes
	CPI r16, 1
	BRNE _DM_NORMAL
	LDI r16, 12
	RJMP _DM_GUARDAR
	_DM_NORMAL:
	DEC r16
	_DM_GUARDAR:
	STS mes, r16
	POP r16
	RET

	//Rutina que incrementa la fecha cuando 23:59----->00:00 | Segun el mes//
	INCREMENTAR_FECHA:
	
	PUSH r16
	PUSH r17
	PUSH r18

	LDS  r16, dia
    INC  r16
    STS  dia, r16

	LDS r17, mes 
	LDI r18, 31		;Resto de meses con 31 dias 

	CPI r17, 2
	BREQ MAX_28		;Febrero 28 dias

	CPI r17, 4		
	BREQ MAX_30		;Abril 30 dias 

	CPI r17, 6		
	BREQ MAX_30		;Junio con 30 dias 

	CPI r17, 9		
	BREQ MAX_30		;Septiembre con 30 dias 

	CPI r17, 11
	BREQ MAX_30		;Noviembre con 30 dias 

	RJMP REVISAR_DIA 


	MAX_28:
		LDI r18, 28
	RJMP REVISAR_DIA
	
	MAX_30:
		LDI r18, 30

	REVISAR_DIA:
	
	LDS  r16, dia
    CP   r18, r16       
    BRLO ROLLOVER
    RJMP FECHA_DIGITS

	ROLLOVER:
    LDI  r16, 1
    STS  dia, r16

    LDS  r16, mes
    INC  r16
    CPI  r16, 13
    BRLO SAVE_M
    LDI  r16, 1
	SAVE_M:
    STS  mes, r16

	FECHA_DIGITS:
    RCALL UPDATE_DIA_DIGITS
    RCALL UPDATE_MES_DIGITS

    POP  r18
    POP  r17
    POP  r16

	RET	

	//Rutina para la hora de la alarma 
	UPDATE_ALARMA_HORA_DIGITS:
    LDS R16, alarm_hora
    CLR R17

	ALARMA_H_LOOP:
    CPI R16, 10
    BRLO ALARMA_H_YA
    SUBI R16, 10
    INC R17
    RJMP ALARMA_H_LOOP

	ALARMA_H_YA:
    STS alarm_hora_dec, R17
    STS alarm_hora_unid, R16
    RET

	//Rutina para los minutos de la alarma 
	UPDATE_ALARMA_MIN_DIGITS:
    LDS R16, alarm_mins
    CLR R17

	ALARMA_M_LOOP:
    CPI R16, 10
    BRLO ALARMA_M_YA
    SUBI R16, 10
    INC R17
    RJMP ALARMA_M_LOOP

	ALARMA_M_YA:
    STS alarm_min_dec, R17
    STS alarm_min_unid, R16
    RET

	//Rutina para mostrar el valor de la alarma, basicamente es la misma que REFRESH_HHMM pero con las variables para la alarma 
	REFRESH_ALARMA:
	
	//Parpadeo de displays en modo alarma 
	LDS r16, parpadeo_led
	CPI r16, 25				
	BRLO MOSTRAR_ALARMA

	; si es mayor ? NO mostrar (apagado)
	RCALL LIMPIAR_SEG
	CBI PORTB, PORTB0
	CBI PORTB, PORTB1
	CBI PORTB, PORTB2
	CBI PORTB, PORTB3
	RET

	MOSTRAR_ALARMA:

    LDS R16, alarm_hora_dec
    RCALL MOSTRAR_DIGITO
    SBI PORTB, PORTB0
    RCALL DELAY_PEQUE
    CBI PORTB, PORTB0			; PB0 decenas hora alarma

    LDS R16, alarm_hora_unid
    RCALL MOSTRAR_DIGITO
    SBI PORTB, PORTB1
    RCALL DELAY_PEQUE
    CBI PORTB, PORTB1			; PB1 unidades hora alarma

    LDS R16, alarm_min_dec
    RCALL MOSTRAR_DIGITO
    SBI PORTB, PORTB2
    RCALL DELAY_PEQUE
    CBI PORTB, PORTB2			 ; PB2 decenas min alarma

    LDS R16, alarm_min_unid
    RCALL MOSTRAR_DIGITO
    SBI PORTB, PORTB3
    RCALL DELAY_PEQUE
    CBI PORTB, PORTB3			; PB3 unidades min alarma

    RET

	REVISAR_ALARMA:
    ; primero revisar si la alarma está activada
    LDS r16, alarm_on
    CPI r16, 1
    BRNE NO_ALARMA

    ; comparar hora actual con hora de alarma
    LDS r16, hora
    LDS r17, alarm_hora
    CP  r16, r17
    BRNE NO_ALARMA

    ; comparar minutos actuales con minutos de alarma
    LDS r16, mins
    LDS r17, alarm_mins
    CP  r16, r17
    BRNE NO_ALARMA

    SBI PORTB, PORTB5
    RET

NO_ALARMA:
    CBI PORTB, PORTB5
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



;Interrupcion del timer_0 para parpadear leds
ISR_TM0_COMPA:
	PUSH r16
	IN   r16, SREG
    PUSH r16
    PUSH r17

    LDS r16, parpadeo_led
    INC r16
    STS parpadeo_led, r16

    CPI r16, 50
    BRLO FIN_ISR_T0

    LDI r16, 0
    STS parpadeo_led, r16

    
	SBIC PORTC, PORTC5
	RJMP APAGAR_LED_T0
	SBI  PORTC, PORTC5
	RJMP FIN_ISR_T0

	APAGAR_LED_T0:
	CBI  PORTC, PORTC5
	FIN_ISR_T0:
    POP  r17
    POP  r16
    OUT  SREG, r16
    POP  r16
    RETI
/****************************************/



