import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class CmsInspectableContainerCard extends StatelessWidget {
  const CmsInspectableContainerCard({
    super.key,
    required this.container,
    required this.actionLabel,
    required this.canOpen,
    this.onTap,
  });

  final CmsInspectableContainer container;
  final String actionLabel;
  final bool canOpen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    String? shippingLineLabel;
    for (final value in [
      container.shippingLineCode,
      container.shippingLineName
    ]) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) {
        shippingLineLabel = trimmed;
        break;
      }
    }
    final typeLabel = [
      container.containerSize,
      container.containerType,
      container.containerIsoType
    ]
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(' • ');
    final actionIcon = !canOpen
        ? Icons.check_circle_outline_rounded
        : container.canResumeInspection
            ? Icons.play_arrow_rounded
            : Icons.add_task_rounded;
    final typeBadgeColor =
        container.isMechanical ? Colors.deepOrange : Colors.indigo;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: canOpen ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          container.containerNo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          container.transactionNo,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _InspectionTypePill(
                        label: container.inspectionTypeLabel,
                        backgroundColor: typeBadgeColor.withOpacity(0.12),
                        foregroundColor: typeBadgeColor,
                      ),
                      const SizedBox(height: 8),
                      _StatusPill(status: container.cardStatus),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  if (shippingLineLabel != null)
                    _InfoChip(
                      icon: Icons.business_outlined,
                      label: shippingLineLabel,
                    ),
                  if (typeLabel.isNotEmpty)
                    _InfoChip(
                      icon: Icons.inventory_2_outlined,
                      label: typeLabel,
                    ),
                  _InfoChip(
                    icon: Icons.fact_check_outlined,
                    label: container.conditionLabel,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    container.depotArrivalDateTime != null
                        ? 'Depot arrival ${container.depotArrivalDateTime!.toFormattedString()}'
                        : 'Depot arrival pending',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: canOpen ? onTap : null,
                      icon: Icon(actionIcon),
                      label: Text(actionLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: container.canResumeInspection
                            ? kcPrimaryColor
                            : Colors.teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[200],
                        disabledForegroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey[700]),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionTypePill extends StatelessWidget {
  const _InspectionTypePill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final Color backgroundColor;
    final Color foregroundColor;

    switch (normalized) {
      case 'inprogress':
        backgroundColor = kcPrimaryColor.withOpacity(0.14);
        foregroundColor = kcPrimaryColor;
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.14);
        foregroundColor = Colors.green[800]!;
        break;
      case 'blocked':
        backgroundColor = Colors.orange.withOpacity(0.16);
        foregroundColor = Colors.orange[900]!;
        break;
      case 'ready':
      default:
        backgroundColor = Colors.teal.withOpacity(0.14);
        foregroundColor = Colors.teal[800]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
