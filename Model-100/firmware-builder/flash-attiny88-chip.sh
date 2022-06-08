#!/bin/sh


echo "Connect PCBA, then Hit ENTER to flash ATTiny88 chip."
read

echo " About to flash Model 100"


echo " Flashing ATTiny"


avrdude -v -pattiny88 -cusbtiny  && \
avrdude -v -pattiny88 -cusbtiny  -e -U lfuse:w:0xEE:m -U hfuse:w:0xDD:m -U efuse:w:0xFE:m -U lock:w:0x3F:m  && \
avrdude -v -pattiny88 -cusbtiny  -B .5 -U flash:w:output/latest/attiny88_firmware_with_bootloader.hex:i

echo "OK: Flashed ATTiny"

