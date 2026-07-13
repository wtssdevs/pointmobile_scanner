import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/cms_container_inspections_list_viewmodel.dart';

class CmsInspectionsFilterDrawer extends StatelessWidget {
  const CmsInspectionsFilterDrawer({
    super.key,
    required this.model,
  });

  final CmsContainerInspectionsListViewModel model;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter inspections',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close filters',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  const _FilterLabel('Default depot'),
                  const SizedBox(height: 8),
                  if (model.depots.length > 1)
                    DropdownButtonFormField<int>(
                      value: model.stagedDepotId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: model.depots
                          .map(
                            (depot) => DropdownMenuItem<int>(
                              value: depot.id,
                              child: Text(model.depotDisplayName(depot.id)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: model.changeStagedDepot,
                    )
                  else
                    _StaticSelectionTile(
                      icon: Icons.apartment_rounded,
                      label: model.stagedDepotDisplay,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: model.hasFiltersApplied ||
                              model.hasStagedFiltersApplied
                          ? () {
                              model.clearFilters();
                              Navigator.of(context).pop();
                            }
                          : null,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: model.hasDepots
                          ? () {
                              model.applyFilters();
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StaticSelectionTile extends StatelessWidget {
  const _StaticSelectionTile({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
