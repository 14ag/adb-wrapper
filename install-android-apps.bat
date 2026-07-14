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
@REM @echo off

::====================================^^^^^====


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
set "currentDirectory=%~dp0"
set "_path=%~1"
set "empty_var="


:: validate callback script exists and is executable function goes here
if not defined ADB (
    call :error ADB path is not set edit this script and fill in the ADB variable
    goto :end
)


::check if theres need to show usage in single instance mode
call :validate "'%_path%'" '%empty_var%'
if "%validate%"=="true" call :usage

::file validation
if "%_path%"=="" (
	set "loop=1" 
	goto :getFile
) 

goto :file_or_folder0


:getVars
cls
:: sets loop to happen if drag and drop is not happening
set "loop=1"


:getFile
call :info enter the file or folder to be processed here or
call :info Press Enter to process all files with the extensions "%extensions%" in the current directory
set "_path="
set /p "_path=::"
if not defined _path (
	set "_path=%currentDirectory:"=%"
) else if defined _path (
		set "_path=%_path:"=%"
	)


:file_or_folder0
set "workingDirectory="
set "file="
call :file_or_folder "%_path%"
if "%file_or_folder%"=="folder" (
	set "workingDirectory="%_path%""
	goto :directory_processing
) else if "%file_or_folder%"=="file" (
	set "file="%_path%""
	goto :fileProcessing
) else if "%file_or_folder%"=="" (
	call :error "...%_path:~-10%" not found
	goto :getFile
) else goto :getFile

:directory_processing
cls
call :info "%workingDirectory%" in use
set "workingDirectory=%workingDirectory:"=%"
if "%workingDirectory:~-1%"=="\" (
	set "workingDirectory=%workingDirectory:~0,-1%"
	)

:: check for compatible files
cd %workingDirectory%
set "found_files=0"
for %%j in (%extensions%) do (
    dir /b *%%j 2>nul | find "." >nul && set /a "found_files+=1"
	)

if %found_files% equ 0 (
    call :error No compatible files found in "...%workingDirectory:~-10%"
	pause
	cls
    goto :getFile
	)

cls
for %%j in (%extensions%) do (
	dir /b *%%j
	)


setlocal enabledelayedexpansion
:: confirm install all files in the current directory
echo.
call :reset_choice
CHOICE /C yn /N /M "\\\\\\\\ continue? [Y]es, [N]o ///////////"
if %errorlevel% equ 2 (
	cls
	goto :getVars
) else if %errorlevel% equ 1 (
	cls
	set "ok_count=0"
	set "all_count=0"
	:: install each file in the current directory
	for %%j in (%extensions%) do (
		for /r "%workingDirectory%" %%i in (*%%j) do (
		    call :subRoutine "%%~i"
			set /a "all_count+=1"
			if !errorlevel! equ 0 set /a "ok_count+=1"
		)   )
	:: show number of files installed successfully
	call :info done. !ok_count!/!all_count! files processed.
	endlocal
	goto :end
) else exit /b 1


:fileProcessing
call :check %file% "%extensions%"
if "%check%"=="fail" goto :getFile
call :subRoutine %file%
if errorlevel 0 (
	call :info \\\\\\\ done ///////
	) else if not errorlevel 0 (
		call :error /////// failed \\\\\\\
		)
goto :end




:subRoutine
set "x=%*"
call :main %x%
exit /b %errorlevel%



:main
set "program_full_path=%*"
:: call :info Processing %program_full_path%...
for %%i in ("%program_full_path:"=%") do (
	set "ext=%%~xe"
	)
if /I "%ext%"==".apk" (
    "%ADB%" -s "%device_serial%" install -r %program_full_path%
) else if /I "%ext%"==".apks" (
    if not defined JAVA (
        call :error JAVA path is not set edit this script and fill in the JAVA variable
        goto :end
    )
	if not defined BUNDLETOOL (
    	call :error BUNDLETOOL path is not set edit this script and fill in the BUNDLETOOL variable
    	goto :end
    )
	"%JAVA%" -jar "%BUNDLETOOL%" install-apks --apks=%program_full_path% --device-id="%device_serial%"
)
exit /b %errorlevel%



::---------------------------------------------------------------------------------------------------

::.........additional functions go here.........::
:: Display usage information and instructions here

:adb_device_list
:: builds a comma separated list of every connected adb device serial
:: stores each serial in a dynamic indexed variable the same way as adb_device_selector.bat
:: returns the comma separated list in variable adb_device_list
:: returns an empty string when no device is connected
:: call :adb_device_list
set "adb_device_list="
setlocal enabledelayedexpansion
set "device_count=0"
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices') do (
    if "%%b"=="device" (
        set /a "device_count+=1"
        set "device_!device_count!=%%a"
	    )
	)
for /l %%i in (1,1,!device_count!) do (
    if defined adb_device_list (
        set "adb_device_list=!adb_device_list!,!device_%%i!"
    ) else (
        set "adb_device_list=!device_%%i!"
   	 	)
	)
endlocal & set "adb_device_list=%adb_device_list%"
exit /b 0


:apk_name
:: reads the package name from an apk or apks file using aapt2 dump badging
:: for an apks file it first extracts the splits base master apk then reads that instead
:: returns the package name in variable apk_name
:: call :apk_name "path to apk or apks file"
if not defined AAPT2 (
    call :error AAPT2 path is not set. Using the file name instead
	set "apk_name=%~1"
    exit /b 0
)
set "apk_name="
set "_target=%~1"
set "_cleanup="
if /I "%~x1"==".apks" (
    set "_tmp_dir=%TEMP%\apkinstall_%RANDOM%"
    md "%_tmp_dir%" >nul 2>&1
    powershell -NoProfile -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[System.IO.Compression.ZipFile]::OpenRead('%~1'); $e=$z.Entries | Where-Object { $_.FullName -eq 'splits/base-master.apk' }; if ($e) { [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e,'%_tmp_dir%\base.apk',$true) }; $z.Dispose()" >nul 2>&1
    if exist "%_tmp_dir%\base.apk" (
        set "_target=%_tmp_dir%\base.apk"
        set "_cleanup=%_tmp_dir%"
    	)
	)
for /f "tokens=2 delims='" %%n in ('"%AAPT2%" dump badging "%_target%" ^| findstr /b "package:"') do (
    if not defined apk_name set "apk_name=%%n"
	)
if defined _cleanup rd /s /q "%_cleanup%" >nul 2>&1
exit /b 0


:device_dpi
:: reads the physical screen density of the connected device
:: returns device_dpi
:: call :device_dpi
set "device_dpi="
for /f "tokens=2 delims=:" %%d in ('"%ADB%" -s "%device_serial%" shell wm density ^| findstr /b "Physical density"') do (
    set "device_dpi=%%d"
	)
set "device_dpi=%device_dpi: =%"
exit /b 0


:device_locale
:: reads the current locale of the connected device
:: returns device_locale
:: call :device_locale
set "device_locale="
for /f %%l in ('"%ADB%" -s "%device_serial%" shell getprop persist.sys.locale') do (
    set "device_locale=%%l"
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
set "control_extension=%1"
set "filename=%2"
for /L %%a in (1,1,10) do (
    if "!control_extension:~%%a!"=="" (
        for /f "tokens=1" %%b in ("-%%a") do (
            for /f "tokens=1 skip=0" %%c in ("!filename:~%%b!") do (
                endlocal & set "truncate_str=%%c"
            )   )   )   ) >nul 2>&1
echo %truncate_str% ============================================================================================================================

exit /b 0


:file_or_folder
:: checks if [%1] is a file or folder
:: returns "file" or "folder" in variable [file_or_folder]
:: file_or_folder is the path to the file or folder
::call :file_or_folder file_or_folder
set "file_or_folder="
setlocal enabledelayedexpansion
set "b=%*"
set "b=%b:"=%"
if exist "%b%" (
	for %%I in ("%b%") do (
		set "attrs=%%~aI"
		:: Check if the first attribute is 'd' (directory)
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
if "%count%" geq "%items%" (
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
choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
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
			call :truncate_str %%j %%~nxk
			if /i not "%%j"=="!truncate_str!" (
				call :error not a %%j file.
				endlocal & set "check=fail" 
				) else (
					endlocal & set "check=pass"
				) 	)	)
) else if not exist "%filename%" (
	call :error "%filename%" not found
	endlocal & set "check=fail"
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
