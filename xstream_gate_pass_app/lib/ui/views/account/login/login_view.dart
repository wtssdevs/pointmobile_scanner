import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/text_link.dart';
import 'package:xstream_gate_pass_app/ui/views/account/login/login_view.form.dart';

import 'login_viewmodel.dart';

@FormView(fields: [
  FormTextField(name: 'tenantCode'),
  FormTextField(name: 'email'),
  FormTextField(name: 'password'),
])
class LoginView extends StatelessWidget with $LoginView {
  LoginView({Key? key}) : super(key: key);
  final _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/wtssgrplogo.png"), context);
    void validateForm(LoginViewModel model) async {
      model.validateModel(tenantCodeController.text, emailController.text, passwordController.text);
      if (_loginFormKey.currentState!.validate()) {
        FocusScope.of(context).requestFocus(FocusNode());
        await model.signInRequest(
          tenancyName: tenantCodeController.text,
          userNameOrEmailAddress: emailController.text,
          password: passwordController.text,
        );
      }
    }

    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(),
      onModelReady: (model) => listenToFormUpdated(model),
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          body: SafeArea(
            child: Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/wtssgrplogo.png'), fit: BoxFit.scaleDown),
              ),
              child: ClipRRect(
                // make sure we apply clip it properly
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: ListView(
                      children: [
                        verticalSpaceRegular,
                        const Text(
                          "Xstream Gatepass",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 34),
                        ),
                        verticalSpaceSmall,
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: screenWidthPercentage(context, percentage: 0.7),
                            child: BoxText.body(
                              "Enter your account details to sign in.",
                              color: Colors.black,
                            ),
                          ),
                        ),
                        verticalSpaceRegular,
                        verticalSpaceLarge,
                        Form(
                          key: _loginFormKey,
                          child: Column(
                            children: [
                              InputField(
                                placeholder: "Code",
                                controller: tenantCodeController,
                                icon: const Icon(
                                  Icons.house,
                                  color: Colors.black,
                                ),
                                fieldFocusNode: tenantCodeFocusNode,
                                nextFocusNode: emailFocusNode,
                                textInputType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Code is required!';
                                  }
                                  return null;
                                },
                              ),
                              InputField(
                                placeholder: "Username",
                                controller: emailController,
                                icon: const Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                fieldFocusNode: emailFocusNode,
                                nextFocusNode: passwordFocusNode,
                                textInputType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Email is required!';
                                  }
                                  return null;
                                },
                              ),
                              InputField(
                                placeholder: "Password",
                                controller: passwordController,
                                password: true,
                                icon: const Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                ),
                                fieldFocusNode: passwordFocusNode,
                                textInputType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                enterPressed: () {
                                  //used to close the keyboard on last text inputfield
                                  FocusScope.of(context).unfocus();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password is required!';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceRegular,
                        if (model.validationMessage != null)
                          BoxText.body(
                            model.validationMessage!,
                            color: Colors.red,
                          ),
                        if (model.validationMessage != null) verticalSpaceRegular,
                        GestureDetector(
                          onTap: () async {
                            validateForm(model);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kcPrimaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: model.isBusy
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  )
                                : const Text(
                                    "SIGN IN",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                          ),
                        ),
                        verticalSpaceLarge,
                        TextLink(
                          'By signing in you agree to our terms, conditions and privacy policy.',
                          const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          onPressed: () {
                            model.navigateToTermsView();
                          },
                        ),
                        verticalSpaceRegular,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
