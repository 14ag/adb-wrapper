@echo off
setlocal enabledelayedexpansion

:: Test script for Task 6.1 - Locale manager invocation in install_aab
:: This script verifies that the install_aab subroutine calls locale_manager

echo ========================================
echo Test: Task 6.1 - Locale Manager Invocation
echo ========================================
echo.

:: Check if a device is connected
adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    echo SKIP: No device connected. Cannot test locale_manager invocation.
    echo.
    echo To run this test:
    echo 1. Connect an Android device with USB debugging enabled
    echo 2. Run this test again
    echo.
    pause
    exit /b 0
)

echo Test: Verifying locale_manager is called by install_aab
echo.
echo Creating a dummy AAB file for testing...
echo dummy > test-dummy.aab

echo.
echo Calling install_aab with dummy AAB file...
echo Expected: locale_manager should be called and detect device configuration
echo.
echo ----------------------------------------

:: Call the install_aab subroutine through the main script
:: This will trigger device selection and then install_aab
call adb-wrapper.bat install test-dummy.aab 2>&1 | findstr /C:"Detecting device configuration" /C:"Device DPI" /C:"Device Language"

if errorlevel 1 (
    echo.
    echo FAIL: locale_manager was not called or did not produce expected output
    echo.
) else (
    echo.
    echo ----------------------------------------
    echo.
    echo PASS: locale_manager was successfully invoked by install_aab
    echo.
)

:: Cleanup
del test-dummy.aab 2>nul

pause
exit /b 0
