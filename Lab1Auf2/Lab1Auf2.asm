; Titel: Assmebler Labor 1 Aufgabe 2
; Laborgruppe: A9
; 
; Lars Jelschen, Matrikelnummer: 5100174
; Marvin Klusmeyer, Matrikelnummer: 5093298
;
; Anprechpartner: ljelschen@hs-bremen.de
;
; Programmiert am: Fr 23. Apr 20201

#include "m328pdef.inc"

;input variables
#define LED1 0
#define LED2 1
#define LED3 2

;output variables
#define BTN1 3
#define BTN2 4

;register variables
#define temp R16
#define ledReg R17

.org 0x00
	jmp setup

.org 0x32						;start the programm at bit 0

setup:
;---------------- Stack Initialisirung
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
  
  ldi temp, 0b00000111 				;set the first 3 bit's to 1 (as Output)
  out DDRB, temp 					;set direction of the Inputs / Outputs from temp reg.


  clr temp
  out PORTB, temp 					;set all Outputs to null

main:
  clr ledReg 						;clear the ledReg reg.

  ;check for BTN1 is pressed 
  ldi temp, 0b00000001 				;set temp reg. to 1
  sbic PINB, BTN1 					;check for bit 3 in PINB is off
  add ledReg, temp 					; if bit 3 is on add 1 to ledReg.
 
 ;check for BTN2 is pressed
  ldi temp, 0b00000010 				;set temp reg. to 2
  sbic PINB, BTN2 					;check for bit 4 in PINB is off
  add ledReg, temp 					;if bit 4 is on add 1 to ledReg.
 
  ;check for BTN1 + BTN2 is pressed
  ldi temp, 0b00000011 				;set the temp reg. to 3
  cp temp, ledReg 					;compare if both btn are pressed
  breq setLED3 						;jmp to setLED if both btn are pressed
 
 setOutputs:
 ; set the Outputs
  ldi temp, 0b00011000				;set the temp reg. with bit 4 + 5 
  add ledReg, temp					;add the temp reg. to the ledReg. to hold the Pull-up Pins
  out PORTB, ledReg  				;set all Outputs to ledReg
  rjmp main 						;jump to main:


setLED3:
  ldi temp, 0b00000100 				;set the 3th bit from the temp reg.
  rjmp setOutputs 					;jump to main:
