bin\avrdude -patmega32u4 -v -cusbtiny -B 1 -e -Ulock:w:0x3F:m -Uefuse:w:0xcb:m -Uhfuse:w:0xd8:m -Ulfuse:w:0xff:m  >> atmega-log.txt 2>&1 

bin\avrdude -patmega32u4 -v -cusbtiny -B 1 -Uflash:w:firmware/model-01-atmega-bootloader-2016-08-06.hex:i -Ulock:w:0x2F:m  >> atmega-log.txt 2>&1

bin\avrdude -patmega32u4 -v -cusbtiny -B 1 -D -Uflash:w:firmware/model01-atmega-2016-08-06.hex:i >> atmega-log.txt 2>&1

