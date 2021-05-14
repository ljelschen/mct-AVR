; Titel: Assmebler Labor 2 Aufgabe 3
; Laborgruppe: A9
; 
; Lars Jelschen, Matrikelnummer: 5100174
; Marvin Klusmeyer, Matrikelnummer: 5093298
;
; Anprechpartner: ljelschen@hs-bremen.de
;
; Programmiert am: Mo 03. Mai 20201


.include "m328pdef.inc"

;define outputs
#define PWM_PIN 1 ; bit PB1

.org 0x0000 ; save the Programm at flash address 0
	jmp setup

.org 0x0016
	jmp PosA

.org 0x0018
	jmp PosB

setup:
;---------------- Stack Init.
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; ouput direction for PROTB / PROTD
	ldi r16, 1<<PWM_PIN 
	out DDRB, r16


	; ist für die on Zeit (281) 
	ldi r16, 0b00000001  ;setze die oberen 8 bit
	ldi r17, 0b00011001 ;setze die unteren 8 bit
	sts OCR1AH, r16 
	sts OCR1AL, r17


	; ist für die on Zeit (31) 
	ldi r16, 0b00000000  ;setze die oberen 8 bit
	ldi r17, 0b00011111 ;setze die unteren 8 bit
	sts OCR1BH, r16 
	sts OCR1BL, r17

	; set output for the timer and fast PWM
	ldi r16, 1<<COM1A0 | 1<<WGM11 | 1<<WGM10
 	sts TCCR1A, r16 ; save the parameters to the timer reg.

	ldi r16, 1<<WGM12 | 1<<WGM13 | 1<<CS12 | 1<<CS10   ; set the timer to 8 clock ticks to inc.
	sts TCCR1B, r16 ; save the parameters to the timer reg.

	; 16.000.000 Takte/s * 0.02 s = 320.000 Takte entsprechen 20ms
	; 320.000 Takte  / 1024 Clock = 312.5  mal zählen 
	; 312 in Binär  = 1 0011 1000
	; 
	;ansteuerung:
	; von 31 = 0001 1111 0x31 entspricht 0% servo
	; bis 62 = 0011 1110 0x62  entspricht 180% servo
	; 

	;pause:
	; 250  = 1111 1010 0xFA
	; 281 = 0001 0001 1001  H:0x01  L:0x19
	;
	;	 31 - 62 Takte						  PosA	   PosB
	;			|									|		|
	;			v									v 		v
	;		---------								---------
	;		|		|		 250 - 281   	Takte   |		|
	;		|		|			|					|		|
	;		|		|			v					|		|
	;-------|		|-------------------------------|		|--------------
	;
	;				^								^
	;				|								|
	;	  	      OCR1A							  OCR1B
	;
	;


	;Interrupt Mask setzten 
	ldi r16, 1<<OCIE1A | 1<<OCIE1B
	sts TIMSK1, r16
	sei ; interrups enable
;main loop 
main:
	rjmp main


PosA:

	ldi r16, 0  
	sts TCNT1H, r16 
	sts TCNT1L, r16

	sei
	ret
	;Pin ON


PosB:
	;Pin OFF
	sei
	ret
	rjmp main
