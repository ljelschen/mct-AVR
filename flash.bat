@echo off

set PORT="COM5"
set CHIP="atmega328p"

set ASMFILE=%1
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" %ASMFILE% -fI -o flash.hex
"C:\Program Files (x86)\Atmel\AVR Tools\toolchain\bin\avrdude.exe" -C"C:\Program Files (x86)\Atmel\AVR Tools\toolchain\bin\avrdude.conf" -v -p%CHIP% -carduino -P%PORT% -b57600 -D -Uflash:w:flash.hex:i