# Implementation Plan: ADB Wrapper System

## Overview

This implementation plan breaks down the ADB Wrapper System into discrete coding tasks. The system will be implemented as a single batch script (`adb-wrapper.bat`) with modular subroutines following the established patterns from `selector.bat` and `adb2.bat`.

The implementation follows a bottom-up approach: building utility functions first, then core components, and finally integrating everything into the main entry point.

## Tasks

- [ ] 1. Create script foundation and utility subroutines
  - [ ] 1.1 Create adb-wrapper.bat with script header and initialization
    - Add `@echo off` and `setlocal enabledelayedexpansion`
    - Set up script structure with labeled sections
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [ ] 1.2 Implement utility subroutines (reset_choice, show_usage)
    - Write `:reset_choice` subroutine to reset errorlevel
    - Write `:show_usage` subroutine with usage instructions and examples
    - _Requirements: 6.2, 6.4, 7.1_

- [ ] 2. Implement device selector component
  - [ ] 2.1 Write device enumeration logic
    - Query ADB devices using `adb devices` command
    - Parse output and create dynamic device variables (device_1, device_2, etc.)
    - Count total devices and store in device_count variable
    - _Requirements: 1.1, 1.5, 6.7_
  
  - [ ] 2.2 Implement device selection logic
    - Handle zero devices case with error message
    - Auto-select single device without user prompt
    - Display numbered menu for multiple devices using choice command
    - Store selected device ID in selected_device variable
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 6.6, 7.1, 7.2, 7.5_

- [ ] 3. Implement locale manager component
  - [ ] 3.1 Write DPI detection logic
    - Query device DPI using `adb shell getprop ro.sf.lcd_density`
    - Store result in device_dpi variable
    - Validate DPI value is not empty
    - _Requirements: 3.1, 3.3, 7.1, 7.2_
  
  - [ ] 3.2 Write language detection logic
    - Query device language using `adb shell getprop persist.sys.language`
    - Implement fallback to `ro.product.locale` if primary query fails
    - Parse locale to extract language code
    - Store result in device_language variable
    - Validate language value is not empty
    - _Requirements: 3.2, 3.4, 7.1, 7.2_
  
  - [ ] 3.3 Add console output for detected configuration
    - Display detected DPI and language to user
    - Use blank lines for readability
    - _Requirements: 7.4, 7.5_

- [ ] 4. Implement install handler component
  - [ ] 4.1 Write package validation logic
    - Check if package file exists
    - Display error if file not found
    - _Requirements: 2.1, 7.1, 7.5_
  
  - [ ] 4.2 Write package type detection logic
    - Extract file extension using `%~x1` syntax
    - Perform case-insensitive comparison for .apk and .aab
    - Route to appropriate installer based on extension
    - Display error for invalid extensions
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 7.1, 7.5_

- [ ] 5. Implement APK installer component
  - [ ] 5.1 Write APK installation logic
    - Execute `adb -s %selected_device% install -r` command
    - Check errorlevel for installation failure
    - Display success or error message with device ID
    - _Requirements: 2.2, 7.1, 7.2, 7.4, 7.5_

- [ ] 6. Implement AAB installer component
  - [ ] 6.1 Write locale manager invocation
    - Call `:locale_manager` subroutine
    - Check errorlevel and abort on failure
    - _Requirements: 3.1, 3.2, 3.5_
  
  - [ ] 6.2 Write language list construction logic
    - Set languages to "en" by default
    - Add device_language if different from English
    - Avoid duplication when device is English
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [ ] 6.3 Write bundletool build-apks execution
    - Execute `java -jar bundletool-all-1.18.3_2.jar build-apks`
    - Pass bundle, output, mode, and device-id parameters
    - Use line continuation for readability
    - Check errorlevel for bundletool failure
    - Display error message on failure
    - _Requirements: 4.1, 4.2, 7.1, 7.3, 7.5_
  
  - [ ] 6.4 Write bundletool install-apks execution
    - Execute `java -jar bundletool-all-1.18.3_2.jar install-apks`
    - Pass apks and device-id parameters
    - Check errorlevel for installation failure
    - Display error message with device ID on failure
    - _Requirements: 4.3, 4.4, 7.1, 7.2, 7.5_
  
  - [ ] 6.5 Implement cleanup logic
    - Delete temp_apks.apks file after installation
    - Ensure cleanup happens even on error
    - Suppress error output from del command
    - _Requirements: 4.4_
  
  - [ ] 6.6 Add console output for AAB installation
    - Display installation progress messages
    - Show configuration (DPI and languages) being used
    - Display success message on completion
    - _Requirements: 7.4, 7.5_

- [ ] 7. Implement main entry point and command routing
  - [ ] 7.1 Write command-line argument parsing
    - Parse first argument as command
    - Parse second argument as package file (for install command)
    - _Requirements: 6.2_
  
  - [ ] 7.2 Write command routing logic
    - Route "install" command to device selector and install handler
    - Route empty command to show_usage
    - Route all other commands to adb_passthrough
    - _Requirements: 6.2, 6.4_
  
  - [ ] 7.3 Implement ADB passthrough subroutine
    - Pass all arguments directly to ADB with selected device
    - Preserve errorlevel from ADB command
    - _Requirements: 6.4_

- [ ] 8. Checkpoint - Integration testing and validation
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 9. Create integration test script
  - [ ]* 9.1 Write test cases for device selection scenarios
    - Test no devices connected (error case)
    - Test single device (auto-select)
    - Test multiple devices (manual selection)
    - _Requirements: 1.2, 1.3, 1.4_
  
  - [ ]* 9.2 Write test cases for package type detection
    - Test .apk file routing
    - Test .aab file routing
    - Test invalid extension error
    - Test missing file error
    - _Requirements: 2.2, 2.3, 2.4_
  
  - [ ]* 9.3 Write test cases for locale detection
    - Test DPI detection on connected device
    - Test language detection on connected device
    - Test fallback language detection mechanism
    - _Requirements: 3.1, 3.2_
  
  - [ ]* 9.4 Write test cases for installation workflows
    - Test APK installation end-to-end
    - Test AAB installation with bundletool
    - Test error handling for failed installations
    - _Requirements: 2.2, 2.3, 4.1, 4.3_

- [ ] 10. Final checkpoint - Ensure all functionality works
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- The implementation follows the modular subroutine pattern from existing codebase
- Batch script uses labeled sections (`:label_name`) for all subroutines
- Error handling is implemented at each step with descriptive messages
- Console output uses `echo.` for blank lines to improve readability
- The script uses `setlocal enabledelayedexpansion` for dynamic variable handling
- Device selection uses the `choice` command pattern from `selector.bat`
- All subroutines use `exit /b` with appropriate return codes
