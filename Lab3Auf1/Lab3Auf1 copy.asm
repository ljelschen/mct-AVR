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
#define PWM_PIN 9 ; bit PD6

.org 0x0000 ; save the Programm at flash address 0
	jmp setup

.org 0x0014
	ret

setup:
;---------------- Stack Init.
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; ouput direction for PROTB / PROTD
	;ldi r16, 1<<PWM_PIN 
	;out DDRB, r16


	; set output for the timer and fast PWM
	ldi r16, 1<<COM1A0 | 1<<WGM11 | 1<<WGM10
 	sts TCCR1A, r16 ; save the parameters to the timer reg.

	ldi r16, 1<<WGM12 | 1<<WGM13 | 1<<CS11  ; set the timer to 8 clock ticks to inc.
	sts TCCR1B, r16 ; save the parameters to the timer reg.

	; 16.000.000 Takte/s * 0.02 s = 320.000 Takte entsprechen 20ms
	; 320.000 Takte  / 8 Clock = 40.000 x zählen wenn der Zähler auf 8 steht
	; 40.000 in Binär  = 1001 1100 0100 0000
	; 2000 bis 4000 ist steuerbereicht und der rest ist pause (38.000 - 36.000)
	;
	;	 2000 - 4000 Takte						  PosA	   PosB
	;			|									|		|
	;			v									v 		v
	;		---------								---------
	;		|		|		38.000 - 36.000	Takte   |		|
	;		|		|			|					|		|
	;		|		|			v					|		|
	;-------|		|-------------------------------|		|--------------
	;
	;				^								^
	;				|								|
	;	  	      OCR1A							  OCR1B
	;
	;
	;zahlen:
	;	111 1101 0000 = 2000 = 1ms <-- min
	;  1111 1010 0000 = 4000 = 2ms <--- max


	;Interrupt Mask setzten 
	ldi r16, 1<<ICIE1
	sts TIMSK1, r16
	sei ; interrups enable

	rcall PosA
;main loop 
main:
	sbic TIFR1, ICF1
	rjmp PosB

	rjmp main


PosA:
	
	; ist für die on Zeit (variable)
	ldi r16, 0x07 ;setze die oberen 8 bit
	ldi r17, 0xD0 ;setze die unteren 8 bit
	sts ICR1H, r16 
	sts ICR1L, r17

	ret
	;Pin ON


PosB:
	;Pin OFF


	;ende des Pulses bei (40.000 Zähleinheiten)
	ldi r16, 0x9C  ;setze die oberen 8 bit
	ldi r17, 0x80;setze die unteren 8 bit
	sts ICR1H, r16 
	sts ICR1L, r17
	rjmp main


