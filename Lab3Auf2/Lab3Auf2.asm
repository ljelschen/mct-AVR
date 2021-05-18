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
#define BetriebLED 3


.include "m328pdef.inc"

.org 0x0000 ; save the Programm at flash address 0
	jmp setup

.org 0x20
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

	ldi r16, 0<<Button | 1<<BetriebLED
	out DDRB, r16

	ldi r16, 1<<Button | 0<<BetriebLED
	out PORTB, r16

	;--------------------------------------------------
	;  			Timer 0 init (Laufliucht)
	;--------------------------------------------------
	
	ldi r16, 1<<CS00 | 1<<CS02 ; setzt die timer0 Clock auf 1024
	out TCCR0B, r16  ;speichert die einstellung in den Timer0

	ldi r16, 1<<TOIE0 ; Timer0 Overflow Interrupt einschalten
	sts TIMSK0, r16 ; Interrupts im Timer0 Mask-Register speichern


	
	;--------------------------------------------------
	;  			Timer 2 init (Ein-und Audgangsverzögerung)
	;--------------------------------------------------


	

	rcall LauflichtAus
	sei ;global Interrupts anschalten
	

	ldi r20, 0x00 ; -> Status Register (nicht Überschreiben)
	; Bit0: Betrieb
	; Bit1: Lüfter / Einschaltsperre

	ldi r18, 0x00 ; Lauflichtzeit
	ldi r21, 0x00 ; Lauflicht bit in DEC (entspricht der LED)

main:
    sbic PINB, Button
    rjmp ButtonEntprellen
	
	rjmp main





Timer0Interrupt:
	sei ;global Interrupts anschalten
	
	cpi r18, 12
	breq LauflichtCheckState

	inc r18
	ret ;return (führt das Programm weiter aus)





;--------------------------------------------------
;  		Unter Funktionen
;--------------------------------------------------

ButtonEntprellen:
    sbis PINB, Button
    rjmp Toggle

    rjmp ButtonEntprellen


Toggle:
    ldi r16, 0<<0
    cp r20, r16 ; if r20 == 0
    breq ToggleOn  ; true
    brne ToggleOff ; false

ToggleOn:
    ldi r20, 1<<0
    sbi PORTB, BetriebLED

    rjmp main

ToggleOff:
    ldi r20, 0<<0
    cbi PORTB, BetriebLED

    rjmp main


;----------- Lauflicht

LauflichtCheckState:
	clr r18
	cpi r20, 1<<0  ; if status == 1:
	breq LauflichtEin
	ret

LauflichtAus:
	ldi r16, 0x00
	out PORTD, r16
	ret

LauflichtEin:

	cpi r21, 0 ;if Lauflicht != Aus
	brne LauflichtWeiter ;  springe wenn Lauflicht ein Zu Lauflicht weiter
	; else
	ldi r16, 1<<2
	ldi r21, 1 ; erste LED Wird auf Aktiv gesetzt
	out PORTD, r16 ;ersten Bit im Lauflicht auf 1 setzten
	ret


; ist was in ProtB


; ProtD

LauflichtWeiter:

	cpi r21, 8
	breq ResetLauflicht

	cpi r21, 6 ; ist r21 < oder > als?
	brge LauflichtPortB ; größer als
	brlt LauflichtPortD ; kleiner als

ResetLauflicht:
	ldi r21, 1 ; erste LED Wird auf Aktiv gesetzt

	cbi PORTB, 1 ;löscht den bit 1

	ldi r16, 1<<2
	out PORTD, r16 ;ersten Bit im Lauflicht auf 1 setzten
	ret

LauflichtPortB:
	ldi r16, 0
	out PORTD, r16
	inc r21

	sbis PORTB, 0 ; überspringe wenn 0bit an  => if BIT0 == 0
		rjmp LauflichtPortB1 ;setzt den ersten bit von PortB
	sbic PORTB, 0 ; überspringe wenn 0bit aus => if BIT0 == 1
		rjmp LauflichtPortB2 ;setzt den zweiten bit von ProtB

LauflichtPortB1:
	sbi PORTB, 0
ret

LauflichtPortB2:
	cbi PORTB, 0
	sbi PORTB, 1
ret

LauflichtPortD:
 	inc r21
	in r16, PORTD
	lsl r16 ; rotiert die Bits nach links weiter
	out PORTD, r16 
	ret
