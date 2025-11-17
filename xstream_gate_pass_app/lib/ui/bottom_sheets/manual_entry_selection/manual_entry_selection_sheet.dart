import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class ManualEntrySelectionSheet extends StatelessWidget {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const ManualEntrySelectionSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final action = request.data?['action'] as String? ?? 'checkin';
    final entries = request.data?['entries'] as List<GatePassAccess>? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          verticalSpaceSmall,
          Text(
            request.title ?? 'Select',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpaceSmall,
          Text(
            request.description ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          verticalSpaceMedium,
          if (action == 'checkin') ...[
            _OptionCard(
              label: 'BreakBulk',
              value: 'breakbulk',
              icon: Icons.inventory_2,
              color: Colors.brown,
              onTap: () {
                completer!(SheetResponse(
                  confirmed: true,
                  data: 'breakbulk',
                ));
              },
            ),
            verticalSpaceSmall,
            _OptionCard(
              label: 'Container',
              value: 'container',
              icon: Icons.inbox,
              color: Colors.blue,
              onTap: () {
                completer!(SheetResponse(
                  confirmed: true,
                  data: 'container',
                ));
              },
            ),
          ] else if (action == 'checkout' && entries.isNotEmpty) ...[
            ...entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _VehicleCard(
                    gatePass: entry,
                    onTap: () {
                      completer!(SheetResponse(
                        confirmed: true,
                        data: entry,
                      ));
                    },
                  ),
                )),
          ],
          verticalSpaceMedium,
          TextButton(
            onPressed: () => completer!(SheetResponse(confirmed: false)),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            horizontalSpaceSmall,
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final GatePassAccess gatePass;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.gatePass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.grey[700]),
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
                  Text(
                    gatePass.transactionNo ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
