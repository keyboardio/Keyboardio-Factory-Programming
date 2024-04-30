

echo "Connect PCBA, then Hit ENTER to flash GD32 chip."
read

st-info --chipid  && sleep 2 && \
st-flash erase && sleep 2 &&\
st-flash --format ihex write "./output/latest/gd32_firmware_with_bootloader.hex" && sleep 2 && \
st-flash reset
