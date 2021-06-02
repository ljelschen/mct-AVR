  
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
#define LuefterLED 4


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

	;----------------Status LED (Luefter, Betrieb) / Button EIN/AUS

	ldi r16, 0<<Button | 1<<BetriebLED | 1<<LuefterLED | 1<<1 | 1<<0
	out DDRB, r16

	ldi r16, 1<<Button | 0<<BetriebLED | 0<<LuefterLED
	out PORTB, r16

	;--------------------------------------------------
	;  			Timer 0 init (Lauflicht)
	;--------------------------------------------------
	; setzt die timer0 Clock auf 1024
	ldi r16, 1<<CS00 | 1<<CS02 
	;speichert die einstellung in den Timer0
	out TCCR0B, r16  
	; Timer0 Overflow Interrupt einschalten
	ldi r16, 1<<TOIE0 
	; Interrupts im Timer0 Mask-Register speichern
	sts TIMSK0, r16  


	;--------------------------------------------------
	;  			Variablen
	;--------------------------------------------------	
	ldi r20, 0x00 ; -> Betrieb
	ldi r18, 0x00 ; Lauflichtzeit
	ldi r22, 0x00 ; Einschaltverz�gerung
	ldi r23, 0x00 ; Ausschaltverzoegerung
	ldi r24, 0x00 ; Lauflicht Bit
	ldi r25, 0x00 ; Lauflicht Richtung
	
	rcall LauflichtAus
	sei ;global Interrupts anschalten
	
main:
    sbic PINB, Button 
		; springe zu entprellen wenn der btn grdrueckt
	    rjmp ButtonEntprellen 
	
rjmp main


Timer0Interrupt:
	sei ;global Interrupts anschalten
	
	cpi r18, 12
		breq LauflichtCheckState
	;Kontrolle fuer Einschaltverzoegerung
	cpi r22, 122 
		breq Einschaltverzoegerung
	;Kontrolle fuer Ausschaltverzoegerung	
	cpi r23, 244 
		breq Ausschaltverzoegerung
	
	;zaehler hochzaehlen
	inc r18
	inc r22
	inc r23
ret 


;--------------------------------------------------
;  		Unter Funktionen
;--------------------------------------------------

ButtonEntprellen:
	sbis PINB, Button ; springe zu toggle wenn btn losgelassen
		rjmp Toggle

rjmp ButtonEntprellen


Toggle:
	; Betrieb status ueberprüfen
	cpi r20, 0
    breq ToggleOn  ; true
    brne ToggleOff ; false

ToggleOn:
	;Einschaltveriegelung
	sbic PORTB, LuefterLED
		rjmp main
	;zuruecksetzen der register
	clr r18
	clr r22
	ldi r20, 1
	; Betrieb LED anschalten
    sbi PORTB, BetriebLED
rjmp main

ToggleOff:
	; springe zu MaschineAus wenn der Luefter aus 
	sbis PORTB, LuefterLED
		rjmp MaschineAUS
	; betrieb der Maschine auf 0 setzen
    ldi r20, 0
	clr r23
rjmp main

Einschaltverzoegerung:
	; luefter einschalten nach 2s
	clr r22
	cpi r20, 1
	breq LuefterLEDAn
ret

LuefterLEDAn:
	; wenn Luefter aus, dann einschalten
	sbis PORTB, LuefterLED
		sbi PORTB, LuefterLED
ret

Ausschaltverzoegerung:
	; nach 4. Maschiene Aus
	clr r23
	cpi r20, 0
	breq MaschineAUS
ret

MaschineAUS:
	; Lauflicht und Betrieb zuruecksetzen
    cbi PORTB, BetriebLED
	cbi PORTB, LuefterLED
	rcall LauflichtAus
ret

;----------- Lauflicht
LauflichtCheckState:
	; betrieb der Maschine pruefen
	clr r18
	cpi r20, 1  ; if status == 1:
	breq LauflichtEin
ret


LauflichtAus:
	;lauflicht ausschalten
	rcall resetPorts
	ldi r24, 0 
ret

LauflichtEin:
	if Lauflicht != Aus
	cpi r24, 0 
	;  springe wenn Lauflicht ein Zu Lauflicht weiter
	brne LauflichtRichtung 
	; else
	ldi r24, 1
	rcall LauflichtSet
ret

	
LauflichtRichtung:
	; Lauflicht richtung bestimmen
	cpi r25, 1
	brne LauflichtVor
	breq LauflichtZur

LauflichtVor:
 	; bit nach links bewegen
	lsl r24
	; Richtung aendern wenn das 8. Bit gesetzt ist
	sbrc r24, 7 
		ldi r25, 1

rjmp LauflichtSet

LauflichtZur:
	; bit nach rechts bewegen
	lsr r24 
	; Richtung aendern wenn das 0. Bit gesetzt ist
	sbrc r24, 0
		ldi r25, 0

rjmp LauflichtSet


LauflichtSet:
	; Ports zuruecksetzen
	rcall resetPorts 
	
	; ausgang nach reg. 24 setzen
	sbrc r24, 0
		sbi PORTD, 2
	sbrc r24, 1
		sbi PORTD, 3
	sbrc r24, 2
		sbi PORTD, 4
	sbrc r24, 3
		sbi PORTD, 5
	sbrc r24, 4
		sbi PORTD, 6
	sbrc r24, 5
		sbi PORTD, 7
	sbrc r24, 6
		sbi PORTB, 0
	sbrc r24, 7
		sbi PORTB, 1
ret

resetPorts:
	; loescht alle bits für das Lauflicht
	cbi PORTB, 0
	cbi PORTB, 1
	ldi r16, 0
	out PORTD, r16
ret
