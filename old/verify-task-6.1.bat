@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Task 6.1 Verification: Command-Line Argument Parsing
:: ============================================================================
:: Verifies that the :main entry point correctly parses:
:: - First argument as command
:: - Second argument as package file (for install command)
:: 
:: Requirements: 4.2 (Use labels for subroutines and control flow)
:: ============================================================================

echo ========================================
echo Task 6.1 Verification
echo Command-Line Argument Parsing
echo ========================================
echo.

set "all_passed=1"

:: ============================================================================
:: Verification 1: Code inspection - parsing logic exists
:: ============================================================================
echo [1] Verifying parsing logic exists in :main section...

findstr /C:"set \"command=%%~1\"" adb-wrapper.bat >nul
if errorlevel 1 (
    echo    FAIL: First argument parsing not found
    set "all_passed=0"
) else (
    echo    PASS: First argument parsed as command
)

findstr /C:"set \"package_file=%%~2\"" adb-wrapper.bat >nul
if errorlevel 1 (
    echo    FAIL: Second argument parsing not found
    set "all_passed=0"
) else (
    echo    PASS: Second argument parsed as package_file
)
echo.

:: ============================================================================
:: Verification 2: Empty command test
:: ============================================================================
echo [2] Testing empty command (no arguments)...
echo    Expected: Usage message displayed

call adb-wrapper.bat > temp_test.txt 2>&1
findstr /C:"ADB Wrapper System" /C:"Usage:" temp_test.txt >nul
if errorlevel 1 (
    echo    FAIL: Usage not displayed for empty command
    set "all_passed=0"
) else (
    echo    PASS: Empty command handled correctly
)
echo.

:: ============================================================================
:: Verification 3: Install command with package file
:: ============================================================================
echo [3] Testing install command with package file...
echo    Expected: Script parses both arguments and proceeds to device selection

echo dummy > test-verify.apk

call adb-wrapper.bat install test-verify.apk > temp_test.txt 2>&1

:: Check if it reached device selection (proves arguments were parsed)
findstr /C:"ERROR: No devices connected" /C:"Multiple devices detected" /C:"Installing" temp_test.txt >nul
if errorlevel 1 (
    echo    FAIL: Arguments not parsed correctly
    type temp_test.txt
    set "all_passed=0"
) else (
    echo    PASS: Install command and package file parsed correctly
    echo         (Confirmed by reaching device selection/installation stage)
)

del test-verify.apk 2>nul
echo.

:: ============================================================================
:: Verification 4: Command routing uses parsed arguments
:: ============================================================================
echo [4] Verifying command routing logic uses parsed command variable...

findstr /C:"if \"%%command%%\"==\"\"" adb-wrapper.bat >nul
if errorlevel 1 (
    echo    FAIL: Command routing does not use parsed command variable
    set "all_passed=0"
) else (
    echo    PASS: Command routing uses parsed command variable
)

findstr /C:"if /i \"%%command%%\"==\"install\"" adb-wrapper.bat >nul
if errorlevel 1 (
    echo    FAIL: Install routing does not use parsed command variable
    set "all_passed=0"
) else (
    echo    PASS: Install routing uses parsed command variable
)

findstr /C:"call :install_handler \"%%package_file%%\"" adb-wrapper.bat >nul
if errorlevel 1 (
    echo    FAIL: Install handler does not receive parsed package_file
    set "all_passed=0"
) else (
    echo    PASS: Install handler receives parsed package_file
)
echo.

:: ============================================================================
:: Verification 5: Requirement 4.2 compliance
:: ============================================================================
echo [5] Verifying Requirement 4.2 compliance...
echo    (Labels used for subroutines and control flow)

findstr /C:":main" adb-wrapper.bat >nul
if errorlevel 1 (
    echo    FAIL: :main label not found
    set "all_passed=0"
) else (
    echo    PASS: :main label exists for entry point
)

findstr /C:"goto :main" adb-wrapper.bat >nul
if errorlevel 1 (
    echo    FAIL: goto :main not found
    set "all_passed=0"
) else (
    echo    PASS: Control flow uses goto :main
)
echo.

:: ============================================================================
:: Cleanup
:: ============================================================================
del temp_test.txt 2>nul

:: ============================================================================
:: Final Result
:: ============================================================================
echo ========================================
echo Verification Result
echo ========================================

if "%all_passed%"=="1" (
    echo.
    echo ✓ TASK 6.1 VERIFIED SUCCESSFULLY
    echo.
    echo The :main entry point correctly implements command-line argument parsing:
    echo   • First argument is parsed as command using set "command=%%~1"
    echo   • Second argument is parsed as package_file using set "package_file=%%~2"
    echo   • Parsed variables are used in command routing logic
    echo   • Implementation follows Requirement 4.2 (label-based control flow)
    echo.
    exit /b 0
) else (
    echo.
    echo ✗ TASK 6.1 VERIFICATION FAILED
    echo.
    echo Please review the failed checks above.
    echo.
    exit /b 1
)
