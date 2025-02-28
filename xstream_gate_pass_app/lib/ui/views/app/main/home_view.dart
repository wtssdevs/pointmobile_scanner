import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:animations/animations.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/account/account_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/home_view_model.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/gate_access_menu_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_view.dart';

// ignore: must_be_immutable
class HomeView extends StatelessWidget {
  int? tabIndex;
  HomeView({Key? key, this.tabIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? getViewForIndex(int index, HomeViewModel model) {
      if (index >= 0) {
        switch (index) {
          case 0:
            //return const GatePassView();
            return const GateAccessMenuView();

          case 1:
            return const AccountView();
        }
      }
      return null;
    }

    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) {
        SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) {
            model.handleStartUpLogic(tabIndex);
          },
        );
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: model.currentTabIndex,
            onTap: model.setTabIndex,
            items: const [
              BottomNavigationBarItem(
                label: "GatePass",
                icon: FaIcon(FontAwesomeIcons.buildingLock),
                activeIcon: FaIcon(FontAwesomeIcons.buildingLock),
              ),
              BottomNavigationBarItem(
                label: "Account",
                icon: Icon(Icons.person),
                activeIcon: Icon(Icons.person),
              )
            ],
          ),
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                child: child,
              );
            },
            child: getViewForIndex(model.currentTabIndex, model),
          ),
        ),
      ),
    );
  }
}
