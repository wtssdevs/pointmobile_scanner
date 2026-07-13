import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class CmsInspectableContainerCard extends StatelessWidget {
  const CmsInspectableContainerCard({
    super.key,
    required this.container,
    required this.actionLabel,
    this.onTap,
  });

  final CmsInspectableContainer container;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    String? shippingLineLabel;
    for (final value in [container.shippingLineCode, container.shippingLineName]) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) {
        shippingLineLabel = trimmed;
        break;
      }
    }
    final typeLabel = [container.containerSize, container.containerType, container.containerIsoType]
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(' • ');
    final statusLabel = (container.statusDisplayName?.trim().isNotEmpty == true)
        ? container.statusDisplayName!.trim()
        : (container.statusName?.trim() ?? '');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      container.containerNo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _HeaderBadge(container: container),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  if (container.transactionNo.trim().isNotEmpty)
                    _InfoChip(
                      icon: Icons.confirmation_number_outlined,
                      label: container.transactionNo.trim(),
                    ),
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
                  if (statusLabel.isNotEmpty)
                    _InfoChip(
                      icon: Icons.flag_outlined,
                      label: statusLabel,
                    ),
                  if (container.isReefer)
                    const _InfoChip(
                      icon: Icons.ac_unit_rounded,
                      label: 'Reefer',
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                container.depotArrivalDateTime != null
                    ? 'Depot arrival ${container.depotArrivalDateTime!.toFormattedString()}'
                    : 'Depot arrival pending',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              if (container.hasLastInspection) ...[
                const SizedBox(height: 12),
                _LastInspectionBlock(container: container),
              ],
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(
                    container.canResumeInspection ? Icons.play_arrow_rounded : Icons.chevron_right_rounded,
                  ),
                  label: Text(actionLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: container.canResumeInspection ? kcPrimaryColor : Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.container});

  final CmsInspectableContainer container;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color background;
    final Color foreground;

    if (container.canResumeInspection) {
      label = 'Open inspection';
      background = kcPrimaryColor.withOpacity(0.14);
      foreground = kcPrimaryColor;
    } else if (!container.hasLastInspection) {
      label = 'No inspections';
      background = Colors.grey.withOpacity(0.16);
      foreground = Colors.grey[700]!;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LastInspectionBlock extends StatelessWidget {
  const _LastInspectionBlock({required this.container});

  final CmsInspectableContainer container;

  @override
  Widget build(BuildContext context) {
    final byLine = container.lastInspectionByLine;
    final conditionName = container.lastInspectionConditionTypeName?.trim() ?? '';
    final secondLineParts = <String>[
      if (byLine.isNotEmpty) byLine,
      if (conditionName.isNotEmpty) conditionName,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 16, color: Colors.blueGrey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  container.lastInspectionSummary,
                  style: TextStyle(
                    color: Colors.blueGrey[900],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (secondLineParts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                secondLineParts.join(' • '),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (!container.lastInspectionIsCurrentVisit) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'Previous visit',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
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
