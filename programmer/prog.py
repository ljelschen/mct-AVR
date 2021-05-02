import os

#user Variables
chip = "m328p"
port = "COM3"
labor = 1
aufgabe = 2



#---------------- do not change 
#name management
name = f"Lab{labor}Auf{aufgabe}"
file = f"../{name}/{name}.hex" 

file = os.path.abspath(file) #set the absolut file path

if os.path.exists(file):
    befehl = f"avrdude.exe -C \"avrdude.conf\" -v -p \"{chip}\" -P \"{port}\" -b 57600 -D Uflash:w:{file}:i -c arduino"
    prog = os.system(befehl)
else:
    print("Programmdatei ist nicht vorhanden")

print("-"*5, "Programmieren abgeschlossen", "-"*5)