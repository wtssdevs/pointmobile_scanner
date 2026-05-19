import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class CmsContainerSchematicView extends StatelessWidget {
  const CmsContainerSchematicView({
    super.key,
    required this.lines,
    required this.onPanelTap,
    this.containerLabel,
  });

  final List<CmsInspectionLineEdit> lines;
  final ValueChanged<CmsInspectionPanelTapDetails> onPanelTap;
  final String? containerLabel;

  @override
  Widget build(BuildContext context) {
    final label = containerLabel?.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tap a panel to start a damage line',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label == null || label.isEmpty
                          ? 'The dropdown editor still stays available for unusual locations.'
                          : 'Working on $label. The dropdown editor still stays available for unusual locations.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_coveredPanelCount()} / ${CmsInspectionPanels.values.length} panels touched',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kcPrimaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.38,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final schematicSize = Size(constraints.maxWidth, constraints.maxHeight);
                final markers = _buildMarkers();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.white),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: SvgPicture.asset(
                            'assets/images/cms_container_schematic.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      for (final panel in CmsInspectionPanels.values)
                        _PanelTapTarget(
                          panel: panel,
                          size: schematicSize,
                          highlighted: lines.any((line) => CmsInspectionPanels.fromLine(line)?.code == panel.code),
                          lineCount: lines.where((line) => CmsInspectionPanels.fromLine(line)?.code == panel.code).length,
                          onTap: onPanelTap,
                        ),
                      for (final marker in markers)
                        Positioned(
                          left: (constraints.maxWidth * marker.x) - 8,
                          top: (constraints.maxHeight * marker.y) - 8,
                          child: Tooltip(
                            message: marker.tooltip,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LegendChip(
                color: kcPrimaryColor,
                label: 'Tap panel',
                outlined: true,
              ),
              _LegendChip(
                color: Colors.red,
                label: 'Saved damage line',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_SchematicMarker> _buildMarkers() {
    final markers = <_SchematicMarker>[];

    for (final line in lines) {
      final panel = CmsInspectionPanels.fromLine(line);
      if (panel == null) {
        continue;
      }

      markers.add(
        _SchematicMarker(
          x: line.panelX ?? panel.centerX,
          y: line.panelY ?? panel.centerY,
          tooltip: [
            panel.label,
            line.inspectionItemName,
            line.inspectionDamageName,
            line.inspectionActionName,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' • '),
        ),
      );
    }

    return markers;
  }

  int _coveredPanelCount() {
    final covered = <String>{};
    for (final line in lines) {
      final panelCode = CmsInspectionPanels.fromLine(line)?.code;
      if (panelCode != null) {
        covered.add(panelCode);
      }
    }

    return covered.length;
  }
}

class _PanelTapTarget extends StatelessWidget {
  const _PanelTapTarget({
    required this.panel,
    required this.size,
    required this.highlighted,
    required this.lineCount,
    required this.onTap,
  });

  final CmsInspectionPanelDefinition panel;
  final Size size;
  final bool highlighted;
  final int lineCount;
  final ValueChanged<CmsInspectionPanelTapDetails> onTap;

  @override
  Widget build(BuildContext context) {
    final width = size.width * panel.width;
    final height = size.height * panel.height;
    return Positioned(
      left: size.width * panel.left,
      top: size.height * panel.top,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: 'Add damage line on ${panel.label}',
        child: GestureDetector(
          onTapUp: (details) {
            final localX = width <= 0 ? 0.5 : (details.localPosition.dx / width).clamp(0.0, 1.0);
            final localY = height <= 0 ? 0.5 : (details.localPosition.dy / height).clamp(0.0, 1.0);
            onTap(
              CmsInspectionPanelTapDetails(
                panel: panel,
                x: panel.left + (panel.width * localX),
                y: panel.top + (panel.height * localY),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: highlighted ? kcPrimaryColor.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: highlighted ? kcPrimaryColor.withOpacity(0.28) : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    panel.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Spacer(),
                if (lineCount > 0)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$lineCount line${lineCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    this.outlined = false,
  });

  final Color color;
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: outlined ? color : color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: outlined ? Colors.transparent : color,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SchematicMarker {
  const _SchematicMarker({
    required this.x,
    required this.y,
    required this.tooltip,
  });

  final double x;
  final double y;
  final String tooltip;
}
