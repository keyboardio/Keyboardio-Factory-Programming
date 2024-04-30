
:start

@set /p DUMMY=Connect PCBA, then Hit ENTER to flash ATTiny88 chips and then GD32 chip.

@echo "%time% About to flash Model 100"


bin\st-info --chipid 2>&1 || goto :wrong_chip


@echo "%time% Erasing GD32 flash"
bin\st-flash erase
timeout 1

@echo "%time% Flashing ATTiny"

:attiny_1

bin\avrdude -v -pattiny88 -cusbtiny   || goto :wrong_attiny_1
bin\avrdude -v -pattiny88 -cusbtiny  -e -U lfuse:w:0xEE:m -U hfuse:w:0xDD:m -U efuse:w:0xFE:m -U lock:w:0x3F:m || goto :attiny_1_error
bin\avrdude -v -pattiny88 -cusbtiny  -V -B .5 -U flash:w:firmware/attiny88.hex:i || goto :attiny_1_error
bin\avrdude -v -pattiny88 -cusbtiny  -U flash:v:firmware/attiny88.hex:i || goto :attiny_1_error

@echo "OK: Flashed ATTiny"


@echo "%time% Installing firmware onto GD32"

bin\st-flash --format ihex write ".\firmware\gd32.hex" || goto :error

@echo "%time% Flashed GD32 ok!"

bin\st-flash reset


@goto :start

:error 
@echo "BAD: Check the cable: Failed with error #%errorlevel%." 
@echo "Failed with error #%errorlevel%." >> gd32.log.txt
@cscript bin\popup.vbs "BAD: Check STLink"

@goto :start


:wrong_chip
@echo "BAD: Could not find GD32 chip."
@echo "Could not find device GD32 Failed with error #%errorlevel%." >> gd32.log.txt
@cscript bin\popup.vbs "BAD: Could not find GD32 chip"

@goto :start





goto :start

:attiny_1_error
echo "Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: Check cable"
goto :attiny_2

:wrong_attiny_1
echo "Could not find device Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: ATTiny88 not found"
goto :attiny_2


:attiny_2_error
echo "Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: Check cable"
goto :start


:wrong_attiny_2
echo "Could not find device Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: ATTiny88 not found"
goto :


