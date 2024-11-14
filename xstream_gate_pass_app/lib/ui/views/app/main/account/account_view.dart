import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/account/account_view_model.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/wrappers/list_seperator_wrapper.dart';

class AccountView extends StatelessWidget {
  const AccountView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AccountViewModel>.reactive(
      viewModelBuilder: () => AccountViewModel(),
      onModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.handleStartUpLogic();
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 6,
            title: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.account_box,
                  ),
                ),
                Column(
                  children: [
                    BoxText.subheading(
                        model.currentLoginInformation?.showFullName ?? "")
                  ],
                ),
              ],
            ),
            titleSpacing: 10.0,
            leading: null,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  verticalSpaceSmall,
                  const ListDividerWrapper(
                    size: 2000,
                    child: BoxText.headingThree("Settings"),
                  ),
                  Card(
                    elevation: 8,
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      onTap: model.logout,
                      title: const BoxText.tileTitle(
                        "Logout",
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    child: ListTile(
                      leading: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.black,
                      ),
                      onTap: model.navigateToTermsView,
                      title: const BoxText.tileTitle(
                        "T&Cs - Privacy Policy",
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    child: ListTile(
                      leading: Icon(
                        model.hasConnection == false
                            ? Icons.offline_bolt
                            : Icons.online_prediction,
                        color: model.hasConnection == false
                            ? Colors.red
                            : Colors.green,
                      ),
                      title: BoxText.tileTitle(
                        "Status: ${model.showConnectionStatus} - ${model.connectivityResultDisplayName}",
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    child: ListTile(
                      onTap: () async {
                        model.gotoSyncList();
                      },
                      leading: Icon(
                        Icons.sync,
                        color:
                            model.syncCount > 0 ? Colors.orange : Colors.green,
                      ),
                      // onTap: model.navigateToTermsView,
                      title: BoxText.tileTitle(
                        "Sync Count: ${model.syncCount}",
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: AboutListTile(
                                dense: true,
                                applicationName: snapshot.data?.appName,
                                applicationVersion:
                                    'Version: ${snapshot.data?.version}.${snapshot.data?.buildNumber}',
                                applicationIcon: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "assets/wtssgrplogo.png"),
                                        fit: BoxFit.contain),
                                  ),
                                ),
                                icon: const Icon(Icons.info),
                                //should get all of this from app session info
                                child: const Text("About"),
                              ),
                            );

                          default:
                            return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
