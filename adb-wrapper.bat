@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: ADB Wrapper System
:: ============================================================================
:: Simplifies ADB operations by automatically routing commands to the correct
:: device and intelligently handling APK and APKS installations.
::
:: Usage:
::   adb-wrapper.bat install <package-file>
::   adb-wrapper.bat <adb-command> [arguments]
:: ============================================================================

:: Main entry point - parse arguments and route to appropriate handler
goto :main

:: ============================================================================
:: UTILITY SUBROUTINES
:: ============================================================================

:reset_choice
:: Resets errorlevel to 0 for choice command
exit /b 0

:show_usage
:: Display usage instructions
echo.
echo ADB Wrapper System
echo.
echo Usage:
echo   adb-wrapper.bat install ^<package-file^>
echo   adb-wrapper.bat ^<adb-command^> [arguments]
echo.
echo Examples:
echo   adb-wrapper.bat install myapp.apk
echo   adb-wrapper.bat install myapp.apks
echo   adb-wrapper.bat shell pm list packages
echo   adb-wrapper.bat logcat
echo.
exit /b 0

:: ============================================================================
:: DEVICE SELECTOR COMPONENT
:: ============================================================================

:device_selector
:: Enumerate connected devices and select target device
:: Output: Sets %selected_device% environment variable
:: Return: 0 on success, 1 on error
setlocal enabledelayedexpansion
set "i=0"
set "device_count=0"

:: Enumerate devices - skip "List of devices attached" line
for /f "eol=L tokens=1" %%a in ('adb devices ^| findstr "device"') do (
    set /a "i+=1"
    :: Create dynamic variable names (device_1, device_2, etc.)
    set "device_!i!=%%a"
    set /a "device_count+=1"
)

:: Handle device count scenarios
if "!device_count!"=="0" (
    echo.
    echo ERROR: No devices connected
    echo.
    exit /b 1
)

if "!device_count!"=="1" (
    for %%d in (!device_1!) do (
        endlocal & set "selected_device=%%d"
    )
    exit /b 0
)

:: Multiple devices - show selection menu
echo.
echo Multiple devices detected:
echo.
set "choicelist="
for /l %%c in (1, 1, !device_count!) do (
    echo %%c. !device_%%c!
    set "choicelist=!choicelist!%%c"
)

call :reset_choice
choice /c %choicelist% /n /m "Select device: "
set "selection=%errorlevel%"

for %%d in (!device_%selection%!) do (
    endlocal & set "selected_device=%%d"
)

exit /b 0

:: ============================================================================
:: INSTALL HANDLER COMPONENT
:: ============================================================================

:install_handler
:: Detect package type and route to appropriate installer
:: Input: %1 - Package file path
:: Return: 0 on success, 1 on error
set "package=%~1"

:: Validate package exists
if not exist "%package%" (
    echo.
    echo ERROR: Package file not found: %package%
    echo.
    exit /b 1
)

:: Extract file extension
set "ext=%~x1"

:: Route based on extension (case-insensitive)
if /i "%ext%"==".apk" (
    call :install_apk "%package%"
    exit /b %errorlevel%
)

if /i "%ext%"==".apks" (
    call :install_apks "%package%"
    exit /b %errorlevel%
)

:: Invalid extension
echo.
echo ERROR: Invalid package format: %ext%
echo Supported formats: .apk, .apks
echo.
exit /b 1

:: ============================================================================
:: APK INSTALLER COMPONENT
:: ============================================================================

:install_apk
:: Install APK files using standard ADB install command
:: Input: %1 - APK file path
:: Return: 0 on success, 1 on error
set "apk_file=%~1"

echo.
echo Installing APK to device %selected_device%...
echo.

adb -s %selected_device% install -r "%apk_file%"

if errorlevel 1 (
    echo.
    echo ERROR: APK installation failed on device %selected_device%
    echo.
    exit /b 1
)

echo.
echo SUCCESS: APK installed successfully on device %selected_device%
echo.

exit /b 0

:: ============================================================================
:: APKS INSTALLER COMPONENT
:: ============================================================================

:install_apks
:: Install APKS files using bundletool
:: Input: %1 - APKS file path
:: Return: 0 on success, 1 on error
set "apks_file=%~1"

echo.
echo Installing APKS to device %selected_device%...
echo.

:: Install using bundletool
java -jar bundletool-all-1.18.3_2.jar install-apks ^
    --apks="%apks_file%" ^
    --device-id=%selected_device%

if errorlevel 1 (
    echo.
    echo ERROR: APKS installation failed on device %selected_device%
    echo.
    exit /b 1
)

echo.
echo SUCCESS: APKS installed successfully on device %selected_device%
echo.

exit /b 0

:: ============================================================================
:: ADB PASSTHROUGH
:: ============================================================================

:adb_passthrough
:: Pass any non-install command directly to ADB with selected device
:: Input: All command-line arguments
:: Return: ADB command errorlevel
adb -s %selected_device% %*
exit /b %errorlevel%

:: ============================================================================
:: MAIN ENTRY POINT
:: ============================================================================

:main
:: Parse command-line arguments
set "command=%~1"
set "package_file=%~2"

:: Route based on command
if "%command%"=="" (
    call :show_usage
    exit /b 0
)

if /i "%command%"=="install" (
    call :device_selector
    if errorlevel 1 exit /b 1
    call :install_handler "%package_file%"
    exit /b %errorlevel%
)

:: For all other commands, pass through to ADB
call :device_selector
if errorlevel 1 exit /b 1
call :adb_passthrough %*
exit /b %errorlevel%
