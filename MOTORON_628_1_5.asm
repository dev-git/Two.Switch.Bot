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
;    Filename:	    MOTORON_628_1_5.asm                               *
;    Date:          19/07/2011                                        *
;    File Version:  0.1.5                                             *
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

	list P = 16F628a	;microcontroller identity
	#include <p16f628a.inc>        ; processor specific variable definitions
	
	;__CONFIG _CP_OFF & _WDT_ON & _BODEN_ON & _PWRTE_ON & _INTRC_OSC_CLKOUT & _MCLRE_ON & _LVP_ON
	   		; e.g: 0x033 = hex value

	__Config 3F18h
	
;****************************************************************
;Equates
;****************************************************************
status	equ	0x03
cmcon	equ	0x1F
rp1	equ	0x06	;this is bit 6 in file 03
rp0	equ	0x05	;this is bit 5 in file 03
portA	equ	0x05	;file 5 is Port A
portB	equ	0x06	;file 6 is Port B
flags	equ	0x30	;flag file
decrA	equ	0x20	;file to decrement
decrB	equ	0x21	;file to decrement 

;INPUTS
sw1		EQU     H'00'		;SW1 is triggering RA0
sw2		EQU     H'01'		;SW2 is triggering RA1

;OUTPUTS
mt1		EQU		H'00'		;LD1 is connected to RB0
mt2		EQU		H'01'		;LD2 is connected to RB1

;****************************************************************
;Beginning of program
;****************************************************************
reset:	org	0x00	;reset vector address	
	goto	SetUp	;goto set-up
	nop
	nop
	nop
	org	4	;interrupts go to this location 
	goto	isr1	;goto to Interrupt Routine  - not used
			;isr1 must be written at address 004
			;   otherwise bcf status,rp1 will be 
			;   placed at address 01 by assembler!	

;****************************************************************
;* Port A and B initialisation			*
;****************************************************************

SetUp	
	bcf	status,rp1		;select bank 1 (must be = 0)
	bsf	status,rp0                 ; also to select bank 1  
	
	movlw	B'00001111'		;make all Port A inputs
	movwf	portA			
	movlw	B'11000000'		; out out in in in in in in 
	movwf	portB		;    

	bcf	status,rp0		;select programming area - bank0
	clrf 	portA
	clrf	portB

	movlw	0x07		;turn comparators off and enable
	movwf	cmcon		;    pins for I/O functions
	goto 	Main

;****************************************************************
;* Interrupt Service Routine will go here (not used)	*
;****************************************************************
isr1

;****************************************************************
;Delay sub-routine - approx 130mS
;****************************************************************
delay	movlw	0x80	;load 80h into w
	movwf	decrA	;shift 80h into the file for decrementing
delx	nop
	decfsz	decrB,1	;decrement the file
	goto	delx
	decfsz	decrA,1	;decrement the file
	goto	delx
	retlw	0x00	;return

;****************************************************************
;* Main 					*
;****************************************************************

Main	
	clrf	flags
MainA	
	call	delay	;1/10 second delay
	; For debugging use 'btfsc' and for deploying use 'btfss' as there is a problem with the switches on the board.
	btfsc	portA,0		;front button pressed, go into reverse
		goto	Motor1_Forward	;Yes
	btfsc	portA,1		;back button pressed, go forward
		goto	Motor1_Reverse	;Yes
	clrf	flags	;clear flag file
	goto	MainA	;No. Loop again

Motor1_Reverse	
	btfsc	flags,0	;test red flag 
		goto	MainA	;return if flag is SET	
	clrf	portB	; All Stop
	;call 	delay
	movlw	B'00000001'		;set the bit for the red LED
	xorwf	portB,1	;put answer into file 06 to toggle LED
	bsf		flags,0	;set the red flag
	goto	MainA
	
Motor1_Forward	
	btfsc	flags,1	;test green flag 
		goto	MainA	;return if flag is SET	
	clrf	portB	; All Stop
	;call 	delay
	movlw	B'00000010'	;set the bit for the green LED
	xorwf	portB,1	;put answer into file 06 to toggle LED
	bsf		flags,1	;set the green flag
	goto	MainA

END