@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Test Script for Task 6.1 - Command-Line Argument Parsing
:: ============================================================================
:: This script verifies that the :main entry point correctly parses
:: command-line arguments as specified in task 6.1:
:: - Parse first argument as command
:: - Parse second argument as package file (for install command)
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
echo Expected: Usage message displayed
echo.

call adb-wrapper.bat > temp_output.txt 2>&1
findstr /C:"ADB Wrapper System" /C:"Usage:" temp_output.txt >nul
if errorlevel 1 (
    echo FAIL: Usage message not displayed for empty command
    set /a "test_failed+=1"
) else (
    echo PASS: Usage message displayed correctly
    set /a "test_passed+=1"
)
echo.

:: ============================================================================
:: Test 2: Install command with APK file
:: ============================================================================
echo Test 2: Install command with APK file
echo Expected: Script attempts to parse 'install' as command and 'test.apk' as package
echo.

:: Create a dummy APK file for testing
echo dummy > test-dummy.apk

:: Check if device is connected
adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    echo SKIP: No device connected. Cannot fully test install command parsing.
    echo      However, we can verify the script accepts the arguments.
    echo.
    
    :: Even without a device, the script should parse arguments and fail at device selection
    call adb-wrapper.bat install test-dummy.apk > temp_output.txt 2>&1
    findstr /C:"ERROR: No devices connected" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Script did not parse arguments correctly (expected device error)
        set /a "test_failed+=1"
    ) else (
        echo PASS: Script parsed 'install' command and 'test-dummy.apk' package correctly
        echo      (Confirmed by reaching device selection stage)
        set /a "test_passed+=1"
    )
) else (
    :: Device is connected - test full flow
    call adb-wrapper.bat install test-dummy.apk > temp_output.txt 2>&1
    
    :: Check if it attempted installation (should fail because dummy file is invalid)
    findstr /C:"Installing" /C:"ERROR" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Script did not parse install command correctly
        set /a "test_failed+=1"
    ) else (
        echo PASS: Script parsed 'install' command and 'test-dummy.apk' package correctly
        set /a "test_passed+=1"
    )
)
echo.

:: ============================================================================
:: Test 3: Install command with APKS file
:: ============================================================================
echo Test 3: Install command with APKS file
echo Expected: Script attempts to parse 'install' as command and 'test.apks' as package
echo.

:: Create a dummy APKS file for testing
echo dummy > test-dummy.apks

adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    echo SKIP: No device connected. Cannot fully test install command parsing.
    echo      However, we can verify the script accepts the arguments.
    echo.
    
    call adb-wrapper.bat install test-dummy.apks > temp_output.txt 2>&1
    findstr /C:"ERROR: No devices connected" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Script did not parse arguments correctly (expected device error)
        set /a "test_failed+=1"
    ) else (
        echo PASS: Script parsed 'install' command and 'test-dummy.apks' package correctly
        echo      (Confirmed by reaching device selection stage)
        set /a "test_passed+=1"
    )
) else (
    call adb-wrapper.bat install test-dummy.apks > temp_output.txt 2>&1
    
    :: Check if it attempted installation
    findstr /C:"Installing" /C:"ERROR" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Script did not parse install command correctly
        set /a "test_failed+=1"
    ) else (
        echo PASS: Script parsed 'install' command and 'test-dummy.apks' package correctly
        set /a "test_passed+=1"
    )
)
echo.

:: ============================================================================
:: Test 4: Non-install command (passthrough)
:: ============================================================================
echo Test 4: Non-install command (ADB passthrough)
echo Expected: Script parses 'devices' as command and passes through to ADB
echo.

call adb-wrapper.bat devices > temp_output.txt 2>&1

:: Check if ADB devices command was executed
findstr /C:"List of devices attached" /C:"ERROR: No devices connected" temp_output.txt >nul
if errorlevel 1 (
    echo FAIL: Script did not parse and pass through non-install command correctly
    set /a "test_failed+=1"
) else (
    echo PASS: Script parsed 'devices' command and passed through to ADB correctly
    set /a "test_passed+=1"
)
echo.

:: ============================================================================
:: Test 5: Install command without package file
:: ============================================================================
echo Test 5: Install command without package file argument
echo Expected: Script should handle missing package file gracefully
echo.

adb devices | findstr "device" | findstr /v "List" >nul
if errorlevel 1 (
    echo SKIP: No device connected. Cannot test missing package file handling.
    echo.
) else (
    call adb-wrapper.bat install > temp_output.txt 2>&1
    
    :: Should get an error about missing or invalid package
    findstr /C:"ERROR" /C:"not found" temp_output.txt >nul
    if errorlevel 1 (
        echo FAIL: Script did not handle missing package file correctly
        set /a "test_failed+=1"
    ) else (
        echo PASS: Script handled missing package file with appropriate error
        set /a "test_passed+=1"
    )
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
    echo ✓ ALL TESTS PASSED
    echo.
    echo Task 6.1 Verification: SUCCESSFUL
    echo The :main entry point correctly parses command-line arguments:
    echo   - First argument is parsed as command
    echo   - Second argument is parsed as package file
    echo.
) else (
    echo ✗ SOME TESTS FAILED
    echo.
    echo Task 6.1 Verification: FAILED
    echo Please review the failed tests above.
    echo.
)

pause
exit /b %test_failed%
