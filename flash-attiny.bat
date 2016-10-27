bin\avrdude -v -pattiny88 -cusbtiny -B1 -e -U lfuse:w:0xEE:m -U hfuse:w:0xDD:m -U efuse:w:0xFe:m -U lock:w:0xFF:m

# >> attiny-log.txt 2>&1

bin\avrdude -v -pattiny88 -cusbtiny -B1 -U flash:w:firmware/model01-attiny-2016-08-06.hex:i 


# >> attiny-log.txt 2>&1

