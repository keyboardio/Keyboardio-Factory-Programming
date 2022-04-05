:chip_1

bin\avrdude -v -pattiny88 -cusbtiny -P usb:bus-0:\\.\libusb0-0001--0x1781-0x0c9f  || goto :wrong_chip_1
bin\avrdude -v -pattiny88 -cusbtiny -P usb:bus-0:\\.\libusb0-0001--0x1781-0x0c9f -e -U lfuse:w:0xEE:m -U hfuse:w:0xDD:m -U efuse:w:0xFE:m -U lock:w:0x3F:m || goto :error_1
bin\avrdude -v -pattiny88 -cusbtiny -P usb:bus-0:\\.\libusb0-0001--0x1781-0x0c9f -B .5 -U flash:w:firmware/attiny88.hex:i || goto :error_1

@echo "OK: Flashed ATTiny #1."

:chip_2

bin\avrdude -v -pattiny88 -cusbtiny -P usb:bus-0:\\.\libusb0-0002--0x1781-0x0c9f  || goto :wrong_chip_2
bin\avrdude -v -pattiny88 -cusbtiny -P usb:bus-0:\\.\libusb0-0002--0x1781-0x0c9f -e -U lfuse:w:0xEE:m -U hfuse:w:0xDD:m -U efuse:w:0xFE:m -U lock:w:0x3F:m || goto :error_2
bin\avrdude -v -pattiny88 -cusbtiny -P usb:bus-0:\\.\libusb0-0002--0x1781-0x0c9f -B 0.5 -U flash:w:firmware/attiny88.hex:i || goto :error_2

@echo "OK: Flashed ATTiny #2."

goto :EOF

:error_1
echo "Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: Check cable"
goto :chip_2

:wrong_chip_1
echo "Could not find device Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: ATTiny88 not found"
goto :chip_2


:error_2
echo "Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: Check cable"
goto :EOF


:wrong_chip_2
echo "Could not find device Failed with error #%errorlevel%." >> attiny-log.txt
cscript bin\popup.vbs "FAIL: ATTiny88 not found"
goto :EOF


