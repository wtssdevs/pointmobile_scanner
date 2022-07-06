import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/device_screen_type.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/search/search_app_bar.dart';

class GatePassView extends StatelessWidget {
  const GatePassView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double searchWidth = getDeviceType(MediaQuery.of(context)) == DeviceScreenType.Tablet
        ? MediaQuery.of(context).size.height * 0.8
        : MediaQuery.of(context).size.height * 0.5;
    return ViewModelBuilder<GatePassViewModel>.reactive(
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
              leading: const SizedBox.shrink(),
              leadingWidth: 0, //shrinks leading space to allow bar to be full,
              title: SearchAppBar(
                controller: model.filterController,
                searchWidth: searchWidth,
                onChanged: (value) {
                  model.onFilterValueChanged(value);
                },
              ),
            ),
            body: ListView(
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
      viewModelBuilder: () => GatePassViewModel(),
    );
  }
}
