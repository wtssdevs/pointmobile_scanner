import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view_model.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/listicons/gatepass_list_icon.dart';

class GatePassEditView extends StatelessWidget {
  final GatePass gatePass;
  GatePassEditView({Key? key, required this.gatePass}) : super(key: key);

  final TextEditingController vehicleRegNumberTextController = TextEditingController();
  final FocusNode vehicleRegNumberTextFocusNode = FocusNode();
  final formKeyAtGate = GlobalKey<FormState>();
  onModelSet(GatePass data) {
    vehicleRegNumberTextController.text = data.vehicleRegNumber;
  }

  Future<bool> validateByFormKey(GlobalKey<FormState> formKey, BuildContext context, GatePassEditViewModel model) async {
    var isvalid = formKey.currentState!.validate();
    if (isvalid) {
      formKey.currentState!.save();
      return true;
    } else {
      model.notifyListeners();
      return false;
    }
  }

  Future<bool> validateForm(GatePassEditViewModel model, BuildContext context) async {
    //validate per status
    var isValid = false;
    switch (model.gatePass.gatePassStatus) {
      case 1: //GatePassStatus.atGate.value:
        isValid = await validateByFormKey(formKeyAtGate, context, model);
        if (isValid) {
          //model.authorizeEntry();
        } else {}
        break;
      default:
    }

    return isValid;
  }

  void updateModelData(GatePassEditViewModel model) {
    //gatePass.approvedQuantity = double.tryParse(approvedQuantityTextController.text) ?? 0;
    gatePass.vehicleRegNumber = vehicleRegNumberTextController.text;

    model.setModeldata(gatePass);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GatePassEditViewModel>.reactive(
      onModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.listenToModelSet(onModelSet);
        model.runStartupLogic();
        if (gatePass.id == 0) {
          FocusScope.of(context).requestFocus(vehicleRegNumberTextFocusNode);
        }
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            persistentFooterButtons: [
              Visibility(
                visible: model.gatePass.hasDeliveryDocuments == false,
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
                visible: model.gatePass.id == 0 && model.gatePass.hasDeliveryDocuments == true,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // valiate first
                    var isValid = await validateForm(model, context);
                    if (isValid == true) {
                      model.authorizeEntry();
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.arrowsDownToLine,
                    color: Colors.yellow,
                  ),
                  label: const Text("Authorize Entry"), // <-- Text
                ),
              ),
            ],
            appBar: AppBar(
              elevation: 6,
              title: const BoxText.headingThree("GatePass"),
              titleSpacing: 10.0,
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
                Visibility(
                  visible: model.gatePass.hasDeliveryDocuments == true,
                  child: ElevatedButton.icon(
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
                ),
              ],
            ),
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: formKeyAtGate,
                    child: Column(
                      children: [
                        InputField(
                          placeholder: "Type The Vehicle Reg Number...",
                          padding: const EdgeInsets.only(left: 4, right: 4, top: 5),
                          controller: vehicleRegNumberTextController,
                          icon: FaIcon(
                            FontAwesomeIcons.truck,
                            color: model.gatePass.vehicleRegNumber.isNotEmpty ? Colors.green : Colors.red,
                          ),
                          fieldFocusNode: vehicleRegNumberTextFocusNode,
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
                            var valMsg = "Vehicle Reg Number is required!";

                            if (value == null || value.isEmpty) {
                              model.setValidationMessage(valMsg);
                              return valMsg;
                            }
                            model.clearValidationMessage(valMsg);
                            return null;
                          },
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 9.0),
                          leading: GatePassListIcon(statusId: model.gatePass.gatePassStatus),
                          subtitle: BoxText.caption(model.gatePass.getGatePassStatusText()),
                          title: BoxText.label(
                            "Status",
                            color: Colors.black,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 9.0),
                          subtitle: BoxText.caption(model.gatePass.timeAtGate.toFormattedString()),
                          title: BoxText.label(
                            "Time At Gate",
                            color: Colors.black,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 9.0),
                          subtitle: BoxText.caption(model.gatePass.timeIn?.toString() ?? ""),
                          title: BoxText.label(
                            "Time In",
                            color: Colors.black,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 9.0),
                          subtitle: BoxText.caption(model.gatePass.timeOut?.toString() ?? ""),
                          title: BoxText.label(
                            "Time Out",
                            color: Colors.black,
                          ),
                        ),
                        CheckboxListTile(
                          contentPadding: const EdgeInsets.only(left: 9.0),
                          activeColor: Colors.green,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                          ),
                          dense: true,
                          //font change
                          title: const Text(
                            "Documents Received",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          ),
                          value: model.gatePass.hasDeliveryDocuments,
                          onChanged: (bool? val) {
                            model.setDocRecievedChange(val);
                          },
                        ),
                      ],
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
