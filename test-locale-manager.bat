@echo off
setlocal enabledelayedexpansion

:: Test script for locale_manager subroutine
echo ============================================
echo Testing Locale Manager Component
echo ============================================
echo.

:: Check if a device is connected
echo Checking for connected devices...
adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    echo ERROR: No device connected. Please connect a device to test.
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
echo Found device: %selected_device%
echo.

:: Test DPI detection
echo Testing DPI detection...
for /f "tokens=*" %%a in ('adb -s %selected_device% shell getprop ro.sf.lcd_density 2^>nul') do (
    set "device_dpi=%%a"
)

if "%device_dpi%"=="" (
    echo FAIL: DPI detection failed
) else (
    echo PASS: DPI detected = %device_dpi%
)
echo.

:: Test primary language detection
echo Testing primary language detection (persist.sys.language)...
for /f "tokens=*" %%b in ('adb -s %selected_device% shell getprop persist.sys.language 2^>nul') do (
    set "device_language=%%b"
)

if "%device_language%"=="" (
    echo INFO: persist.sys.language is empty, will test fallback
) else (
    echo PASS: Primary language detected = %device_language%
)
echo.

:: Test fallback language detection
echo Testing fallback language detection (ro.product.locale)...
set "fallback_language="
for /f "tokens=1 delims=-" %%c in ('adb -s %selected_device% shell getprop ro.product.locale 2^>nul') do (
    set "fallback_language=%%c"
)

if "%fallback_language%"=="" (
    echo INFO: Fallback language is also empty
) else (
    echo PASS: Fallback language detected = %fallback_language%
)
echo.

:: Test final language value
if "%device_language%"=="" (
    set "device_language=%fallback_language%"
)

if "%device_language%"=="" (
    echo FAIL: Language detection completely failed
) else (
    echo PASS: Final language value = %device_language%
)
echo.

echo ============================================
echo Test Complete
echo ============================================
echo.
pause
