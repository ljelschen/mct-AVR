@echo off

set PORT="COM5"
set CHIP="atmega328p"



set HEXFILE=./Lab2Auf2/Lab2Auf2.hex

copy *.hex %HEXFILE%
"C:\Program Files (x86)\Atmel\AVR Tools\toolchain\bin\avrdude.exe" -C"C:\Program Files (x86)\Atmel\AVR Tools\toolchain\bin\avrdude.conf" -v -p%CHIP% -carduino -P%PORT% -b57600 -D -Uflash:w:%HEXFILE%:i
pause