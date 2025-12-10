import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'gate_access_manual_list_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/nav_action_button.dart';

class GateAccessManualListView extends StatelessWidget {
  const GateAccessManualListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GateAccessManualListViewModel>.reactive(
      viewModelBuilder: () => GateAccessManualListViewModel(),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Manual Entries'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => model.refreshList(),
            ),
          ],
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => model.refreshList(),
                child: model.manualEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            verticalSpaceMedium,
                            Text(
                              'No manual entries in yard',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            verticalSpaceSmall,
                            Text(
                              'Tap "Check In" below to add entry',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: model.manualEntries.length,
                        itemBuilder: (context, index) {
                          final gatePass = model.manualEntries[index];
                          return _ManualEntryCard(
                            gatePass: gatePass,
                            onTap: () => model.openGatePass(gatePass),
                          );
                        },
                      ),
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              NavActionButton(
                label: "Check In",
                icon: Icons.login,
                color: Colors.green,
                onTap: () => model.showCheckInOptions(),
                isVisible: true,
              ),
              NavActionButton(
                label: "Check Out",
                icon: Icons.logout,
                color: Colors.red,
                onTap: model.hasInYardEntries
                    ? () => model.showCheckOutOptions()
                    : () {},
                isVisible: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualEntryCard extends StatelessWidget {
  final GatePassAccess gatePass;
  final VoidCallback onTap;

  const _ManualEntryCard({
    required this.gatePass,
    required this.onTap,
  });

  Color _getStatusBackgroundColor() {
    switch (gatePass.gatePassStatus) {
      case GatePassStatus.pending:
        return Colors.grey.shade300; 
      case GatePassStatus.atGate:
        return Colors.orange.shade100;
      case GatePassStatus.inYard:
        return Colors.grey.shade300; 
      case GatePassStatus.leftTheYard:
        return Colors.green.shade100;
      case GatePassStatus.rejectedEntry:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor() {
    switch (gatePass.gatePassStatus) {
      case GatePassStatus.pending:
        return Colors.black87; 
      case GatePassStatus.atGate:
        return Colors.orange.shade700;
      case GatePassStatus.inYard:
        return Colors.black87; 
      case GatePassStatus.leftTheYard:
        return Colors.green.shade700;
      case GatePassStatus.rejectedEntry:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _getStatusIcon() {
    switch (gatePass.gatePassStatus) {
      case GatePassStatus.pending:
            return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case GatePassStatus.atGate:
        return Icon(
          Icons.access_time,
          size: 16,
          color: _getStatusTextColor(),
        );
      case GatePassStatus.inYard:
        return Icon(
          Icons.keyboard_double_arrow_down,
          size: 16,
          color: Colors.red.shade700,
        );
      case GatePassStatus.leftTheYard:
        return Icon(
          Icons.check_circle_outline,
          size: 16,
          color: _getStatusTextColor(),
        );
      case GatePassStatus.rejectedEntry:
        return Icon(
          Icons.cancel_outlined,
          size: 16,
          color: _getStatusTextColor(),
        );
      default:
        return Icon(
          Icons.help_outline,
          size: 16,
          color: _getStatusTextColor(),
        );
    }
  }

  String _getStatusText() {
    switch (gatePass.gatePassStatus) {
      case GatePassStatus.pending:
        return 'Pending';
      case GatePassStatus.atGate:
        return 'At Gate';
      case GatePassStatus.inYard:
        return 'In Yard';
      case GatePassStatus.leftTheYard:
        return 'Left Yard';
      case GatePassStatus.rejectedEntry:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

Color _getTruckIconBackgroundColor() {
  return Colors.grey.shade300; 
}

Color _getTruckIconColor() {
  switch (gatePass.gatePassStatus) {
    case GatePassStatus.pending:
      return Colors.blue.shade700;
    case GatePassStatus.atGate:
      return Colors.orange.shade700; 
    case GatePassStatus.inYard:
      return Colors.red.shade700; 
    case GatePassStatus.leftTheYard:
      return Colors.green.shade700; 
    case GatePassStatus.rejectedEntry:
      return Colors.red.shade700; 
    default:
      return Colors.grey.shade700;
  }
}

Widget _getLeftIconWidget() {
  switch (gatePass.gatePassStatus) {
    case GatePassStatus.pending:

      return Icon(
        Icons.hourglass_empty,
        color: _getTruckIconColor(),
        size: 28,
      );
    case GatePassStatus.atGate:
      return Icon(
        Icons.access_time,
        color: _getTruckIconColor(),
        size: 28,
      );
    case GatePassStatus.inYard:
      return Icon(
        Icons.warehouse,
        color: _getTruckIconColor(),
        size: 28,
      );
    case GatePassStatus.leftTheYard:
      return Icon(
        Icons.local_shipping,
        color: _getTruckIconColor(),
        size: 28,
      );
    case GatePassStatus.rejectedEntry:
      return Icon(
        Icons.cancel,
        color: _getTruckIconColor(),
        size: 28,
      );
    default:
      return Icon(
        Icons.help,
        color: _getTruckIconColor(),
        size: 28,
      );
  }
}
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTruckIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _getLeftIconWidget(),
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gatePass.vehicleRegNumber ?? 'No Reg',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    verticalSpaceTiny,
                    Text(
                      'Transaction No: ${gatePass.transactionNo ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    if (gatePass.gatePassStatus == GatePassStatus.inYard &&
                        gatePass.timeIn != null) ...[
                      verticalSpaceTiny,
                      Text(
                        'Time In: ${gatePass.timeIn!.toLocal().toString().substring(0, 16).replaceAll('T', ' ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (gatePass.transporterName != null &&
                        gatePass.transporterName!.isNotEmpty) ...[
                      verticalSpaceTiny,
                      Text(
                        'Transporter: ${gatePass.transporterName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getStatusIcon(),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusTextColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}