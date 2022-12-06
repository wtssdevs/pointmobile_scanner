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