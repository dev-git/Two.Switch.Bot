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
;    Filename:	    MOTORON_628_1_2.asm                                 *
;    Date:          05/07/2010                                        *
;    File Version:  0.1.2                                               *
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


;***** VARIABLE DEFINITIONS
w_temp        EQU     0x70        ; variable used for context saving 
status_temp   EQU     0x71        ; variable used for context saving

	cblock 	0x20 			;start of general purpose registers
		count			;used in table read routine
		count1 			;used in delay routine
	endc

MOTORPORT	Equ	PORTB			;set constant MOTORPORT = 'PORTB'
MOTORTRIS   Equ TRISB
SWPORT		Equ	PORTA			;set constant SWPORT = 'PORTA'
SWTRIS		Equ	TRISA			;set constant for TRIS register
BACKSW  	Equ	1			;set constants for the switches
FRONTSW		Equ	0
MOTOR1		Equ	1				; and the motor
MOTOR0		Equ	0

;SWDel	Set	Delay			;set the de-bounce delay (has to use 'Set' and not 'Equ')

;**********************************************************************
	ORG     0x000             ; processor reset vector

	movlw	0x07
	movwf	CMCON					;turn comparators off (make it like a 16F84)

	goto    main              		; go to beginning of program

;  Mainline of MOTORON
main

  	PAGE
  	nop					  			;  "nop" is Required for Emulators
  
  	bsf    	STATUS, RP0            	;  Goto Bank 1 to set Port Direction
  	movlw 	b'11000000'				; set PortB all outputs
  	movwf 	MOTORTRIS
  	movlw 	b'00001111'				;set PortA all inputs
	movwf	SWTRIS
  	bcf    	STATUS, RP0            ;  Go back to Bank 0
  	clrf 	MOTORPORT
  	clrf	SWPORT

Loop
  	; if frontswitch 
  	; go backwards
  	; else go forwards
  	
	btfsc	SWPORT,	FRONTSW
		call	Reverse
	btfsc	SWPORT,	BACKSW
		call	Forward
	movlw b'00000001'		;Code for Forward.
	movwf MOTORPORT		;Both motors forward.
	movlw 0Ah
  	goto   	Loop
 
 ALLSTOP:  	
	;clrf   MOTORPORT
 	;call	Delay
	retlw	0x00
 
 Forward:  
	call 	ALLSTOP
	bsf		MOTORPORT,	MOTOR0 		;turn MOTOR0 on
	retlw	0x00
	
 Reverse:
 	call 	ALLSTOP
	bsf		MOTORPORT,	MOTOR1 		;turn MOTOR1 on
	retlw	0x00
 
Delay	movlw	d'250'				;delay 250 ms (4 MHz clock)
	movwf	count1
 
	end		;End of source code.