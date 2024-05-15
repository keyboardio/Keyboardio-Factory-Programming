@echo off
setlocal enabledelayedexpansion
cls

:: Set the code page to 936 which supports Simplified Chinese
@chcp 936

:: Ensure the script's working directory is set to the location of the script
cd /d "%~dp0"

:start
    echo.
    echo.
    echo.
    echo 请在按住 'prog' 键的同时连接键盘。 / Please connect the keyboard while holding down the 'prog' key.
    echo.
    echo.
    echo.
    color 0E

:: Execute the firmware flashing command
call :flash_firmware
if %ERRORLEVEL% equ 0 (
    call :search_com_port
    call :send_command
    call :finish
) else (
    call :fail
)

goto start

:flash_firmware
echo Running firmware flashing command...
if exist dfu-util-static.exe (
    echo dfu-util-static.exe found
) else (
    echo dfu-util-static.exe not found
    pause
    exit /b 1
)

dfu-util-static.exe -w -R -D gd32_firmware.bin
set FLASH_EXIT_CODE=%ERRORLEVEL%
echo dfu-util-static exit code: %FLASH_EXIT_CODE%

:: Additional test of the flash error code
if %FLASH_EXIT_CODE% equ 0 (
    echo Initial test: Firmware flashing succeeded.
    exit /b 0
) else (
    echo Initial test: Firmware flashing failed with exit code %FLASH_EXIT_CODE%.
    exit /b 1
)

:search_com_port
echo Searching for COM port...

:search_com_port_retry
powershell -Command "Get-WmiObject Win32_SerialPort | Where-Object { $_.PNPDeviceID -match '^USB\\VID_3496&PID_0006' } | Select-Object -ExpandProperty DeviceID" > com_port.txt
set /p com_port=<com_port.txt

:: Debugging output for the COM port detection
echo Detected COM port: %com_port%

:: Check if a COM port was found
if "%com_port%"=="" (
    echo No COM ports found. Retrying...
    timeout /t 1 /nobreak >nul
    goto search_com_port_retry
)
exit /b 0

:send_command
echo eeprom.erase > %com_port%
set ECHO_EXIT_CODE=%ERRORLEVEL%
echo Command exit code: %ECHO_EXIT_CODE%
if %ECHO_EXIT_CODE% neq 0 (
    echo Error sending command to %com_port%. Retrying...
    timeout /t 1 /nobreak >nul
    goto search_com_port_retry
)
exit /b 0

:finish
color 07
echo.
echo 完成 / OK

exit /b 0

:fail
echo Firmware flashing failed with exit code %FLASH_EXIT_CODE%.
color 0C
echo.
echo 失败 / FAIL
color 0C
msg * "固件烧录失败！/ FIRMWARE FLASHING FAILED!"
pause
exit /b 1
