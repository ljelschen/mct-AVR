; Titel: Assmebler Labor 2 Aufgabe 3
; Laborgruppe: A9
; 
; Lars Jelschen, Matrikelnummer: 5100174
; Marvin Klusmeyer, Matrikelnummer: 5093298
;
; Anprechpartner: ljelschen@hs-bremen.de
;
; Programmiert am: Mo 03. Mai 20201


.include "m328pdef.inc"

.org 0x0000 ; save the Programm at flash address 0
    rjmp    init
  

.org 0x0016
          rjmp    Compare_vect

init: 
          ldi      r16, HIGH(RAMEND)     ; Stackpointer initialisieren
          out      SPH, r16
          ldi      r16, LOW(RAMEND)
          out      SPL, r16

          ldi  r16, 0x80
          out  DDRB, r16                ; Servo Ausgangspin -> Output

          ldi  r17, 0                   ; Software-Zähler
            
          ldi  r16, 120
          out  OCR1BL, r16                ; OCR2 ist der Servowert

          ldi  r16, 1<<OCIE1A
          out  TIMSK1, r16

          ldi  r16, (1<<WGM11) | (1<<CS12) ; CTC, Prescaler: 64
          out  TCCR0B, r16

          sei

main:
          rjmp main

Compare_vect:
          in   r18, SREG
          inc  r17
          cpi  r17, 1
          breq PulsOn
          cpi  r17, 2
          breq PulsOff
          cpi  r17, 10
          brne return
          ldi  r17, 0
return:   out  SREG, r18
          reti

PulsOn:   sbi  PORTB, 0
          rjmp return

PulsOff:  cbi  PORTB, 0
          rjmp return