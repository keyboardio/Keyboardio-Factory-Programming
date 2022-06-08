

echo "Connect PCBA, then Hit ENTER to flash GD32 chip."
read

echo "About to flash Model 100"

st-info --chipid 2>&1 || goto :wrong_chip

echo "Erasing GD32 flash"
st-flash erase

echo "Installing firmware onto GD32"

st-flash --format ihex write "./output/latest/gd32_firmware_with_bootloader.hex"

echo "Flashed GD32 ok!"

st-flash reset
