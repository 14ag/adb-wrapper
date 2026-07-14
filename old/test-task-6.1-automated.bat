@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Automated Test Script for Task 6.1 - Command-Line Argument Parsing
:: ============================================================================

echo ========================================
echo Test: Task 6.1 - Command-Line Argument Parsing
echo ========================================
echo.

set "test_passed=0"
set "test_failed=0"

:: ============================================================================
:: Test 1: Empty command (no arguments) - should show usage
:: ============================================================================
echo Test 1: Empty command (no arguments)
call adb-wrapper.bat > temp_output.txt 2>&1
findstr /C:"ADB Wrapper System" /C:"Usage:" temp_output.txt >nul
if errorlevel 1 (
    echo FAIL: Usage message not displayed
    set /a "test_failed+=1"
) else (
    echo PASS: Usage message displayed
    set /a "test_passed+=1"
)
echo.

:: ============================================================================
:: Test 2: Install command with APK file
:: ============================================================================
echo Test 2: Install command with APK file
echo dummy > test-dummy.apk

adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    call adb-wrapper.bat install test-dummy.apk > temp_output.txt 2>&1
    findstr /C:"ERROR: No devices connected" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Did not reach device selection
        set /a "test_failed+=1"
    ) else (
        echo PASS: Parsed install + APK file correctly
        set /a "test_passed+=1"
    )
) else (
    call adb-wrapper.bat install test-dummy.apk > temp_output.txt 2>&1
    findstr /C:"Installing" /C:"ERROR" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Did not parse install command
        set /a "test_failed+=1"
    ) else (
        echo PASS: Parsed install + APK file correctly
        set /a "test_passed+=1"
    )
)
echo.

:: ============================================================================
:: Test 3: Install command with APKS file
:: ============================================================================
echo Test 3: Install command with APKS file
echo dummy > test-dummy.apks

adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    call adb-wrapper.bat install test-dummy.apks > temp_output.txt 2>&1
    findstr /C:"ERROR: No devices connected" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Did not reach device selection
        set /a "test_failed+=1"
    ) else (
        echo PASS: Parsed install + APKS file correctly
        set /a "test_passed+=1"
    )
) else (
    call adb-wrapper.bat install test-dummy.apks > temp_output.txt 2>&1
    findstr /C:"Installing" /C:"ERROR" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Did not parse install command
        set /a "test_failed+=1"
    ) else (
        echo PASS: Parsed install + APKS file correctly
        set /a "test_passed+=1"
    )
)
echo.

:: ============================================================================
:: Test 4: Non-install command (passthrough)
:: ============================================================================
echo Test 4: Non-install command (ADB passthrough)
call adb-wrapper.bat devices > temp_output.txt 2>&1
findstr /C:"List of devices attached" /C:"ERROR: No devices connected" temp_output.txt >nul
if errorlevel 1 (
    echo FAIL: Did not pass through to ADB
    set /a "test_failed+=1"
) else (
    echo PASS: Parsed and passed through command
    set /a "test_passed+=1"
)
echo.

:: ============================================================================
:: Cleanup
:: ============================================================================
del test-dummy.apk 2>nul
del test-dummy.apks 2>nul
del temp_output.txt 2>nul

:: ============================================================================
:: Test Summary
:: ============================================================================
echo ========================================
echo Test Summary
echo ========================================
echo Tests Passed: %test_passed%
echo Tests Failed: %test_failed%
echo.

if "%test_failed%"=="0" (
    echo ALL TESTS PASSED
    echo Task 6.1 Verification: SUCCESSFUL
) else (
    echo SOME TESTS FAILED
    echo Task 6.1 Verification: FAILED
)

exit /b %test_failed%
