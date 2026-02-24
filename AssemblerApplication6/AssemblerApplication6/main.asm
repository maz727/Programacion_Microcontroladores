//
// NombreProgra.asm
//
// Creado: 01/02/2026
// Autor : Sebastian Da Silva 
// Descripci?n: Sum

// Encabezado (Definici?n de Registros, Variables y Constantes)

.include "M328PDEF.inc"     // Include definitions specific to ATMega328P
.dseg
.org    SRAM_START

//variable_name:     .byte   1   
//Memory alocation for variable_name:     .byte   (byte size)

.cseg
.org 0x0000

// Configuraci?n de la pila

LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16

// Configuracion MCU

SETUP:
    // 2 botones con pullup 
    CBI DDRD, DDD2     // PD2 = Incremento
    SBI PORTD, PORTD2
    CBI DDRD, DDD3     // PD3 = Decremento
    SBI PORTD, PORTD3

	// Salidas para contador 4 bits
    SBI DDRB, DDB0     ; PB0 = menos significativo
    SBI DDRB, DDB1     ; PB1
    SBI DDRB, DDB2     ; PB2
    SBI DDRB, DDB3     ; PB3
	// Inicia en 0
	CBI PORTB, PORTB0
    CBI PORTB, PORTB1
    CBI PORTB, PORTB2
    CBI PORTB, PORTB3

	CLR R16            // Contador 
    CLR R17            // Estado anterior bot?n INC
    CLR R18            // Estado anterior bot?n DEC

// Loop Infinito

MAIN_LOOP:

    CALL PRESS_SUMA
    CALL PRESS_RESTA
    CALL DELAY
    RJMP MAIN_LOOP

// NON-Interrupt subroutines

PRESS_SUMA:

    SBIC PIND, PIND2        //Salta si PD2=0 (presionado)
    RJMP LIMPIAR17
    // si esta presionado salta hasta aqui
    SBRC R17, 0             //si PD2 ya se habia presionado  RET y si no salta RET
    RET                     
    SBR R17, (1<<0)         // Guarda en R17 que ya se presiono SUMA   (1)
    // Antirebote
    CALL DELAY
    // Si sigue presionado salta, si no salta a Guardar en R17 que no se presiono (0)
    SBIC PIND, PIND2        
    RJMP LIMPIAR17    
    // INCREMENTAR CONTADOR
    INC R16
	//Evitar overflow
    CPI R16, 16
    BRLO SUMA         // Si < 16, Salta el CLR
    CLR R16           // Si = 16, es overflow y reinicia la cuenta

SUMA:
    CALL ACTUALIZAR
    RET
    
LIMPIAR17:
    CBR R17, (1<<0)         //No se presiona
    RET

PRESS_RESTA:   //Igual que PRESS_SUMA pero con resta
	//Checkea el presente
    SBIC PIND, PIND3        
    RJMP LIMPIAR18
	// Checkea el pasado
    SBRC R18, 0             
    RET
    SBR R18, (1<<0)
	//Antirebote
    CALL DELAY
    //Sigue presionado?
    SBIC PIND, PIND3        
    RJMP LIMPIAR18
    // RESTA
    DEC R16
    CPI R16, 255            //underflow?
    BRNE RESTA         // Si no es 255, salta
    LDI R16, 15             // Si es 255, poner 15
    
RESTA:
    CALL ACTUALIZAR
    RET
    
LIMPIAR18:
    CBR R18, (1<<0)
    RET

ACTUALIZAR:
   
    MOV R20, R16            // Copiar contador
    
    // Para cada BIT de PB0 a PB3
	// Comparar el bit de la cuenta R20 al bit correspondiente
	// Dependiendo de el resultado apaga o "enciende" el led para representar la cuenta 
   
    BST R20, 0
    BRTS SET_PB0
    CBI PORTB, PORTB0
    RJMP CHECK_PB1
SET_PB0:
    SBI PORTB, PORTB0
    
CHECK_PB1:
    BST R20, 1
    BRTS SET_PB1
    CBI PORTB, PORTB1
    RJMP CHECK_PB2
SET_PB1:
    SBI PORTB, PORTB1
    
CHECK_PB2:
    BST R20, 2
    BRTS SET_PB2
    CBI PORTB, PORTB2
    RJMP CHECK_PB3
SET_PB2:
    SBI PORTB, PORTB2
    
CHECK_PB3:
    BST R20, 3
    BRTS SET_PB3
    CBI PORTB, PORTB3
    RET
SET_PB3:
    SBI PORTB, PORTB3
    RET

	//Espera
DELAY:
    LDI R21, 160
DELAYA:
    LDI R22, 133
DELAYB:
    DEC R22
    BRNE DELAYB
    DEC R21
    BRNE DELAYA
    RET

// Interrupt routines