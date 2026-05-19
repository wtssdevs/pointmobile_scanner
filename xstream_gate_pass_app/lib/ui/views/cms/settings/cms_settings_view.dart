import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/main/widgets/cms_shell_card.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/settings/cms_settings_viewmodel.dart';

class CmsSettingsView extends StackedView<CmsSettingsViewModel> {
  const CmsSettingsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CmsSettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('CMS Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: viewModel.close,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CMS session',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${viewModel.tenantDisplay} • ${viewModel.userDisplay}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Depots: ${viewModel.depotCount} • Yards: ${viewModel.yardCount}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: viewModel.busy(CmsSettingsViewModel.refreshSessionKey) ? null : viewModel.refreshSessionInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: viewModel.busy(CmsSettingsViewModel.refreshSessionKey)
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh session info'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Inspection master files',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: viewModel.busy(CmsSettingsViewModel.syncAllKey) ? null : viewModel.syncAll,
                    icon: viewModel.busy(CmsSettingsViewModel.syncAllKey)
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded),
                    label: const Text('Sync all'),
                  ),
                ],
              ),
            ),
            if (viewModel.latestError != null && viewModel.latestError!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.amber[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      viewModel.latestError!,
                      style: TextStyle(color: Colors.amber[900], fontSize: 12),
                    ),
                  ),
                ),
              ),
            ...viewModel.stores.map(
              (store) => _StoreSyncCard(
                store: store,
                meta: viewModel.metaFor(store),
                isSyncing: viewModel.isStoreSyncing(store),
                progress: viewModel.latestProgress,
                onSync: () => viewModel.syncStore(store),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  CmsSettingsViewModel viewModelBuilder(BuildContext context) => CmsSettingsViewModel();

  @override
  void onViewModelReady(CmsSettingsViewModel viewModel) {
    viewModel.initialise();
  }
}

class _StoreSyncCard extends StatelessWidget {
  const _StoreSyncCard({
    required this.store,
    required this.meta,
    required this.isSyncing,
    required this.progress,
    required this.onSync,
  });

  final CmsMasterFileStore<CmsInspectionLookupBase> store;
  final CmsStoreSyncMeta? meta;
  final bool isSyncing;
  final CmsSyncProgress? progress;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final subtitle = isSyncing && progress?.storeBase == store.storeBase ? (progress?.message ?? 'Sync in progress') : _buildSummary();

    return CmsShellCard(
      icon: Icons.inventory_2_outlined,
      title: store.displayName,
      subtitle: subtitle,
      trailing: isSyncing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              onPressed: onSync,
              icon: const Icon(Icons.sync_rounded),
              tooltip: 'Sync ${store.displayName}',
            ),
      onTap: isSyncing ? null : onSync,
    );
  }

  String _buildSummary() {
    final parts = <String>[
      '${meta?.itemCount ?? 0} cached',
    ];

    if (meta?.lastSuccessfulSyncAt != null) {
      parts.add('Last sync ${meta!.lastSuccessfulSyncAt.toFormattedString()}');
    } else {
      parts.add('Not synced yet');
    }

    if (meta?.lastError != null && meta!.lastError!.isNotEmpty) {
      parts.add('Error: ${meta!.lastError!}');
    }

    return parts.join(' • ');
  }
}
