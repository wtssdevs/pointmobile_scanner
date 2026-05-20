import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/main/cms_home_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/main/widgets/cms_shell_card.dart';

class CmsHomeView extends StatelessWidget {
  const CmsHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CmsHomeViewModel>.reactive(
      viewModelBuilder: () => CmsHomeViewModel(),
      onViewModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.handleStartUpLogic();
      }),
      builder: (context, model, child) => PopScope(
        canPop: false,
        child: Scaffold(
          //backgroundColor: Colors.grey[50],
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            elevation: 4,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('CMS Portal'),
            actions: [
              IconButton(
                onPressed: model.openSettings,
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'CMS settings',
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: kcPrimaryColor.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to CMS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${model.tenantDisplay} • ${model.userDisplay}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // CmsShellCard(
                //   icon: Icons.verified_user_outlined,
                //   title: model.isCmsLoggedIn
                //       ? 'CMS session active'
                //       : 'CMS session inactive',
                //   subtitle:
                //       'Tenant and user details are stored separately from XAC. System details live in settings.',
                // ),
                CmsShellCard(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Container inspections',
                  subtitle: 'Start or resume empty-container inspections using the synced CMS lookup master files.',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: model.openContainerInspections,
                ),
                CmsShellCard(
                  icon: Icons.settings_suggest_outlined,
                  title: 'CMS settings',
                  subtitle: 'Manage CMS session, connection, sync, and portal actions.',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: model.openSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
