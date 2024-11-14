import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';

import 'package:xstream_gate_pass_app/core/enums/gate_pass_type.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/empty_list_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/error_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/labels/top_label_bottom_value_display.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/listicons/gatepass_list_icon.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/search/search_app_bar.dart';

class GatePassView extends StatelessWidget {
  const GatePassView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double searchWidth =
        getDeviceType(MediaQuery.of(context)) == DeviceScreenType.tablet
            ? MediaQuery.of(context).size.height * 0.8
            : MediaQuery.of(context).size.height * 0.5;
    return ViewModelBuilder<GatePassViewModel>.reactive(
      onModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
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
            //backgroundColor: Colors.blue,
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
          floatingActionButton: FloatingActionButton(
            //backgroundColor: Colors.white,
            onPressed: () async {
              model.onAddNewGatePass();
            },
            child: const FaIcon(FontAwesomeIcons.listCheck),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              backgroundColor: Colors.blue,
              color: Colors.white,
              onRefresh: () => Future.sync(
                () => model.refreshList(),
              ),
              child: PagedListView.separated(
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: GatePassListIcon(
                                      statusId: entity.gatePassStatus),
                                ),
                                TopLabelWithTextWidget(
                                  label: "Status", //referenceNumber
                                  value: entity.getGatePassStatusText(),
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                                TopLabelWithTextWidget(
                                  label: "Vehicle Reg No ", //referenceNumber
                                  value: entity.vehicleRegNumber,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TopLabelWithTextWidget(
                                  label: "Time At Gate ", //referenceNumber
                                  value:
                                      entity.timeAtGate?.toFormattedString() ??
                                          "",
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                                TopLabelWithTextWidget(
                                  label: "Time In ", //referenceNumber
                                  value:
                                      entity.timeIn?.toFormattedString() ?? "",
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                                TopLabelWithTextWidget(
                                  label: "Time Out ", //referenceNumber
                                  value:
                                      entity.timeOut?.toFormattedString() ?? "",
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TopLabelWithTextWidget(
                                  label: "Customer", //referenceNumber
                                  value: entity.customerName ?? "",
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                                TopLabelWithTextWidget(
                                  label: "Gatepass Type ", //referenceNumber
                                  value: GatePassType.collection
                                      .mapToEnum(entity.gatePassType ?? 0)
                                      .displayName,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                                TopLabelWithTextWidget(
                                  label: "Transporter ", //referenceNumber
                                  value: entity.transporterName ?? "",
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
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
        ),
      ),
      viewModelBuilder: () => GatePassViewModel(),
    );
  }
}
