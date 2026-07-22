@echo off
set "_target=C:\Users\philip\sauce\adb-wrapper\New folder (2)\AppManager_v4.1.0.apks"
set "_tmp_dir=%~dp0apkinstall_%RANDOM%"
md "%_tmp_dir%" >nul 2>&1
copy "%_target%" "%_tmp_dir%\bundle.zip" >nul 2>&1
powershell -Command "Expand-Archive -LiteralPath '%_tmp_dir%\bundle.zip' -DestinationPath '%_tmp_dir%' -Force" >nul 2>&1
dir /b /s "%_tmp_dir%\*base*"
for /f "delims=" %%b in ('dir /b /s "%_tmp_dir%\*base*" 2^>nul') do (
    set "_base_target=%%b"
)
echo Base target found: "%_base_target%"
set AAPT2=aapt2
for /f "tokens=2 delims='" %%n in ('call "%AAPT2%" dump badging "%_base_target%" ^| findstr /b "package:"') do (
    set "package_name=%%n"
)
echo Package name: "%package_name%"
