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
    this.selectedPanelCode,
    this.coverageFor,
    this.onPanelDoubleTap,
    this.onAddLineForSelectedPanel,
    this.onQuickPhotoForSelectedPanel,
    this.onMarkSelectedPanelClean,
    this.onMarkerTap,
  });

  static const String _assetPath =
      'assets/images/cms_container_schematic_unfolded.svg';
  static const double _majorCostThreshold = 500;

  final List<CmsInspectionLineEdit> lines;
  final ValueChanged<CmsInspectionPanelTapDetails> onPanelTap;
  final String? containerLabel;
  final String? selectedPanelCode;
  final CmsPanelCoverage Function(String panelCode)? coverageFor;
  final ValueChanged<CmsInspectionPanelTapDetails>? onPanelDoubleTap;
  final VoidCallback? onAddLineForSelectedPanel;
  final VoidCallback? onQuickPhotoForSelectedPanel;
  final VoidCallback? onMarkSelectedPanelClean;
  final ValueChanged<CmsInspectionLineEdit>? onMarkerTap;

  @override
  Widget build(BuildContext context) {
    final label = containerLabel?.trim();
    final mapHint = label == null || label.isEmpty ? 'Tap a panel' : label;
    final selectedPanel = _selectedPrimaryPanel();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: CmsInspectionPanels.viewBoxWidth /
                CmsInspectionPanels.viewBoxHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final schematicSize =
                    Size(constraints.maxWidth, constraints.maxHeight);
                final hintBadgeMaxWidth = constraints.maxWidth > 120
                    ? constraints.maxWidth - 96
                    : constraints.maxWidth - 16;
                final markers = _buildMarkers();

                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.white),
                      Positioned.fill(
                        child: SvgPicture.asset(
                          _assetPath,
                          fit: BoxFit.fill,
                        ),
                      ),
                      for (final panel in CmsInspectionPanels.values)
                        _PanelTapTarget(
                          panel: panel,
                          size: schematicSize,
                          selected: selectedPanel?.code == panel.code,
                          touched: _coverageFor(panel.code).hasLines,
                          lineCount: _coverageFor(panel.code).lineCount,
                          onTap: onPanelTap,
                          onDoubleTap: onPanelDoubleTap,
                        ),
                      for (final panel in CmsInspectionPanels.values)
                        _StatusDot(
                          panel: panel,
                          size: schematicSize,
                          coverage: _coverageFor(panel.code),
                        ),
                      for (final marker in markers)
                        _DamageMarker(
                          marker: marker,
                          size: schematicSize,
                          onTap: onMarkerTap,
                        ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: hintBadgeMaxWidth),
                          child: _MapBadge(label: mapHint),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: _MapBadge(
                          label:
                              '${_coveredPanelCount()} / ${CmsInspectionPanels.values.length}',
                          color: kcPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _PanelDetailStrip(
            panel: selectedPanel,
            coverage: selectedPanel == null
                ? const CmsPanelCoverage.pending()
                : _coverageFor(selectedPanel.code),
            onAddLine: onAddLineForSelectedPanel,
            onQuickPhoto: onQuickPhotoForSelectedPanel,
            onMarkClean: onMarkSelectedPanelClean,
          ),
          const _SchematicLegend(),
        ],
      ),
    );
  }

  CmsInspectionPanelDefinition? _selectedPrimaryPanel() {
    final panel = CmsInspectionPanels.byCode(selectedPanelCode);
    if (panel?.isPrimary != true) {
      return null;
    }

    return panel;
  }

  CmsPanelCoverage _coverageFor(String panelCode) {
    return coverageFor?.call(panelCode) ?? _fallbackCoverageFor(panelCode);
  }

  CmsPanelCoverage _fallbackCoverageFor(String panelCode) {
    var lineCount = 0;
    var unclassifiedLineCount = 0;
    var hasMajor = false;

    for (final line in lines) {
      final panel = CmsInspectionPanels.fromLine(line);
      if (panel?.code != panelCode) {
        continue;
      }

      lineCount++;
      if (line.isUnclassifiedDraft) {
        unclassifiedLineCount++;
      }
      if ((line.cost ?? 0) >= _majorCostThreshold) {
        hasMajor = true;
      }
    }

    if (lineCount == 0) {
      return const CmsPanelCoverage.pending();
    }

    return CmsPanelCoverage(
      lineCount: lineCount,
      unclassifiedLineCount: unclassifiedLineCount,
      severity: hasMajor ? CmsPanelSeverity.major : CmsPanelSeverity.minor,
    );
  }

  List<_SchematicMarker> _buildMarkers() {
    final markers = <_SchematicMarker>[];

    for (final line in lines) {
      final panel = CmsInspectionPanels.fromLine(line);
      if (panel == null || !panel.isPrimary) {
        continue;
      }

      final isDraft = line.isUnclassifiedDraft;
      markers.add(
        _SchematicMarker(
          line: line,
          x: line.panelX ?? panel.centerX,
          y: line.panelY ?? panel.centerY,
          severity: _severityForLine(line),
          isDraft: isDraft,
          tooltip: [
            panel.label,
            if (isDraft) 'Needs classification',
            line.inspectionItemName,
            line.inspectionDamageName,
            line.inspectionActionName,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' • '),
        ),
      );
    }

    return markers;
  }

  CmsPanelSeverity _severityForLine(CmsInspectionLineEdit line) {
    if ((line.cost ?? 0) >= _majorCostThreshold) {
      return CmsPanelSeverity.major;
    }

    return CmsPanelSeverity.minor;
  }

  int _coveredPanelCount() {
    final covered = <String>{};
    for (final line in lines) {
      final panel = CmsInspectionPanels.fromLine(line);
      if (panel?.isPrimary == true) {
        covered.add(panel!.code);
      }
    }

    return covered.length;
  }
}

class _PanelTapTarget extends StatelessWidget {
  const _PanelTapTarget({
    required this.panel,
    required this.size,
    required this.selected,
    required this.touched,
    required this.lineCount,
    required this.onTap,
    this.onDoubleTap,
  });

  final CmsInspectionPanelDefinition panel;
  final Size size;
  final bool selected;
  final bool touched;
  final int lineCount;
  final ValueChanged<CmsInspectionPanelTapDetails> onTap;
  final ValueChanged<CmsInspectionPanelTapDetails>? onDoubleTap;

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
        label: 'Select ${panel.label} on the container map',
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) =>
              onTap(_detailsFor(details.localPosition, width, height)),
          onDoubleTapDown: onDoubleTap == null
              ? null
              : (details) => onDoubleTap!(
                    _detailsFor(details.localPosition, width, height),
                  ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? kcPrimaryColor.withOpacity(0.12)
                        : touched
                            ? kcPrimaryColor.withOpacity(0.04)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected
                          ? kcPrimaryColor.withOpacity(0.65)
                          : touched
                              ? kcPrimaryColor.withOpacity(0.22)
                              : Colors.transparent,
                      width: selected ? 1.6 : 1,
                    ),
                  ),
                ),
              ),
              if (selected && panel.subRegions.isNotEmpty)
                for (final subRegion in panel.subRegions)
                  _SubRegionGuide(subRegion: subRegion),
              if (lineCount > 0)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: kcPrimaryColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      '$lineCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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

  CmsInspectionPanelTapDetails _detailsFor(
    Offset localPosition,
    double width,
    double height,
  ) {
    final localX = width <= 0
        ? 0.5
        : (localPosition.dx / width).clamp(0.0, 1.0).toDouble();
    final localY = height <= 0
        ? 0.5
        : (localPosition.dy / height).clamp(0.0, 1.0).toDouble();

    return CmsInspectionPanelTapDetails(
      panel: panel,
      x: panel.left + (panel.width * localX),
      y: panel.top + (panel.height * localY),
      localX: localX,
      localY: localY,
      subRegion: panel.subRegionAt(localX, localY),
    );
  }
}

class _SubRegionGuide extends StatelessWidget {
  const _SubRegionGuide({required this.subRegion});

  final CmsInspectionSubRegion subRegion;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(
          -1 + ((subRegion.left + (subRegion.width / 2)) * 2),
          -1 + ((subRegion.top + (subRegion.height / 2)) * 2),
        ),
        child: FractionallySizedBox(
          widthFactor: subRegion.width,
          heightFactor: subRegion.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kcPrimaryColor.withOpacity(0.04),
              border: Border.all(color: kcPrimaryColor.withOpacity(0.14)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.panel,
    required this.size,
    required this.coverage,
  });

  final CmsInspectionPanelDefinition panel;
  final Size size;
  final CmsPanelCoverage coverage;

  @override
  Widget build(BuildContext context) {
    final dotColor = _severityColor(coverage.severity);
    final isPending = coverage.severity == CmsPanelSeverity.pending;

    return Positioned(
      left: (size.width * panel.right) - 16,
      top: (size.height * panel.top) + 4,
      child: Tooltip(
        message:
            '${panel.label}: ${_severityLabel(coverage.severity)}${coverage.lineCount > 0 ? ' • ${coverage.lineCount} line(s)' : ''}',
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isPending ? Colors.white : dotColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isPending ? Colors.grey.shade500 : Colors.white,
              width: isPending ? 1.2 : 1.6,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DamageMarker extends StatelessWidget {
  const _DamageMarker({
    required this.marker,
    required this.size,
    required this.onTap,
  });

  final _SchematicMarker marker;
  final Size size;
  final ValueChanged<CmsInspectionLineEdit>? onTap;

  @override
  Widget build(BuildContext context) {
    final markerColor =
        marker.isDraft ? Colors.blueGrey : _severityColor(marker.severity);

    return Positioned(
      left: (size.width * marker.x) - 9,
      top: (size.height * marker.y) - 9,
      child: Tooltip(
        message: marker.tooltip,
        child: GestureDetector(
          onTap: onTap == null ? null : () => onTap!(marker.line),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: marker.isDraft ? Colors.white : markerColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: markerColor, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: marker.isDraft
                ? Icon(
                    Icons.photo_camera_outlined,
                    size: 10,
                    color: markerColor,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _PanelDetailStrip extends StatelessWidget {
  const _PanelDetailStrip({
    required this.panel,
    required this.coverage,
    this.onAddLine,
    this.onQuickPhoto,
    this.onMarkClean,
  });

  final CmsInspectionPanelDefinition? panel;
  final CmsPanelCoverage coverage;
  final VoidCallback? onAddLine;
  final VoidCallback? onQuickPhoto;
  final VoidCallback? onMarkClean;

  @override
  Widget build(BuildContext context) {
    final selectedPanel = panel;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: selectedPanel == null
          ? Row(
              children: [
                Icon(Icons.touch_app_outlined, color: Colors.grey[600]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap a container panel to see its IICL code, line count, and quick actions.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            selectedPanel.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          _CodePill(label: selectedPanel.cedexPrefix),
                          _SeverityPill(coverage: coverage),
                        ],
                      ),
                    ),
                    Text(
                      '${coverage.lineCount} line${coverage.lineCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if ((selectedPanel.subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    selectedPanel.subtitle!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
                if (coverage.hasUnclassifiedLines) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${coverage.unclassifiedLineCount} photo line${coverage.unclassifiedLineCount == 1 ? '' : 's'} need classification.',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                      ),
                      onPressed: onAddLine,
                      icon: const Icon(Icons.add),
                      label: const Text('Add damage line'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onQuickPhoto,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Quick photo'),
                    ),
                    Tooltip(
                      message: onMarkClean == null
                          ? 'Mark clean is coming soon'
                          : 'Mark this panel as inspected with no damage',
                      child: OutlinedButton.icon(
                        onPressed: onMarkClean,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark clean'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SchematicLegend extends StatelessWidget {
  const _SchematicLegend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _LegendItem(label: 'Pending', severity: CmsPanelSeverity.pending),
          _LegendItem(label: 'Clean', severity: CmsPanelSeverity.clean),
          _LegendItem(label: 'Minor', severity: CmsPanelSeverity.minor),
          _LegendItem(label: 'Major', severity: CmsPanelSeverity.major),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.severity,
  });

  final String label;
  final CmsPanelSeverity severity;

  @override
  Widget build(BuildContext context) {
    final isPending = severity == CmsPanelSeverity.pending;
    final color = _severityColor(severity);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: isPending ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isPending ? Colors.grey : color),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CodePill extends StatelessWidget {
  const _CodePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kcPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kcPrimaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({required this.coverage});

  final CmsPanelCoverage coverage;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(coverage.severity);
    final label = _severityLabel(coverage.severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({
    required this.label,
    this.color = Colors.black87,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SchematicMarker {
  const _SchematicMarker({
    required this.line,
    required this.x,
    required this.y,
    required this.tooltip,
    required this.severity,
    required this.isDraft,
  });

  final CmsInspectionLineEdit line;
  final double x;
  final double y;
  final String tooltip;
  final CmsPanelSeverity severity;
  final bool isDraft;
}

Color _severityColor(CmsPanelSeverity severity) {
  switch (severity) {
    case CmsPanelSeverity.clean:
      return const Color(0xFF1D9E75);
    case CmsPanelSeverity.minor:
      return const Color(0xFFEF9F27);
    case CmsPanelSeverity.major:
      return const Color(0xFFE24B4A);
    case CmsPanelSeverity.pending:
      return Colors.grey;
  }
}

String _severityLabel(CmsPanelSeverity severity) {
  switch (severity) {
    case CmsPanelSeverity.clean:
      return 'Clean';
    case CmsPanelSeverity.minor:
      return 'Minor';
    case CmsPanelSeverity.major:
      return 'Major';
    case CmsPanelSeverity.pending:
      return 'Pending';
  }
}
