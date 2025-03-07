import 'package:flutter/material.dart';
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
      // MenuItem(
      //     title: translate('GateEntry'),
      //     icon: Icons.login,
      //     route: '/page2',
      //     requiredPermission: AppPermissions.mobileOperationsCreate),
      // MenuItem(
      //     title: translate('GateExit'),
      //     icon: Icons.logout,
      //     route: '/page2',
      //     requiredPermission: AppPermissions.mobileOperationsCreate),
      MenuItem(title: translate('PreBookings'), icon: Icons.find_in_page, route: Routes.gateAccessPreBookingView, requiredPermission: AppPermissions.mobileOperationsPreBookings),
      MenuItem(title: translate('Visitors'), icon: Icons.people, route: Routes.gateAccessVisitorsListView, requiredPermission: AppPermissions.mobileOperationsVisitors),
      MenuItem(title: translate('Staff'), icon: Icons.book, route: Routes.gateAccessStaffListView, requiredPermission: AppPermissions.mobileOperationsStaff),
      MenuItem(title: translate('YardOperations'), icon: Icons.storage, route: Routes.gatePassView, requiredPermission: AppPermissions.mobileOperationsYardOperations),
    ];
    rebuildUi();
  }

  void navigateToView(String route) async {
    await _navigationService.navigateTo(
      route,
    );
  }
}
