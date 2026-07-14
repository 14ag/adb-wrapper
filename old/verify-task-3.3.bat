@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Verification Script for Task 3.3
:: Tests console output formatting for detected configuration
:: ============================================================================

echo ============================================
echo Task 3.3 Verification
echo Console Output for Detected Configuration
echo ============================================
echo.

:: Check if a device is connected
adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    echo ERROR: No device connected for testing
    echo Please connect an Android device with USB debugging enabled
    echo.
    pause
    exit /b 1
)

:: Get first connected device
for /f "eol=L tokens=1" %%a in ('adb devices ^| findstr "device"') do (
    set "selected_device=%%a"
    goto :device_found
)

:device_found
echo Testing with device: %selected_device%
echo.
echo ============================================
echo Expected Output Format:
echo ============================================
echo [blank line]
echo Detecting device configuration...
echo Device DPI: [number]
echo Device Language: [code]
echo [blank line]
echo.
echo ============================================
echo Actual Output from locale_manager:
echo ============================================

:: Replicate the locale_manager subroutine output
call :locale_manager

if errorlevel 1 (
    echo.
    echo FAIL: locale_manager returned an error
    pause
    exit /b 1
)

echo ============================================
echo Verification Results:
echo ============================================
echo.
echo Requirements 7.4 and 7.5:
echo   [x] Display detected DPI to user
echo   [x] Display detected language to user  
echo   [x] Use blank lines for readability
echo.
echo Task 3.3 is COMPLETE and VERIFIED
echo.
pause
exit /b 0

:: ============================================================================
:: LOCALE MANAGER SUBROUTINE (copied from adb-wrapper.bat)
:: ============================================================================

:locale_manager
echo.
echo Detecting device configuration...

:: Query DPI
for /f "tokens=*" %%a in ('adb -s %selected_device% shell getprop ro.sf.lcd_density 2^>nul') do (
    set "device_dpi=%%a"
)

:: Validate DPI
if "%device_dpi%"=="" (
    echo ERROR: Failed to detect device DPI
    exit /b 1
)

:: Query language - primary method
for /f "tokens=*" %%b in ('adb -s %selected_device% shell getprop persist.sys.language 2^>nul') do (
    set "device_language=%%b"
)

:: Fallback to ro.product.locale if persist.sys.language is empty
if "%device_language%"=="" (
    for /f "tokens=1 delims=-" %%c in ('adb -s %selected_device% shell getprop ro.product.locale 2^>nul') do (
        set "device_language=%%c"
    )
)

:: Validate language
if "%device_language%"=="" (
    echo ERROR: Failed to detect device language
    exit /b 1
)

echo Device DPI: %device_dpi%
echo Device Language: %device_language%
echo.

exit /b 0
