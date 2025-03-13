// import 'package:flutter/material.dart';

// import 'package:stacked/stacked.dart';
// import 'package:stacked_services/stacked_services.dart';
// import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
// import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

// import 'info_alert_dialog_model.dart';

// const double _graphicSize = 60;

// class InfoAlertDialog extends StackedView<InfoAlertDialogModel> {
//   final DialogRequest request;
//   final Function(DialogResponse) completer;

//   const InfoAlertDialog({
//     Key? key,
//     required this.request,
//     required this.completer,
//   }) : super(key: key);

//   @override
//   Widget builder(
//     BuildContext context,
//     InfoAlertDialogModel viewModel,
//     Widget? child,
//   ) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       backgroundColor: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         request.title!,
//                         style: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.w900),
//                       ),
//                       verticalSpaceTiny,
//                       Text(
//                         request.description!,
//                         style:
//                             const TextStyle(fontSize: 14, color: kcMediumGrey),
//                         maxLines: 3,
//                         softWrap: true,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   width: _graphicSize,
//                   height: _graphicSize,
//                   decoration: const BoxDecoration(
//                     color: Color(0xffF6E7B0),
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(_graphicSize / 2),
//                     ),
//                   ),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     '⭐️',
//                     style: TextStyle(fontSize: 30),
//                   ),
//                 )
//               ],
//             ),
//             verticalSpaceMedium,
//             GestureDetector(
//               onTap: () => completer(DialogResponse(
//                 confirmed: true,
//               )),
//               child: Container(
//                 height: 50,
//                 width: double.infinity,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Text(
//                   'Got it',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   InfoAlertDialogModel viewModelBuilder(BuildContext context) =>
//       InfoAlertDialogModel();
// }

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/ui/dialogs/info_alert/info_alert_dialog_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_text.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';

class InfoAlertDialog extends StackedView<InfoAlertDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  InfoAlertDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);
  final TextEditingController getInformationTextController =
      TextEditingController();
  final FocusNode getInformationTextFocusNode = FocusNode();
  @override
  Widget builder(
    BuildContext context,
    InfoAlertDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      clipBehavior: Clip.none,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              minRadius: 16,
              maxRadius: 28,
              backgroundColor: _getStatusColor(request.data),
              child: Icon(
                _getStatusIcon(request.data),
                size: 28,
                color: Colors.white,
              ),
            ),
            verticalSpaceSmall,
            AppText.appBarTitle(
              request.title ?? '',
              align: TextAlign.center,
            ),
            verticalSpaceSmall,
            AppText.body(
              request.description ?? '',
              align: TextAlign.center,
            ),
            verticalSpaceMedium,
            if (request.takesInput != null && request.takesInput! == true)
              Center(
                child: InputField(
                  isMultiLine: true,
                  placeholder: "Please Type here...",
                  icon: FaIcon(
                    FontAwesomeIcons.noteSticky,
                    color: getInformationTextController.text.isNotEmpty
                        ? Colors.green
                        : Colors.green,
                  ),
                  controller: getInformationTextController,
                  fieldFocusNode: FocusNode(),
                  nextFocusNode: FocusNode(),
                  textInputType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  enterPressed: () {
                    //used to close the keyboard on last text inputfield
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (String value) {
                    //getInformationTextController.value = TextEditingValue(text: value);
                  },
                  validator: (value) {
                    return null;
                  },
                ),
              ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (request.secondaryButtonTitle != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      side: const BorderSide(
                          color: Colors.red,
                          width: 2), // Border color and width
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    child: viewModel.isBusy
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : Text(
                            request.secondaryButtonTitle ?? '',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                    onPressed: () async {
                      completer(
                        DialogResponse<String>(
                          confirmed: false,
                        ),
                      );
                    },
                  ),
                if (request.mainButtonTitle != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      side: const BorderSide(
                          color: Colors.green,
                          width: 2), // Border color and width
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    child: viewModel.isBusy
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : Text(
                            request.mainButtonTitle ?? '',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                    onPressed: () async {
                      completer(
                        DialogResponse<String>(
                            confirmed: true,
                            data: getInformationTextController.text),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic customData) {
    if (customData is BasicDialogStatus) {
      switch (customData) {
        case BasicDialogStatus.error:
          return Colors.red;
        case BasicDialogStatus.warning:
          return Colors.orange;
        case BasicDialogStatus.success:
          return Colors.green;
        default:
          return kcPrimaryColor;
      }
    } else {
      return kcPrimaryColor;
    }
  }

  IconData _getStatusIcon(dynamic regionDialogStatus) {
    if (regionDialogStatus is BasicDialogStatus) {
      switch (regionDialogStatus) {
        case BasicDialogStatus.error:
          return Icons.close;
        case BasicDialogStatus.warning:
          return Icons.warning_amber;
        default:
          return Icons.check;
      }
    } else {
      return Icons.check;
    }
  }

  @override
  InfoAlertDialogModel viewModelBuilder(BuildContext context) =>
      InfoAlertDialogModel();
}
