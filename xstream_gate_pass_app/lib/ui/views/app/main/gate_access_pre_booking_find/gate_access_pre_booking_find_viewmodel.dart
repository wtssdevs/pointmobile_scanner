import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/loadcon_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';

import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessPreBookingFindViewModel extends BaseViewModel
    with AppViewBaseHelper {
  final log = getLogger('GateAccessPreBookingFindViewModel');
  final _scanningService = locator<ScanningService>();
  StreamSubscription<String>? streamSubscription;
  final TextEditingController filterController = TextEditingController();
  final TextEditingController voageNoController = TextEditingController();
  runStartupLogic() async {
    _scanningService.initialise(barcodeScanType: BarcodeScanType.loadConQrCode);
    //we can lter do scan image of vehicle number plate or ...
  }

  void startconnectionListen() {
    streamSubscription =
        _scanningService.rawStringStream.asBroadcastStream().listen((data) {
      log.i("data: $data");
      //convert to correct format
      //var loadCOn = LoadconQrCodeModel.fromJson(data);

      //try convert to model here
      //if model is not null then navigate to view
      //navigate to view

      //else
      //we allow to scan again on the same screen

      notifyListeners();
    });
  }

  void onFilterValueChanged(String value) {}

  void findGatePassByVoyageNo() {
    if (voageNoController.text.isNotEmpty) {
      log.i("voyageNo: ${voageNoController.text}");

      rebuildUi();
    }
  }

  void onBarcodeScanned(String barcode) {
    if (barcode.isNotEmpty) {
//      filterController.text = barcode;
      log.i("barcode: $barcode");
      rebuildUi();
    }
  }
}
