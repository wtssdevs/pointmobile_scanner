import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view_model.dart';

class GatePassEditView extends StatelessWidget {
  final GatePass gatePass;
  const GatePassEditView({Key? key, required this.gatePass}) : super(key: key);

  onModelSet(GatePass data) {}

  Future<void> validateForm(GatePassEditViewModel model, BuildContext context) async {
    var isvalid = model.formKey.currentState!.validate();
    if (isvalid && model.showValidation == false) {
      model.formKey.currentState!.save();
      FocusScope.of(context).requestFocus(FocusNode()); //clears keyboard
      await model.save();
    } else {
      //check validation messages toast
      model.notifyListeners();
    }
  }

  void updateModelData(GatePassEditViewModel model) {
    //gatePass.approvedQuantity = double.tryParse(approvedQuantityTextController.text) ?? 0;
    //gatePass.invoiceNo = invoiceNoTextController.text;

    model.setModeldata(gatePass);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GatePassEditViewModel>.reactive(
      onModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              elevation: 6,
              title: const BoxText.headingThree("GatePass"),
              titleSpacing: 10.0,
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () async {
                    await validateForm(model, context);
                  },
                  icon: const Icon(
                    Icons.save,
                    color: kcButtonPrimarySaveColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            resizeToAvoidBottomInset: true,
            body: model.rsaDriversLicense == null
                ? const Padding(
                    padding: EdgeInsets.only(top: 100, left: 8, right: 8),
                    child: Text("Scan your driver's license."),
                  )
                : ListView(
                    children: [
                      ListTile(
                        dense: true,
                        title: Text('LicenseNumber: ${model.rsaDriversLicense?.licenseNumber}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('ID No: ${model.rsaDriversLicense?.idNumber}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('ID No Type: ${model.rsaDriversLicense?.idNumberType}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Country Of Issue: ${model.rsaDriversLicense?.idCountryOfIssue}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('First Names: ${model.rsaDriversLicense?.firstNames}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Surname: ${model.rsaDriversLicense?.surname}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Birth Date: ${model.rsaDriversLicense?.birthDate}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Gender: ${model.rsaDriversLicense?.gender}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Driver Restrictions: ${model.rsaDriversLicense?.driverRestrictions}'),
                      ),

                      // ListTile(
                      //   title: Text('issueDates: ${rsaDriversLicense?.issueDates}'),
                      // ),

                      ListTile(
                        dense: true,
                        title: Text('License Issue Number: ${model.rsaDriversLicense?.licenseIssueNumber}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('License Country Of Issue: ${model.rsaDriversLicense?.licenseCountryOfIssue}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Prdp Code: ${model.rsaDriversLicense?.prdpCode}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Prdp Expiry: ${model.rsaDriversLicense?.prdpExpiry}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Valid From: ${model.rsaDriversLicense?.validFrom}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Valid To: ${model.rsaDriversLicense?.validTo}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Vehicle Codes: ${model.rsaDriversLicense?.vehicleCodes}'),
                      ),

                      ListTile(
                        dense: true,
                        title: Text('Vehicle Restrictions: ${model.rsaDriversLicense?.vehicleRestrictions}'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      viewModelBuilder: () => GatePassEditViewModel(gatePass),
    );
  }
}
