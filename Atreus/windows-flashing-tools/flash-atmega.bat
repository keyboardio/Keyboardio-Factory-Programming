bin\avrdude -v -patmega32u4 -cusbtiny >> attiny-log.txt 2>&1 || goto :wrong_chip

bin\avrdude -patmega32u4 -v -cusbtiny  -e -Ulock:w:0x3F:m -Uefuse:w:0xcb:m -Uhfuse:w:0xd8:m -Ulfuse:w:0xff:m  >> atmega-log.txt 2>&1  || goto :error

bin\avrdude -patmega32u4 -v -cusbtiny -B 0.5  -Uflash:w:firmware/atmega.hex:i -Ulock:w:0x2F:m  >> atmega-log.txt 2>&1 || goto :error


cscript bin\popup.vbs "OK: Flashed ATMega"

goto :EOF

:error 
echo "Failed with error #%errorlevel%." >> atmega-log.txt
cscript bin\popup.vbs "FAIL: Check cable"
exit /b %errorlevel%
goto :EOF


:wrong_chip
echo "Could not find device Failed with error #%errorlevel%." >> atmega-log.txt
cscript bin\popup.vbs "FAIL: ATMega32U4 not found"
exit /b %errorlevel%
goto :EOF


