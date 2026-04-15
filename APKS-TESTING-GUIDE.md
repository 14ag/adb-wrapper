# APKS File Testing Guide

## Overview

This guide explains how to test APKS files with the ADB Wrapper System.

## What You Need

1. **bundletool-all-1.18.3_2.jar** - Already in workspace ✓
2. **Java Runtime** - Required to run bundletool
3. **ADB** - Android Debug Bridge (must be in PATH)
4. **Connected Android Device** - With USB debugging enabled
5. **Sample APKS file** - For testing

## Creating a Test APKS File

Since we don't have a sample AAB file, here are options to get test files:

### Option 1: Download Sample from GitHub

The Android team provides sample app bundles:
```bash
git clone https://github.com/android/app-bundle-samples
cd app-bundle-samples/InstantApps
# Build the sample to generate AAB
./gradlew bundleRelease
```

### Option 2: Use Existing APK to Create Test APKS

If you have any APK file, you can create a simple APKS for testing:

1. Create a minimal APKS structure manually (for testing wrapper logic only)
2. Use bundletool to generate from an AAB

### Option 3: Download Pre-built Sample

Download a sample app from APKMirror or similar sources, then use bundletool to create APKS.

## Testing the ADB Wrapper with APKS

### Test Scenario 1: Install APKS File

```bash
# Using the wrapper (once implemented)
adb-wrapper.bat install sample-app.apks

# Expected behavior:
# 1. Device selector runs
# 2. Locale manager detects DPI and language
# 3. Bundletool extracts appropriate APKs
# 4. Installation proceeds
```

### Test Scenario 2: Multiple Devices

```bash
# Connect 2+ devices
adb devices

# Run wrapper
adb-wrapper.bat install sample-app.apks

# Expected: Device selection menu appears
```

### Test Scenario 3: Error Handling

```bash
# Test with non-existent file
adb-wrapper.bat install nonexistent.apks
# Expected: "ERROR: Package file not found"

# Test with invalid format
adb-wrapper.bat install test.zip
# Expected: "ERROR: Invalid package format"
```

## Manual APKS Installation (Reference)

### Using bundletool directly:

```bash
# Generate APKS from AAB
java -jar bundletool-all-1.18.3_2.jar build-apks \
  --bundle=app.aab \
  --output=app.apks \
  --mode=default

# Install to connected device
java -jar bundletool-all-1.18.3_2.jar install-apks \
  --apks=app.apks
```

### With device specification:

```bash
# Get device spec
java -jar bundletool-all-1.18.3_2.jar get-device-spec \
  --output=device-spec.json

# Build for specific device
java -jar bundletool-all-1.18.3_2.jar build-apks \
  --bundle=app.aab \
  --output=app.apks \
  --device-spec=device-spec.json

# Install
java -jar bundletool-all-1.18.3_2.jar install-apks \
  --apks=app.apks
```

## APKS File Structure

An APKS file is a ZIP archive containing:

```
app.apks (ZIP archive)
├── toc.pb                          # Table of contents
├── base-master.apk                 # Base APK
├── base-arm64_v8a.apk             # Architecture split
├── base-armeabi_v7a.apk           # Architecture split
├── base-x86.apk                   # Architecture split
├── base-x86_64.apk                # Architecture split
├── base-ldpi.apk                  # Density split
├── base-mdpi.apk                  # Density split
├── base-hdpi.apk                  # Density split
├── base-xhdpi.apk                 # Density split
├── base-xxhdpi.apk                # Density split
├── base-xxxhdpi.apk               # Density split
├── base-en.apk                    # Language split
├── base-es.apk                    # Language split
└── base-fr.apk                    # Language split
```

## Extracting APKS Contents

To inspect an APKS file:

```bash
# Rename to .zip
copy app.apks app.zip

# Extract with any ZIP tool
unzip app.zip -d extracted/

# Or use 7-Zip on Windows
7z x app.apks -oextracted/
```

## Verification Checklist

After implementing APKS support in the wrapper:

- [ ] APKS file is recognized by extension
- [ ] Locale manager detects device configuration
- [ ] Bundletool is invoked correctly
- [ ] APKs are installed successfully
- [ ] Error messages are clear
- [ ] Cleanup happens after installation
- [ ] Works with multiple devices
- [ ] Handles installation failures gracefully

## Common Issues

### Issue 1: "java not recognized"
**Solution**: Install Java JRE/JDK and add to PATH

### Issue 2: "bundletool not found"
**Solution**: Ensure bundletool-all-1.18.3_2.jar is in same directory as wrapper

### Issue 3: "Installation failed"
**Solution**: Check device storage, USB debugging, and app permissions

### Issue 4: "Device not found"
**Solution**: Enable USB debugging, accept RSA key prompt on device

## Next Steps

1. Complete implementation of AAB installer tasks (6.2-6.6)
2. Obtain sample APKS file for testing
3. Test with real device
4. Verify all error scenarios
5. Document any edge cases discovered

## Resources

- [bundletool GitHub](https://github.com/google/bundletool)
- [Android App Bundle documentation](https://developer.android.com/guide/app-bundle)
- [Testing app bundles](https://developer.android.com/guide/app-bundle/test)
