; Titel: Assmebler Labor 2 Aufgabe 2
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
#define LED1 5 ; bit PB5 
#define TIMER_PIN 6 ; bit PD6

.org 0x00 ; save the Programm at flash address 0
	jmp setup

setup:
;---------------- Stack Init. 
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	
	; ouput direction for PROTB / PROTD
	ldi r16, 1<<TIMER_PIN
	out DDRD, r16

	; set the internal LED to a Output
	ldi r16, 1<<LED1
	out DDRB, r16

	; set output for the timer and fast PWM
	ldi r16, 1<<COM0A1 | 1<<WGM00 | 1<<WGM01
 	out TCCR0A, r16 ;save the parameters to the timer reg.

	ldi r16, 1<<CS00 | 1<<CS02 ; set the timer to 1024 clock ticks to inc.
	out TCCR0B, r16 ; save the parameters to the timer reg.

main:
	sbic TIFR0, 0 ; skip if not Timer0 Flag
	rjmp clrTimer ; if timer0 Flag is on jmp to clrTimer

auswertung:

	; Timer0 takes 256 times to overflow
	; Timer0 add's +1 after 1024 clock 
	;
	; 256 * 1024 = 262144(cycls/timeroverflows)
	;
	; 16.000.000 (cycles/second)/ 262144(cycls) = 61(timeroverflows) (without remainder)
	; 
	ldi r16, 61 ; load dec. 16 in r16
	cp r25, r16 ; if r25 == r16
	breq LED_Toggle ; then jump to LED_Toogle

	rjmp main

;---------------- sub Functions -----------------

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
