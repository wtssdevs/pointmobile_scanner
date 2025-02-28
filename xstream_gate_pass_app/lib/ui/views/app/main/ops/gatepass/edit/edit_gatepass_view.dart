import 'dart:io';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';

import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';

import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/modal_lookup/modal_sheet_selection.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/Widgets/gate_pass_status_chip_widget.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view_model.dart';

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

  final formKeyAtGate = GlobalKey<FormState>();
  onModelSet(GatePassAccess data) {
    vehicleRegNumberTextController.text = data.vehicleRegNumber ?? "";
    trailerNo1TextController.text = data.trailerRegNumberOne ?? "";
    trailerNo2TextController.text = data.trailerRegNumberTwo ?? "";

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

  Future<bool> validateForm(
      GatePassEditViewModel model, BuildContext context) async {
    //validate per status
    var isValid = false;
    switch (model.gatePass.gatePassStatus) {
      case GatePassStatus.atGate: //GatePassStatus.atGate.value:
      case 2: //GatePassStatus.atGate.value:
      case 3: //GatePassStatus.atGate.value:
      case 4: //GatePassStatus.atGate.value:
        isValid = await validateByFormKey(formKeyAtGate, context, model);
        if (isValid) {
          //model.authorizeEntry();
        } else {
          Fluttertoast.showToast(
              msg:
                  "Validation Failed!,Please correct all missing information. ${model.validationMessages.isNotEmpty ? model.validationMessages[0] : ""} ",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM_LEFT,
              timeInSecForIosWeb: 8,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 14.0);
        }
        break;
      default:
    }

    return isValid;
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

  @override
  Widget build(BuildContext context) {
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
        onPopInvokedWithResult: (r, d) {
          //return true;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            persistentFooterButtons: [
              Visibility(
                visible: model.gatePass.gatePassStatus.value ==
                        GatePassStatus.atGate.value ||
                    model.gatePass.gatePassStatus.value ==
                        GatePassStatus.inYard.value ||
                    model.gatePass.gatePassStatus.value ==
                        GatePassStatus.pending.value,
                // (model.gatePass.gatePassQuestions?.hasDeliveryDocuments == false && model.gatePass.gatePassStatus == GatePassStatus.atGate.index) || (model.gatePass.gatePassQuestions?.hasDeliveryDocuments == false && model.gatePass.gatePassStatus == GatePassStatus.inYard.index),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // call method
                    //validate UI first
                    var isValid = await validateForm(model, context);
                    if (isValid == true) {
                      model.rejectEntry();
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.ban,
                    color: Colors.red,
                  ),
                  label: const Text('Reject Entry'), // <-- Text
                ),
              ),
              Visibility(
                visible: model.gatePass.gatePassStatus.value ==
                        GatePassStatus.atGate.value ||
                    model.gatePass.gatePassStatus.value ==
                        GatePassStatus.pending
                            .value, //&& model.gatePass.gatePassQuestions?.hasDeliveryDocuments == true,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // valiate first
                    var isValid = await validateForm(model, context);
                    if (isValid == true) {
                      model.authorizeEntry();
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.rightToBracket,
                    color: Colors.blue,
                  ),
                  label: const Text("Authorize Entry"), // <-- Text
                ),
              ),
              Visibility(
                visible: model.gatePass.gatePassStatus.value ==
                    GatePassStatus.inYard
                        .index, //&& model.gatePass.gatePassQuestions?.hasDeliveryDocuments == true,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // valiate first
                    var isValid = await validateForm(model, context);
                    if (isValid == true) {
                      model.authorizeExit();
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.green,
                  ),
                  label: const Text("Authorize Exit"), // <-- Text
                ),
              ),
            ],
            appBar: AppBar(
              elevation: 6,

              //title: const BoxText.headingThree("GatePass"),
              title: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 2.0),
                //leading:
                //  GatePassListIcon(statusId: model.gatePass.gatePassStatus),
                title: GateStatusChip(
                    gatePassStatus: gatePass
                        .gatePassStatus), // BoxText.label(model.gatePass.gatePassStatus.displayName.toUpperCase(), color: Colors.white),
              ),
              titleSpacing: 2.0,
              centerTitle: true,

              actions: [
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
                ElevatedButton.icon(
                  onPressed: () async {
                    // valiate first
                    var isValid = await validateForm(model, context);
                    if (isValid == true) {
                      model.saveOnly();
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.floppyDisk,
                    color: Colors.green,
                  ),
                  label: const Text("Save"), // <-- Text
                ),
              ],
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
                  SingleChildScrollView(
                    child: Form(
                      key: formKeyAtGate,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  contentPadding: const EdgeInsets.all(2),
                                  value: DeliveryType.dispatch,
                                  groupValue:
                                      model.gatePass.gatePassDeliveryType,
                                  dense: true,
                                  title: BoxText.label(
                                    DeliveryType.dispatch.text.toUpperCase(),
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                  onChanged: (v) {
                                    model.gatePass.gatePassDeliveryType =
                                        DeliveryType.dispatch;
                                    model.modelNotifyListeners();
                                  },
                                  activeColor: Colors.green,
                                  selected: false,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  contentPadding: const EdgeInsets.all(2),
                                  value: DeliveryType.receive,
                                  groupValue:
                                      model.gatePass.gatePassDeliveryType,
                                  dense: true,
                                  title: BoxText.label(
                                    DeliveryType.receive.text.toUpperCase(),
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                  onChanged: (v) {
                                    model.gatePass.gatePassDeliveryType =
                                        DeliveryType.receive;
                                    model.modelNotifyListeners();
                                  },
                                  activeColor: Colors.green,
                                  selected: false,
                                ),
                              ),
                            ],
                          ),
                          InputField(
                            placeholder: "Type The Vehicle Reg Number...",
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 5),
                            controller: vehicleRegNumberTextController,
                            icon: FaIcon(
                              FontAwesomeIcons.truck,
                              color: model.gatePass.vehicleRegNumber ==
                                      vehicleRegNumberValiTextController.text
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            fieldFocusNode: vehicleRegNumberTextFocusNode,
                            nextFocusNode: trailerNo1TextFocusNode,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.text,
                            isReadOnly: model.gatePass.externalId != null,
                            formatter: [
                              UpperCaseTextFormatter(),
                            ],
                            onChanged: (value) {
                              updateModelData(model);
                            },
                            enterPressed: () {
                              //used to close the keyboard on last text inputfield
                              // FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              var valMsg = "Vehicle Reg Number is required!";

                              if (value == null || value.isEmpty) {
                                model.setValidationMessage(valMsg);
                                return valMsg;
                              }
                              model.clearValidationMessage(valMsg);
                              return null;
                            },
                          ),
                          InputField(
                            placeholder: "Scan Vehicle Lisence Disc",
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 5),
                            controller: vehicleRegNumberValiTextController,
                            icon: FaIcon(
                              FontAwesomeIcons.truck,
                              color: model.gatePass.vehicleRegNumberValidation
                                          ?.isNotEmpty ??
                                      false
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            fieldFocusNode: vehicleRegNumberTextFocusNode,
                            nextFocusNode: trailerNo1TextFocusNode,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.text,
                            formatter: [
                              UpperCaseTextFormatter(),
                            ],
                            onChanged: (value) {
                              updateModelData(model);
                            },
                            enterPressed: () {
                              //used to close the keyboard on last text inputfield
                              // FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              var valMsg = "Vehicle Reg Number is required!";

                              if (value == null || value.isEmpty) {
                                model.setValidationMessage(valMsg);
                                return valMsg;
                              }
                              model.clearValidationMessage(valMsg);
                              return null;
                            },
                          ),
                          InputField(
                            placeholder: "Type The Trailer No 1...",
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 0),
                            controller: trailerNo1TextController,
                            icon: FaIcon(
                              FontAwesomeIcons.trailer,
                              color:
                                  model.gatePass.trailerRegNumberOne != null &&
                                          model.gatePass.trailerRegNumberOne!
                                              .isNotEmpty
                                      ? Colors.green
                                      : Colors.red,
                            ),
                            fieldFocusNode: trailerNo1TextFocusNode,
                            nextFocusNode: trailerNo2TextFocusNode,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.text,
                            formatter: [
                              UpperCaseTextFormatter(),
                            ],
                            onChanged: (value) {
                              updateModelData(model);
                            },
                            enterPressed: () {
                              //used to close the keyboard on last text inputfield
                              //FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              // var valMsg = "Trailer No 1 Number is required!";

                              // if (value == null || value.isEmpty) {
                              //   model.setValidationMessage(valMsg);
                              //   return valMsg;
                              // }
                              // model.clearValidationMessage(valMsg);
                              return null;
                            },
                          ),
                          InputField(
                            placeholder: "Type The Trailer No 2...",
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 0),
                            controller: trailerNo1TextController,
                            icon: FaIcon(
                              FontAwesomeIcons.trailer,
                              color:
                                  model.gatePass.trailerRegNumberOne != null &&
                                          model.gatePass.trailerRegNumberOne!
                                              .isNotEmpty
                                      ? Colors.green
                                      : Colors.red,
                            ),
                            fieldFocusNode: trailerNo2TextFocusNode,
                            nextFocusNode: null,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.text,
                            formatter: [
                              UpperCaseTextFormatter(),
                            ],
                            onChanged: (value) {
                              updateModelData(model);
                            },
                            enterPressed: () {
                              //used to close the keyboard on last text inputfield
                              FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              // var valMsg = "Trailer No 1 Number is required!";

                              // if (value == null || value.isEmpty) {
                              //   model.setValidationMessage(valMsg);
                              //   return valMsg;
                              // }
                              // model.clearValidationMessage(valMsg);
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8),
                            child: BoxText.label(
                              "Customer",
                              color: Colors.black,
                            ),
                          ),
                          ModalSheetSelection<BaseLookup>(
                            key: const Key("Customer"),
                            dropDownList: model.customers,
                            dropDownIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                              size: 23,
                            ),
                            onDropDownItemClick: (selectedItem) {
                              model.setCustomer(selectedItem);
                            },
                            onTapped: (isValid) {
                              var valMsg = "Customer is required!";
                              if (isValid = false) {
                                model.setValidationMessage(valMsg);
                                return valMsg;
                              } else {
                                model.clearValidationMessage(valMsg);
                              }
                            },
                            selectedItem: model.getCustomer(),
                          ),
                          InputField(
                            placeholder: "Driver Name",
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 4),
                            controller: driverNameTextController,
                            icon: FaIcon(
                              FontAwesomeIcons.idCard,
                              color: model.gatePass.driverName != null &&
                                      model.gatePass.driverName!.isNotEmpty
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            fieldFocusNode: driverdriverNameTextFocusNode,
                            nextFocusNode: null,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.text,
                            onChanged: (value) {
                              updateModelData(model);
                            },
                            enterPressed: () {
                              //used to close the keyboard on last text inputfield
                              FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              // var valMsg = "Trailer No 1 Number is required!";

                              // if (value == null || value.isEmpty) {
                              //   model.setValidationMessage(valMsg);
                              //   return valMsg;
                              // }
                              // model.clearValidationMessage(valMsg);
                              return null;
                            },
                          ),
                          InputField(
                            placeholder: "Driver ID",
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 0),
                            controller: driverIDTextController,
                            icon: FaIcon(
                              FontAwesomeIcons.idCard,
                              color: model.gatePass.driverIdNo != null &&
                                      model.gatePass.driverIdNo!.isNotEmpty
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            fieldFocusNode: driverIDTextFocusNode,
                            nextFocusNode: null,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.text,
                            onChanged: (value) {
                              updateModelData(model);
                            },
                            enterPressed: () {
                              //used to close the keyboard on last text inputfield
                              FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              // var valMsg = "Trailer No 1 Number is required!";

                              // if (value == null || value.isEmpty) {
                              //   model.setValidationMessage(valMsg);
                              //   return valMsg;
                              // }
                              // model.clearValidationMessage(valMsg);
                              return null;
                            },
                          ),
                          InputField(
                            placeholder: "Driver License No",
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 0),
                            controller: driverLisenceNoTextController,
                            icon: FaIcon(
                              FontAwesomeIcons.idCard,
                              color: model.gatePass.driverLicenceNo != null &&
                                      model.gatePass.driverLicenceNo!.isNotEmpty
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            fieldFocusNode: driverLisenceNoTextFocusNode,
                            nextFocusNode: null,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.text,
                            onChanged: (value) {
                              updateModelData(model);
                            },
                            enterPressed: () {
                              //used to close the keyboard on last text inputfield
                              FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              // var valMsg = "Trailer No 1 Number is required!";

                              // if (value == null || value.isEmpty) {
                              //   model.setValidationMessage(valMsg);
                              //   return valMsg;
                              // }
                              // model.clearValidationMessage(valMsg);
                              return null;
                            },
                          ),
                          ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.only(left: 9.0, right: 9),
                            //  leading: GatePassListIcon(statusId: model.gatePass.gatePassStatus),
                            trailing: GateStatusChip(
                                gatePassStatus: model.gatePass.gatePassStatus),
                            title: BoxText.label(
                              "Status",
                              color: Colors.black,
                            ),
                          ),
                          ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(left: 9.0),
                            subtitle: BoxText.caption(
                                model.gatePass.timeAtGate.toFormattedString()),
                            title: BoxText.label(
                              "Time At Gate",
                              color: Colors.black,
                            ),
                          ),
                          ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(left: 9.0),
                            subtitle: BoxText.caption(
                                model.gatePass.timeIn?.toString() ?? ""),
                            title: BoxText.label(
                              "Time In",
                              color: Colors.black,
                            ),
                          ),
                          ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(left: 9.0),
                            subtitle: BoxText.caption(
                                model.gatePass.timeOut?.toString() ?? ""),
                            title: BoxText.label(
                              "Time Out",
                              color: Colors.black,
                            ),
                          ),
                          // ListRadioBoolWithLabel(
                          //   label: "Documents Received ?",
                          //   value: model.gatePass.gatePassQuestions
                          //           ?.hasDeliveryDocuments ??
                          //       false,
                          //   onValueChanged: (Object? newValue) {
                          //     if (newValue is bool?) {
                          //       model.setDocRecievedChange(newValue);
                          //     }
                          //   },
                          // ),
                          // ListRadioBoolWithLabel(
                          //   label: "Containerised (Y/N)?",
                          //   value: model.gatePass.gatePassQuestions
                          //           ?.isContainerised ??
                          //       false,
                          //   onValueChanged: (Object? val) {
                          //     if (val is bool?) {
                          //       model.gatePass.gatePassQuestions
                          //           ?.isContainerised = val ?? false;
                          //       model.modelNotifyListeners();
                          //     }
                          //   },
                          // ),
                          // ListRadioBoolWithLabel(
                          //   label:
                          //       "Any visible damages/quality defects on the items/pallets/packaging (Y/N)?",
                          //   value: model.gatePass.gatePassQuestions
                          //           ?.hasDamagesDefects ??
                          //       false,
                          //   onValueChanged: (Object? val) {
                          //     if (val is bool?) {
                          //       model.gatePass.gatePassQuestions
                          //           ?.hasDamagesDefects = val ?? false;
                          //       model.modelNotifyListeners();
                          //     }
                          //   },
                          // ),
                          // ListRadioBoolWithLabel(
                          //   label:
                          //       "Does the qty delivered match the docs? (Y/N)?",
                          //   value: model.gatePass.gatePassQuestions
                          //           ?.qtyMatchedDocs ??
                          //       false,
                          //   onValueChanged: (Object? val) {
                          //     if (val is bool?) {
                          //       model.gatePass.gatePassQuestions
                          //           ?.qtyMatchedDocs = val ?? false;
                          //       model.modelNotifyListeners();
                          //     }
                          //   },
                          // ),
                          // ListRadioBoolWithLabel(
                          //   label: "Do the item numbers match the docs (Y/N)?",
                          //   value: model.gatePass.gatePassQuestions
                          //           ?.itemCodesMatchDocs ??
                          //       false,
                          //   onValueChanged: (Object? val) {
                          //     if (val is bool?) {
                          //       model.gatePass.gatePassQuestions
                          //           ?.itemCodesMatchDocs = val ?? false;
                          //       model.modelNotifyListeners();
                          //     }
                          //   },
                          // ),
                          // ListRadioBoolWithLabel(
                          //   label: "Was the delivery expected (Y/N)?",
                          //   value: model.gatePass.gatePassQuestions
                          //           ?.expectedDelivery ??
                          //       false,
                          //   onValueChanged: (Object? val) {
                          //     if (val is bool?) {
                          //       model.gatePass.gatePassQuestions
                          //           ?.expectedDelivery = val ?? false;
                          //       model.modelNotifyListeners();
                          //     }
                          //   },
                          // ),
                          // ListRadioBoolWithLabel(
                          //   label:
                          //       "Does the driver agree with the info captured (Y/N)?",
                          //   value:
                          //       model.gatePass.gatePassQuestions?.driverAgree ??
                          //           false,
                          //   onValueChanged: (Object? val) {
                          //     if (val is bool?) {
                          //       model.gatePass.gatePassQuestions?.driverAgree =
                          //           val ?? false;
                          //       model.modelNotifyListeners();
                          //     }
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Scaffold(
                    floatingActionButton: SpeedDial(
                      visible: model.gatePass.id.isEmptyOrNull,
                      icon: Icons.add_a_photo,
                      spaceBetweenChildren: 6,
                      activeIcon: Icons.close,
                      children: [
                        SpeedDialChild(
                          child: const Icon(Icons.camera_alt_outlined),
                          label: 'Take Photo',
                          onTap: () => model.goToCamView(FileStoreType.image),
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
                        SpeedDialChild(
                          child: const Icon(Icons.barcode_reader),
                          label: 'Barcode Scanner',
                          onTap: () =>
                              model.goToCamView(FileStoreType.documentScan),
                        ),
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
                                        if (fileItem.filestoreType ==
                                            FileStoreType
                                                .customerSignature.index)
                                          const FaIcon(
                                              FontAwesomeIcons.signature,
                                              size: 16,
                                              color: Colors.black),
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

            // model.gatePass.id == 0
            //     ? const Padding(
            //         padding: EdgeInsets.only(top: 100, left: 8, right: 8),
            //         child: Text("Scan your driver's license."),
            //       )
            //     : ListView(
            // children: [
            //   ListTile(
            //     dense: true,
            //     title: Text('LicenseNumber: ${model.rsaDriversLicense?.licenseNumber}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('ID No: ${model.rsaDriversLicense?.idNumber}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('ID No Type: ${model.rsaDriversLicense?.idNumberType}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Country Of Issue: ${model.rsaDriversLicense?.idCountryOfIssue}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('First Names: ${model.rsaDriversLicense?.firstNames}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Surname: ${model.rsaDriversLicense?.surname}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Birth Date: ${model.rsaDriversLicense?.birthDate}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Gender: ${model.rsaDriversLicense?.gender}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Driver Restrictions: ${model.rsaDriversLicense?.driverRestrictions}'),
            //   ),

            //   // ListTile(
            //   //   title: Text('issueDates: ${rsaDriversLicense?.issueDates}'),
            //   // ),

            //   ListTile(
            //     dense: true,
            //     title: Text('License Issue Number: ${model.rsaDriversLicense?.licenseIssueNumber}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('License Country Of Issue: ${model.rsaDriversLicense?.licenseCountryOfIssue}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Prdp Code: ${model.rsaDriversLicense?.prdpCode}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Prdp Expiry: ${model.rsaDriversLicense?.prdpExpiry}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Valid From: ${model.rsaDriversLicense?.validFrom}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Valid To: ${model.rsaDriversLicense?.validTo}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Vehicle Codes: ${model.rsaDriversLicense?.vehicleCodes}'),
            //   ),

            //   ListTile(
            //     dense: true,
            //     title: Text('Vehicle Restrictions: ${model.rsaDriversLicense?.vehicleRestrictions}'),
            //   ),
            // ],
          ),
        ),
      ),
      viewModelBuilder: () => GatePassEditViewModel(gatePass),
    );
  }
}
