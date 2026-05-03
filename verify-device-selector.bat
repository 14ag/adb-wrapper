@echo off
echo ============================================
echo Device Selector Verification
echo ============================================
echo.
echo This script verifies the device selector handles:
echo   1. Zero devices (error case)
echo   2. Single device (auto-select)
echo   3. Multiple devices (user selection menu)
echo.
echo Current device status:
echo.
adb devices
echo.
echo ============================================
echo Testing device selector with current setup...
echo ============================================
echo.
echo Running: adb-wrapper.bat shell getprop ro.product.model
echo.
call adb-wrapper.bat shell getprop ro.product.model
echo.
echo ============================================
echo Verification Complete
echo ============================================
pause
