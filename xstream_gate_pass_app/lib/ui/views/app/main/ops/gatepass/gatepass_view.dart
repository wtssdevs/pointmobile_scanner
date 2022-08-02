import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/device_screen_type.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/empty_list_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/error_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/search/search_app_bar.dart';

class GatePassView extends StatelessWidget {
  const GatePassView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double searchWidth = getDeviceType(MediaQuery.of(context)) == DeviceScreenType.Tablet
        ? MediaQuery.of(context).size.height * 0.8
        : MediaQuery.of(context).size.height * 0.5;
    return ViewModelBuilder<GatePassViewModel>.reactive(
      onModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              leading: const SizedBox.shrink(),
              leadingWidth: 0, //shrinks leading space to allow bar to be full,
              title: SearchAppBar(
                controller: model.filterController,
                searchWidth: searchWidth,
                onChanged: (value) {
                  model.onFilterValueChanged(value);
                },
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: RefreshIndicator(
              backgroundColor: Colors.blue,
              color: Colors.white,
              onRefresh: () => Future.sync(
                () => model.pagingController.refresh(),
              ),
              child: CustomScrollView(
                slivers: [
                  PagedSliverList.separated(
                    pagingController: model.pagingController,
                    builderDelegate: PagedChildBuilderDelegate<GatePass>(
                      itemBuilder: (context, entity, index) => InkWell(
                        onTap: () => model.goToDetail(entity),
                        child: (Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const BoxText.bodyListheading("Vehicle Reg No: "),
                                    Text(entity.vehicleRegNumber),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const BoxText.bodyListheading("License No: "),
                                    Text(entity.driverLicenseNo ?? ""),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const BoxText.bodyListheading("Status: "),
                                    Text(entity.getGatePassStatusText()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const BoxText.bodyListheading("Time At Gate: "),
                                    Text(entity.timeAtGate?.toString() ?? ""),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const BoxText.bodyListheading("Time In: "),
                                    Text(entity.timeIn?.toString() ?? ''),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const BoxText.bodyListheading("Time Out: "),
                                    Text(entity.timeOut?.toString() ?? ''),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
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
                        error: model.pagingController.error,
                        onTryAgain: () => model.pagingController.refresh(),
                      ),
                      noItemsFoundIndicatorBuilder: (context) => EmptyListIndicator(
                        onTryAgain: () => model.pagingController.refresh(),
                      ),
                      newPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                        error: model.pagingController.error,
                        onTryAgain: () => model.pagingController.refresh(),
                      ),
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      viewModelBuilder: () => GatePassViewModel(),
    );
  }
}
