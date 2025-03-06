import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_staff_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/visitor_status_Icon.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/Widgets/finder_app_bar.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/actions_cards/action_card_widget.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/empty_list_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/error_indicator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'gate_access_staff_list_viewmodel.dart';

class GateAccessStaffListView extends StackedView<GateAccessStaffListViewModel> {
  const GateAccessStaffListView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    GateAccessStaffListViewModel viewModel,
    Widget? child,
  ) {
    double searchWidth = getDeviceType(MediaQuery.of(context)) == DeviceScreenType.tablet ? MediaQuery.of(context).size.height * 0.8 : MediaQuery.of(context).size.height * 0.5;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: "Find by QR code values",
            iconSize: 28,
            onPressed: () async {
              viewModel.findGatePassByStaffQrCode();
            },
            icon: const Icon(
              Icons.find_in_page,
              color: kcPrimaryColor,
            ),
          ),
        ],
        //backgroundColor: Colors.blue,
        //leading: const SizedBox.shrink(),
        leadingWidth: 25, //shrinks leading space to allow bar to be full,
        title: FinderAppBar(
          controller: viewModel.filterController,
          searchWidth: searchWidth,
          onChanged: (value) async {
            viewModel.onFilterValueChanged(value);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ActionCardWidget(
          title: 'Scan Staff In',
          isSelected: viewModel.scanInOrOut == true,
          icon: Icons.login,
          color: Colors.green,
          onTap: viewModel.setScanStaffIn,
        ),
        ActionCardWidget(
          title: 'Scan Staff Out',
          isSelected: viewModel.scanInOrOut == false,
          icon: Icons.logout,
          color: Colors.red,
          onTap: viewModel.setScanStaffOut,
        ),
      ],
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.blue,
          color: Colors.white,
          onRefresh: () => Future.sync(
            () => viewModel.refreshList(),
          ),
          child: PagedListView.separated(
            pagingController: viewModel.pagingController,
            builderDelegate: PagedChildBuilderDelegate<GatePassStaffAccess>(
              itemBuilder: (context, entity, index) => Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: entity.gatePassStatus.value == GatePassStatus.inYard.value ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                    child: Icon(
                      entity.gatePassStatus.value == GatePassStatus.inYard.value ? Icons.login : Icons.logout,
                      color: Colors.white,
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.driverName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (entity.vehicleRegNumber != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          entity.vehicleRegNumber ?? "",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Time In: ${entity.timeIn?.toSocialMediaTime() ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Time Out: ${entity.timeOut?.toSocialMediaTime() ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      VisitorStatusIcon(gatePassStatus: entity.gatePassStatus),
                    ],
                  ),
                  trailing: QrImageView(
                    data: entity.staffCode, // Or any other unique identifier you want to encode
                    version: QrVersions.auto,
                    padding: const EdgeInsets.all(2),
                    constrainErrorBounds: true,
                    size: 55.0,
                  ),
                  onTap: () {
                    // Handle tap event - could show more details or navigate to detail view
                  },
                ),
              ),
              animateTransitions: true,
              transitionDuration: const Duration(milliseconds: 500),
              firstPageProgressIndicatorBuilder: (context) => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                  ),
                ),
              ),
              newPageProgressIndicatorBuilder: (context) => const Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                  ),
                ),
              ),
              firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                error: viewModel.pagingController.error,
                onTryAgain: () => viewModel.pagingController.refresh(),
              ),
              noItemsFoundIndicatorBuilder: (context) => EmptyListIndicator(
                onTryAgain: () => viewModel.pagingController.refresh(),
              ),
              newPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                error: viewModel.pagingController.error,
                onTryAgain: () => viewModel.pagingController.refresh(),
              ),
            ),
            separatorBuilder: (context, index) => const SizedBox(
              height: 2,
            ),
          ),

          // CustomScrollView(
          //   physics: const AlwaysScrollableScrollPhysics(),
          //   slivers: [
          //     PagedSliverList.separated(

          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(GateAccessStaffListViewModel viewModel) => SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(),
      );

  @override
  GateAccessStaffListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      GateAccessStaffListViewModel();
}
