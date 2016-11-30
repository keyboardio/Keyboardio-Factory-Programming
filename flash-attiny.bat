bin\avrdude -v -pattiny88 -cusbtiny >> attiny-log.txt 2>&1 || goto :wrong_chip
bin\avrdude -v -pattiny88 -cusbtiny -e -U lfuse:w:0xEE:m -U hfuse:w:0xDD:m -U efuse:w:0xFE:m -U lock:w:0x3F:m >> attiny-log.txt 2>&1 || goto :error

bin\avrdude -v -pattiny88 -cusbtiny -U flash:w:firmware/model01-attiny-2016-11-07.hex:i  >> attiny-log.txt 2>&1 || goto :error

cscript bin\popup.vbs "OK: Flashed ATTiny."

goto :EOF

:error 
echo "Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: Check cable"
exit /b %errorlevel%
goto :EOF


:wrong_chip
echo "Could not find device Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: ATTiny88 not found"
exit /b %errorlevel%
goto :EOF


