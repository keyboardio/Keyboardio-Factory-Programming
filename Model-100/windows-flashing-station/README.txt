Setting up the PC: (Only one time per PC)

1. Run 'drivers/stlink/stlink_winusb_install.bat' as Administrator to install the STLinkV2 Driver
2. Connect one USBTiny to the PC
3. Run bin/zadig-2.7.exe
4. Pick "USBTiny" from the menu at the top of the window
5. If the current driver is not 'libusb', pick 'libusb' and click "Install driver"
6. When zadig says the driver is installed, DISCONNECT the USBTiny


Installing the firmware on the PCBA: 

Starting up:

1. Connect STLink to computer
2. Connect TWO USBTiny boards to compuer
3. Double-click 'flash-gd32.bat'


Every time:

1. Connect one set of PCBA (Left + Right) to all three programmers, maybe with the pin jig
2. Hit return.
	. If everything goes ok, a lot of text will show on the screen
	. If there is a problem, a small window should pop up
	. At the end, you should see "Flashed GD32 ok!""
3. Remove PCBA 
4. You are ready to flash the next set
