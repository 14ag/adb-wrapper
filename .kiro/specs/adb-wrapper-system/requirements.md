# Requirements Document

## Introduction

The ADB Wrapper System is a batch script-based tool that simplifies Android Debug Bridge (ADB) operations by automatically routing commands to the correct device when multiple devices are connected, intelligently handling APK and APKS installations using bundletool, and ensuring proper locale configuration during app installation.

## Glossary

- **ADB_Wrapper**: The main batch script system that wraps ADB commands
- **Device_Selector**: The component that detects and allows selection of connected Android devices
- **Install_Handler**: The component that manages app installation for both APK and APKS formats
- **Bundletool**: A command-line tool (bundletool-all-1.18.3_2.jar) that installs APKS files to devices
- **APK**: Android Package file format (direct install)
- **APKS**: APK Set Archive file format (contains multiple APKs, requires bundletool installation)
- **DPI**: Dots Per Inch, the screen density of the Android device
- **Device_Language**: The primary language configured on the Android device

## Requirements

### Requirement 1: Device Detection and Selection

**User Story:** As a developer, I want the system to automatically detect connected devices and route commands appropriately, so that I don't have to manually specify device IDs for each command.

#### Acceptance Criteria

1. WHEN the ADB_Wrapper is invoked, THE Device_Selector SHALL enumerate all connected Android devices
2. IF no devices are connected, THEN THE Device_Selector SHALL display an error message and exit
3. WHEN exactly one device is connected, THE Device_Selector SHALL automatically select that device without user interaction
4. WHEN multiple devices are connected, THE Device_Selector SHALL present a numbered list of devices and prompt the user to select one
5. THE Device_Selector SHALL store the selected device ID for use by subsequent operations

### Requirement 2: Installation Package Type Detection

**User Story:** As a developer, I want the system to automatically detect whether I'm installing an APK or APKS file, so that the correct installation method is used without manual intervention.

#### Acceptance Criteria

1. WHEN an installation is requested, THE Install_Handler SHALL examine the file extension of the provided package
2. IF the package has an ".apk" extension, THEN THE Install_Handler SHALL use standard ADB install commands
3. IF the package has an ".apks" extension, THEN THE Install_Handler SHALL use bundletool for installation
4. IF the package has neither ".apk" nor ".apks" extension, THEN THE Install_Handler SHALL display an error message indicating invalid package format

### Requirement 3: Bundletool Integration

**User Story:** As a developer, I want APKS files to be automatically installed using bundletool to the correct device, so that I can install app bundle sets as easily as APK files.

#### Acceptance Criteria

1. WHEN an APKS installation is requested, THE Install_Handler SHALL invoke bundletool-all-1.18.3_2.jar
2. THE Install_Handler SHALL pass the selected device ID to bundletool
3. THE Install_Handler SHALL direct bundletool to install the APKS file to the selected device
4. IF bundletool execution fails, THEN THE Install_Handler SHALL display the error output and exit

### Requirement 4: Batch Script Implementation Style

**User Story:** As a developer, I want the system to follow established batch scripting conventions from the existing codebase, so that the code is maintainable and consistent with other scripts.

#### Acceptance Criteria

1. THE ADB_Wrapper SHALL use `@echo off` at the beginning of each script file
2. THE ADB_Wrapper SHALL use labels (`:label_name`) for subroutines and control flow
3. THE ADB_Wrapper SHALL use `setlocal enabledelayedexpansion` when working with dynamic variables
4. THE ADB_Wrapper SHALL use `exit /b` to return from subroutines
5. THE ADB_Wrapper SHALL include inline comments explaining complex logic
6. THE ADB_Wrapper SHALL use the `choice` command for user selection menus
7. THE ADB_Wrapper SHALL use dynamic variable naming patterns (e.g., `device_1`, `device_2`) for list management

### Requirement 5: Error Handling and User Feedback

**User Story:** As a developer, I want clear error messages and feedback during operations, so that I can quickly identify and resolve issues.

#### Acceptance Criteria

1. WHEN an error occurs, THE ADB_Wrapper SHALL display a descriptive error message to the console
2. WHEN a device operation fails, THE ADB_Wrapper SHALL include the device ID in the error message
3. WHEN bundletool fails, THE ADB_Wrapper SHALL display the bundletool error output
4. WHEN an installation succeeds, THE ADB_Wrapper SHALL display a success confirmation message
5. THE ADB_Wrapper SHALL use `echo.` to insert blank lines for improved readability of console output
