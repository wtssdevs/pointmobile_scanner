# xstream_gate_pass_app



## Getting Started



cd..
cd..
cd platform-tools_r30.0.5-windows
cd platform-tools

adb reverse tcp:44311 tcp:44311

--CMS
adb reverse tcp:6636 tcp:6636

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
fvm flutter clean
#2
fvm flutter pub get
#3
fvm flutter pub run build_runner build --delete-conflicting-outputs
#4
#Chekc .env file for correct Server API Connection

#5 Build APK/Bundle
fvm flutter build appbundle

#Google APKS drive testing
fvm flutter build apk --debug
fvm flutter build apk --release

#Google Play Store uploading
fvm flutter build appbundle

#
Run ./gradlew app:dependencies to see which:

$ cd android
$ ./gradlew  app:dependencies




# Stacked Commands

Made any changes to the cofiguration
dart pub global activate stacked_cli

stacked generate

stacked create view login

This will create a new View called LoginView with its associated ViewModel in the ui/views folder. This will also create the ViewModel tests file, as well as add the View to the available routes in app.dart file.

The following arguments are available on create view command:

Argument	Alias	Description
--help	-h	Prints this usage information.
--[no-]exclude-route		When a route is excluded it will not be added to your app.dart routes collection.
--[no-]v1		When v1 or use-builder is provided, ViewModelBuilder will be used instead of StackedView.
--template	-t	Selects the type of view to create instead of the default empty view.
--config-path	-c	Sets the file path for the custom config.
--line-length	-l	When a number is provided, it will be used as the line length for formatting code.
Add a new Service
From the root folder of your Stacked application, run the command:

stacked create service stripe


Add a new Bottom Sheet
From the root folder of your Stacked application, run the command:

stacked create bottom_sheet alert

This will create a new BottomSheet called AlertSheet in the ui/bottom_sheets folder and add it to the dependencies in the app.dart file. By default, this will also create a SheetModel and the unit test file. If you only want a BottomSheet without a model and their test you just need to pass the flag --no-model to the command.

The following arguments are available on create bottom_sheet command:

Argument	Alias	Description
--help	-h	Prints this usage information.
--[no-]exclude-route		When a route is excluded it will not be added to your app.dart routes collection.
--[no-]model		When model is provided, StackedView will be used instead of StatelessWidget and a Model will be created. Defaults: true.
--template	-t	Selects the type of bottom sheet to create instead of the default empty bottom sheet.
--config-path	-c	Sets the file path for the custom config.
--line-length	-l	When a number is provided, it will be used as the line length for formatting code.
Add a new Dialog
From the root folder of your Stacked application, run the command:

stacked create dialog error

This will create a new Dialog called ErrorDialog in the ui/dialogs folder and add it to the dependencies in the app.dart file. By default, this will also create a DialogModel and the unit test file. If you only want a Dialog without a model and their test you just need to pass the flag --no-model to the command.

The following arguments are available on create dialog command:

Argument	Alias	Description
--help	-h	Prints this usage information.
--[no-]exclude-route		When a route is excluded it will not be added to your app.dart routes collection.
--[no-]model		When model is provided, StackedView will be used instead of StatelessWidget and a Model will be created. Defaults: true.
--template	-t	Selects the type of dialog to create instead of the default empty dialog.
--config-path	-c	Sets the file path for the custom config.
--line-length	-l	When a number is provided, it will be used as the line length for formatting code.
Add a new Widget
From the root folder of your Stacked application, run the command:

stacked create widget users_list

This will create a new Widget called UsersList with its associated WidgetModel called UsersListModel in the ui/widgets/common/users_list folder. This will also create the WidgetModel test file inside test/widget_models/.

The following arguments are available on create view command:

Argument	Alias	Description
--help	-h	Prints this usage information.
--[no-]model		When model is provided, StackedView will be used instead of StatelessWidget and a Model will be created.
--template	-t	Selects the type of widget to create instead of the default empty widget.
--config-path	-c	Sets the file path for the custom config.
--path	-p	Sets the path for the component.
--line-length	-l	When a number is provided, it will be used as the line length for formatting code.
Generate Code
When you've changed something manually, or added a new model, instead of executing the command flutter pub run build_runner build --delete-conflicting-outputs you can simply run stacked generate.

Update CLI
When you want to update the stacked_cli app, instead of executing the command dart pub global activate stacked_cli you can simply run stacked update.

Use the CLI with Existing Project
Using the Stacked CLI with an existing project takes a little bit more effort than above. There are a few things that you have to ensure:

You need to have your app file in lib/app/app.dart
If you have tests setup as presented in the unit testing videos your helper file should be test/helpers/test_helpers.dart
You tell Stacked where to make the modifications
The way we know where to add modifications into your code is by reading what we call a template identifier. This tells our tools, "At this position you can make a modification". For now, we only have four scaffolding commands:

Create View
This command creates all the scaffolding to add a new View into the project:

Creates a new folder with the View name in lib/ui/views/
Creates the new View and ViewModel files in lib/ui/views/view_name/
Creates the ViewModel tests file in the test/viewmodel_tests/ folder
Adds the route to the lib/app/app.dart file
For us to achieve #4, we need to know where to add the route and its import. To indicate that we use the template identifiers, open your lib/app/app.dart file and under the last import, add:

// @stacked-import

And underneath your last route add:

// @stacked-route

Now if you run stacked create view profile you'll see that all the files are generated AND we also add the route into your app.dart file. The modifications are optional so if you don't have the template identifiers, Stacked will still generate the necessary files but won't automatically add the route to your app.dart file. Everything else will still work though.

Create Service
This command creates all the scaffolding to add a new Service into the project:

Creates a new Service file in lib/services/
Creates the unit tests file in test/services/
Registers the Service with your StackedApp
Adds the Service Mock into the test_helpers and registers it
For us to achieve #3, we need to know where to add the dependency registration. Open your lib/app/app.dart file and under the last dependency registration, add:

// @stacked-service

For us to achieve #4, we need to know where to add the Service Mock. Open your test_helpers.dart file and under all the imports, add:

// @stacked-import

Under your last MockSpec<T>(), add:

// @stacked-mock-spec

Under your last getAndRegisterService that creates a Mock and returns it, add:

// @stacked-mock-create

Under your last Service registration in registerServices, add:

// @stacked-mock-register

Now, when you run stacked create service user, you'll see the files created for the UserService and all the registration will happen automatically.

Create BottomSheet
This command creates all the scaffolding to add a new BottomSheet into the project:

Creates a new folder with the Sheet name in lib/ui/bottom_sheets/
Creates a new Sheet file in lib/ui/bottom_sheets/sheet_name/
Registers the BottomSheet with your StackedApp
For us to achieve #3, we need to know where to add the dependency registration. Open your lib/app/app.dart file and under the last dependency registration inside bottomsheets property of StackedApp, add:

// @stacked-bottom-sheet

Now if you run stacked create bottom_sheet alert you'll see that all the files are generated AND we register the SheetBuilder into BottomSheetService. The modifications are optional so if you don't have the template identifiers, Stacked will still generate the necessary files but won't automatically register the dependencies. Everything else will still work though.

Create Dialog
This command creates all the scaffolding to add a new Dialog into the project:

Creates a new folder with the Dialog name in lib/ui/dialogs/
Creates a new Dialog file in lib/ui/dialogs/dialog_name/
Registers the Dialog with your StackedApp
For us to achieve #3, we need to know where to add the dependency registration. Open your lib/app/app.dart file and under the last dependency registration inside dialogs property of StackedApp, add:

// @stacked-dialog

Now if you run stacked create dialog error you'll see that all the files are generated AND we register the DialogBuilder into DialogService. The modifications are optional so if you don't have the template identifiers, Stacked will still generate the necessary files but won't automatically register the dependencies. Everything else will still work though.

Config
If you want to use stacked_cli in a package that doesn't fit the structure that the CLI expects, then you can configure Stacked to look in the correct places. Create a new file in the root folder of your package called stacked.json. Inside the file, create a JSON body with the following properties:

Property	Description
bottom_sheets_path	The path where BottomSheets will be generated.
dialogs_sheets_path	The path where Dialogs will be generated.
line_length	Passed into the Flutter formatter when running CLI commands.
locator_name	The name of the locator that Services are registered with. This is used when creating a new Service using the create service command.
prefer_web	Determines to use or not web template when no template argument is passed.
register_mocks_function	The name of the function that registers all the Mocks when running a test. This is used when generating a test file during create service command.
services_path	The path where Services will be generated.
stacked_app_file_path	The path to the file that contains the StackedApp setup.
test_helpers_file_path	The path to the file that contains the test helpers (mocks, registerService, etc).
test_services_path	The path where the unit tests of the Services will be generated.
test_views_path	The path where the unit tests of the ViewModels will be generated.
test_widgets_path	The path where the unit tests of the Widgets will be generated.
v1	Indicates whether you want to use ViewModelBuilder (v1) or StackedView (v2).
views_path	The path where Views and ViewModels will be generated.
widgets_path	The path where Widgets and WidgetModels will be generated.
Only include the paths you want to customize. If you exclude a path, the default value will be used for it.

Default Stacked configuration
{
    "bottom_sheets_path": "ui/bottom_sheets",
    "dialogs_path": "ui/dialogs",
    "line_length": 80,
    "locator_name": "locator",
    "prefer_web": true,
    "register_mocks_function": "registerServices",
    "services_path": "services",
    "stacked_app_file_path": "app/app.dart",
    "test_helpers_file_path": "helpers/test_helpers.dart",
    "test_services_path": "services",
    "test_views_path": "viewmodels",
    "test_widgets_path": "widget_models",
    "v1": false,
    "views_path": "ui/views",
    "widgets_path": "ui/widgets/common"