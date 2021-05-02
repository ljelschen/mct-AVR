; Assmebler code quick and dirty
; ljelschen@hs-bremen.de
; Fr 23. Apr 20201

.include "m328pdef.inc"

.org 0x00
	jmp reset

.org 0x32

reset:

; ---------------- Stack Initialisirung
	; ldi r16, HIGH(RAMEND)
	; out SPH, r16
	; ldi r16, LOW(RAMEND)
	; out SPL, r16

; ---------------- Eingangs Pins Initialisierung
	cbi DDRD,2	; Pin D2 Input
	sbi PORTD,2	; Pin D2 Pullup einschalten
	
	sbi PIND,2	; HAPSIM Pullup wirkt auf Eingang (hier auch für die Simulation)

; ---------------- Ausgangs Ports Initialisierung
	sbi DDRB,0	; Port B0 Output

; ---------------- Main Loop
mainloop:
	ldi r16, 0

	sbis PIND,2
	ldi r16,1

	out PORTB,r16

	rjmp mainloop

; ---------------- Programm Ende
