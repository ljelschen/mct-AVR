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

.org 0x00
	jmp setup

.org 0x32						;start the programm at bit 0

#define acc0 r16

setup:
;---------------- Stack Initialisirung
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

; overflow interrupt enable
	ldi acc0, $02
	out TIMSK, acc0

	ldi acc0, $82
	out TCCR1A, acc0
	ldi acc0, $1c
	out TCCR1B, acc0
	
	ldi acc0, CNTTOP
	out ICR1H, r0
	out ICR1L, acc0
	
	ldi acc0, $14
	out OCR1AH, r0 
	out OCR1AL, acc0

	out TCNT1H, r0
	out TCNT1L, r0

	ldi stavec, $00
	clr acc0
	sts TICKS_100ms, acc0
	sts TICKS_1s, acc0
	ldi button, $11

	sei

	main: 
		sbrc button, 0
		rjmp not_pressed

		sbrs stavec, 0
		rjmp main

		clr stavec
		in acc0, OCR1AL
		cpi acc0, CNTTOP
		breq main
		inc acc0

	wr_ocr1a:
		out OCR1AH, r0
		out OCR1AL, acc0
		rjmp main

	not_pressed:
		sbrc button, 4
		rjmp main

		sbrs stavec, 0
		rjmp main
		
		clr stavec
		in acc0, OCR1AL
		cpi acc, $00
		breq main
		dec acc0
		rjmp wr_ocr1a

