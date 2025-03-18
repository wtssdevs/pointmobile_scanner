import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/menu_card.dart';

import 'gate_access_menu_viewmodel.dart';

class GateAccessMenuView extends StatefulWidget {
  const GateAccessMenuView({Key? key}) : super(key: key);

  @override
  _GateAccessMenuViewState createState() => _GateAccessMenuViewState();
}

class _GateAccessMenuViewState extends State<GateAccessMenuView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<GateAccessMenuViewModel>.reactive(
      viewModelBuilder: () => GateAccessMenuViewModel(),
      onViewModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.initialise();
      }),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        //create list of menu items for action to route to new views for users to acces functions

        appBar: AppBar(
          title: const Text('Gate Access Menu'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: model.menuItems.length,
          itemBuilder: (context, index) {
            var menuItem = model.menuItems[index];
            return Visibility(
              visible: model.hasPermission(menuItem.requiredPermission),
              child: MenuCard(
                  item: menuItem,
                  onTap: () {
                    model.navigateToView(menuItem.route);
                  }),
            );
          },
        ),
      ),
    );
  }
}
