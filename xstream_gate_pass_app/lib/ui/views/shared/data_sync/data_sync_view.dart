import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/labels/top_label_bottom_value_display.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/data_sync/data_sync_view_model.dart';

class DataSyncView extends StatelessWidget {
  const DataSyncView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DataSyncViewModel>.reactive(
      viewModelBuilder: () => DataSyncViewModel(),
      onModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 6,
            title: BoxText.headingThree("To Sync: ${model.sync.length}"),
            titleSpacing: 10.0,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () async {
                  model.syncData();
                },
                icon: const Icon(
                  Icons.sync_alt,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ],
          ),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: RefreshIndicator(
              //color: kcMediumGreyColor,
              //backgroundColor: Colors.blue,
              onRefresh: model.onRefresh,
              child: CustomScrollView(
                slivers: [
                  if (model.hasSyncTasks && model.isExecuting)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.redAccent,
                        valueColor: AlwaysStoppedAnimation(Colors.green),
                        minHeight: 15,
                      ),
                    ),
                  model.hasSyncTasks
                      ? SliverList(
                          // Use a delegate to build items as they're scrolled on screen.
                          delegate: SliverChildBuilderDelegate(
                            // The builder function returns a ListTile with a title that
                            // displays the index of the current item.
                            (context, index) {
                              var stop = model.sync[index];

                              return Card(
                                elevation: 8,
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        if (stop.hasError)
                                          const FittedBox(
                                            fit: BoxFit.fill,
                                            child: Icon(
                                              Icons.error_outline,
                                              size: 42,
                                              color: Colors.red,
                                            ),
                                          ),
                                        const FittedBox(
                                          fit: BoxFit.fill,
                                          child: FaIcon(
                                            FontAwesomeIcons.clockRotateLeft,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        BoxText.body(
                                          "#${stop.stopId} ${BackgroundJobType.none.mapToEnum(stop.jobType).displayName}",
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.grey[300],
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              BoxText.body(
                                                "Try Count",
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              BoxText.body(
                                                stop.tryCount.toString(),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    verticalSpaceSmall,
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TopLabelWithTextWidget(label: "Task Creation Time", value: stop.creationTime.toDateTime().toFormattedString()),
                                        TopLabelWithTextWidget(
                                          label: "Task Next Try Time",
                                          value: stop.nextTryTime.toDateTime().toFormattedString(),
                                        ),
                                        TopLabelWithTextWidget(
                                          label: "Task Last Try Time",
                                          value: stop.lastTryTime.toDateTime().toFormattedString(),
                                        ),
                                      ],
                                    ),
                                    verticalSpaceSmall,
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (stop.hasError)
                                          const FittedBox(
                                            fit: BoxFit.fill,
                                            child: Icon(
                                              Icons.error_outline,
                                              size: 42,
                                              color: Colors.red,
                                            ),
                                          ),
                                        if (stop.hasError == false)
                                          const FittedBox(
                                            fit: BoxFit.fill,
                                            child: Icon(
                                              Icons.check,
                                              size: 42,
                                              color: Colors.green,
                                            ),
                                          ),
                                        TopLabelWithTextWidget(
                                          label: "Error Message",
                                          value: stop.errorMessage.isEmpty ? "None" : stop.errorMessage,
                                        ),
                                      ],
                                    ),
                                    verticalSpaceTiny
                                  ],
                                ),
                              );
                            },
                            childCount: model.sync.length,
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: Container(
                          padding: const EdgeInsets.only(top: 30),
                          child: Card(
                            child: ListTile(
                              title: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.hourglass_empty,
                                    color: Theme.of(context).primaryColor,
                                    size: 35.0,
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  const Text(
                                    "No Sync Task Found!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18.0, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
