import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

import 'images_viewer_list_viewmodel.dart';

class ImagesViewerListView extends StackedView<ImagesViewerListViewModel> {
  final String gatePassId;
  const ImagesViewerListView({Key? key, required this.gatePassId})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ImagesViewerListViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${viewModel.translate('View')} ${viewModel.translate('Photots')}"),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: GridView.builder(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          childAspectRatio: 1,
        ),
        itemCount: viewModel.fileStoreItems.length,
        itemBuilder: (BuildContext ctx, index) {
          var fileItem = viewModel.fileStoreItems[index];

          return InkWell(
            onTap: () {
              // model.gotEditImageView(fileItem.path);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            image: FileImage(
                              File(fileItem.path),
                            ),
                            fit: BoxFit.fill),
                      ),
                      alignment: Alignment.center,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        children: [
                          fileItem.upLoaded
                              ? const Icon(
                                  Icons.checklist,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.pending,
                                  color: Colors.orange,
                                ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void onViewModelReady(ImagesViewerListViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(),
      );
  @override
  ImagesViewerListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ImagesViewerListViewModel(gatePassId: this.gatePassId);
}
