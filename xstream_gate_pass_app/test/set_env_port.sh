cd..
cd..
cd platform-tools_r30.0.5-windows
cd platform-tools

adb reverse tcp:6634 tcp:6634


# Setup Wifi connection debug
#From a computer, if you have USB access already (no root required)
adb tcpip 5555
adb connect 192.168.0.30:5555

adb connect 192.168.1.34:5555


##Build Runner Commands
## This creates all the json files and DB schemeaflutte
flutter pub run build_runner build --delete-conflicting-outputs

#STEPS TP FOLLOW FOR APP Build/Uploading to app store
# clean before build to clear all cahce
#1
flutter clean
#2
flutter pub get
#3
flutter pub run build_runner build --delete-conflicting-outputs
#4
#Chekc .env file for correct Server API Connection

#5 Build APK/Bundle
flutter build appbundle

#Google APKS drive testing
flutter build apk --debug
flutter build apk --release

#Google Play Store uploading
flutter build appbundle

#How to add the Point Mobile SDK files & add to path from root project
1. In pubspec.yaml file add in the SDK " pointmobile_scanner:"
2. Un-Comment all the scanning code from the scan manager (ScanningService) "PointmobileScanner"
3. In the android app scr main androidManifest file un-comment the "<uses-library android:name="device.sdk" android:required="true" />"
3.1 android:required="true" is for installing on actual Point Mobile device (not emulator) or if you want to test on emulator then set to "false"