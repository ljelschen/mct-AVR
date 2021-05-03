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

;define outputs
#define LED1 0

.org 0x00
	jmp setup

.org 0x32						;start the programm at bit 0

setup:
;---------------- Stack Initialisirung 🤢
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

    ldi r17, 0 ;brightness save 0 - 255
    ldi r18, 0<<0; fade direction, set the bit 0 to 0; 0 = fade_in; 1 = fade_out

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
	breq sw_directions ; then jump to LED_Toogle

	rjmp main

;---------------- Fade -----------------

clrTimer:
    ;brightness calculation
    ;min = 0; max = 255
    ;timer ends 61x in the second
    ;255  / 61 = 4
    
    ;fade_out--------------------
    ldi r16, 4 ; set the r16 to dec. 4
    sub r17, r16  ; decrease r16 from r17 (fade out)
    ;end fade_out--------------------------
        ;wert << BIT
    ldi r16, 0<<0 ; load a null in r16
    cp r18, r16 ; check for the right direktrion
    breq add_brightness ; if the direction is null (fade in)

end_fade:
    out OCR0A, r17; set the brightness to the led as PWM signal
	inc r25	; increase Register r25 
	sbi TIFR0, 0 ; reset Timer Overflow Flag
	rjmp auswertung ; jmp back

add_brightness:
    ldi r16, 8 ; add 8 to r16
    add r17, r16 ; add to r17, r16
    rjmp end_fade ; jump back

;---------------fade directions

sw_directions: ; reach after 1s
	clr r25	; clear the register 
    ldi r16, 0<<0 ; set the first bit to null in the r16 register

    ; if r18 == 0:
    cp r18, r16 ; compere the register r16 with the r18 register
        breq fade_out ; jump to the fade out direction
    ;else
        brne fade_in ; jump to the fade in direction
    ;end

fade_in:
    ldi r18, 0<<0 ; change the bit 0 to 0 from the r18(brightness) reg.
    ldi r17, 0
   	rjmp main ; jmp back to main

fade_out:
    ldi r18, 1<<0 ;change the bit 0 to 1 from the r18(brightness) reg.
    ldi r17, 255
   	rjmp main ; jmp back to main

