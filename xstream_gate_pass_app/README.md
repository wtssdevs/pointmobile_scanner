# xstream_gate_pass_app



## Getting Started



cd..
cd..
cd platform-tools_r30.0.5-windows
cd platform-tools

adb reverse tcp:44311 tcp:44311

Run the adb devices command to list all the connected devices
Example output:
List of devices attached
adb devices

emulator-5556 device
emulator-5554 device
Do the reverse command for the specific device you want to run your app on
adb -s emulator-5554 reverse tcp:44311 tcp:44311
adb -s emulator-5556 reverse tcp:44311 tcp:44311
adb -s EUH4C20528000575 reverse tcp:44311 tcp:44311
EUH4C20528000575

# Setup Wifi connection debug
#From a computer, if you have USB access already (no root required)
adb tcpip 5555
adb 192.168.1.65:5555

--Get IP and Port from MObile Device Wifi debugging settings
adb connect 192.168.1.34:5555

### ngrok
command to run ngrok
ngrok http 44311
ngrok http --host-header=localhost https://localhost:44311

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

#
Run ./gradlew app:dependencies to see which:

$ cd android
$ ./gradlew  app:dependencies




# Stacked Commands

Made any changes to the cofiguration
stacked generate