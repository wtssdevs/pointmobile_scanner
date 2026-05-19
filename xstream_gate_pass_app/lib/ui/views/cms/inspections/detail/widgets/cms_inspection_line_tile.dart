import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';

class CmsInspectionLineTile extends StatelessWidget {
  const CmsInspectionLineTile({
    super.key,
    required this.line,
    required this.photoCount,
    required this.onAddPhoto,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    this.photoStatus,
    this.isPhotoBusy = false,
  });

  final CmsInspectionLineEdit line;
  final int photoCount;
  final String? photoStatus;
  final bool isPhotoBusy;
  final VoidCallback onAddPhoto;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = [line.inspectionLocationName, line.inspectionItemName, line.inspectionDamageName]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .join(' • ');
    final subtitle =
        [line.inspectionActionName, line.partNumber, line.descriptionOne].whereType<String>().where((item) => item.isNotEmpty).join(' • ');
    final panelLabel = CmsInspectionPanels.fromLine(line)?.label;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title.isEmpty ? 'Inspection line' : title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (panelLabel != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    panelLabel,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _InfoChip(
                    icon: Icons.photo_library_outlined,
                    label: '$photoCount photo${photoCount == 1 ? '' : 's'}',
                  ),
                  if (photoStatus != null)
                    _InfoChip(
                      icon: Icons.cloud_upload_outlined,
                      label: photoStatus!,
                      accentColor: photoStatus!.contains('issue') ? Colors.red : Colors.blueGrey,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Qty ${line.qty ?? 0} • Cost ${line.cost ?? 0} • Labour ${line.labourQty ?? 0} x ${line.labourRate ?? 0}',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: 'Add photo',
              onPressed: isPhotoBusy ? null : onAddPhoto,
              icon: isPhotoBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
            ),
            IconButton(
              tooltip: 'Edit line',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Duplicate line',
              onPressed: onDuplicate,
              icon: const Icon(Icons.copy_all_outlined),
            ),
            IconButton(
              tooltip: 'Delete line',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.accentColor = Colors.blueGrey,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
