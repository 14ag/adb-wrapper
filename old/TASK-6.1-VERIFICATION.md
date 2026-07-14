# Task 6.1 Verification: Locale Manager Invocation

## Task Description
**Task 6.1**: Write locale manager invocation
- Call `:locale_manager` subroutine
- Check errorlevel and abort on failure
- Requirements: 3.1, 3.2, 3.5

## Implementation Summary

The locale manager invocation has been successfully implemented in the `:install_aab` subroutine at lines 217-227 of `adb-wrapper.bat`.

### Code Implementation

```batch
:install_aab
:: Convert AAB to APK set using bundletool and install to device
:: Input: %1 - AAB file path
:: Return: 0 on success, 1 on error
set "aab_file=%~1"

:: Detect device configuration (DPI and language)
call :locale_manager
if errorlevel 1 exit /b 1

exit /b 0
```

## Requirements Validation

### Requirement 3.1: DPI Detection
✅ **SATISFIED** - The `:locale_manager` subroutine queries device DPI using `adb shell getprop ro.sf.lcd_density`

### Requirement 3.2: Language Detection
✅ **SATISFIED** - The `:locale_manager` subroutine queries device language using `adb shell getprop persist.sys.language` with fallback to `ro.product.locale`

### Requirement 3.5: Error Handling on Device Query Failure
✅ **SATISFIED** - The implementation checks `errorlevel` after calling `:locale_manager` and aborts with `exit /b 1` if the locale manager returns an error

## Implementation Details

1. **Subroutine Call**: The `:install_aab` subroutine calls `:locale_manager` using the `call` command
2. **Error Checking**: Immediately after the call, the code checks `if errorlevel 1` to detect failures
3. **Abort on Failure**: If locale_manager fails (returns errorlevel 1), the install_aab subroutine exits with `exit /b 1`, propagating the error up the call stack
4. **Variable Storage**: The aab_file parameter is stored in a local variable for future use in subsequent tasks

## Behavior Flow

When `:install_aab` is invoked:
1. Stores the AAB file path in `%aab_file%` variable
2. Calls `:locale_manager` subroutine
3. `:locale_manager` detects device DPI and language, storing them in `%device_dpi%` and `%device_language%`
4. If detection succeeds, `:locale_manager` returns 0 and execution continues
5. If detection fails, `:locale_manager` returns 1, triggering the error check
6. On error, `:install_aab` immediately exits with code 1, aborting the installation

## Error Scenarios Handled

| Scenario | Detection | Response |
|----------|-----------|----------|
| DPI query fails | `%device_dpi%` is empty | locale_manager displays "ERROR: Failed to detect device DPI" and returns 1 |
| Language query fails | `%device_language%` is empty after fallback | locale_manager displays "ERROR: Failed to detect device language" and returns 1 |
| locale_manager returns error | `errorlevel 1` after call | install_aab aborts with `exit /b 1` |

## Testing Approach

To manually verify this implementation:

1. **Success Case**: Connect a device and run `adb-wrapper.bat install test.aab`
   - Expected: "Detecting device configuration..." message appears
   - Expected: "Device DPI: [value]" and "Device Language: [value]" are displayed
   - Expected: Installation continues (or would continue if bundletool logic was implemented)

2. **Failure Case**: Disconnect device after selection but before locale detection
   - Expected: "ERROR: Failed to detect device DPI" or language error
   - Expected: Script exits with error code 1

## Conclusion

Task 6.1 has been successfully implemented. The `:install_aab` subroutine now:
- ✅ Calls the `:locale_manager` subroutine
- ✅ Checks errorlevel after the call
- ✅ Aborts installation on failure with proper error propagation

The implementation follows the design specification and satisfies all referenced requirements (3.1, 3.2, 3.5).
