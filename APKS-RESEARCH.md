# APKS File Format Research

## What is an APKS File?

An **APKS file** (APK Set Archive) is a container format used by bundletool and Google Play to store multiple APK files generated from an Android App Bundle (AAB). The file uses the `.apks` extension and is essentially a ZIP archive containing optimized APK files for different device configurations.

## Key Characteristics

### File Structure
- **Format**: ZIP archive with `.apks` extension
- **Contents**: Multiple APK files optimized for different device configurations
- **Purpose**: Testing and deployment of Android App Bundles before uploading to Google Play

### APK Variants Included
An APKS file typically contains:
- **Base APK**: Core app functionality
- **Configuration APKs**: Split by:
  - Screen density (ldpi, mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
  - CPU architecture (armeabi-v7a, arm64-v8a, x86, x86_64)
  - Language/locale (en, es, fr, etc.)
- **Feature Module APKs**: Dynamic feature modules (if any)

## Bundletool Commands

### 1. Generate APKS from AAB

```bash
bundletool build-apks --bundle=app.aab --output=app.apks
```

**With signing** (required for installation):
```bash
bundletool build-apks \
  --bundle=app.aab \
  --output=app.apks \
  --ks=keystore.jks \
  --ks-pass=file:keystore.pwd \
  --ks-key-alias=MyKeyAlias \
  --key-pass=file:key.pwd
```

**For connected device** (generates only needed APKs):
```bash
bundletool build-apks \
  --bundle=app.aab \
  --output=app.apks \
  --connected-device
```

**For specific device configuration**:
```bash
bundletool build-apks \
  --bundle=app.aab \
  --output=app.apks \
  --device-spec=device-spec.json
```

### 2. Install APKS to Device

```bash
bundletool install-apks --apks=app.apks
```

**With specific device**:
```bash
bundletool install-apks \
  --apks=app.apks \
  --device-id=DEVICE_SERIAL
```

### 3. Extract APKs from APKS

```bash
bundletool extract-apks \
  --apks=app.apks \
  --output-dir=extracted_apks/ \
  --device-spec=device-spec.json
```

### 4. Get Device Specification

```bash
bundletool get-device-spec --output=device-spec.json
```

## Device Specification JSON Format

```json
{
  "supportedAbis": ["arm64-v8a", "armeabi-v7a"],
  "supportedLocales": ["en", "fr"],
  "screenDensity": 640,
  "sdkVersion": 27
}
```

## Installation Process

### How bundletool Installs APKS:

1. **Device Detection**: Queries connected device configuration (DPI, ABI, locale, SDK version)
2. **APK Selection**: Extracts only the APKs needed for that specific device from the APKS archive
3. **Installation**: Installs the selected APKs using ADB install-multiple command
4. **Cleanup**: Temporary files are managed automatically

### What Gets Installed:

For a device with:
- SDK 27 (Android 8.1)
- arm64-v8a architecture
- 640 DPI (xxxhdpi)
- English locale

bundletool will install:
- base.apk (core app)
- base-arm64_v8a.apk (architecture-specific)
- base-xxxhdpi.apk (density-specific)
- base-en.apk (language-specific)

## Use Cases

### 1. Local Testing
- Test AAB before uploading to Google Play
- Verify app works on different device configurations
- Debug split APK issues

### 2. Internal Distribution
- Share pre-release builds with testers
- Test on multiple device types
- Validate dynamic feature modules

### 3. CI/CD Pipelines
- Automated testing on emulators
- Device farm testing
- Regression testing across configurations

## Advantages of APKS Format

1. **Smaller Downloads**: Users only download APKs for their device configuration
2. **Faster Installation**: Only necessary components are installed
3. **Testing Flexibility**: Can test specific device configurations without physical devices
4. **Google Play Simulation**: Mimics how Google Play serves APKs to users

## Comparison: APK vs AAB vs APKS

| Format | Purpose | Size | Installation |
|--------|---------|------|--------------|
| **APK** | Direct install | Large (universal) | Direct via ADB |
| **AAB** | Upload to Play Store | Medium (source) | Cannot install directly |
| **APKS** | Testing/deployment | Variable (optimized) | Via bundletool |

## Important Notes

### Signing Requirements
- APKS files must be signed to install on devices
- Use same keystore as production builds
- Debug signing available for testing (bundletool auto-signs if no keystore provided)

### Compatibility
- Requires Android 5.0+ (API 21) for split APKs
- Android 4.4 and below receive multi-APK (if available)
- bundletool handles compatibility automatically

### File Size
- APKS files contain ALL device configurations
- Larger than individual APKs but smaller than universal APK
- Actual installed size depends on device configuration

## References

- [Official bundletool documentation](https://developer.android.com/tools/bundletool)
- [Android App Bundle format](https://developer.android.com/guide/app-bundle)
- [Testing app bundles](https://developer.android.com/guide/app-bundle/test)
