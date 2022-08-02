import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class TextFieldWidget extends StatelessWidget {
  final IconData icon;
  final String? hint;
  final String? errorText;
  final bool isObscure;
  final bool isIcon;
  final TextInputType? inputType;
  final TextEditingController textController;
  final EdgeInsets padding;
  final Color hintColor;
  final Color iconColor;
  final FocusNode? focusNode;
  final ValueChanged? onFieldSubmitted;
  final ValueChanged? onChanged;
  final bool autoFocus;
  final TextInputAction? inputAction;

  final String? Function(String?)? validator;

  final String? validationMessage;
  //final Function? enterPressed;

  final FocusNode? nextFocusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      decoration: fieldDecortaion,
      child: TextFormField(
        controller: textController,
        focusNode: focusNode,

        validator: validator,
        //onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        autofocus: autoFocus,
        onFieldSubmitted: (value) {
          if (nextFocusNode != null) {
            nextFocusNode!.requestFocus();
          }
        },
        textInputAction: inputAction,
        obscureText: this.isObscure,
        keyboardType: this.inputType,
        decoration: InputDecoration(
            hintText: this.hint,
            border: InputBorder.none,
            errorText: errorText,
            counterText: '',
            icon: this.isIcon ? Icon(this.icon, color: iconColor) : null),
      ),
    );
  }

  const TextFieldWidget({
    Key? key,
    required this.icon,
    required this.errorText,
    required this.textController,
    this.nextFocusNode,
    this.inputType,
    this.hint,
    this.isObscure = false,
    this.isIcon = true,
    this.padding = const EdgeInsets.all(0),
    this.hintColor = Colors.grey,
    this.iconColor = Colors.grey,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.autoFocus = false,
    this.inputAction,
    this.validationMessage,
    this.validator,
  }) : super(key: key);
}
