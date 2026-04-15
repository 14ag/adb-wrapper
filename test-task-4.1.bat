@echo off
echo ============================================================================
echo Testing Task 4.1: Package Validation Logic
echo ============================================================================
echo.

echo Test 1: Package file not found (should display error)
echo -----------------------------------------------------------------------
call adb-wrapper.bat install nonexistent-file.apk
echo.
echo Expected: ERROR message indicating file not found
echo.

echo Test 2: Package file exists (should proceed without error at this stage)
echo -----------------------------------------------------------------------
:: Create a dummy test file
echo dummy > test-dummy.apk
call adb-wrapper.bat install test-dummy.apk
echo.
echo Expected: No file-not-found error (may fail at device selection if no devices)
echo.

:: Cleanup
del test-dummy.apk 2>nul

echo ============================================================================
echo Test Complete
echo ============================================================================
