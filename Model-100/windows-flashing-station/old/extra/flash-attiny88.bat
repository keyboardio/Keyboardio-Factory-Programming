
:start

@set /p DUMMY=Connect PCBA, then Hit ENTER to flash Atreus


@echo "%time% About to flash Atreus"

@bin\avrdude -v -patmega32u4 -cusbtiny >> atmega-log.txt 2>&1 || goto :wrong_chip

@echo "%time% Setting device fuses"

@bin\avrdude -patmega32u4 -vvv -cusbtiny  -e -Ulock:w:0x3F:m -Uefuse:w:0xcb:m -Uhfuse:w:0xd8:m -Ulfuse:w:0xff:m >> atmega-log.txt 2>&1
@echo "%time% Installing firmware onto Atreus"

@bin\avrdude -patmega32u4  -vvv -cusbtiny -B 0.5 -Uflash:w:firmware/atmega.hex:i -Ulock:w:0x2F:m >> atmega-log.txt 2>&1
@echo "%time% Flashed ok!"



@goto :start

:error 
@echo "BAD: Check the cable: Failed with error #%errorlevel%." 
@echo "Failed with error #%errorlevel%." >> atmega-log.txt
@cscript bin\popup.vbs "BAD: Check cable"

goto :start


:wrong_chip
@echo "BAD: Could not find Atreus"
@echo "Could not find device Failed with error #%errorlevel%." >> atmega-log.txt

@goto :start


