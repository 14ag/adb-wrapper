@echo off
echo ============================================================================
echo Testing Task 4.2: Package Type Detection Logic
echo ============================================================================
echo.

echo Test 1: Valid APK file (should route to APK installer)
echo -----------------------------------------------------------------------
:: Create a dummy APK file
echo dummy > test-app.apk
call adb-wrapper.bat install test-app.apk
echo.
echo Expected: Routes to APK installer (may fail at device selection if no devices)
echo.

echo Test 2: Valid AAB file (should route to AAB installer)
echo -----------------------------------------------------------------------
:: Create a dummy AAB file
echo dummy > test-app.aab
call adb-wrapper.bat install test-app.aab
echo.
echo Expected: Routes to AAB installer (may fail at device selection if no devices)
echo.

echo Test 3: Invalid extension - ZIP file (should display error)
echo -----------------------------------------------------------------------
:: Create a dummy ZIP file
echo dummy > test-app.zip
call adb-wrapper.bat install test-app.zip
echo.
echo Expected: ERROR message indicating invalid package format
echo.

echo Test 4: Invalid extension - TXT file (should display error)
echo -----------------------------------------------------------------------
:: Create a dummy TXT file
echo dummy > test-app.txt
call adb-wrapper.bat install test-app.txt
echo.
echo Expected: ERROR message indicating invalid package format
echo.

echo Test 5: Case-insensitive APK extension (should route to APK installer)
echo -----------------------------------------------------------------------
:: Create a dummy file with uppercase extension
echo dummy > test-app.APK
call adb-wrapper.bat install test-app.APK
echo.
echo Expected: Routes to APK installer (case-insensitive match)
echo.

echo Test 6: Case-insensitive AAB extension (should route to AAB installer)
echo -----------------------------------------------------------------------
:: Create a dummy file with uppercase extension
echo dummy > test-app.AAB
call adb-wrapper.bat install test-app.AAB
echo.
echo Expected: Routes to AAB installer (case-insensitive match)
echo.

:: Cleanup
del test-app.apk 2>nul
del test-app.aab 2>nul
del test-app.zip 2>nul
del test-app.txt 2>nul
del test-app.APK 2>nul
del test-app.AAB 2>nul

echo ============================================================================
echo Test Complete
echo ============================================================================
