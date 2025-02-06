import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/labels/easy_label_text.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/labels/left_label_right_value_display.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/listicons/gatepass_list_icon.dart';

class GatePassCard extends StatelessWidget {
  final GatePassAccess gatePass;

  const GatePassCard({
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
                    label: 'Vehicle',
                    labelFontSize: 16,
                    value: gatePass.vehicleRegNumber ?? '',
                    textFontSize: 14,
                  ),
                  _buildStatusChip(),
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
                          label: 'SI Number',
                          value: gatePass.siNumber ?? '',
                        ),
                        EasyLabelText(
                          label: 'TransactionNo',
                          value: gatePass.transactionNo ?? '',
                        ),
                        EasyLabelText(
                          label: 'Customer Ref',
                          value: gatePass.customerRefNo ?? '',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EasyLabelText(
                          label: 'Transporter',
                          value: gatePass.transporterName ?? '',
                        ),
                        EasyLabelText(
                          label: 'Voyage',
                          value: gatePass.voyageNo ?? '',
                        ),
                        EasyLabelText(
                          label: 'Time At Gate',
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

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (gatePass.gatePassStatus) {
      case GatePassStatus.pending:
        chipColor = Colors.grey;
        statusText = GatePassStatus.pending.displayName;
        break;
      case GatePassStatus.atGate:
        chipColor = Colors.orange;
        statusText = GatePassStatus.atGate.displayName;
        break;
      case GatePassStatus.inYard:
        chipColor = Colors.green;
        statusText = GatePassStatus.inYard.displayName;
        break;
      case GatePassStatus.leftTheYard:
        chipColor = Colors.blue;
        statusText = GatePassStatus.leftTheYard.displayName;
        break;
      default:
        chipColor = Colors.red;
        statusText = GatePassStatus.rejectedEntry.displayName;
    }

    return Chip(
      avatar: GatePassListIcon(statusId: gatePass.gatePassStatus),
      // CircleAvatar(
      //   backgroundColor: chipColor,
      //   child: Text(
      //     statusText[0],
      //     style: const TextStyle(color: Colors.white),
      //   ),
      // ),
      backgroundColor: Colors.grey.withOpacity(0.3),
      label: Text(
        statusText,
        //style: TextStyle(color: chipColor),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}
