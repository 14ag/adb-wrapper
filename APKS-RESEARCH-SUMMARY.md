# APKS File Research Summary

## Research Completed ✓

### 1. APKS File Format Understanding

**What is APKS?**
- File extension: `.apks`
- Format: ZIP archive containing multiple APK files
- Purpose: Container for device-optimized APKs generated from Android App Bundle (AAB)
- Created by: bundletool (Google's official tool)

**Key Characteristics:**
- Contains split APKs for different configurations (screen density, CPU architecture, language)
- Used for testing AAB files before uploading to Google Play
- Mimics how Google Play serves optimized APKs to users
- Requires bundletool to install (cannot install directly via ADB)

### 2. Installation Process

**How bundletool installs APKS files:**

1. **Device Detection**
   - Queries device configuration (DPI, ABI, locale, SDK version)
   - Uses ADB shell commands to get device properties

2. **APK Selection**
   - Extracts only the APKs needed for the specific device
   - Filters by architecture, density, language, SDK version

3. **Installation**
   - Uses `adb install-multiple` command internally
   - Installs all selected APKs as a single atomic operation

4. **Cleanup**
   - Temporary files are managed automatically

### 3. Bundletool Commands

**Generate APKS from AAB:**
```bash
java -jar bundletool-all-1.18.3_2.jar build-apks \
  --bundle=app.aab \
  --output=app.apks \
  --mode=default
```

**Install APKS to device:**
```bash
java -jar bundletool-all-1.18.3_2.jar install-apks \
  --apks=app.apks \
  --device-id=DEVICE_SERIAL
```

**Get device specification:**
```bash
java -jar bundletool-all-1.18.3_2.jar get-device-spec \
  --output=device-spec.json
```

### 4. File Structure

Typical APKS contents:
```
app.apks (ZIP)
├── toc.pb                    # Table of contents
├── base-master.apk           # Base APK
├── base-arm64_v8a.apk       # Architecture splits
├── base-armeabi_v7a.apk
├── base-xxxhdpi.apk         # Density splits
├── base-xxhdpi.apk
├── base-en.apk              # Language splits
└── base-es.apk
```

## Implementation Impact on ADB Wrapper

### Current Implementation Status

The ADB Wrapper System currently handles:
- ✅ APK files (direct installation via ADB)
- ✅ AAB files (conversion to APKS + installation via bundletool)
- ❌ APKS files (NOT YET IMPLEMENTED)

### Required Changes for APKS Support

**Option 1: Treat APKS like AAB (Recommended)**

Since APKS files are already the output of `bundletool build-apks`, we can:
1. Skip the build-apks step (already done)
2. Go directly to `bundletool install-apks`
3. Use same locale detection for consistency

**Implementation in `:install_handler`:**
```batch
if /i "%ext%"==".apks" (
    call :install_apks_bundle "%package%"
    exit /b %errorlevel%
)
```

**New subroutine `:install_apks_bundle`:**
```batch
:install_apks_bundle
set "apks_file=%~1"

echo.
echo Installing APKS bundle to device %selected_device%...
echo.

:: Install directly using bundletool
java -jar bundletool-all-1.18.3_2.jar install-apks ^
    --apks="%apks_file%" ^
    --device-id=%selected_device%

if errorlevel 1 (
    echo.
    echo ERROR: APKS installation failed on device %selected_device%
    echo.
    exit /b 1
)

echo.
echo SUCCESS: APKS installed successfully on device %selected_device%
echo.

exit /b 0
```

**Option 2: Extract and Install Manually**

More complex, involves:
1. Unzip APKS file
2. Detect device configuration
3. Select appropriate APKs
4. Use `adb install-multiple` to install

This is NOT recommended as it duplicates bundletool's logic.

## Testing Recommendations

### For Testing APKS Support:

1. **Create test APKS from existing AAB:**
   ```bash
   # If you have an AAB file
   java -jar bundletool-all-1.18.3_2.jar build-apks \
     --bundle=test.aab \
     --output=test.apks
   ```

2. **Use Android sample projects:**
   - Clone https://github.com/android/app-bundle-samples
   - Build any sample project to generate AAB
   - Convert to APKS for testing

3. **Create minimal test APK:**
   - Build a simple "Hello World" Android app
   - Generate AAB from Android Studio
   - Use bundletool to create APKS

### Testing Checklist:

- [ ] APKS file is recognized by extension (.apks)
- [ ] Device selector works correctly
- [ ] bundletool install-apks command executes
- [ ] Installation succeeds on connected device
- [ ] Error handling works (file not found, installation failure)
- [ ] Success message displays with device ID
- [ ] Works with multiple devices (device selection)

## Documentation Created

1. **APKS-RESEARCH.md** - Comprehensive technical documentation
   - File format details
   - bundletool commands
   - Installation process
   - Use cases and advantages

2. **APKS-TESTING-GUIDE.md** - Practical testing guide
   - How to create test files
   - Testing scenarios
   - Verification checklist
   - Troubleshooting common issues

3. **APKS-RESEARCH-SUMMARY.md** (this file) - Executive summary
   - Key findings
   - Implementation recommendations
   - Testing approach

## Recommendations

### Immediate Actions:

1. **Add APKS support to install_handler** (Task 4.2 extension)
   - Add `.apks` extension detection
   - Route to new `:install_apks_bundle` subroutine

2. **Implement `:install_apks_bundle` subroutine**
   - Similar to APK installer but uses bundletool
   - No need for locale detection (bundletool handles it)
   - Simpler than AAB installer (no build-apks step)

3. **Update requirements and design documents**
   - Add APKS as supported format
   - Document the installation flow
   - Update test cases

### Future Enhancements:

1. **Unified bundle installer**
   - Combine AAB and APKS handling
   - Detect if APKS already exists for AAB
   - Cache APKS files to avoid regeneration

2. **Advanced options**
   - Support for `--modules` flag (install specific modules)
   - Support for instant app installation
   - Device spec file support

## Conclusion

APKS files are an intermediate format between AAB and final APKs. Supporting them in the ADB Wrapper is straightforward since bundletool provides a direct `install-apks` command. The implementation would be simpler than AAB support (no build-apks step needed) and would provide users with more flexibility in testing app bundles.

**Estimated effort:** 1-2 tasks (similar to APK installer implementation)

**Priority:** Medium (nice-to-have for complete bundle support)

**Complexity:** Low (simpler than AAB, similar to APK)
