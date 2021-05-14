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

init:
          ldi      r16, HIGH(RAMEND)     ; Stackpointer initialisieren
          out      SPH, r16
          ldi      r16, LOW(RAMEND)
          out      SPL, r16

          ldi r16, 0xFF
          out DDRD, r16

loop:     ldi  r18, 0
           
loop1:    inc r18
          cpi r18, 160
          breq loop2

          rcall servoPuls

          rjmp loop1

loop2:    dec r18
          cpi r18, 0
          breq loop1

          rcall servoPuls

          rjmp loop2

servoPuls:
          push r18
          ldi r16, 0xFF         ; Ausgabepin auf 1
          out PORTD, r16
          
          rcall wait_puls        ; die Wartezeit abwarten

          ldi r16, 0x00         ; Ausgabepin wieder auf 0
          out PORTD, r16

          rcall wait_pause       ; und die Pause hinten nach abwarten
          pop r18
          ret
;
wait_pause:
          ldi r19, 15
w_paus_1: rcall wait_1ms
          dec r19
          brne w_paus_1
          ret
;
wait_1ms: ldi r18, 10           ; 1 Millisekunde warten
w_loop2:  ldi r17, 132          ; Es muessen bei 4 Mhz 4000 Zyklen verbraten werden
w_loop1:  dec r17               ; die innerste Schleife umfasst 3 Takte und wird 132
          brne w_loop1          ; mal abgearbeitet: 132 * 3 = 396 Takte
          dec r18               ; dazu noch 4 Takte für die äussere Schleife = 400
          brne w_loop2          ; 10 Wiederholungen: 4000 Takte
          ret                   ; der ret ist nicht eingerechnet
;
; r18 muss mit der Anzahl der Widerholungen belegt werden
; vernünftige Werte laufen von 1 bis ca 160
wait_puls:
w_loop4:  ldi r17, 10           ; die variable Zeit abwarten
w_loop3:  dec r17
          brne w_loop3
          dec r18
          brne w_loop4

          rcall wait_1ms         ; und noch 1 Millisekunde drauflegen
          ret