import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/Widgets/gate_pass_status_chip_widget.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/labels/easy_label_text.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GatePassCard extends StatelessWidget with AppViewBaseHelper {
  final GatePassAccess gatePass;

  GatePassCard({
    Key? key,
    required this.gatePass,
    required this.onTap,
  }) : super(key: key);
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function(),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EasyLabelText(
                    label: translate('VehicleRegNumber'),
                    labelFontSize: 16,
                    value: gatePass.vehicleRegNumber ?? '',
                    textFontSize: 14,
                  ),
                  GateStatusChip(gatePassStatus: gatePass.gatePassStatus),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EasyLabelText(
                          label: translate('SiNumber'),
                          value: gatePass.siNumber ?? '',
                        ),
                        EasyLabelText(
                          label: translate('TransactionNo'),
                          value: gatePass.transactionNo ?? '',
                        ),
                        EasyLabelText(
                          label: translate('CustomerRefNo'),
                          value: gatePass.customerRefNo ?? '',
                        ),
                        EasyLabelText(
                          label: translate('TimeOut'),
                          value: gatePass.timeIn.toFormattedString(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EasyLabelText(
                          label: translate('Transporter'),
                          value: gatePass.transporterName ?? '',
                        ),
                        EasyLabelText(
                          label: translate('VoyageNo'),
                          value: gatePass.voyageNo ?? '',
                        ),
                        EasyLabelText(
                          label: translate('TimeAtGate'),
                          value: gatePass.timeAtGate.toFormattedString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
