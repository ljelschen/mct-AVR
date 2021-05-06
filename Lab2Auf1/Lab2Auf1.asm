; Titel: Assmebler Labor 2 Aufgabe 1
; Laborgruppe: A9
; 
; Lars Jelschen, Matrikelnummer: 5100174
; Marvin Klusmeyer, Matrikelnummer: 5093298
;
; Anprechpartner: ljelschen@hs-bremen.de
;
; Programmiert am: So 02. Mai 20201


.include "m328pdef.inc"

;define outputs
#define TIMER_PIN 6 ; bit PD6

.org 0x00 ; save the Programm at flash address 0
	jmp setup

setup:
;---------------- Stack Init. 🤢
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	
	; ouput direction 
	ldi r16, 1<<TIMER_PIN ; set the PWM Signal Pin as Output
	out DDRD, r16

	; set output for the timer and fast PWM
	ldi r16, 1<<COM0A1 | 1<<WGM00 | 1<<WGM01
 	out TCCR0A, r16

	ldi r16, CS01 
	out TCCR0B, r16

	ldi r16, 1 ;Helligkeit einstellen
	out OCR0A, r16
	
main:
rjmp main


