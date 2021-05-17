; Titel: Assmebler Labor 3 Aufgabe 2
; Laborgruppe: A9
; 
; Lars Jelschen, Matrikelnummer: 5100174
; Marvin Klusmeyer, Matrikelnummer: 5093298
;
; Anprechpartner: ljelschen@hs-bremen.de
;
; Programmiert am: Sa 15. Mai 20201


#define BetriebLED 0
#define LuefterLED 1
#define Button 2

#define StatusMaschine 0
#define StatusLuefter 1

.include "m328pdef.inc"

.org 0x0000 ; save the Programm at flash address 0
	jmp setup

.org 0x0002
    jmp MaschieneToggle

.org 0x0004
	jmp MaschieneToggle

.org 0x0020
	jmp Timer0Interrupt	


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
    ldi r16, 1<<BetriebLED | 1<<LuefterLED | 0<<Button
	out DDRB, r16

	ldi r16, 0<<BetriebLED | 0<<LuefterLED | 1<<Button
	out PORTB, r16

	;--------------------------------------------------
	;  			Timer 0 init (Laufliucht)
	;--------------------------------------------------
	
	ldi r16, 1<<COM0A1 | 1<<WGM00 | 1<<WGM01 ; setzt den Timer0 auf fast PWM 
 	out TCCR0A, r16  ;speichert die einstellung in den Timer0

	ldi r16, 1<<CS00 | 1<<CS02 ; setzt die timer0 Clock auf 1024
	out TCCR0B, r16  ;speichert die einstellung in den Timer0

	ldi r16, 1<<TOIE0 ; Timer0 Overflow Interrupt einschalten
	sts TIMSK0, r16 ; Interrupts im Timer0 Mask-Register speichern


	
	;--------------------------------------------------
	;  			Timer 2 init (Ein-und Audgangsverzögerung)
	;--------------------------------------------------

    rcall LauflichtAus
	sei ;global Interrupts anschalten
	

	ldi r20, 0<<StatusMaschine | 0<<StatusLuefter; -> Status Register (nicht Überschreiben)
	; Bit0: Betrieb
	; Bit1: Lüfter / Einschaltsperre

main:
    sbic PINB, Button
    rjmp ButtonEntprellen
rjmp main



Timer0Interrupt:
	sei ;global Interrupts anschalten

	ldi r16, 1<<0 ; lade den Maschinen status in Reg. 16
	cp r20, r16 ; if status == 1:
	breq LauflichtEin

	ret ;return (führt das Programm weiter aus)

;--------------------------------------------------
;  		Unter Funktionen
;--------------------------------------------------


ButtonEntprellen:
    sbis PINB, Button
    rjmp MaschieneToggle

    rjmp ButtonEntprellen

;Maschine
MaschieneToggle:
    ldi r16, 0<<StatusMaschine
    
    cp r20, r16 ; if Status == off
    breq MaschineAn ; yes
    brne MaschineAus ; no

MaschineAn:
    ldi r20, 1<<StatusMaschine

	ldi r16, 1<<BetriebLED
    out PORTB, r16

    rjmp main

MaschineAus:
    ldi r20, 0<<StatusMaschine

	ldi r16, 0<<BetriebLED
    out PORTB, r16

    rjmp main






;----------- Lauflicht
LauflichtAus:
	ldi r16, 0x00
	out PORTD, r16
	ret

LauflichtEin:
	in r16, PORTD ;lade PortB in Register 16
	ldi r17, 0

	cp r16, r17 ;if Lauflicht != Aus
	brne LauflichtWeiter ;  springe wenn Lauflicht ein Zu Lauflicht weiter
	; else
	ldi r16, 1<<0
	out PORTD, r16 ;ersten Bit im Lauflicht auf 1 setzten
	ret

LauflichtWeiter:
	rol r16 ; rotiert die Bits nach links weiter
	out PORTD, r16 
	ret
