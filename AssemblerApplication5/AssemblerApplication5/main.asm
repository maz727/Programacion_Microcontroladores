// NombreProgra.asm
//
// Creado: 09/02/2026
// Autor : Sebastian Da Silva
// Descripci?n: PreLab3 interrupciones
// MOD: LEDs del contador de PD4-PD7 -> PC0-PC3 (Dylan)

.include "M328PDEF.inc"     // Include definitions specific to ATMega328P
.dseg
.org    SRAM_START

.cseg
.org 0x0000
	RJMP SETUP
.org 0x0002
	RJMP BOTMAS	   //SUMA (INT0)
.org 0x0004
	RJMP BOTMENOS  //RESTA (INT1)	
	
.org 0x0034
// Configuraci?n de la pila

LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16


// Configuracion MCU

SETUP:

LDI ZH, HIGH(disp7seg << 1)
LDI ZL, LOW(disp7seg << 1)

TIMERSETUP:
    ldi r16, (1 << WGM01) //Configurando a modo CTC (0 a N) 
    out TCCR0A, r16
	ldi r16, 156          //Configurando el "N" para que sean aprox 10ms
    out OCR0A, r16     
	ldi r16, (1 << CS02) | (1 << CS00) //prescaler = 1024
    out TCCR0B, r16

IO:
	//Entradas
		//Botones (pullup) (PD2 y PD3)
	cbi DDRD, DDD2
	sbi PORTD, PORTD2
	cbi DDRD, DDD3
	sbi PORTD, PORTD3

	//Salidas
		//Leds para el contador (inician apagados) (PC0 -- PC3)
	sbi DDRC, DDC0
	cbi PORTC, PORTC0
	sbi DDRC, DDC1
	cbi PORTC, PORTC1
	sbi DDRC, DDC2
	cbi PORTC, PORTC2
	sbi DDRC, DDC3
	cbi PORTC, PORTC3
		// 7 segmentos ( todos inician apagados ) 


INTERRUPCiONES:
    // Configurar INT0 e INT1 para flanco de bajada
    ldi r16, (1<<ISC01)|(1<<ISC11)  
    sts EICRA, r16
    
    // Habilitar INT0 e INT1
    ldi r16, (1<<INT0)|(1<<INT1)
    out EIMSK, r16

REGISTROS:
	clr R16 // Cuenta del timer 0 (y otros (PUSH POP))
	clr R17 // Cuenta de ciclos deltimer 0 para 1s (y otros (PUSH POP))
	clr R18	// Cuenta para los leds
    clr r19 // Flag de INT0 (0=inactivo, 1=esperando)
    clr r20 // Flag de INT1
	clr r21 // copia de la cuenta en r18


SEI //(habilita las interrupciones)


// Loop Infinito

MAIN_LOOP:
	CALL TIMER
	CALL LEDS
	RJMP MAIN_LOOP


// NON-Interrupt subroutines

TIMER:
	in r16, TIFR0
	sbrs r16, OCF0A		// sin la cuenta alcanzo 156 (100ms) salta
	RET					// en loop hasta que haga un ciclo
	sbi TIFR0, OCF0A	// Reinicia la cuenta de 10s
	inc r17				// Cuenta el ciclo de 10ms
	cpi r17, 100
    brlo MAIN_LOOP		// si no han pasado 1s se queda en loop
	clr r17				// ya paso 1s (se reinicia la cuenta de ciclos)
	RET
	 
LEDS:
	PUSH r17
	//SUMA
    CPI r19, 1
    BRNE VERIFICAR_INT1	 //si no esta activo el "flag" salta
	SBIS PIND, PD2       //skip si esta set
    RJMP VERIFICAR_INT1
	//SUMA (si salto lo anterior)
    INC r18
	CPI r18, 15
    BRLO OVERFLOW
	CLR r18
OVERFLOW:
    clr r19 //quita el flag

    // Esperar clr del bot?n
    ldi r17, 0
ESPERA_LIBERACION_MAS:
    SBIC PIND, PD2       // ?Dejo de presionar?
    RJMP LIBERADO_MAS
    CPI r17, 50          // Delay
    BREQ LIBERADO_MAS
    INC r17
    RJMP ESPERA_LIBERACION_MAS
LIBERADO_MAS:
    PUSH r16 // Rehabilitar INT0
    ldi r16, (1<<INT0)|(1<<INT1)
    out EIMSK, r16
	POP r16


VERIFICAR_INT1: 
	// (RESTA)
    CPI r20, 1
    BRNE ACTUALIZARLEDS	 //si no esta activo el "flag" salta
	SBIS PIND, PD3       //skip si esta set
    RJMP ACTUALIZARLEDS
// UNDERFLOW 
    CPI r18, 0          
    BRNE DECREMENTAR     // Si no es 0, decrementar normal
    LDI r18, 15          
    RJMP RESTA_COMPLETADA
DECREMENTAR:
    DEC r18              
RESTA_COMPLETADA:
    clr r20             //quita el flag de resta

	ldi r17, 0
ESPERA_LIBERACION_MENOS:
    SBIC PIND, PD3       // ?Dejo de presionar?
    RJMP LIBERADO_MENOS
    CPI r17, 50          //Delay
    BREQ LIBERADO_MENOS
    INC r17
    RJMP ESPERA_LIBERACION_MENOS
LIBERADO_MENOS:

	PUSH r16 // Rehabilitar INT1
	ldi r16, (1<<INT0)|(1<<INT1)
    out EIMSK, r16
	POP r16

	POP r17


ACTUALIZARLEDS:
    mov r21, r18          // Copiar contador a r21
    
    // bit0 -> PC0
    sbrc r21, 0
    sbi PORTC, PORTC0
    sbrs r21, 0
    cbi PORTC, PORTC0
    
    // bit1 -> PC1
    sbrc r21, 1			
	sbi PORTC, PORTC1
    sbrs r21, 1
    cbi PORTC, PORTC1
    
    // bit2 -> PC2
    sbrc r21, 2
    sbi PORTC, PORTC2
    sbrs r21, 2
    cbi PORTC, PORTC2
    
    // bit3 -> PC3
    sbrc r21, 3
    sbi PORTC, PORTC3
    sbrs r21, 3
    cbi PORTC, PORTC3

	RET



//Interrupt subroutines
BOTMAS:
	//Guarda la cuenta del timer 0 y el sreg
    PUSH r16
    IN r16, SREG
    PUSH r16
    
    ldi r19, 1           // Flag INT0 (Hay que sumar)
    
    // Deshabilitar INT0 temporalmente (hasta que suma)
    ldi r16, (1<<INT1)   
    out EIMSK, r16
    
	//Saco la cuenta del timer0 y el sreg
    POP r16
    OUT SREG, r16
    POP r16
    RETI

BOTMENOS: //lo mismo que BOTMAS pero la flag de resta esta en r20
	PUSH r16
    IN r16, SREG
    PUSH r16
   
    ldi r20, 1           
    
    ldi r16, (1<<INT0)  
    out EIMSK, r16
    
    POP r16
    OUT SREG, r16
    POP r16
    RETI



disp7seg:
	//para mi los bits son XGFEDCBA (X nada) las letras son las pos en el display			
.db 0b00111111 //0
.db 0b00000110 //1
.db 0b01011011 //2
.db 0b01001111 //3
.db 0b01100110 //4
.db 0b01101101 //5
.db 0b01111101 //6
.db 0b00000111 //7
.db 0b01111111 //8
.db 0b01100111 //9
.db 0b01110111 //A
.db 0b01111100 //b
.db 0b00111001 //C
.db 0b01011110 //d
.db 0b01111001 //E
.db 0b01110001 //F
