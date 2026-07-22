@echo off
set AAPT2=aapt2
set "_t=C:\Users\philip\sauce\adb-wrapper\New folder (2)\AppManager_v4.1.0.apk"
for /f "tokens=2 delims='" %%n in ('call "%AAPT2%" dump badging "%_t%" ^| findstr /b "package:"') do echo %%n
