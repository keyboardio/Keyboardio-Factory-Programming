

echo "Connect PCBA, then Hit ENTER to flash GD32 chip."
read

st-info --chipid  && \
st-flash erase && \
st-flash --format ihex write "./output/latest/gd32_firmware_with_bootloader.hex" && \
st-flash reset
