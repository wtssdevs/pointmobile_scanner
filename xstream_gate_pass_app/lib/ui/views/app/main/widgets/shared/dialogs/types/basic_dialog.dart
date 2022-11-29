import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';

class BasicDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;
  const BasicDialog({Key? key, required this.request, required this.completer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(backgroundColor: Colors.transparent, child: _BasicDialogContent(request: request, completer: completer));
  }
}

class _BasicDialogContent extends StatelessWidget {
  _BasicDialogContent({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  final DialogRequest request;
  final Function(DialogResponse dialogResponse) completer;

  final TextEditingController getInformationTextController = TextEditingController();
  final FocusNode getInformationTextFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 2, right: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpaceSmall,
              BoxText.subheading(
                request.title ?? '',
                align: TextAlign.center,
              ),
              verticalSpaceSmall,
              BoxText.body(
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
                      color: getInformationTextController.text.isNotEmpty ? Colors.green : Colors.green,
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
                    OutlinedButton(
                      onPressed: () => completer(DialogResponse(confirmed: false)),
                      child: BoxText.body(
                        request.secondaryButtonTitle!,
                        color: Colors.red,
                      ),
                    ),
                  OutlinedButton(
                    onPressed: () {
                      // print(getInformationTextController.text);
                      completer(
                        DialogResponse<String>(confirmed: true, data: getInformationTextController.text),
                      );
                    },
                    child: BoxText.body(
                      request.mainButtonTitle ?? '',
                      color: kcPrimaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -28,
          child: CircleAvatar(
            minRadius: 16,
            maxRadius: 28,
            backgroundColor: _getStatusColor(request.data),
            child: Icon(
              _getStatusIcon(request.data),
              size: 28,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Color _getStatusColor(dynamic customData) {
    if (customData is BasicDialogStatus) {
      switch (customData) {
        case BasicDialogStatus.error:
          return Colors.red;
        case BasicDialogStatus.warning:
          return Colors.orange;
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
}
