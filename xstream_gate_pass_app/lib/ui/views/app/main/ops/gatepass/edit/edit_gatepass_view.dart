import 'dart:io';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart';

import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/modal_lookup/modal_sheet_selection.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_Info_item.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_info_card.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_scanning_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/foreign_license_photo_card.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/visitor_status_Icon.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/Widgets/gate_pass_status_chip_widget.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view_model.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/listicons/gatepass_list_icon.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/manual_input_field_widget.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/photo_preview_widget.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/nav_action_button.dart';

class GatePassEditView extends StatelessWidget {
  final GatePassAccess gatePass;
  GatePassEditView({Key? key, required this.gatePass}) : super(key: key);

  final TextEditingController vehicleRegNumberTextController =
      TextEditingController();
  final FocusNode vehicleRegNumberTextFocusNode = FocusNode();

  final TextEditingController vehicleRegNumberValiTextController =
      TextEditingController();
  final FocusNode vehicleRegNumberValiTextFocusNode = FocusNode();

  final TextEditingController trailerNo1TextController =
      TextEditingController();
  final FocusNode trailerNo1TextFocusNode = FocusNode();

  final TextEditingController trailerNo2TextController =
      TextEditingController();
  final FocusNode trailerNo2TextFocusNode = FocusNode();

  final TextEditingController driverIDTextController = TextEditingController();
  final FocusNode driverIDTextFocusNode = FocusNode();

  final TextEditingController driverLisenceNoTextController =
      TextEditingController();
  final FocusNode driverLisenceNoTextFocusNode = FocusNode();

  final TextEditingController driverNameTextController =
      TextEditingController();
  final FocusNode driverdriverNameTextFocusNode = FocusNode();

  final TextEditingController driverGenderTextController =
      TextEditingController();
  final FocusNode driverdriverGenderTextFocusNode = FocusNode();

  final TextEditingController driverLicenseTypeTextController =
      TextEditingController();
  final FocusNode driverLicenseTypeTextFocusNode = FocusNode();
  final FocusNode containerNumberTextFocusNode = FocusNode();

  final formKeyAtGate = GlobalKey<FormState>();
  onModelSet(GatePassAccess data) {
    //vehicleRegNumberTextController.text = data.vehicleRegNumber ?? "";
    //trailerNo1TextController.text = data.trailerRegNumberOne ?? "";
    //trailerNo2TextController.text = data.trailerRegNumberTwo ?? "";
    driverNameTextController.text = data.driverName ?? "";

    driverIDTextController.text = data.driverIdNo ?? "";
    driverLisenceNoTextController.text = data.driverLicenceNo ?? "";
  }

  Future<bool> validateByFormKey(GlobalKey<FormState> formKey,
      BuildContext context, GatePassEditViewModel model) async {
    var isvalid = formKey.currentState!.validate();
    if (isvalid && model.showValidation == false) {
      formKey.currentState!.save();
      return true;
    } else {
      model.notifyListeners();
      return false;
    }
  }

  Future<bool> validateForAuthEntry(
      GatePassEditViewModel model, BuildContext context) async {
    //validate per status
    if (model.isManualInput) {
      if (model.isManualEntryWizard &&
          !model.isExitMode &&
          model.gatePass.gatePassBookingType != GatePassBookingType.visitor &&
          !model.manualEntryScanComplete) {
        Fluttertoast.showToast(
            msg:
                "Complete driver, vehicle and trailer scans (Transporter/Container Info) before authorizing entry",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_LEFT,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
        return false;
      }
    }
    if (model.isManualInput) {
      if (model.gatePass.vehicleRegNumber == null &&
          model.gatePass.vehicleRegNumberValidation == null) {
        model.setValidationMessage("Vehicle registration is required");
      } else {
        model.clearValidationMessage("Vehicle registration is required");
        if (model.gatePass.vehicleRegNumber == null &&
            model.gatePass.vehicleRegNumberValidation != null) {
          model.gatePass.vehicleRegNumber =
              model.gatePass.vehicleRegNumberValidation;
        }
      }

      if (model.gatePass.driverName == null) {
        model.setValidationMessage("Driver name is required");
      } else {
        model.clearValidationMessage("Driver name is required");
      }

      if (model.gatePass.gatePassBookingType != GatePassBookingType.visitor) {
        if (model.gatePass.transporterId == null) {
          model.setValidationMessage("Transporter is required");
        } else {
          model.clearValidationMessage("Transporter is required");
        }

        if (model.gatePass.driverIdNo == null &&
            model.gatePass.driverIdNoValidation == null) {
          model.setValidationMessage("Driver ID is required");
        } else {
          model.clearValidationMessage("Driver ID is required");
          // Copy scanned data to main field if not set
          if (model.gatePass.driverIdNo == null &&
              model.gatePass.driverIdNoValidation != null) {
            model.gatePass.driverIdNo = model.gatePass.driverIdNoValidation;
          }
        }
      }

      if (model.showValidation) {
        model.rebuildUi();
        Fluttertoast.showToast(
            msg:
                "Validation Failed! ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ''}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_LEFT,
            timeInSecForIosWeb: 8,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
        return false;
      }

      return true;
    }

    if (model.gatePass.gatePassBookingType == GatePassBookingType.visitor) {
      if (model.gatePass.vehicleRegNumber == null) {
        model.setValidationMessage("Vehicle Reg Number is required");
      } else {
        model.clearValidationMessage("Vehicle Reg Number is required");
      }

      if (model.gatePass.driverName == null) {
        model.setValidationMessage("Driver Name is required");
      } else {
        model.clearValidationMessage("Driver Name is required");
      }
      if (model.gatePass.driverIdNo == null) {
        model.setValidationMessage("Driver ID Number is required");
      } else {
        model.clearValidationMessage("Driver ID Number is required");
      }

      if (model.showValidation) {
        model.rebuildUi();
        Fluttertoast.showToast(
            msg:
                "Validation Failed!,Please correct all missing information. ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ""} ",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_LEFT,
            timeInSecForIosWeb: 8,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
        return false;
      }

      return true;
    }

//GatePassBookingType.breakBulk || GatePassBookingType.containers
    if (model.gatePass.vehicleRegNumber == null) {
      model.setValidationMessage("Vehicle Reg Number is required");
    } else {
      model.clearValidationMessage("Vehicle Reg Number is required");
    }

    if (model.gatePass.driverName == null) {
      model.setValidationMessage("Driver Name is required");
    } else {
      model.clearValidationMessage("Driver Name is required");
    }
    if (model.gatePass.driverIdNo == null) {
      model.setValidationMessage("Driver ID Number is required");
    } else {
      model.clearValidationMessage("Driver ID Number is required");
    }

    // Foreign license photo validation
    if (model.gatePass.driverHasForeignID == true &&
        !model.foreignLicensePhotoTaken) {
      model.setValidationMessage("Foreign license photo is required");
    } else {
      model.clearValidationMessage("Foreign license photo is required");
    }

    if (model.gatePass.driverHasForeignID == false) {
      model.setDriverValidationMessage();
    }

    if (model.vehicleManualEntryUsed && !model.vehicleManualPhotoTaken) {
      model.setValidationMessage("Photo required for manual input Vehicle");
    } else {
      model.clearValidationMessage("Photo required for manual input Vehicle");
    }

    if (model.trailerOneManualEntryUsed && !model.trailerOneManualPhotoTaken) {
      model.setValidationMessage("Photo required for manual input Trailer One");
    } else {
      model.clearValidationMessage(
          "Photo required for manual input Trailer One");
    }

    if (model.trailerTwoManualEntryUsed && !model.trailerTwoManualPhotoTaken) {
      model.setValidationMessage("Photo required for manual input Trailer Two");
    } else {
      model.clearValidationMessage(
          "Photo required for manual input Trailer Two");
    }
    // Validate Trailer One if it exists
    if (model.gatePass.trailerRegNumberOne != null &&
        model.gatePass.trailerRegNumberOne!.isNotEmpty) {
      model.setTrailerValidationMessage("One");

      if (model.gatePass.trailerRegNumberOneMatch == false &&
          !model.trailerOneManualEntryUsed) {
        model.setValidationMessage(
            "Trailer One registration must be scanned or manually entered");
      } else {
        model.clearValidationMessage(
            "Trailer One registration must be scanned or manually entered");
      }
    }
    if (model.gatePass.trailerRegNumberTwo != null &&
        model.gatePass.trailerRegNumberTwo!.isNotEmpty) {
      model.setTrailerValidationMessage("Two");

      if (model.gatePass.trailerRegNumberTwoMatch == false &&
          !model.trailerTwoManualEntryUsed) {
        model.setValidationMessage(
            "Trailer Two registration must be scanned or manually entered");
      } else {
        model.clearValidationMessage(
            "Trailer Two registration must be scanned or manually entered");
      }
    }
    model.setVehicleValidationMessage();

    if (model.showValidation) {
      model.rebuildUi();
      Fluttertoast.showToast(
          msg:
              "Validation Failed!,Please correct all missing information. ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ""} ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
      return false;
    }

    return !model.showValidation;
  }

  Future<bool> validateForAuthExit(
      GatePassEditViewModel model, BuildContext context) async {
    model.clearAllValidationMessage();

    if (model.gatePass.driverHasForeignID == true) {
      if (!model.foreignLicensePhotoTaken) {
        model.setValidationMessage(
            "Foreign license photo verification required for exit");
      } else {
        model.clearValidationMessage(
            "Foreign license photo verification required for exit");
      }
    } else {
      if (!model.driverScannedOnExit) {
        model.setValidationMessage("Please scan the driver's license");
      } else {
        model.clearValidationMessage("Please scan the driver's license");
      }
    }

    // Check if vehicle was scanned on exit
    if (!model.vehicleScannedOnExit) {
      model.setValidationMessage("Please scan the vehicle license disc");
    } else {
      model.clearValidationMessage("Please scan the vehicle license disc");
    }

    // Check if trailer one needs to be scanned
    if (model.gatePass.trailerRegNumberOne != null &&
        model.gatePass.trailerRegNumberOne!.isNotEmpty) {
      if (!model.trailerOneScannedOnExit) {
        model.setValidationMessage("Please scan Trailer One license disc");
      } else {
        model.clearValidationMessage("Please scan Trailer One license disc");
      }
    }

    // Check if trailer two needs to be scanned
    if (model.gatePass.trailerRegNumberTwo != null &&
        model.gatePass.trailerRegNumberTwo!.isNotEmpty) {
      if (!model.trailerTwoScannedOnExit) {
        model.setValidationMessage("Please scan Trailer Two license disc");
      } else {
        model.clearValidationMessage("Please scan Trailer Two license disc");
      }
    }

    if (model.showValidation) {
      model.rebuildUi();

      Fluttertoast.showToast(
          msg:
              "Exit Validation Failed! ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ""} ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);

      return false;
    }

    return true;
  }

  Future<bool> validateForm(
      GatePassEditViewModel model, BuildContext context) async {
    //validate per status

    if (model.gatePass.gatePassBookingType == GatePassBookingType.visitor) {
      if (model.gatePass.vehicleRegNumber == null) {
        model.setValidationMessage("Vehicle Reg Number is required");
      } else {
        model.clearValidationMessage("Vehicle Reg Number is required");
      }

      if (model.gatePass.driverName == null) {
        model.setValidationMessage("Driver Name is required");
      } else {
        model.clearValidationMessage("Driver Name is required");
      }
      if (model.gatePass.driverIdNo == null) {
        model.setValidationMessage("Driver ID Number is required");
      } else {
        model.clearValidationMessage("Driver ID Number is required");
      }

      if (model.showValidation) {
        model.rebuildUi();
        Fluttertoast.showToast(
            msg:
                "Validation Failed!,Please correct all missing information. ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ""} ",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_LEFT,
            timeInSecForIosWeb: 8,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
        return false;
      }

      return true;
    }

//GatePassBookingType.breakBulk || GatePassBookingType.containers
    if (model.gatePass.vehicleRegNumber == null) {
      model.setValidationMessage("Vehicle Reg Number is required");
    } else {
      model.clearValidationMessage("Vehicle Reg Number is required");
    }

//split between foreign license and normal drivers lisence
    if (model.gatePass.driverHasForeignID == true &&
        !model.foreignLicensePhotoTaken) {
      model.setValidationMessage("Foreign license photo is required");
    } else {
      model.clearValidationMessage("Foreign license photo is required");
    }

    if (model.gatePass.driverName == null) {
      model.setValidationMessage("Driver Name is required");
    } else {
      model.clearValidationMessage("Driver Name is required");
    }
    if (model.gatePass.driverIdNo == null) {
      model.setValidationMessage("Driver ID Number is required");
    } else {
      model.clearValidationMessage("Driver ID Number is required");
    }

    if (model.showValidation) {
      model.rebuildUi();
      Fluttertoast.showToast(
          msg:
              "Validation Failed!,Please correct all missing information. ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ""} ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
      return false;
    }

    return !model.showValidation;

    // var isValid = false;
    // switch (model.gatePass.gatePassStatus) {
    //   case GatePassStatus.atGate: //GatePassStatus.atGate.value:
    //   case 2: //GatePassStatus.atGate.value:
    //   case 3: //GatePassStatus.atGate.value:
    //   case 4: //GatePassStatus.atGate.value:
    //     isValid = await validateByFormKey(formKeyAtGate, context, model);
    //     if (isValid) {
    //       //model.authorizeEntry();
    //     } else {
    //       Fluttertoast.showToast(msg: "Validation Failed!,Please correct all missing information. ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ""} ", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
    //     }
    //     break;
    //   default:
    // }

    //  return isValid;
  }

  void updateModelData(GatePassEditViewModel model) {
    //gatePass.approvedQuantity = double.tryParse(approvedQuantityTextController.text) ?? 0;
    gatePass.vehicleRegNumber = vehicleRegNumberTextController.text;
    gatePass.trailerRegNumberOne = trailerNo1TextController.text;
    gatePass.trailerRegNumberTwo = trailerNo2TextController.text;

    gatePass.driverName = driverNameTextController.text;
    gatePass.driverIdNo = driverIDTextController.text;
    gatePass.driverLicenceNo = driverLisenceNoTextController.text;

    model.setModeldata(gatePass);
  }

  bool _validateRegistration(String value) {
    if (value.isEmpty) return false;

    // Remove any spaces and convert to uppercase
    final cleanValue = value.replaceAll(' ', '').toUpperCase();

    // South African registration formats:

    // Format 1: CA123456 (2 letters, 6 digits) - Old format
    final format1 = RegExp(r'^[A-Z]{2}\d{6}$');

    // Format 2: ABC123GP (2-3 letters, 2-4 digits, 2 letters) - Provincial format
    // Covers: ABC123GP, DW65SFGP, etc.
    final format2 = RegExp(r'^[A-Z]{2,3}\d{2,4}[A-Z]{2}$');

    // Format 3: CB12CDGP (2 letters, 2 digits, 2 letters, 2 letters) - New alphanumeric
    final format3 = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{2}[A-Z]{2}$');

    // Format 4: AA12345 (2 letters, 5 digits) - Standard format
    final format4 = RegExp(r'^[A-Z]{2}\d{5}$');

    // Format 5: ABC123 (3 letters, 3 digits) - Older town format
    final format5 = RegExp(r'^[A-Z]{3}\d{3}$');

    // Format 6: A123456 (1 letter, 6 digits) - Very old format
    final format6 = RegExp(r'^[A-Z]\d{6}$');

    // Format 7: Personalized (1-7 characters, letters and numbers)
    final format7 = RegExp(r'^[A-Z0-9]{1,7}$');

    return format1.hasMatch(cleanValue) ||
        format2.hasMatch(cleanValue) ||
        format3.hasMatch(cleanValue) ||
        format4.hasMatch(cleanValue) ||
        format5.hasMatch(cleanValue) ||
        format6.hasMatch(cleanValue) ||
        format7.hasMatch(cleanValue);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.95;
    final dropdownMaxHeight =
        (MediaQuery.of(context).size.height * 0.3).clamp(180.0, 280.0).toDouble();
    return ViewModelBuilder<GatePassEditViewModel>.reactive(
      onViewModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.listenToModelSet(onModelSet);
        model.runStartupLogic();
        if (gatePass.id == 0) {
          FocusScope.of(context).requestFocus(vehicleRegNumberTextFocusNode);
        }
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => PopScope(
        onPopInvokedWithResult: (r, d) async {
          model.routePop();
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
    persistentFooterButtons: [
  Row(
    children: [
      NavActionButton(
        label: "Reject Entry",
        icon: FontAwesomeIcons.ban,
        color: Colors.red,
        onTap: () async {
          if (model.gatePass.id != Guid.defaultValue.toString() &&
              model.gatePass.id != "") {
            model.rejectEntry();
          }
        },
        isVisible: !model.isExitMode &&
            !model.isBusy &&
            (model.gatePass.gatePassStatus.value ==
                    GatePassStatus.atGate.value ||
                model.gatePass.gatePassStatus.value ==
                    GatePassStatus.pending.value),
      ),
      NavActionButton(
        label: "Authorize Entry",
        icon: FontAwesomeIcons.rightToBracket,
        color: Colors.blue,
        onTap: () async {
          var isValid = await validateForAuthEntry(model, context);
          if (isValid == true) {
            model.authorizeEntry();
          } else {
            model.scrollController.animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          }
        },
        isVisible: !model.isBusy &&
            (model.gatePass.gatePassStatus.value ==
                    GatePassStatus.atGate.value ||
                model.gatePass.gatePassStatus.value ==
                    GatePassStatus.pending.value),
      ),
      NavActionButton(
        label: "Authorize Exit",
        icon: FontAwesomeIcons.rightFromBracket,
        color: Colors.green,
        onTap: () async {
          var isValid = await validateForAuthExit(model, context);
          if (isValid == true) {
            model.authorizeExit();
          } else {
            model.scrollController.animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          }
        },
        isVisible: !model.isBusy &&
            model.gatePass.gatePassStatus.value == GatePassStatus.inYard.index,
      ),
    ],
  ),
],
            appBar: AppBar(
              elevation: 6,

              title: ListTile(
                dense: true,
                horizontalTitleGap: 0.0,
                contentPadding: const EdgeInsets.only(
                    left: 0.0, right: 0.0, top: 0, bottom: 0),
                title: BoxText.label(model.gatePass.transactionNo ?? "",
                    color: Colors.black),
                subtitle: BoxText.label(model.gatePass.voyageNo ?? "",
                    color: Colors.black),
                trailing: GateStatusChip(
                    gatePassStatus: model.gatePass.gatePassStatus),
              ),
              titleSpacing: 0.0,
              centerTitle: true,

              //actions: [
              // Visibility(
              //   visible: model.gatePass.id != 0,
              //   child: IconButton(
              //     onPressed: () async {
              //       await validateForm(model, context);
              //     },
              //     icon: const Icon(
              //       Icons.save,
              //       color: kcButtonPrimarySaveColor,
              //       size: 32,
              //     ),
              //   ),
              // ),
              // ElevatedButton.icon(
              //   onPressed: () async {
              //     // valiate first
              //     var isValid = await validateForm(model, context);
              //     if (isValid == true) {
              //       model.saveOnly();
              //     }
              //   },
              //   icon: const FaIcon(
              //     FontAwesomeIcons.floppyDisk,
              //     color: Colors.green,
              //   ),
              //   label: const Text("Save"), // <-- Text
              // ),
              // ],
              bottom: TabBar(
                onTap: (index) {
                  model.onTabBarTap(index);
                },
                isScrollable: false,
                padding: const EdgeInsets.all(0),
                indicatorColor: kcTabBarIndicatorColor,
                labelStyle: tabBarHeadingTextStyle,
                tabs: [
                  Tab(
                    iconMargin: const EdgeInsets.all(0),
                    icon: const FaIcon(FontAwesomeIcons.listCheck),
                    text: model.translate("GatePassAccess"),
                  ),
                  const Tab(
                    iconMargin: EdgeInsets.all(0),
                    icon: Icon(Icons.camera_alt_outlined),
                    text: "Images",
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  //GATE ACCESS
                  Scaffold(
                    floatingActionButton: Visibility(
                      visible: model.gatePass.gatePassBookingType ==
                          GatePassBookingType.containers,
                      child: FloatingActionButton(
                        onPressed: () => model.goToCamCaptureContainerNoText(),
                        child: const Icon(Icons.camera),
                      ),
                    ),
                    body: SingleChildScrollView(
                        controller: model.scrollController,
                        child: model.gatePass.gatePassBookingType ==
                                    GatePassBookingType.visitor ||
                                model.gatePass.gatePassBookingType ==
                                    GatePassBookingType.staff
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (model.showValidation) ...[
                                    verticalSpaceSmall,
                                    BuildErrorsView(
                                      validationMessages:
                                          model.validationMessages,
                                    ),
                                  ],
                                  verticalSpaceSmall,
                                  BuildInfoCard(
                                    width: width,
                                    title: "Visitor Drivers Lisence Card",
                                    isSelected: model.barcodeScanType ==
                                        BarcodeScanType.driversCard,
                                    onTap: () {
                                      model.setBarcodeScanType(
                                          BarcodeScanType.driversCard);
                                    },
                                    hasInfo: model.gatePass.hasDriverInfo,
                                    icon: Icons.credit_card,
                                    color: Colors.blue,
                                    infoList: [
                                      BuildInfoItem(
                                          label: 'Driver Name',
                                          value: model.gatePass.driverName ??
                                              'Not Scanned'),
                                      BuildInfoItem(
                                          label: 'ID Number',
                                          value: model.gatePass.driverIdNo ??
                                              'Not Scanned'),
                                      BuildInfoItem(
                                          label: 'License No',
                                          value:
                                              model.gatePass.driverLicenceNo ??
                                                  'Not Scanned'),
                                    ],
                                  ),
                                  verticalSpaceSmall,
                                  BuildInfoCard(
                                    width: width,
                                    title: "Vehicle Lisence Disc",
                                    isSelected: model.barcodeScanType ==
                                        BarcodeScanType.vehicleDisc,
                                    onTap: () {
                                      model.setBarcodeScanType(
                                          BarcodeScanType.vehicleDisc);
                                    },
                                    hasInfo: model.gatePass.hasVehicleInfo,
                                    icon: Icons.directions_car,
                                    color: Colors.green,
                                    infoList: [
                                      BuildInfoItem(
                                          label: 'Registration',
                                          value:
                                              model.gatePass.vehicleRegNumber ??
                                                  'Not Scanned'),
                                      BuildInfoItem(
                                          label: 'Make',
                                          value: model.gatePass.vehicleMake ??
                                              'Not Scanned'),
                                    ],
                                  ),
                                  verticalSpaceSmall,
                                  BuildInfoCard(
                                    width: width,
                                    title: "Times",
                                    isSelected:
                                        model.gatePass.timeAtGate != null &&
                                            model.gatePass.timeIn != null,
                                    hasInfo: true,
                                    icon: Icons.timelapse_sharp,
                                    color: Colors.amber[300]!,
                                    infoList: [
                                      BuildInfoItem(
                                          label: 'Time At Gate',
                                          value: model.gatePass.timeAtGate
                                                  ?.toSocialMediaTime() ??
                                              ''),
                                      BuildInfoItem(
                                          label: 'Time In',
                                          value: model.gatePass.timeIn
                                                  ?.toSocialMediaTime() ??
                                              ''),
                                      BuildInfoItem(
                                          label: 'Time Out',
                                          value: model.gatePass.timeOut
                                                  ?.toSocialMediaTime() ??
                                              ''),
                                    ],
                                  ),
                                  model.gatePass.serviceTypeId != null
                                      ? Text(
                                          '(${model.serviceTypes.firstWhere((element) => element.value == model.gatePass.serviceTypeId).label})',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (model.showValidation) ...[
                                    verticalSpaceSmall,
                                    BuildErrorsView(
                                      validationMessages:
                                          model.validationMessages,
                                    ),
                                  ],
                                  verticalSpaceSmall,
                                  BuildInfoCard(
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
                                    title: "Main Information",
                                    isSelected: true,
                                    hasInfo: model.gatePass != null,
                                    icon: Icons.list_alt_outlined,
                                    color: Colors.green,
                                    infoList: [
                                      BuildInfoItem(
                                        label: model
                                            .translate("GatePassDeliveryType"),
                                        value: model
                                            .gatePass.gatePassDeliveryType.text,
                                        validationStatus:
                                            ValidationStatus.passed,
                                        passedIcon: model.gatePass
                                                    .gatePassDeliveryType ==
                                                DeliveryType.receive
                                            ? const Icon(
                                                FontAwesomeIcons
                                                    .arrowsDownToLine,
                                                color: Colors.green)
                                            : const Icon(
                                                FontAwesomeIcons.arrowsUpToLine,
                                                color: Colors.red,
                                              ),
                                      ),
                                      BuildInfoItem(
                                        label: model
                                            .translate("GatePassBookingType"),
                                        value: model
                                            .gatePass.gatePassBookingType.text,
                                        validationStatus:
                                            ValidationStatus.passed,
                                        passedIcon: model.gatePass
                                                    .gatePassBookingType ==
                                                GatePassBookingType.containers
                                            ? const Icon(
                                                Icons
                                                    .check_box_outline_blank_sharp,
                                                color: Colors.blue,
                                              )
                                            : Icon(
                                                model.gatePass
                                                    .gatePassBookingType.icon,
                                                color: model.gatePass
                                                            .gatePassBookingType ==
                                                        GatePassBookingType
                                                            .containers
                                                    ? Colors.blue
                                                    : Colors.brown,
                                              ),
                                      ),
                                      BuildInfoItem(
                                        label: model.translate("TransactionNo"),
                                        value:
                                            model.gatePass.transactionNo ?? '',
                                      ),
                                      BuildInfoItem(
                                          label: model.translate("RefNo"),
                                          value: model.gatePass.refNo ?? ''),
                                      BuildInfoItem(
                                          label:
                                              model.translate("CustomerRefNo"),
                                          value: model.gatePass.customerRefNo ??
                                              ''),
                                      BuildInfoItem(
                                          label: model.translate("TicketNo"),
                                          value: model.gatePass.ticketNo ?? ''),
                                      BuildInfoItem(
                                          label: model.translate("VoyageNo"),
                                          value: model.gatePass.voyageNo ?? ''),
                                    ],
                                  ),
                                  verticalSpaceTiny,
                                  //*********Drivers TEMP Lisence Card******** */
                                  //new widget for driver  foreign lisence ID
                                  ForeignLicensePhotoCard(
                                    isVisible:
                                        model.gatePass.driverHasForeignID ==
                                            true,
                                    width: width,
                                    isPhotoTaken:
                                        model.foreignLicensePhotoTaken,
                                    fileStore: model.foreignLicensePhotoPath,
                                    onTap: () {
                                      model.captureForeignLicensePhoto();
                                    },
                                    onViewAllImages: () {
                                      model.viewAllForeignLicensePhotos();
                                    },
                                    infoList: [
                                      BuildInfoItem(
                                          label: 'Driver Name',
                                          value: model.gatePass.driverName ??
                                              'Missing Information'),
                                      BuildInfoItem(
                                          label: 'ID Number',
                                          value: model.gatePass.driverIdNo ??
                                              'Missing Information'),
                                    ],
                                  ),

                                  !model.gatePass.hasDriverInfo ||
                                          !model.gatePass.hasVehicleInfo
                                      ? BuildScanningView(
                                          barcodeScanType:
                                              model.barcodeScanType)
                                      : const SizedBox.shrink(),
                                  verticalSpaceSmall,

                                  //*********Drivers Lisence Card******** */
                                  BuildInfoCard(
                                    isVisible:
                                        model.gatePass.driverHasForeignID ==
                                            false,
                                    key: model.driverInfoCardKey,
                                    width: width,
                                    title: "Drivers Lisence Card",
                                    isSelected: model.barcodeScanType ==
                                        BarcodeScanType.driversCard,
                                    onTap: () {
                                      model.setBarcodeScanType(
                                          BarcodeScanType.driversCard);
                                    },
                                    hasInfo: model.gatePass.hasDriverInfo &&
                                        model.gatePass.driverIdNoMatch,
                                    icon: Icons.credit_card,
                                    color: Colors.blue,
                                    infoList: [
                                      BuildInfoItem(
                                          label: 'Driver Name',
                                          value: model.gatePass.driverName ??
                                              'Not Scanned'),
                                      //BuildInfoItem(label: 'ID Number', value: model.gatePass.driverIdNo ?? 'Not Scanned'),

                                      BuildInfoItem(
                                        label: 'ID Number',
                                        value: model.gatePass.driverIdNo ??
                                            'Not Scanned',
                                        validationStatus: model.gatePass
                                                        .driverIdNoValidation !=
                                                    null &&
                                                model.gatePass
                                                        .driverIdNoMatch ==
                                                    false
                                            ? ValidationStatus.failed
                                            : null,
                                        validationMessage: 'ID Number mismatch',
                                      ),
                                      //BuildInfoItem(label: 'Registration', value: model.gatePass.vehicleRegNumber ?? 'Not Scanned'),
                                      model.gatePass.driverIdNoValidation !=
                                                  null &&
                                              model.gatePass.driverIdNoMatch ==
                                                  false
                                          ? BuildInfoItem(
                                              label: 'Mismatch',
                                              value: model.gatePass
                                                      .driverIdNoValidation ??
                                                  'ID Number mismatch',
                                              validationStatus:
                                                  ValidationStatus.failed,
                                            )
                                          : const SizedBox.shrink(),

                                      BuildInfoItem(
                                          label: 'License No',
                                          value:
                                              model.gatePass.driverLicenceNo ??
                                                  'Not Scanned'),
                                      BuildInfoItem(
                                          label: 'License Expiry',
                                          value: model.gatePass
                                                  .driverLicenceExpiryDate
                                                  ?.toLocal()
                                                  .toFormattedString() ??
                                              'Not Scanned'),
                                    ],
                                  ),

                                  verticalSpaceSmall,
                                  BuildInfoCard(
                                    key: model.vehicleInfoCardKey,
                                    width: width,
                                    title: "Vehicle Lisence Disc",
                                    isSelected: model.barcodeScanType ==
                                        BarcodeScanType.vehicleDisc,
                                    onTap: () {
                                      model.setBarcodeScanType(
                                          BarcodeScanType.vehicleDisc);
                                    },
                                    hasInfo: model.gatePass.vehicleRegNumber !=
                                            null &&
                                        (model.gatePass.vehicleRegNoMatch ||
                                            model.vehicleManualEntryUsed),
                                    icon: Icons.directions_car,
                                    color: Colors.green,
                                    infoList: [
                                      BuildInfoItem(
                                        label: 'Registration',
                                        value:
                                            model.gatePass.vehicleRegNumber ??
                                                'Not Scanned',
                                        validationStatus: model.gatePass
                                                        .vehicleRegNumberValidation !=
                                                    null &&
                                                model.gatePass
                                                        .vehicleRegNoMatch ==
                                                    false
                                            ? ValidationStatus.failed
                                            : null,
                                        validationMessage:
                                            'Registration number mismatch',
                                      ),
                                      model.gatePass.vehicleRegNumberValidation !=
                                                  null &&
                                              model.gatePass
                                                      .vehicleRegNoMatch ==
                                                  false
                                          ? BuildInfoItem(
                                              label: 'Mismatch',
                                              value: model.gatePass
                                                      .vehicleRegNumberValidation ??
                                                  'Registration number mismatch',
                                              validationStatus:
                                                  ValidationStatus.failed,
                                            )
                                          : const SizedBox.shrink(),
                                      BuildInfoItem(
                                          label: 'Make',
                                          value: model.gatePass.vehicleMake ??
                                              'Not Scanned'),
                                      BuildInfoItem(
                                          label: 'Model',
                                          value:
                                              model.gatePass.vehicleVinNumber ??
                                                  'Not Scanned'),

                                      // MANUAL INPUT (ENTRY MODE ONLY)
                                      if (model
                                              .hasVehicleManualInputPermission &&
                                          ((model.isExitMode &&
                                                  model.gatePass
                                                          .vehicleRegNoMatch ==
                                                      false) ||
                                              (!model.isExitMode &&
                                                  (model.gatePass
                                                              .vehicleRegNumber !=
                                                          null ||
                                                      model.isManualInput))))
                                        ManualInputFieldWidget(
                                          controller:
                                              vehicleRegNumberTextController,
                                          isManualEntryUsed:
                                              model.vehicleManualEntryUsed,
                                          isPhotoTaken:
                                              model.vehicleManualPhotoTaken,
                                          photoPath:
                                              model.vehicleManualPhotoPath,
                                          onManualInput: (val) =>
                                              model.manualInputVehicle(val),
                                          onViewPhoto: () =>
                                              model.viewVehiclePhoto(),
                                          validateRegistration:
                                              _validateRegistration,
                                        ),
                                    ],
                                  ),
                                  // TRAILER ONE
                                  BuildInfoCard(
                                    isVisible: model.isManualInput ||
                                        model.hasTrailerOneEntryReg,
                                    key: model.trailerOneInfoCardKey,
                                    width: width,
                                    title: model.isExitMode
                                        ? "Trailer One (Entry Record)"
                                        : "Trailer One Disc",
                                    isSelected: model.barcodeScanType ==
                                        BarcodeScanType.trailerOneDisc,
                                    onTap: () {
                                      model.setBarcodeScanType(
                                          BarcodeScanType.trailerOneDisc);
                                    },
                                    hasInfo: model.hasTrailerOneEntryReg &&
                                        model.gatePass.trailerRegNumberOneMatch,
                                    icon: FontAwesomeIcons.trailer,
                                    color: Colors.green,
                                    infoList: [
                                      // ENTRY vs EXIT display
                                      if (model.isExitMode) ...[
                                        // What was recorded on entry
                                        BuildInfoItem(
                                          label: 'Entry registration',
                                          value: model.trailerOneEntryReg ??
                                              'Not available',
                                        ),
                                        // What you scanned now on exit
                                        BuildInfoItem(
                                          label: 'Scanned exit registration',
                                          value: model.gatePass
                                                  .trailerRegNumberOneValidation ??
                                              'Not Scanned',
                                          validationStatus: model.gatePass
                                                          .trailerRegNumberOneValidation !=
                                                      null &&
                                                  model.gatePass
                                                          .trailerRegNumberOneMatch ==
                                                      false
                                              ? ValidationStatus.failed
                                              : null,
                                          validationMessage:
                                              'Registration number mismatch',
                                        ),
                                      ] else ...[
                                        // ENTRY mode behaviour
                                        BuildInfoItem(
                                          label: 'Registration',
                                          value: model.trailerOneEntryReg ??
                                              'Not Scanned',
                                          validationStatus: model.gatePass
                                                          .trailerRegNumberOneValidation !=
                                                      null &&
                                                  model.gatePass
                                                          .trailerRegNumberOneMatch ==
                                                      false
                                              ? ValidationStatus.failed
                                              : null,
                                          validationMessage:
                                              'Registration number mismatch',
                                        ),
                                        model.gatePass.trailerRegNumberOneValidation !=
                                                    null &&
                                                model.gatePass
                                                        .trailerRegNumberOneMatch ==
                                                    false
                                            ? BuildInfoItem(
                                                label: 'Mismatch',
                                                value: model.gatePass
                                                        .trailerRegNumberOneValidation ??
                                                    'Registration number mismatch',
                                                validationStatus:
                                                    ValidationStatus.failed,
                                              )
                                            : const SizedBox.shrink(),
                                      ],

                                      // MANUAL INPUT (same logic you had)
                                      if (model
                                              .hasTrailerManualInputPermission &&
                                          ((model.isExitMode &&
                                                  model.gatePass
                                                          .trailerRegNumberOneMatch ==
                                                      false) ||
                                              (!model.isExitMode &&
                                                  (model.gatePass
                                                              .trailerRegNumberOne !=
                                                          null ||
                                                      model.isManualInput))))
                                        ManualInputFieldWidget(
                                          controller: trailerNo1TextController,
                                          isManualEntryUsed:
                                              model.trailerOneManualEntryUsed,
                                          isPhotoTaken:
                                              model.trailerOneManualPhotoTaken,
                                          photoPath:
                                              model.trailerOneManualPhotoPath,
                                          onManualInput: (val) =>
                                              model.manualInputTrailerOne(val),
                                          onViewPhoto: () =>
                                              model.viewTrailerOnePhoto(),
                                          validateRegistration:
                                              _validateRegistration,
                                          label: 'Manual Entry (Trailer 1)',
                                        ),
                                    ],
                                  ),

                                  verticalSpaceSmall,

// TRAILER TWO
                                  BuildInfoCard(
                                    isVisible: model.isManualInput ||
                                        model.hasTrailerTwoEntryReg,
                                    key: model.trailerTwoInfoCardKey,
                                    width: width,
                                    title: model.isExitMode
                                        ? "Trailer Two (Entry Record)"
                                        : "Trailer Two Disc",
                                    isSelected: model.barcodeScanType ==
                                        BarcodeScanType.trailerTwoDisc,
                                    onTap: () {
                                      model.setBarcodeScanType(
                                          BarcodeScanType.trailerTwoDisc);
                                    },
                                    hasInfo: model.hasTrailerTwoEntryReg &&
                                        model.gatePass.trailerRegNumberTwoMatch,
                                    icon: FontAwesomeIcons.trailer,
                                    color: Colors.green,
                                    infoList: [
                                      // ENTRY vs EXIT display
                                      if (model.isExitMode) ...[
                                        BuildInfoItem(
                                          label: 'Entry registration',
                                          value: model.trailerTwoEntryReg ??
                                              'Not available',
                                        ),
                                        BuildInfoItem(
                                          label: 'Scanned exit registration',
                                          value: model.gatePass
                                                  .trailerRegNumberTwoValidation ??
                                              'Not Scanned',
                                          validationStatus: model.gatePass
                                                          .trailerRegNumberTwoValidation !=
                                                      null &&
                                                  model.gatePass
                                                          .trailerRegNumberTwoMatch ==
                                                      false
                                              ? ValidationStatus.failed
                                              : null,
                                          validationMessage:
                                              'Registration number mismatch',
                                        ),
                                      ] else ...[
                                        BuildInfoItem(
                                          label: 'Registration',
                                          value: model.trailerTwoEntryReg ??
                                              'Not Scanned',
                                          validationStatus: model.gatePass
                                                          .trailerRegNumberTwoValidation !=
                                                      null &&
                                                  model.gatePass
                                                          .trailerRegNumberTwoMatch ==
                                                      false
                                              ? ValidationStatus.failed
                                              : null,
                                          validationMessage:
                                              'Registration number mismatch',
                                        ),
                                        model.gatePass.trailerRegNumberTwoValidation !=
                                                    null &&
                                                model.gatePass
                                                        .trailerRegNumberTwoMatch ==
                                                    false
                                            ? BuildInfoItem(
                                                label: 'Mismatch',
                                                value: model.gatePass
                                                        .trailerRegNumberTwoValidation ??
                                                    'Registration number mismatch',
                                                validationStatus:
                                                    ValidationStatus.failed,
                                              )
                                            : const SizedBox.shrink(),
                                      ],

                                      // MANUAL INPUT (same logic you had)
                                      if (model
                                              .hasTrailerManualInputPermission &&
                                          ((model.isExitMode &&
                                                  model.gatePass
                                                          .trailerRegNumberTwoMatch ==
                                                      false) ||
                                              (!model.isExitMode &&
                                                  (model.gatePass
                                                              .trailerRegNumberTwo !=
                                                          null ||
                                                      model.isManualInput))))
                                        ManualInputFieldWidget(
                                          controller: trailerNo2TextController,
                                          isManualEntryUsed:
                                              model.trailerTwoManualEntryUsed,
                                          isPhotoTaken:
                                              model.trailerTwoManualPhotoTaken,
                                          photoPath:
                                              model.trailerTwoManualPhotoPath,
                                          onManualInput: (val) =>
                                              model.manualInputTrailerTwo(val),
                                          onViewPhoto: () =>
                                              model.viewTrailerTwoPhoto(),
                                          validateRegistration:
                                              _validateRegistration,
                                          label: 'Manual Entry (Trailer 2)',
                                        ),
                                    ],
                                  ),

                                  if (model.isManualInput) ...[
                                    verticalSpaceTiny,
                                    BuildInfoCard(
                                      key: model.logisticsInfoCardKey,
                                      width: width,
                                      title: "Logistics Information",
                                      isSelected: model.logisticsInfoComplete,
                                      hasInfo: model.logisticsInfoComplete,
                                      icon: Icons.local_shipping,
                                      color: model.logisticsInfoComplete
                                          ? Colors.green
                                          : model.shouldShowLogisticsActive
                                              ? Colors.blue
                                              : Colors.grey,
                                      infoList: [
                                        // Transporter Dropdown
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Transporter *',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              verticalSpaceTiny,
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: model
                                                        .transporters.isEmpty
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2),
                                                            ),
                                                            horizontalSpaceSmall,
                                                            Text(
                                                                'Loading transporters...'),
                                                          ],
                                                        ),
                                                      )
                                                    : SearchableDropdownFormField<
                                                        int>(
                                                        initialValue: model.gatePass
                                                            .transporterId,
                                                        dialogOffset: 1,
                                                        dropDownMaxHeight:
                                                            dropdownMaxHeight,
                                                        hintText: const Text(
                                                            'Select Transporter'),
                                                        items: model
                                                            .transporters
                                                            .map((transporter) {
                                                          return SearchableDropdownMenuItem<
                                                              int>(
                                                            value:
                                                                transporter.id,
                                                            label: transporter
                                                                    .name ??
                                                                '',
                                                            child: Text(
                                                                transporter
                                                                        .name ??
                                                                    '',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          model.setTransporter(
                                                              value);
                                                          if (value != null &&
                                                              model
                                                                      .gatePass
                                                                      .gatePassBookingType ==
                                                                  GatePassBookingType
                                                                      .containers &&
                                                              model
                                                                  .isManualInput &&
                                                              !model
                                                                  .isExitMode) {
                                                            WidgetsBinding.instance
                                                                .addPostFrameCallback(
                                                                    (_) async {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              await Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          80));
                                                              if (containerNumberTextFocusNode
                                                                  .canRequestFocus) {
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus(
                                                                        containerNumberTextFocusNode);
                                                              }
                                                            });
                                                          }
                                                        },
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Customer Dropdown
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Customer',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              verticalSpaceTiny,
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: model.customers.isEmpty
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2),
                                                            ),
                                                            horizontalSpaceSmall,
                                                            Text(
                                                                'Loading customers...'),
                                                          ],
                                                        ),
                                                      )
                                                    : SearchableDropdownFormField<
                                                        int>(
                                                        initialValue: model.gatePass
                                                            .customerId,
                                                        dialogOffset: 1,
                                                        dropDownMaxHeight:
                                                            dropdownMaxHeight,
                                                        hintText: const Text(
                                                            'Select Customer (Optional)'),
                                                        items: model.customers
                                                            .map((customer) {
                                                          return SearchableDropdownMenuItem<
                                                              int>(
                                                            value: customer.id,
                                                            label: customer
                                                                    .name ??
                                                                '',
                                                            child: Text(
                                                              customer.name ??
                                                                  '',
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            var customer = model
                                                                .customers
                                                                .firstWhereOrNull(
                                                                    (c) =>
                                                                        c.id ==
                                                                        value);
                                                            if (customer !=
                                                                null) {
                                                              model.setCustomer(
                                                                  customer);
                                                            }
                                                          }
                                                        },
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (model.gatePass.gatePassBookingType ==
                                      GatePassBookingType.containers) ...[
                                    verticalSpaceSmall,

                                    // Container Details Card for Manual Entries
                                    if (model.isManualInput &&
                                        !model.isExitMode) ...[
                                      for (var i = 0; i < model.manualContainerCardCount; i++)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _buildManualContainerCard(
                                            context: context,
                                            model: model,
                                            width: width,
                                            index: i,
                                            cardKey: i == 0 ? model.containerInfoCardKey : null,
                                            containerNumberFocusNode:
                                                i == 0 ? containerNumberTextFocusNode : null,
                                          ),
                                        ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: model.canAddManualContainerCard
                                                  ? model.addManualContainerCard
                                                  : null,
                                              icon: const Icon(Icons.add),
                                              label: const Text('Add Container'),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: model.manualContainerCardCount > 1
                                                  ? model.removeManualContainerCard
                                                  : null,
                                              icon: const Icon(Icons.remove),
                                              label: const Text('Remove Container'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                        'Manual container cards enabled: ${model.manualContainerCardCount}/3',
                                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                        ),
                                      ),
                                      verticalSpaceSmall,
                                    ] else ...[
                                      // Pre-booking container info (read-only)
                                      BuildInfoCard(
                                        key: model.containerInfoCardKey,
                                        width: width,
                                        title: "Container Info",
                                        isSelected:
                                            model.gatePass.timeAtGate != null &&
                                                model.gatePass.timeIn != null,
                                        hasInfo:
                                            model.gatePass.containerNumber !=
                                                null,
                                        icon: Icons.confirmation_num,
                                        color: Colors.blueGrey[300]!,
                                        infoList: [
                                          BuildInfoItem(
                                              label: 'Container No',
                                              value: model.gatePass
                                                      .containerNumber ??
                                                  ''),
                                          BuildInfoItem(
                                              label: 'Size',
                                              value: model
                                                      .gatePass.containerSize ??
                                                  ''),
                                          BuildInfoItem(
                                              label: 'Type',
                                              value: model
                                                      .selectedContainerTypeCode ??
                                                  model.gatePass.containerType ??
                                                  ''),
                                        ],
                                      ),
                                    ],
                                  ],
                                  BuildInfoCard(
                                    width: width,
                                    title: "Times",
                                    isSelected:
                                        model.gatePass.timeAtGate != null &&
                                            model.gatePass.timeIn != null,
                                    hasInfo: true,
                                    icon: Icons.timelapse_sharp,
                                    color: Colors.amber[300]!,
                                    infoList: [
                                      BuildInfoItem(
                                          label: 'Time At Gate',
                                          value: model.gatePass.timeAtGate
                                                  ?.toSocialMediaTime() ??
                                              ''),
                                      BuildInfoItem(
                                          label: 'Time In',
                                          value: model.gatePass.timeIn
                                                  ?.toSocialMediaTime() ??
                                              ''),
                                      BuildInfoItem(
                                          label: 'Time Out',
                                          value: model.gatePass.timeOut
                                                  ?.toSocialMediaTime() ??
                                              ''),
                                    ],
                                  ),
                                  model.gatePass.serviceTypeId != null
                                      ? Text(
                                          '(${model.serviceTypes.firstWhere((element) => element.value == model.gatePass.serviceTypeId).label})',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              )

                        // Form(
                        //     key: formKeyAtGate,
                        //     child: Column(
                        //       children: [
                        //         Row(
                        //           children: [
                        //             Expanded(
                        //               child: RadioListTile(
                        //                 contentPadding: const EdgeInsets.all(2),
                        //                 value: DeliveryType.dispatch,
                        //                 groupValue:
                        //                     model.gatePass.gatePassDeliveryType,
                        //                 dense: true,
                        //                 title: BoxText.label(
                        //                   DeliveryType.dispatch.text
                        //                       .toUpperCase(),
                        //                   color: Colors.black,
                        //                   fontSize: 12,
                        //                 ),
                        //                 onChanged: (v) {
                        //                   model.gatePass.gatePassDeliveryType =
                        //                       DeliveryType.dispatch;
                        //                   model.modelNotifyListeners();
                        //                 },
                        //                 activeColor: Colors.green,
                        //                 selected: false,
                        //               ),
                        //             ),
                        //             Expanded(
                        //               child: RadioListTile(
                        //                 contentPadding: const EdgeInsets.all(2),
                        //                 value: DeliveryType.receive,
                        //                 groupValue:
                        //                     model.gatePass.gatePassDeliveryType,
                        //                 dense: true,
                        //                 title: BoxText.label(
                        //                   DeliveryType.receive.text
                        //                       .toUpperCase(),
                        //                   color: Colors.black,
                        //                   fontSize: 12,
                        //                 ),
                        //                 onChanged: (v) {
                        //                   model.gatePass.gatePassDeliveryType =
                        //                       DeliveryType.receive;
                        //                   model.modelNotifyListeners();
                        //                 },
                        //                 activeColor: Colors.green,
                        //                 selected: false,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         InputField(
                        //           placeholder: "Type The Vehicle Reg Number...",
                        //           padding: const EdgeInsets.only(
                        //               left: 4, right: 4, top: 5),
                        //           controller: vehicleRegNumberTextController,
                        //           icon: FaIcon(
                        //             FontAwesomeIcons.truck,
                        //             color: model.gatePass.vehicleRegNumber ==
                        //                     vehicleRegNumberValiTextController
                        //                         .text
                        //                 ? Colors.green
                        //                 : Colors.red,
                        //           ),
                        //           fieldFocusNode: vehicleRegNumberTextFocusNode,
                        //           nextFocusNode: trailerNo1TextFocusNode,
                        //           textInputAction: TextInputAction.next,
                        //           textInputType: TextInputType.text,
                        //           isReadOnly: model.gatePass.externalId != null,
                        //           formatter: [
                        //             UpperCaseTextFormatter(),
                        //           ],
                        //           onChanged: (value) {
                        //             updateModelData(model);
                        //           },
                        //           enterPressed: () {
                        //             //used to close the keyboard on last text inputfield
                        //             // FocusScope.of(context).unfocus();
                        //           },
                        //           validator: (value) {
                        //             var valMsg =
                        //                 "Vehicle Reg Number is required!";

                        //             if (value == null || value.isEmpty) {
                        //               model.setValidationMessage(valMsg);
                        //               return valMsg;
                        //             }
                        //             model.clearValidationMessage(valMsg);
                        //             return null;
                        //           },
                        //         ),
                        //         InputField(
                        //           placeholder: "Scan Vehicle Lisence Disc",
                        //           padding: const EdgeInsets.only(
                        //               left: 4, right: 4, top: 5),
                        //           controller:
                        //               vehicleRegNumberValiTextController,
                        //           icon: FaIcon(
                        //             FontAwesomeIcons.truck,
                        //             color: model
                        //                         .gatePass
                        //                         .vehicleRegNumberValidation
                        //                         ?.isNotEmpty ??
                        //                     false
                        //                 ? Colors.green
                        //                 : Colors.red,
                        //           ),
                        //           fieldFocusNode: vehicleRegNumberTextFocusNode,
                        //           nextFocusNode: trailerNo1TextFocusNode,
                        //           textInputAction: TextInputAction.next,
                        //           textInputType: TextInputType.text,
                        //           formatter: [
                        //             UpperCaseTextFormatter(),
                        //           ],
                        //           onChanged: (value) {
                        //             updateModelData(model);
                        //           },
                        //           enterPressed: () {
                        //             //used to close the keyboard on last text inputfield
                        //             // FocusScope.of(context).unfocus();
                        //           },
                        //           validator: (value) {
                        //             var valMsg =
                        //                 "Vehicle Reg Number is required!";

                        //             if (value == null || value.isEmpty) {
                        //               model.setValidationMessage(valMsg);
                        //               return valMsg;
                        //             }
                        //             model.clearValidationMessage(valMsg);
                        //             return null;
                        //           },
                        //         ),
                        //         InputField(
                        //           placeholder: "Type The Trailer No 1...",
                        //           padding: const EdgeInsets.only(
                        //               left: 4, right: 4, top: 0),
                        //           controller: trailerNo1TextController,
                        //           icon: FaIcon(
                        //             FontAwesomeIcons.trailer,
                        //             color: model.gatePass.trailerRegNumberOne !=
                        //                         null &&
                        //                     model.gatePass.trailerRegNumberOne!
                        //                         .isNotEmpty
                        //                 ? Colors.green
                        //                 : Colors.red,
                        //           ),
                        //           fieldFocusNode: trailerNo1TextFocusNode,
                        //           nextFocusNode: trailerNo2TextFocusNode,
                        //           textInputAction: TextInputAction.next,
                        //           textInputType: TextInputType.text,
                        //           formatter: [
                        //             UpperCaseTextFormatter(),
                        //           ],
                        //           onChanged: (value) {
                        //             updateModelData(model);
                        //           },
                        //           enterPressed: () {
                        //             //used to close the keyboard on last text inputfield
                        //             //FocusScope.of(context).unfocus();
                        //           },
                        //           validator: (value) {
                        //             // var valMsg = "Trailer No 1 Number is required!";

                        //             // if (value == null || value.isEmpty) {
                        //             //   model.setValidationMessage(valMsg);
                        //             //   return valMsg;
                        //             // }
                        //             // model.clearValidationMessage(valMsg);
                        //             return null;
                        //           },
                        //         ),
                        //         InputField(
                        //           placeholder: "Type The Trailer No 2...",
                        //           padding: const EdgeInsets.only(
                        //               left: 4, right: 4, top: 0),
                        //           controller: trailerNo1TextController,
                        //           icon: FaIcon(
                        //             FontAwesomeIcons.trailer,
                        //             color: model.gatePass.trailerRegNumberOne !=
                        //                         null &&
                        //                     model.gatePass.trailerRegNumberOne!
                        //                         .isNotEmpty
                        //                 ? Colors.green
                        //                 : Colors.red,
                        //           ),
                        //           fieldFocusNode: trailerNo2TextFocusNode,
                        //           nextFocusNode: null,
                        //           textInputAction: TextInputAction.next,
                        //           textInputType: TextInputType.text,
                        //           formatter: [
                        //             UpperCaseTextFormatter(),
                        //           ],
                        //           onChanged: (value) {
                        //             updateModelData(model);
                        //           },
                        //           enterPressed: () {
                        //             //used to close the keyboard on last text inputfield
                        //             FocusScope.of(context).unfocus();
                        //           },
                        //           validator: (value) {
                        //             // var valMsg = "Trailer No 1 Number is required!";

                        //             // if (value == null || value.isEmpty) {
                        //             //   model.setValidationMessage(valMsg);
                        //             //   return valMsg;
                        //             // }
                        //             // model.clearValidationMessage(valMsg);
                        //             return null;
                        //           },
                        //         ),
                        //         Padding(
                        //           padding:
                        //               const EdgeInsets.only(left: 8, top: 8),
                        //           child: BoxText.label(
                        //             "Customer",
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         ModalSheetSelection<BaseLookup>(
                        //           key: const Key("Customer"),
                        //           dropDownList: model.customers,
                        //           dropDownIcon: const Icon(
                        //             Icons.arrow_drop_down,
                        //             color: Colors.grey,
                        //             size: 23,
                        //           ),
                        //           onDropDownItemClick: (selectedItem) {
                        //             model.setCustomer(selectedItem);
                        //           },
                        //           onTapped: (isValid) {
                        //             var valMsg = "Customer is required!";
                        //             if (isValid = false) {
                        //               model.setValidationMessage(valMsg);
                        //               return valMsg;
                        //             } else {
                        //               model.clearValidationMessage(valMsg);
                        //             }
                        //           },
                        //           selectedItem: model.getCustomer(),
                        //         ),
                        //         InputField(
                        //           placeholder: "Driver Name",
                        //           padding: const EdgeInsets.only(
                        //               left: 4, right: 4, top: 4),
                        //           controller: driverNameTextController,
                        //           icon: FaIcon(
                        //             FontAwesomeIcons.idCard,
                        //             color: model.gatePass.driverName != null &&
                        //                     model
                        //                         .gatePass.driverName!.isNotEmpty
                        //                 ? Colors.green
                        //                 : Colors.red,
                        //           ),
                        //           fieldFocusNode: driverdriverNameTextFocusNode,
                        //           nextFocusNode: null,
                        //           textInputAction: TextInputAction.next,
                        //           textInputType: TextInputType.text,
                        //           onChanged: (value) {
                        //             updateModelData(model);
                        //           },
                        //           enterPressed: () {
                        //             //used to close the keyboard on last text inputfield
                        //             FocusScope.of(context).unfocus();
                        //           },
                        //           validator: (value) {
                        //             // var valMsg = "Trailer No 1 Number is required!";

                        //             // if (value == null || value.isEmpty) {
                        //             //   model.setValidationMessage(valMsg);
                        //             //   return valMsg;
                        //             // }
                        //             // model.clearValidationMessage(valMsg);
                        //             return null;
                        //           },
                        //         ),
                        //         InputField(
                        //           placeholder: "Driver ID",
                        //           padding: const EdgeInsets.only(
                        //               left: 4, right: 4, top: 0),
                        //           controller: driverIDTextController,
                        //           icon: FaIcon(
                        //             FontAwesomeIcons.idCard,
                        //             color: model.gatePass.driverIdNo != null &&
                        //                     model
                        //                         .gatePass.driverIdNo!.isNotEmpty
                        //                 ? Colors.green
                        //                 : Colors.red,
                        //           ),
                        //           fieldFocusNode: driverIDTextFocusNode,
                        //           nextFocusNode: null,
                        //           textInputAction: TextInputAction.next,
                        //           textInputType: TextInputType.text,
                        //           onChanged: (value) {
                        //             updateModelData(model);
                        //           },
                        //           enterPressed: () {
                        //             //used to close the keyboard on last text inputfield
                        //             FocusScope.of(context).unfocus();
                        //           },
                        //           validator: (value) {
                        //             // var valMsg = "Trailer No 1 Number is required!";

                        //             // if (value == null || value.isEmpty) {
                        //             //   model.setValidationMessage(valMsg);
                        //             //   return valMsg;
                        //             // }
                        //             // model.clearValidationMessage(valMsg);
                        //             return null;
                        //           },
                        //         ),
                        //         InputField(
                        //           placeholder: "Driver License No",
                        //           padding: const EdgeInsets.only(
                        //               left: 4, right: 4, top: 0),
                        //           controller: driverLisenceNoTextController,
                        //           icon: FaIcon(
                        //             FontAwesomeIcons.idCard,
                        //             color: model.gatePass.driverLicenceNo !=
                        //                         null &&
                        //                     model.gatePass.driverLicenceNo!
                        //                         .isNotEmpty
                        //                 ? Colors.green
                        //                 : Colors.red,
                        //           ),
                        //           fieldFocusNode: driverLisenceNoTextFocusNode,
                        //           nextFocusNode: null,
                        //           textInputAction: TextInputAction.next,
                        //           textInputType: TextInputType.text,
                        //           onChanged: (value) {
                        //             updateModelData(model);
                        //           },
                        //           enterPressed: () {
                        //             //used to close the keyboard on last text inputfield
                        //             FocusScope.of(context).unfocus();
                        //           },
                        //           validator: (value) {
                        //             // var valMsg = "Trailer No 1 Number is required!";

                        //             // if (value == null || value.isEmpty) {
                        //             //   model.setValidationMessage(valMsg);
                        //             //   return valMsg;
                        //             // }
                        //             // model.clearValidationMessage(valMsg);
                        //             return null;
                        //           },
                        //         ),
                        //         ListTile(
                        //           dense: true,
                        //           contentPadding: const EdgeInsets.only(
                        //               left: 9.0, right: 9),
                        //           //  leading: GatePassListIcon(statusId: model.gatePass.gatePassStatus),
                        //           trailing: GateStatusChip(
                        //               gatePassStatus:
                        //                   model.gatePass.gatePassStatus),
                        //           title: BoxText.label(
                        //             "Status",
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         ListTile(
                        //           dense: true,
                        //           contentPadding:
                        //               const EdgeInsets.only(left: 9.0),
                        //           subtitle: BoxText.caption(model
                        //               .gatePass.timeAtGate
                        //               .toFormattedString()),
                        //           title: BoxText.label(
                        //             "Time At Gate",
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         ListTile(
                        //           dense: true,
                        //           contentPadding:
                        //               const EdgeInsets.only(left: 9.0),
                        //           subtitle: BoxText.caption(
                        //               model.gatePass.timeIn?.toString() ?? ""),
                        //           title: BoxText.label(
                        //             "Time In",
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         ListTile(
                        //           dense: true,
                        //           contentPadding:
                        //               const EdgeInsets.only(left: 9.0),
                        //           subtitle: BoxText.caption(
                        //               model.gatePass.timeOut?.toString() ?? ""),
                        //           title: BoxText.label(
                        //             "Time Out",
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         // ListRadioBoolWithLabel(
                        //         //   label: "Documents Received ?",
                        //         //   value: model.gatePass.gatePassQuestions
                        //         //           ?.hasDeliveryDocuments ??
                        //         //       false,
                        //         //   onValueChanged: (Object? newValue) {
                        //         //     if (newValue is bool?) {
                        //         //       model.setDocRecievedChange(newValue);
                        //         //     }
                        //         //   },
                        //         // ),
                        //         // ListRadioBoolWithLabel(
                        //         //   label: "Containerised (Y/N)?",
                        //         //   value: model.gatePass.gatePassQuestions
                        //         //           ?.isContainerised ??
                        //         //       false,
                        //         //   onValueChanged: (Object? val) {
                        //         //     if (val is bool?) {
                        //         //       model.gatePass.gatePassQuestions
                        //         //           ?.isContainerised = val ?? false;
                        //         //       model.modelNotifyListeners();
                        //         //     }
                        //         //   },
                        //         // ),
                        //         // ListRadioBoolWithLabel(
                        //         //   label:
                        //         //       "Any visible damages/quality defects on the items/pallets/packaging (Y/N)?",
                        //         //   value: model.gatePass.gatePassQuestions
                        //         //           ?.hasDamagesDefects ??
                        //         //       false,
                        //         //   onValueChanged: (Object? val) {
                        //         //     if (val is bool?) {
                        //         //       model.gatePass.gatePassQuestions
                        //         //           ?.hasDamagesDefects = val ?? false;
                        //         //       model.modelNotifyListeners();
                        //         //     }
                        //         //   },
                        //         // ),
                        //         // ListRadioBoolWithLabel(
                        //         //   label:
                        //         //       "Does the qty delivered match the docs? (Y/N)?",
                        //         //   value: model.gatePass.gatePassQuestions
                        //         //           ?.qtyMatchedDocs ??
                        //         //       false,
                        //         //   onValueChanged: (Object? val) {
                        //         //     if (val is bool?) {
                        //         //       model.gatePass.gatePassQuestions
                        //         //           ?.qtyMatchedDocs = val ?? false;
                        //         //       model.modelNotifyListeners();
                        //         //     }
                        //         //   },
                        //         // ),
                        //         // ListRadioBoolWithLabel(
                        //         //   label: "Do the item numbers match the docs (Y/N)?",
                        //         //   value: model.gatePass.gatePassQuestions
                        //         //           ?.itemCodesMatchDocs ??
                        //         //       false,
                        //         //   onValueChanged: (Object? val) {
                        //         //     if (val is bool?) {
                        //         //       model.gatePass.gatePassQuestions
                        //         //           ?.itemCodesMatchDocs = val ?? false;
                        //         //       model.modelNotifyListeners();
                        //         //     }
                        //         //   },
                        //         // ),
                        //         // ListRadioBoolWithLabel(
                        //         //   label: "Was the delivery expected (Y/N)?",
                        //         //   value: model.gatePass.gatePassQuestions
                        //         //           ?.expectedDelivery ??
                        //         //       false,
                        //         //   onValueChanged: (Object? val) {
                        //         //     if (val is bool?) {
                        //         //       model.gatePass.gatePassQuestions
                        //         //           ?.expectedDelivery = val ?? false;
                        //         //       model.modelNotifyListeners();
                        //         //     }
                        //         //   },
                        //         // ),
                        //         // ListRadioBoolWithLabel(
                        //         //   label:
                        //         //       "Does the driver agree with the info captured (Y/N)?",
                        //         //   value:
                        //         //       model.gatePass.gatePassQuestions?.driverAgree ??
                        //         //           false,
                        //         //   onValueChanged: (Object? val) {
                        //         //     if (val is bool?) {
                        //         //       model.gatePass.gatePassQuestions?.driverAgree =
                        //         //           val ?? false;
                        //         //       model.modelNotifyListeners();
                        //         //     }
                        //         //   },
                        //         // ),
                        //       ],
                        //     ),
                        //   ),
                        ),
                  ),
                  // IMAGES
                  Scaffold(
                    floatingActionButton: SpeedDial(
                      visible: !model.gatePass.id.isEmptyOrNull,
                      icon: Icons.add_a_photo,
                      spaceBetweenChildren: 6,
                      activeIcon: Icons.close,
                      children: [
                        SpeedDialChild(
                          child: const Icon(Icons.camera_alt_outlined),
                          label: 'Take Photo',
                          onTap: () =>
                              model.goToCamView(FileStoreType.gateBookingImage),
                        ),
                        // SpeedDialChild(
                        //   child: const Icon(Icons.document_scanner_outlined),
                        //   label: 'Document & Crop',
                        //   onTap: () => model.goToCamView(FileStoreType.documentScan),
                        // ),
                        SpeedDialChild(
                          child: const Icon(Icons.attachment_outlined),
                          label: 'Image Picker',
                          onTap: () => model.openImagePicker(),
                        ),
                        // SpeedDialChild(
                        //   child: const Icon(Icons.barcode_reader),
                        //   label: 'Barcode Scanner',
                        //   onTap: () =>
                        //       model.goToCamView(FileStoreType.documentScan),
                        // ),
                      ],
                    ),
                    body: GridView.builder(
                      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        childAspectRatio: 1,
                      ),
                      itemCount: model.fileStoreItems.length,
                      itemBuilder: (BuildContext ctx, index) {
                        var fileItem = model.fileStoreItems[index];

                        return InkWell(
                          onTap: () {
                            // model.gotEditImageView(fileItem.path);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                          image: FileImage(
                                            File(fileItem.path),
                                          ),
                                          fit: BoxFit.fill),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      children: [
                                        fileItem.upLoaded
                                            ? const Icon(
                                                Icons.checklist,
                                                color: Colors.green,
                                              )
                                            : const Icon(
                                                Icons.pending,
                                                color: Colors.orange,
                                              ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      viewModelBuilder: () => GatePassEditViewModel(gatePass),
    );
  }
}

class BuildErrorsView extends StatelessWidget {
  final List<String> validationMessages;
  const BuildErrorsView({
    super.key,
    required this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpaceSmall,
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              horizontalSpaceSmall,
              Expanded(
                child: Text(
                  'Validation Errors:',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (validationMessages.isNotEmpty) ...[
            ...validationMessages
                .map((message) => Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ]
        ],
      ),
    );
  }
}

Widget _buildManualContainerCard({
  required BuildContext context,
  required GatePassEditViewModel model,
  required double width,
  required int index,
  Key? cardKey,
  FocusNode? containerNumberFocusNode,
}) {
  final dropdownMaxHeight =
      (MediaQuery.of(context).size.height * 0.3).clamp(180.0, 280.0).toDouble();
  final container = model.getManualContainer(index);
  return BuildInfoCard(
    key: cardKey,
    width: width,
    title: 'Container ${index + 1} Information',
    isSelected: (container.containerNumber ?? '').isNotEmpty,
    hasInfo: (container.containerNumber ?? '').isNotEmpty,
    icon: Icons.inventory_2,
    color: index == 0
        ? (model.containerInfoComplete
            ? Colors.green
            : model.shouldShowContainerActive
                ? Colors.blue
                : Colors.grey)
        : Colors.blueGrey,
    infoList: [
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Container Number *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          TextFormField(
            key: ValueKey(
                'manual_container_number_${index}_${container.containerNumber ?? ''}'),
            initialValue: container.containerNumber ?? '',
            focusNode: containerNumberFocusNode,
            decoration: InputDecoration(border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.blue), onPressed: () => model.goToCamCaptureContainerNoText(index), tooltip: 'Scan Container')),
            textCapitalization: TextCapitalization.characters,
            onChanged: (val) => model.setManualContainerNumber(index, val),
          ),
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Detected ISO Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
            child: Text(container.containerIsoCode ?? '', style: const TextStyle(fontSize: 14)),
          )
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Container Size *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SearchableDropdownFormField<String>(
              key: ValueKey(
                  'container_size_${index}_${model.manualContainerSizeDropdownValue(index)}_${model.containerSizeOptions.length}'),
              initialValue: model.manualContainerSizeDropdownValue(index),
              dialogOffset: 1,
              dropDownMaxHeight: dropdownMaxHeight,
              items: model.containerSizeOptions.map((o) => SearchableDropdownMenuItem<String>(value: o.label, label: o.label, child: Text(o.label, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => model.setManualContainerSize(index, v),
            ),
          ),
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Container Type *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SearchableDropdownFormField<String>(
              key: ValueKey(
                  'container_type_${index}_${model.manualContainerTypeDropdownValue(index)}_${model.containerTypeOptions.length}'),
              initialValue: model.manualContainerTypeDropdownValue(index),
              dialogOffset: 1,
              dropDownMaxHeight: dropdownMaxHeight,
              items: model.containerTypeOptions.map((o) => SearchableDropdownMenuItem<String>(value: o.code, label: o.code, child: Text(o.code ?? o.label, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => model.setManualContainerType(index, v),
            ),
          ),
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Delivery Type *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Wrap(spacing: 8, runSpacing: 8, children: [
            SizedBox(width: 110, child: _buildRadioOption(context: context, title: 'Receive', icon: Icons.arrow_downward, value: DeliveryType.receive, groupValue: container.containerDeliveryType, onChanged: (v) => model.setManualContainerDeliveryType(index, v))),
            SizedBox(width: 110, child: _buildRadioOption(context: context, title: 'Dispatch', icon: Icons.arrow_upward, value: DeliveryType.dispatch, groupValue: container.containerDeliveryType, onChanged: (v) => model.setManualContainerDeliveryType(index, v))),
            SizedBox(width: 110, child: _buildRadioOption(context: context, title: 'Other', icon: Icons.more_horiz, value: DeliveryType.other, groupValue: container.containerDeliveryType, onChanged: (v) => model.setManualContainerDeliveryType(index, v))),
          ]),
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cargo Type *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Wrap(spacing: 8, runSpacing: 8, children: [
            SizedBox(width: 110, child: _buildRadioOption(context: context, title: 'Empty', icon: Icons.inbox, value: GatePassContainerType.empty, groupValue: container.gatePassContainerType, onChanged: (v) => model.setManualContainerCargoType(index, v))),
            SizedBox(width: 110, child: _buildRadioOption(context: context, title: 'Unpack Full', icon: Icons.inventory, value: GatePassContainerType.unpackFull, groupValue: container.gatePassContainerType, onChanged: (v) => model.setManualContainerCargoType(index, v))),
            SizedBox(width: 110, child: _buildRadioOption(context: context, title: 'Store Full', icon: Icons.warehouse, value: GatePassContainerType.storeFull, groupValue: container.gatePassContainerType, onChanged: (v) => model.setManualContainerCargoType(index, v))),
          ]),
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Shipping Line *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SearchableDropdownFormField<int>(
              key: ValueKey(
                  'container_shipping_line_${index}_${model.manualContainerShippingLineDropdownValue(index)}_${model.shippingLines.length}'),
              initialValue: model.manualContainerShippingLineDropdownValue(index),
              dialogOffset: 1,
              dropDownMaxHeight: dropdownMaxHeight,
              items: model.shippingLines.map((x) => SearchableDropdownMenuItem<int>(value: x.id, label: x.name ?? '', child: Text(x.name ?? '', overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => model.setManualContainerShippingLine(index, v),
            ),
          ),
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Customer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SearchableDropdownFormField<int>(
              key: ValueKey(
                  'container_customer_${index}_${model.manualContainerCustomerDropdownValue(index)}_${model.containerCustomers.length}'),
              initialValue: model.manualContainerCustomerDropdownValue(index),
              dialogOffset: 1,
              dropDownMaxHeight: dropdownMaxHeight,
              items: model.containerCustomers.map((x) => SearchableDropdownMenuItem<int>(value: x.id, label: x.name ?? '', child: Text(x.name ?? '', overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => model.setManualContainerCustomer(index, v),
            ),
          ),
        ]),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Depot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          verticalSpaceTiny,
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SearchableDropdownFormField<int>(
              key: ValueKey(
                  'container_depot_${index}_${model.manualContainerDepotDropdownValue(index)}_${model.containerDepots.length}'),
              initialValue: model.manualContainerDepotDropdownValue(index),
              dialogOffset: 1,
              dropDownMaxHeight: dropdownMaxHeight,
              items: model.containerDepots.map((x) => SearchableDropdownMenuItem<int>(value: x.id, label: x.name ?? '', child: Text(x.name ?? '', overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => model.setManualContainerDepot(index, v),
            ),
          ),
        ]),
      ),
    ],
  );
}

Widget _buildRadioOption<T>({
  required BuildContext context,
  required String title,
  required IconData icon,
  required T value,
  required T? groupValue,
  required Function(T?) onChanged,
}) {
  final isSelected = groupValue == value;
  return InkWell(
    onTap: () => onChanged(value),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 20,
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.blue.shade700 : Colors.grey[700],
            ),
          ),
        ],
      ),
    ),
  );
}