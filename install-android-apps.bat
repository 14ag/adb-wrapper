::from file processing template
:: ==============================================================================
:: File: install-android-apps.bat
:: ------------------------------------------------------------------------------
:: Description:
::     This script processes files and directories. It validates input,
::     checks for file compatibility based on defined extensions, and triggers
::     subroutines for further processing of each file.
::
:: Usage:
::     - Drag and drop a file or folder onto the script,
::       or execute the script and follow the on-screen prompts.
::     - Ensure that the required file extensions (e.g., .txt) are correctly
::       specified.
::
:: Author:
::     Philip
:: Date:
::     1/7/26
::
:: Notes:
::     - This script is designed for batch processing of files in a given directory.
::     - It requires administrative permissions if used on protected folders.
:: ==============================================================================
::---------------------------------------------------------------------------------------------------
@echo off
::============here we go========================^^^^^====


:: user variables
setlocal
set "extensions=.apk .apks"

:: callback script
set "ADB=adb"
set "AAPT2=aapt2"
set "JAVA=java"
set "BUNDLETOOL=C:\Program_Files\adb\bundletool-all-1.18.3_2.jar"


:: functional variables
set "loop=0"
set "currentDirectory=%cd%"
cd /d %currentDirectory%
set "_path=%*"
set "empty_var="


:: validate callback script exists and is executable function goes here
if not defined ADB (
    call :error ADB path is not set edit this script and fill in the ADB variable
    goto :end
)

:getVars
cls
setlocal enabledelayedexpansion
set "adb_device_list="
set "device_count=0"
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices') do (
    if "%%b"=="device" (
        set /a "device_count+=1"
        set "device_!device_count!=%%a"
	 )
)

if %device_count% gtr 0 (

	for /l %%i in (1,1,!device_count!) do (
		if defined adb_device_list (
			set "adb_device_list=!adb_device_list!,!device_%%i!"
		) else (
			set "adb_device_list=!device_%%i!"
		)
	)

	echo !adb_device_list!| findstr "," >nul && (
		call :info more than one device is connected pick one below
		call :selector !adb_device_list!
		set "device_serial=!selector!"
	) || (
		set "device_serial=!adb_device_list!"
	)
		
) else (
	call :error no adb device connected connect a device and enable usb debugging
	goto :end
)

::file validation
set "file="
if not defined _path (
	call :info enter the file or folder to be processed here or
	call :info Press Enter to process all files with the extensions "%extensions%" in the current directory
	set /p "_path=::"
	if not defined _path (
		set "_path=%currentDirectory%"
	)
)

set "_path=%_path:"=%"
for /d %%i in ("%_path%") do set "_path=%%~fi"

if "%_path:~-1%"=="\" (
	set "_path=%_path:~0,-1%"
)

cd "%_path%"

call :file_or_folder "%_path%"
if "%file_or_folder%"=="folder" (
	call :info "%_path%" in use
	cls
	
	:: check for compatible files
	set "found_files=0"
	for %%j in (%extensions%) do (
		dir /b *%%j 2>nul | find "." >nul && set /a "found_files+=1"
	)

	if !found_files! equ 0 (
		call :error No compatible files found in "...%_path:~-10%"
		cls
		goto :getVars
	)

	cls

	for %%j in (%extensions%) do (	
		dir /b *%%j 2>nul
	)

	:: confirm install all files in the current directory
	echo.
	call :reset_choice
	CHOICE /C yn /N /M "\\\\\\\\ continue? [Y]es, [N]o ///////////"
	if errorlevel 2 (
		cls
		goto :getVars
	) else if errorlevel 1 (
		
		cls
		set "ok_count=0"
		set "all_count=0"
		:: install each file in the current directory
		for %%a in (%extensions%) do (
			for /f "delims=" %%b in ('dir /b *%%a') do (
				if not "%%b"=="" (
					call :subRoutine "%%~fb"
					set /a "all_count+=1"
					if not errorlevel 1 set /a "ok_count+=1"
		)   )	) 2>nul
		
		:: show number of files installed successfully
		call :info done. !ok_count!/!all_count! files processed.
	)
) else if "%file_or_folder%"=="file" (
	call :check "%_path%" "%extensions%"
	if not "%check%"=="fail" (
		call :subRoutine "%_path%"
		if not errorlevel 0  (
				call :error /////// failed \\\\\\\
		) else call :info \\\\\\\ done ///////
	)
) else if "%file_or_folder%"=="" (
	call :error "...%_path:~-10%" not found
) 
if errorlevel 1 set "loop=1"
endlocal
goto :end




:subRoutine
set "_target=%~1"
set "package_name="
set "_base_target="
set "_tmp_dir=%~dp0apkinstall_%RANDOM%"

for %%i in ("%_target%") do (
	set "ext=%%~xi"
	set "_target_path=%%~dpi"
)

if /I "%ext%"==".apks" (
	if  defined JAVA (
		if defined BUNDLETOOL (
			if not exist "%temp%\%device_serial%.json" (
				"%JAVA%" -jar "%BUNDLETOOL%"  get-device-spec --device-id="%device_serial%" --output="%temp%\%device_serial%.json"
			)
			md "%_tmp_dir%" >nul 2>&1
			copy "%_target%" "%_tmp_dir%\bundle.zip" >nul 2>&1
			powershell -Command "Expand-Archive -LiteralPath '%_tmp_dir%\bundle.zip' -DestinationPath '%_tmp_dir%' -Force" >nul 2>&1
			for /f "delims=" %%b in ('dir /b /s "%_tmp_dir%\*base*" 2^>nul') do (
				set "_base_target=%%b"
				set "_cleanup=%_tmp_dir%"
			)

			call :package_name "!_base_target!"
			if exist %_cleanup% rd /s /q "%_cleanup%" >nul 2>&1
			call :info installing for !package_name!
			"%JAVA%" -jar "%BUNDLETOOL%" install-apks --apks="%_target%" --device-id="%device_serial%" --device-spec="%temp%\%device_serial%.json"
		) else call :error BUNDLETOOL path is not set edit this script and fill in the BUNDLETOOL variable   
    ) else call :error JAVA path is not set edit this script and fill in the JAVA variable
) 
if /I "%ext%"==".apk" (
		call :package_name "%_target%"
		echo installing !package_name!
		"%ADB%" -s "%device_serial%" install -r "%_target%"
	)
exit /b 0




::-----------------------------------------------------------------------------------------------------------------------------------------------------

::.........additional functions go here.........::
:: Display usage information and instructions here
:usage
exit /b 0

:package_name
:: reads the package name from an apk or apks file using aapt2 dump badging
:: for an apks file it first extracts the splits base master apk then reads that instead
:: returns the package name in variable package_name
:: call :package_name "path to apk or apks file"
set "package_name="
set "_t=%~1"
if defined AAPT2 (
	for /f "tokens=2 delims='" %%n in ('call "%AAPT2%" dump badging "%_t%" ^| findstr /b "package:"') do (
		set "package_name=%%n"
	)
) else (
	call :error AAPT2 path is not set. Using the file name instead
	set "package_name=%_t%"
)

exit /b 0

:::::::::::::::::::::::::::::::::::::::::::helper functions (don't touch)::::::::::::::::::::::::::::::::::::::::::::::

:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0


:error
:: error handling
:: has a beep
:: call :error "error message"
Echo 1n| CHOICE /N >nul 2>&1 & :: BEL
echo error: %*
pause
exit /b 1


:info
:: info handling
:: does not have a beep
:: call :info "info message"
echo.
echo info: %*
exit /b 0


:truncate_str
:: shortens filename to control_extensionl.length() characters 
:: returns shortened filename in variable [truncate_str]
:: filename is the name of the file with extension
:: extension is the extension to be truncated
:: call :truncate_str file.name extension
set "truncate_str="
setlocal enabledelayedexpansion
set "control_extension=%~1"
set "filename=%~2"
for /L %%a in (1,1,10) do (
    if "!control_extension:~%%a!"=="" (
        for /f "tokens=1" %%b in ("-%%a") do (
            for /f "tokens=1 skip=0" %%c in ("!filename:~%%b!") do (
                endlocal & set "truncate_str=%%c"
)   )   )   ) >nul 2>&1

exit /b 0


:file_or_folder
:: checks if a path is a file or folder
:: returns file or folder in variable file_or_folder
:: returns empty string if path does not exist
:: call :file_or_folder "path"
set "file_or_folder="
setlocal enabledelayedexpansion
set "b=%*"
set "b=%b:"=%"
if exist "%b%" (
    for %%I in ("%b%") do (
        set "attrs=%%~aI"
        REM check if the first attribute char is d meaning directory
        if "!attrs:~0,1!" == "d" (
            endlocal & set "file_or_folder=folder"
        ) else (
            endlocal & set "file_or_folder=file"
        )   )
)
exit /b 0


:get_folder_name
:: call :get_folder_name [path]
:: returns the name of the folder whose path was provided in the variable !get_folder_name!
set "myString=%*"
:loop
:: Check if the string contains a backslash
echo "%myString%" | find "\" >nul && (
	:: Strip everything up to the first backslash and repeat
	set "myString=%myString:*\=%"
	goto :loop
) || (
    set "get_folder_name=%myString%"
)
exit /b 0


:validate
:: items_to_test is a single string
:: control is a string of items separated by spaces
:: checks if any item_to_test is in control
:: returns true or false in variable [validate]
:: call :validate "control" %items_to_test%
set "validate="
set "control=%1"
set "item_to_test=%2"
set "items=0"
set "count=0"
for %%i in (%control:"=%) do (
	if not "%item_to_test%"=="%%i" set /a count+=1
	set /a items+=1
)
if %count% geq %items% (
	set "validate=false"
) else (
	set "validate=true"
)
exit /b 0


:selector
:: creates a dynamic list of choices from a command that outputs a list
:: & is just a command separator, while && is a conditional operator
:: call :selector arg1,arg2,arg3,...
setlocal enabledelayedexpansion
set "selector="
set "arg_string=%*"
set "i=0"
set "choicelist="
:: Replace every comma with a quote, a space, and another quote (" ") and Wrap the entire resulting string in quotes
if not defined arg_string goto:break
set "arg_list="%arg_string:,=" "%""
echo Processing arguments:

rem Loop through the new quoted, space-separated list
for %%a in (%arg_list%) do (
	set /a i+=1
	:: Create dynamic variable names (_1, _2, etc.)
	for %%b in (_!i!) do (
		set "%%b=%%a"
		set "choicelist=!choicelist!!i!"
        set "display_value=%%a"
        set "display_value=!display_value:"=!"
		echo   [!i!].. !display_value!
	)   )

call :reset_choice
if %i% gtr 1 (
	choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
) else (
	set "choicelist=1"
)
for /L %%c in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
	if errorlevel %%c (
		for %%d in (!_%%c!) do (
			endlocal & set "selector=%%d"
			goto :break
)   )   )   


:break
set "selector=%selector:"=%"
exit /b 0


:check
:: uses truncate_str, error
:: tests to find out if filename [%1] has any of these extensions [%2]
:: call :check "filename" "extensions"
set "check="
set "filename=%1"
set "extensions=%2"
set "filename=%filename:"=%"
set "extensions=%extensions:"=%"
setlocal enabledelayedexpansion
:: verify file existence & validate its type
if exist "%filename%" (
	::this loops thru each extension
	for %%k in ("%filename%") do (
		for %%j in (%extensions%) do (
			call :truncate_str "%%j" "%%~nxk"
			if /i not "%%j"=="!truncate_str!" (
				call :error not a %%j file.
				endlocal & set "check=fail" & exit /b 0
				) else (
					endlocal & set "check=!truncate_str!" & exit /b 0
) 	)	)
) else if not exist "%filename%" (
	call :error "%filename%" not found
	endlocal & set "check=fail" & exit /b 0
)
exit /b 0


:end
:: this is it guys...
:: loops if drag and drop is not happening
if "%loop%"=="1" (
    pause
    cls
    goto getVars
) else (
    endlocal & exit /b %errorlevel%
)
