;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PICmicro PIC16F628. This file contains the basic code      *
;   building blocks to build upon.                                    *  
;                                                                     *
;   If interrupts are not used all code presented between the ORG     *
;   0x004 directive and the label main can be removed. In addition    *
;   the variable assignments for 'w_temp' and 'status_temp' can       *
;   be removed.                                                       *                         
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PICmicro data sheet for additional        *
;   information on the instruction set.                               *
;                                                                     *
;   Template file assembled with MPLAB V4.00.00 and MPASM V2.20.12    *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    MOTORON_628_1_3.asm                                 *
;    Date:          29/10/2010                                        *
;    File Version:  0.1.3                                               *
;                                                                     *
;    Author:        Paul Bates                                        *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files required:                                                  *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:  "MOTORON - Turns a motor on after a switch is press"     *
;                                                                     *
;  	The Program simply sets up Bit 0 of Port "A" to Output and then   *
;   Sets it Low when RA0 is pulled low.								  *
;																	  *
;  Hardware Notes:													  *
;   _MCLR is tied through a 4.7K Resistor to Vcc and PWRT is Enabled  *
;   A SN754410NE quad half-h driver is attached to PORTB.0 and Vcc    *
;   A 10K pull up is connected to RA0 and it's state is passed to     *
;                                                                     *
;   This is the working version!                                      *
;																	  *
;	Now with SVN support!											  *
;**********************************************************************

	list      p=16f628a            ; list directive to define processor
	#include <p16f628a.inc>        ; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_ON & _BODEN_ON & _PWRTE_ON & _INTRC_OSC_CLKOUT & _MCLRE_ON & _LVP_ON

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

;==========================================================================
;
;	Variables
;    http://www.elsevierdirect.com/companions/9780750665568/pictures/Quester/Quest04.asm   
;==========================================================================

TIMER1          EQU     H'0C' 		;Timer 1, used for general delay.		
TIMER2          EQU     H'0D'   	;Timer 2, used for delay !

	cblock 	0x20 			;start of general purpose registers
		count			;used in table read routine
		count1 			;used in delay routine
		;state
	endc

;==========================================================================
;	PORTA & PORTB  Bits.  
;==========================================================================
;INPUTS
SW1		EQU     H'00'		;SW1 is triggering RA0
SW2		EQU     H'01'		;SW2 is triggering RA1
;SW3		EQU     H'02'		;SW2 is triggering RA1

;OUTPUTS
LD1		EQU		H'00'		;LD1 is connected to RB0
LD2		EQU		H'01'		;LD2 is connected to RB1
;LD3		EQU		H'02'		;LD2 is connected to RB1
;LD4		EQU		H'03'		;LD2 is connected to RB1

;STATE	EQU		b'00000001'

page
ORG	0						;Reset vector address for PIC16F84
nop

movlw	0x07
movwf	CMCON				;turn comparators off (make it like a 16F84)

goto	RESET				;Jump to RESET routine when boot PIC.

	
;		**************************
;      	*     main routine:      *
;      	**************************

RESET:		
		
	BSF		STATUS,RP0		;Switch to program memory bank 1 of PIC
	MOVLW	B'00001111'		;All available PORTA I/O are set as inputs.
	MOVWF	TRISA			;Config here PORTA	
	MOVLW	B'11000000'		;RB0...RB5 are outputs, RB6&7 are set as input.
	MOVWF	TRISB			;                       RB6&7 are used by K8048 for programming PIC.
	BCF		STATUS,RP0		;Switch back to program memory bank 0 of PIC.
	CLRF	PORTB			;Clear all PORTB outputs before start mainloop.
	clrf 	PORTA

; Program starts here
LOOP:
	;movlw 	010h
	;bcf		PORTB, LD2
	;bsf 	PORTB, LD1
	;call 	DELAY
	btfsc	PORTA,	SW1
		call	REVERSE
		;movlw	b'00000001'
	btfsc	PORTA,	SW2
		call	FORWARD
		;movlw	b'00000010'
	
	goto LOOP
		;

FORWARD:
	;bcf 	PORTB, LD2		; Forward.
	;call 	DELAY
	clrf	PORTB
	bsf 	PORTB, LD1
	btfsc	PORTA, SW1		;Test if SW1 is pressed ? Bit Test f, Skip if Clear
		call 	REVERSE
	goto 	$ - 2

	nop

;DELAY:	
;		MOVLW   D'50'       ;Put 50 decimal in the 'TIMER1' register.
;        MOVWF   TIMER1 

; Subroutines start here
REVERSE:
	;bcf 	PORTB, LD1		; Reverse.
	;call 	DELAY
	clrf	PORTB
	bsf 	PORTB, LD2
	btfsc 	PORTA, SW2		;Test if SW1 is pressed ? Bit Test f, Skip if Clear
		goto FORWARD
	goto 	$ - 2
	return
	
Delay2:		
	MOVLW	D'50'		 ;Put 50 decimal in the 'TIMER2' register.
	MOVWF	TIMER2
	DECFSZ  TIMER2,F     ;Timer2 = Timer2 -1, skip next instruction if Timer2 = 0.
    GOTO    $-1          ;Jump back 1 instruction.
                
	DECFSZ	TIMER1,F	;Timer1 = Timer1 - 1, skip next instruction if Timer1 = 0
	GOTO	Delay2		;Jump to 'DELAY2' routine	
	return

END                     ;End of source code.