; Titel: Assmebler Labor 2 Aufgabe 2
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
#define LED1 0

.org 0x00
	jmp setup

.org 0x32						;start the programm at bit 0


setup:
;---------------- Stack Initialisirung
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	
	; ouput direction for PROTB / PROTD
	ldi r16, 0xff
	out DDRD, r16

	ldi r16, 0xff 
	out DDRB, r16

	; set output for the timer and fast PWM
	ldi r16, 1<<COM0A1 | 1<<WGM00 | 1<<WGM01
 	out TCCR0A, r16

	ldi r16, 1<<CS00 | 1<<CS02 ; set the timer to 1024 clock ticks to inc.
	;ldi r16, 1<<CS00 
	out TCCR0B, r16

;	ldi r16, 0x00 ;Helligkeit einstellen
;	out OCR0A, r16


main:
	sbic TIFR0, 0 ; skip if not Timer0 Flag
	rjmp clrTimer ; if timer0 Flag is on jmp to clrTimer

auswertung:

	; Timer0 braucht 262150 Clock-Takte bis die Flag erreicht ist
	; um auf eine Sekunde zu kommen: 
	;
	; 16.000.000 / 262150 = 61
	; 
	ldi r16, 61 ; load dec. 16 in r16
	cp r25, r16 ; if r25 == r16
	breq LED_Toggle ; then jump to LED_Toogle

	rjmp main

;---------------- unter Funktonen -----------------

clrTimer:
	inc r25	; increase Register r25 
	sbi TIFR0, 0 ; reset Timer Overflow Flag
	rjmp auswertung ; jmp back


LED_Toggle:
	
	sbis PORTB, LED1 ; check if the LED is off and set the LED1 on
	rjmp LED_ON

	sbic PORTB, LED1 ; check if the LED is on and set the LED1 off
	rjmp LED_OFF


LED_ON:
	sbi PORTB, LED1 ; set the LED Bit to 1
	clr r25	; clear the register 
	rjmp main ; jmp back to main

LED_OFF:
	cbi PORTB, LED1 ; set the LED Bit to 0
	clr r25	; clear the register 
	rjmp main ; jmp back to main

