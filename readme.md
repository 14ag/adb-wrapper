## apk installer

this is a script that installs apps to your device using [adb](https://developer.android.com/tools/adb) or [bundletool](https://developer.android.com/tools/bundletool)

### prerequisites
- Windows OS
- [adb](https://developer.android.com/tools/adb)
- [bundletool](https://developer.android.com/tools/bundletool)
- [aapt2](https://developer.android.com/tools/aapt2) optional


### usage
1. [download] the latest release
2. connect your device through adb 
3. open `apk` or `apks` file with adb-wrapper.exe

### packaging

- use [bat to exe converter](https://github.com/99fk/Bat-To-Exe-Converter) to convert batch file to exe

- use launcher as the main script, then embed `install-android-apps.bat` 
- 
#### bat to exe converter configuration

- working dorectory: current directory
- exe format: (any) visible
- extract to: temporary directory
- method: syncronous
  