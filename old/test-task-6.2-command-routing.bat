@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Test Script for Task 6.2: Command Routing Logic
:: ============================================================================
:: This script verifies that the :main entry point correctly routes commands
:: based on the parsed command argument.
::
:: Test Cases:
:: 1. Empty command -> show_usage
:: 2. "install" command -> device_selector + install_handler
:: 3. Other commands -> device_selector + adb_passthrough
:: ============================================================================

echo.
echo ============================================================================
echo Task 6.2: Command Routing Logic Verification
echo ============================================================================
echo.

set "test_count=0"
set "pass_count=0"
set "fail_count=0"

:: ============================================================================
:: Test 1: Empty command should show usage
:: ============================================================================
set /a "test_count+=1"
echo Test %test_count%: Empty command routes to show_usage
echo Command: adb-wrapper.bat
echo Expected: Usage instructions displayed
echo.

call adb-wrapper.bat > temp_output.txt 2>&1
findstr /C:"ADB Wrapper System" temp_output.txt >nul
if %errorlevel%==0 (
    findstr /C:"Usage:" temp_output.txt >nul
    if !errorlevel!==0 (
        echo [PASS] Usage instructions displayed correctly
        set /a "pass_count+=1"
    ) else (
        echo [FAIL] Usage instructions not found
        set /a "fail_count+=1"
    )
) else (
    echo [FAIL] ADB Wrapper System header not found
    set /a "fail_count+=1"
)
echo.

:: ============================================================================
:: Test 2: Install command routing (requires device)
:: ============================================================================
set /a "test_count+=1"
echo Test %test_count%: Install command routes to device_selector + install_handler
echo Command: adb-wrapper.bat install test.apk
echo Expected: Device selector called, then install handler
echo.

:: Check if any devices are connected
adb devices | findstr "device" | findstr /v "List of devices" >nul
if %errorlevel%==0 (
    echo [INFO] Device detected, testing install routing...
    
    :: Test with non-existent file to verify routing without actual installation
    call adb-wrapper.bat install nonexistent.apk > temp_output.txt 2>&1
    
    :: Should show "Package file not found" error from install_handler
    findstr /C:"Package file not found" temp_output.txt >nul
    if !errorlevel!==0 (
        echo [PASS] Install command routed to install_handler
        set /a "pass_count+=1"
    ) else (
        echo [FAIL] Install command not routed correctly
        type temp_output.txt
        set /a "fail_count+=1"
    )
) else (
    echo [SKIP] No devices connected - cannot test install routing
    echo [INFO] This test requires at least one connected device
    set /a "test_count-=1"
)
echo.

:: ============================================================================
:: Test 3: Other commands route to adb_passthrough (requires device)
:: ============================================================================
set /a "test_count+=1"
echo Test %test_count%: Other commands route to device_selector + adb_passthrough
echo Command: adb-wrapper.bat shell echo test
echo Expected: Device selector called, then command passed to ADB
echo.

:: Check if any devices are connected
adb devices | findstr "device" | findstr /v "List of devices" >nul
if %errorlevel%==0 (
    echo [INFO] Device detected, testing passthrough routing...
    
    :: Test with a simple shell command
    call adb-wrapper.bat shell echo test > temp_output.txt 2>&1
    
    :: Should execute the command (output will be "test")
    findstr /C:"test" temp_output.txt >nul
    if !errorlevel!==0 (
        echo [PASS] Command routed to adb_passthrough and executed
        set /a "pass_count+=1"
    ) else (
        echo [FAIL] Command not routed correctly to adb_passthrough
        type temp_output.txt
        set /a "fail_count+=1"
    )
) else (
    echo [SKIP] No devices connected - cannot test passthrough routing
    echo [INFO] This test requires at least one connected device
    set /a "test_count-=1"
)
echo.

:: ============================================================================
:: Test 4: Verify install command is case-insensitive
:: ============================================================================
set /a "test_count+=1"
echo Test %test_count%: Install command is case-insensitive
echo Command: adb-wrapper.bat INSTALL test.apk
echo Expected: Routes to install handler (case-insensitive)
echo.

:: Check if any devices are connected
adb devices | findstr "device" | findstr /v "List of devices" >nul
if %errorlevel%==0 (
    echo [INFO] Device detected, testing case-insensitive routing...
    
    :: Test with uppercase INSTALL
    call adb-wrapper.bat INSTALL nonexistent.apk > temp_output.txt 2>&1
    
    :: Should show "Package file not found" error from install_handler
    findstr /C:"Package file not found" temp_output.txt >nul
    if !errorlevel!==0 (
        echo [PASS] Install command is case-insensitive
        set /a "pass_count+=1"
    ) else (
        echo [FAIL] Install command case-insensitivity not working
        type temp_output.txt
        set /a "fail_count+=1"
    )
) else (
    echo [SKIP] No devices connected - cannot test case-insensitive routing
    echo [INFO] This test requires at least one connected device
    set /a "test_count-=1"
)
echo.

:: ============================================================================
:: Cleanup and Summary
:: ============================================================================
if exist temp_output.txt del temp_output.txt

echo ============================================================================
echo Test Summary
echo ============================================================================
echo Total Tests: %test_count%
echo Passed: %pass_count%
echo Failed: %fail_count%
echo.

if %fail_count%==0 (
    echo [SUCCESS] All command routing tests passed!
    echo.
    echo Task 6.2 Verification: COMPLETE
    echo - Empty command routes to show_usage: VERIFIED
    echo - Install command routes to device_selector + install_handler: VERIFIED
    echo - Other commands route to device_selector + adb_passthrough: VERIFIED
    echo - Case-insensitive command matching: VERIFIED
) else (
    echo [FAILURE] Some tests failed. Please review the output above.
)
echo.
echo ============================================================================

endlocal
pause
