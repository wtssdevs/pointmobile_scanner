import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/dual_login_viewmodel.dart';

class PortalLoginCard extends StatelessWidget {
  const PortalLoginCard({
    Key? key,
    required this.portal,
    required this.tenantCodeController,
    required this.usernameController,
    required this.passwordController,
    required this.tenantFocusNode,
    required this.usernameFocusNode,
    required this.passwordFocusNode,
    required this.validationFor,
    required this.isBusy,
    required this.onSubmit,
    this.onTermsPressed,
  }) : super(key: key);

  final AuthPortal portal;
  final TextEditingController tenantCodeController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode tenantFocusNode;
  final FocusNode usernameFocusNode;
  final FocusNode passwordFocusNode;
  final String? Function(AuthPortal portal, String key) validationFor;
  final bool isBusy;
  final VoidCallback onSubmit;
  final VoidCallback? onTermsPressed;

  @override
  Widget build(BuildContext context) {
    final isXac = portal == AuthPortal.xac;
    final title = isXac ? 'XAC Gatepass' : 'CMS Portal';
    final subtitle = isXac
        ? 'Use your current gate-pass account details.'
        : 'Use your CMS tenant and account details.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withOpacity(isXac ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isXac ? Icons.security : Icons.business_center_outlined,
                    color: kcPrimaryColor,
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,
            InputField(
              placeholder: 'Code',
              controller: tenantCodeController,
              icon: const Icon(Icons.house, color: Colors.black87),
              fieldFocusNode: tenantFocusNode,
              nextFocusNode: usernameFocusNode,
              textInputType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validationMessage: validationFor(
                  portal, DualLoginViewModel.tenantCodeField),
            ),
            InputField(
              placeholder: 'Username',
              controller: usernameController,
              icon: const Icon(Icons.person, color: Colors.black87),
              fieldFocusNode: usernameFocusNode,
              nextFocusNode: passwordFocusNode,
              textInputType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validationMessage:
                  validationFor(portal, DualLoginViewModel.usernameField),
            ),
            InputField(
              placeholder: 'Password',
              controller: passwordController,
              password: true,
              icon: const Icon(Icons.lock, color: Colors.black87),
              fieldFocusNode: passwordFocusNode,
              textInputType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              enterPressed: onSubmit,
              validationMessage:
                  validationFor(portal, DualLoginViewModel.passwordField),
            ),
            if (validationFor(portal, DualLoginViewModel.formField) != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  validationFor(portal, DualLoginViewModel.formField)!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isBusy ? null : onSubmit,
                child: isBusy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'SIGN IN TO ${portal.shortLabel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            if (isXac && onTermsPressed != null) ...[
              verticalSpaceMedium,
              Center(
                child: TextButton(
                  onPressed: onTermsPressed,
                  child: const Text(
                    'Terms, conditions and privacy policy',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}