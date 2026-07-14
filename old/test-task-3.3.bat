@echo off
:: Test script for Task 3.3 - Console output for detected configuration
:: This script tests the locale_manager subroutine output formatting

echo ========================================
echo Testing Task 3.3: Console Output
echo ========================================
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

echo Test: Calling locale_manager subroutine
echo.
echo Expected output:
echo   - Blank line before "Detecting device configuration..."
echo   - "Device DPI: [number]"
echo   - "Device Language: [code]"
echo   - Blank line after language
echo.
echo ----------------------------------------
echo Actual output:
echo ----------------------------------------

:: Call the main script's locale_manager by sourcing it
call adb-wrapper.bat test-locale-manager 2>nul

echo ----------------------------------------
echo.
echo Verification:
echo   1. Check if there's a blank line before "Detecting..."
echo   2. Check if DPI is displayed
echo   3. Check if Language is displayed
echo   4. Check if there's a blank line after the output
echo.
pause
