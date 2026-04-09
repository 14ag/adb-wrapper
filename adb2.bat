@echo off


:adb_device
:: Make list of ADB devices
setlocal enabledelayedexpansion
set "i=0"
set "sum_of_devices=0"

:: Loop through ADB devices, skipping the "List of devices attached" line
for /f "eol=L tokens=1" %%a in ('adb devices ^| findstr "device"') do (
    set /a "i+=1"
    :: Create dynamic variable names (device_1, device_2, etc.) and assign device IDs
    for /f "tokens=1" %%b in ('echo device_!i!') do (
        set "%%b=%%a"
        set /a "sum_of_devices+=1"
    )
)

:: check for connected devices
if "!sum_of_devices!"=="0" echo no devices connected & exit /b

:: use the default device 
if "!sum_of_devices!"=="1" set id=1 & goto set_adb_device

:device_selector
:: store devices in variable
for /l %%c in (1, 1, !sum_of_devices!) do (
	set list_of_devices=%list_of_devices% "device_%%c:_!device_%%c!" 
	)
set0 id=device_selector !sum_of_devices! !list_of_devices!
	


    
:: call :selector "[command that outputs list eg echo a & echo b & echo c]"
:: & is just a command separator, while && is a conditional operator
:selector
echo.
setlocal enabledelayedexpansion
set command=%* >nul
set "i=0"
set "selector="
set "choicelist="
:: Loop through a list, act on each line
for /f "eol=L tokens=1" %%a in ('!command!') do (
    set /a i+=1
    :: Create dynamic variable names (_1, _2, etc.)
    for %%b in (_!i!) do (
        set "%%b=%%a"
        set "choicelist=!choicelist!!i!"
        echo !i!. %%a
    )   )

call :reset_choice
choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%c in (%choicelist:~-1,1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%c (
    for %%d in (!_%%c!) do (
            endlocal & set "selector=%%d"
            goto :break
    )   )   )
:break
exit /b

:reset_choice
exit /b 0
