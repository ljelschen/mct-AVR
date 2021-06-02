;
; Lab3Auf1.asm
;
; Created: 2021-06-01 11:50:13
; Author : Lars
;


.include "m328pdef.inc"
 
.org 0x0000
    rjmp init

; winkel zwischen 0 und 180 grad einstellen
#define angle 20 

; länge des PWM Signal
#define maxPWMlength 40000
; Duty Cycle berechnen zwischen 2.5% und 13% 
#define PWM (1000 + ((4200/180) * angle))

init: 
; Stackpointer initialisieren
    ldi  r16, HIGH(RAMEND)     
    out  SPH, r16
    ldi  r16, LOW(RAMEND)
    out  SPL, r16

; Servo Ausgangspin -> Output
    ldi  r16, 0xFF
    out  DDRB, r16                
; Timer1 fast PWM 
    ldi r16, (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11)
    sts TCCR1A, r16
; Timer1 clock auf 8
    ldi r16, (1<<WGM13)|(1<<WGM12)|(1<<CS11)
    sts TCCR1B, r16
; setzen der frequenz
    ldi r16, HIGH(maxPWMlength) 
    ldi r17, LOW(maxPWMlength)
    sts ICR1H, r16
    sts ICR1L, r17
; setzen des Duty Cycle
    ldi r16, HIGH(PWM) 
    ldi r17, LOW(PWM)
    sts OCR1AH, r16
    sts OCR1AL, r17
main:
    rjmp main