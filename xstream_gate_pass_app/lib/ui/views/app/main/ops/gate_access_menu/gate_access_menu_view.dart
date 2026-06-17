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

class _GateAccessMenuViewState extends State<GateAccessMenuView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<GateAccessMenuViewModel>.reactive(
      viewModelBuilder: () => GateAccessMenuViewModel(),
      onViewModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.initialise();
      }),
          builder: (context, model, child) {
        final visibleItems = model.menuItems
            .where((item) => model.hasPermission(item.requiredPermission))
            .toList();
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
        //create list of menu items for action to route to new views for users to acces functions

        appBar: AppBar(
          title: const Text('Gate Access Menu'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            if (model.userBranches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: DropdownButtonFormField<int>(
                  value: model.selectedBranchId > 0 ? model.selectedBranchId : null,
                  decoration: const InputDecoration(
                    labelText: 'Branch (Company)',
                    border: OutlineInputBorder(),
                  ),
                  items: model.userBranches
                      .where((x) => (x.id ?? 0) > 0)
                      .map(
                        (x) => DropdownMenuItem<int>(
                          value: x.id!,
                          child: Text(x.displayName ?? x.name ?? 'Branch ${x.id}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      model.setSelectedBranchId(value);
                    }
                  },
                ),
              ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: visibleItems.length,
                itemBuilder: (context, index) {
                  var menuItem = visibleItems[index];
                  return MenuCard(
                      item: menuItem,
                      onTap: () {
                        model.navigateToView(menuItem.route);
                      });
                },
              ),
            ),
          ],
        ),
        );
      },
    );
  }
}