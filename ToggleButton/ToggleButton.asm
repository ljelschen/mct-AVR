; Titel: Assmebler Labor 3 Aufgabe 2
; Laborgruppe: A9
; 
; Lars Jelschen, Matrikelnummer: 5100174
; Marvin Klusmeyer, Matrikelnummer: 5093298
;
; Anprechpartner: ljelschen@hs-bremen.de
;
; Programmiert am: Sa 15. Mai 20201

#define Button 2
#define BetriebLED 0

.include "m328pdef.inc"


setup:
;---------------- Stack Init.
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)

	;--------------------------------------------------
	;  			Port init
	;--------------------------------------------------


	;-----------------Lauflicht
	ldi r16, 0xFF
	out DDRD, r16	

	ldi r16, 0x00
	out PORTD, r16

	;----------------Status LED (Lüfter, Betrieb) / Button EIN/AUS
    ldi r16, 0<<Button
	out DDRB, r16

	ldi r16, 1<<Button
	out PORTB, r16



main:
    sbic PINB, Button
    rjmp ButtonEntprellen

    rjmp main


ButtonEntprellen:
    sbis PINB, Button
    rjmp Toggle

    rjmp ButtonEntprellen


Toggle:
    ldi r16, 0
    cp r17, r16 ; if r17 == 0
    breq ToggleOn  ; true
    brne ToggleOff ; false

ToggleOn:
    ldi r17, 1
    sbi PORTB, BetriebLED

    rjmp main

ToggleOff:
    ldi r17, 0
    cbi PORTB, BetriebLED

    rjmp main


