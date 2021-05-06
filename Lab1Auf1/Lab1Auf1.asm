; Titel: Assmebler Labor 1 Aufgabe 1
; Laborgruppe: A9
; 
; Lars Jelschen, Matrikelnummer: 5100174
; Marvin Klusmeyer, Matrikelnummer: 5093298
;
; Anprechpartner: ljelschen@hs-bremen.de
;
; Programmiert am: Fr 23. Apr 20201


.include "m328pdef.inc"

;define outputs
#define LED1 0
#define LED2 1
#define LED3 2

;define temp reg
#define temp = R16

.org 0x00
	jmp setup

setup:
;---------------- Stack Initialisirung
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	
	ldi temp, 0b00000111 	; set the temp reg with 3 bits
	out DDRB, temp			; set the direction of the outputs

main:
	sbi PORTB, LED1 			; set LED 1 on
	sbi PORTB, LED2 			; set LED 2 on
	sbi PORTB, LED3 			; set LED 3 on

stop:
	nop 					; loop no operation to prevent flickering of the leds
	rjmp stop
	



