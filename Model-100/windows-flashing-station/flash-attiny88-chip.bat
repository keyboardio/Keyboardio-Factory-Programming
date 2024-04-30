@echo off
:main_loop
set /p DUMMY="Connect PCBA, then hit ENTER to flash ATTiny88 chip."

echo "%time% About to flash Model 100"
echo "%time% Flashing ATTiny"

:try_fuses
for /L %%x in (1, 1, 6) do (
    bin\avrdude -v -pattiny88 -cusbtiny  -B 2 -e -U lfuse:w:0xEE:m -U hfuse:w:0xDD:m -U efuse:w:0xFE:m -U lock:w:0x3F:m && goto try_flash
    echo "Attempt %%x to set fuses failed." >> attiny-log.txt
    timeout /t 1 /nobreak >nul

)
echo "Failed to set fuses after 6 attempts." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: Fuses could not be set"
goto main_loop

:try_flash
for /L %%x in (1, 1, 6) do (
    bin\avrdude -v -pattiny88 -cusbtiny -u -V -B .5 -U flash:w:firmware/attiny88.hex:i && (
        echo "OK: Flashed ATTiny"
        goto main_loop
    )
    echo "Attempt %%x to flash ATTiny failed." >> attiny-log.txt
    timeout /t 1 /nobreak >nul

)
echo "Failed to flash ATTiny after 6 attempts." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: Flashing could not be completed"
goto main_loop

:wrong_chip
echo "BAD: Could not find ATTiny88 chip."
echo "Could not find device ATTiny88. Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: ATTiny88 not found"
goto main_loop
