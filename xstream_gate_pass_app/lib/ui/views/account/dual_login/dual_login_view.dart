import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/dual_login_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/widgets/login_header.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/widgets/portal_login_card.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/widgets/portal_login_tabs.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/widgets/portal_page_indicator.dart';

class DualLoginView extends StatelessWidget {
  const DualLoginView({Key? key, this.initialPortal = AuthPortal.xac})
      : super(key: key);

  final AuthPortal initialPortal;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final pageHeight = screenHeight < 720 ? 500.0 : 520.0;

    return ViewModelBuilder<DualLoginViewModel>.reactive(
      viewModelBuilder: () => DualLoginViewModel(initialPortal: initialPortal),
      onViewModelReady: (model) => model.initialise(),
      onDispose: (model) => model.disposeControllers(),
      builder: (context, model, child) => PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 20),
                  PortalLoginTabs(
                    selectedPortal: model.selectedPortal,
                    onPortalSelected: (portal) {
                      FocusScope.of(context).unfocus();
                      model.selectPortal(portal);
                    },
                  ),
                  const SizedBox(height: 12),
                  PortalPageIndicator(selectedIndex: model.selectedIndex),
                  SizedBox(
                    height: pageHeight,
                    child: PageView(
                      controller: model.pageController,
                      physics: const ClampingScrollPhysics(),
                      onPageChanged: (index) {
                        FocusScope.of(context).unfocus();
                        model.onPageChanged(index);
                      },
                      children: [
                        PortalLoginCard(
                          portal: AuthPortal.xac,
                          tenantCodeController: model.xacTenantCodeController,
                          usernameController: model.xacUsernameController,
                          passwordController: model.xacPasswordController,
                          tenantFocusNode: model.xacTenantFocusNode,
                          usernameFocusNode: model.xacUsernameFocusNode,
                          passwordFocusNode: model.xacPasswordFocusNode,
                          validationFor: model.validationFor,
                          isBusy: model.isBusyForPortal(AuthPortal.xac),
                          onSubmit: () => model.signIn(AuthPortal.xac),
                          onTermsPressed: model.navigateToTermsView,
                        ),
                        PortalLoginCard(
                          portal: AuthPortal.cms,
                          tenantCodeController: model.cmsTenantCodeController,
                          usernameController: model.cmsUsernameController,
                          passwordController: model.cmsPasswordController,
                          tenantFocusNode: model.cmsTenantFocusNode,
                          usernameFocusNode: model.cmsUsernameFocusNode,
                          passwordFocusNode: model.cmsPasswordFocusNode,
                          validationFor: model.validationFor,
                          isBusy: model.isBusyForPortal(AuthPortal.cms),
                          onSubmit: () => model.signIn(AuthPortal.cms),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: kcPrimaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
