import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'gate_access_manual_list_viewmodel.dart';

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
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => model.showCheckInOptions(),
                  icon: const Icon(Icons.login, size: 28),
                  label: const Text(
                    'Check In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: model.hasInYardEntries
                      ? () => model.showCheckOutOptions()
                      : null,
                  icon: const Icon(Icons.logout, size: 28),
                  label: const Text(
                    'Check Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
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

  Color _getStatusColor() {
    switch (gatePass.gatePassStatus) {
      case GatePassStatus.pending:
        return Colors.orange;
      case GatePassStatus.atGate:
        return Colors.blue;
      case GatePassStatus.inYard:
        return Colors.green;
      default:
        return Colors.grey;
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
      default:
        return 'Unknown';
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
                  color: _getStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  gatePass.gatePassStatus == GatePassStatus.inYard
                      ? Icons.check_circle
                      : Icons.access_time,
                  color: _getStatusColor(),
                  size: 28,
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
                      gatePass.transactionNo ?? 'No Transaction',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    verticalSpaceTiny,
                    Text(
                      'Time In: ${gatePass.timeIn?.toLocal().toString().substring(11, 16) ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
