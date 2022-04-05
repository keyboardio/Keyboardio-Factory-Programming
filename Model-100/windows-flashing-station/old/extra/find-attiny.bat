REM NB:in a batch file, need to use %%i not %i
setlocal EnableDelayedExpansion
SET lf=-
FOR /F "tokens=2" %%i IN ('pnputil.exe /enum-devices /connected | findstr "VID_1781&PID_OC9F"') DO set out=%%i
REM FOR /F "tokens=2" %%i IN ('pnputil.exe /enum-devices /connected') DO set out=%%i
ECHO %out%
