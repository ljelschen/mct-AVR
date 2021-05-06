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
#define TIMER_PIN 6 ; bit PD6

.org 0x00 ; save the Programm at flash address 0
	jmp setup

setup:
;---------------- Stack Init. 🤢
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; ouput direction for PROTB / PROTD
	ldi r16, 1<<TIMER_PIN 
	out DDRD, r16

	; set output for the timer and fast PWM
	ldi r16, 1<<COM0A1 | 1<<WGM00 | 1<<WGM01
 	out TCCR0A, r16 ; save the parameters to the timer reg.

	ldi r16, 1<<CS00 | 1<<CS02 ; set the timer to 1024 clock ticks to inc.
	out TCCR0B, r16 ; save the parameters to the timer reg.

    ldi r17, 0 ;brightness save 0 - 255
    ldi r18, 0<<0; fade direction, set the bit 0 to 0; 0 = fade_in; 1 = fade_out

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

;--------------- fade directions

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

