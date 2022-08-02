import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/note_text.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType textInputType;
  final bool password;
  final String? Function(String?)? validator;
  final bool isReadOnly;
  final String placeholder;
  final String? validationMessage;
  final Function? enterPressed;
  final bool smallVersion;
  final FocusNode? fieldFocusNode;
  final FocusNode? nextFocusNode;
  final TextInputAction textInputAction;
  final String? additionalNote;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? formatter;
  final Widget? icon;
  final Widget? suffixIcon;
  final bool isMultiLine;
  final EdgeInsetsGeometry padding;
  final bool isVisible;
  final Function? onTap;

  InputField(
      {required this.controller,
      required this.placeholder,
      this.enterPressed,
      this.fieldFocusNode,
      this.nextFocusNode,
      this.additionalNote,
      this.onChanged,
      this.formatter,
      this.validationMessage,
      this.textInputAction = TextInputAction.next,
      this.textInputType = TextInputType.text,
      this.password = false,
      this.isReadOnly = false,
      this.smallVersion = false,
      this.validator,
      this.icon,
      this.suffixIcon,
      this.isMultiLine = false,
      this.padding = const EdgeInsets.all(0),
      this.onTap,
      this.isVisible = true});

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool isPassword;
  double fieldHeight = 55;

  @override
  void initState() {
    super.initState();
    isPassword = widget.password;
    widget.controller.addListener(_checkInputHeight);
    isPassword = widget.password;
  }

  void _checkInputHeight() async {
//    int count = widget.controller.text.split('\n').length;
    if (widget.isMultiLine == false) {
      return;
    }
    int count = (widget.controller.text.length / (MediaQuery.of(context).size.width * 0.06)).round();

    if (count == 0 && fieldHeight == 55.0) {
      return;
    }
    if (count <= 6) {
      // use a maximum height of 6 rows
      // height values can be adapted based on the font size
      var newHeight = count == 0 ? 50.0 : 28.0 + (count * 18.0);
      setState(() {
        fieldHeight = newHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isVisible
        ? Padding(
            padding: widget.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: widget.smallVersion ? 40 : fieldHeight,
                  alignment: !widget.isMultiLine ? Alignment.centerLeft : Alignment.topCenter,
                  padding: fieldPadding,
                  decoration: widget.isReadOnly ? disabledFieldDecortaion : fieldDecortaion,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: widget.controller,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: widget.validator,
                          keyboardType: widget.textInputType,
                          focusNode: widget.fieldFocusNode,
                          textInputAction: widget.textInputAction,
                          onChanged: widget.onChanged,
                          onTap: widget.onTap as void Function()?,
                          inputFormatters: widget.formatter != null ? widget.formatter! : null,
                          onEditingComplete: () {
                            if (widget.enterPressed != null) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              widget.enterPressed!();
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (widget.nextFocusNode != null) {
                              widget.nextFocusNode!.requestFocus();
                            }
                          },
                          minLines: widget.isMultiLine ? 1 : null,
                          maxLines: widget.isMultiLine ? 5 : 1,
                          obscureText: isPassword,
                          readOnly: widget.isReadOnly,
                          decoration: InputDecoration(
                            hintText: widget.placeholder,
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: widget.smallVersion ? 12 : 15),
                            icon: widget.icon != null ? widget.icon : null,
                            suffixIcon: widget.suffixIcon,

                            //prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.black12) : null,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          isPassword = !isPassword;
                        }),
                        child: widget.password
                            ? Container(
                                width: fieldHeight,
                                height: fieldHeight,
                                alignment: Alignment.center,
                                child: Icon(isPassword ? Icons.visibility : Icons.visibility_off))
                            : Container(),
                      ),
                    ],
                  ),
                ),
                if (widget.validationMessage != null)
                  NoteText(
                    widget.validationMessage,
                    color: Colors.red,
                  ),
                if (widget.additionalNote != null) verticalSpace(5),
                if (widget.additionalNote != null) NoteText(widget.additionalNote),
                verticalSpaceSmall
              ],
            ),
          )
        : SizedBox.shrink();
  }
}
