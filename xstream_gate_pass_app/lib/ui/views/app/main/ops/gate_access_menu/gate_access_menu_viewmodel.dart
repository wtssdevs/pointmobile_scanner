import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/models/shared/menu/menu_ietm.dart';
import 'package:xstream_gate_pass_app/core/utils/app_permissions.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessMenuViewModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('GateAccessMenuViewModel');
  final _navigationService = locator<NavigationService>();

// List of menu items
  List<MenuItem> menuItems = [];

  Future<void> initialise() async {
    menuItems = [
      MenuItem(title: translate('PreBookings'), icon: Icons.find_in_page, route: Routes.gateAccessPreBookingView, requiredPermission: AppPermissions.mobileOperationsPreBookings),
      MenuItem(title: translate('Visitors'), icon: Icons.people, route: Routes.gateAccessVisitorsListView, requiredPermission: AppPermissions.mobileOperationsVisitors),
      MenuItem(title: translate('Staff'), icon: Icons.book, route: Routes.gateAccessStaffListView, requiredPermission: AppPermissions.mobileOperationsStaff),
      MenuItem(title: translate('YardOperations'), icon: Icons.qr_code_2_rounded, route: Routes.gateAccessYardOpsView, requiredPermission: AppPermissions.mobileOperationsYardOperations),
      MenuItem(title: translate('GateAccess'), icon: FontAwesomeIcons.roadBridge, route: Routes.gatePassView, requiredPermission: AppPermissions.mobileOperationsGateAccess),
    ];
    rebuildUi();
  }

  void navigateToView(String route) async {
    await _navigationService.navigateTo(
      route,
    );
  }
}
