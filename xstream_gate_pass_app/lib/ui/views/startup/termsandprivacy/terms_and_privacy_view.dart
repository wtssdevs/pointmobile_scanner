import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'terms_and_privacy_view_model.dart';

class TermsAndPrivacyView extends StatelessWidget {
  const TermsAndPrivacyView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TermsAndPrivacyViewModel>.reactive(
      viewModelBuilder: () => TermsAndPrivacyViewModel(),
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                elevation: 6,
                title: BoxText.body(
                  "T&Cs - Privacy Policy",
                  color: Colors.white,
                ),
                titleSpacing: 10.0,
                centerTitle: true,
              ),
              body: Markdown(data: model.textDataToShow)),
        ),
      ),
    );
  }
}
