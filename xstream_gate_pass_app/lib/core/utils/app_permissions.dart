class AppPermissions {
  AppPermissions._();

  static const String views = "Views.";
  static const String operations = "Operations.";
  static const String gatePassAccess = "GatePassAccess.";
  static const String mobileOperations = "MobileOperations.";
  static const String create = "Create";

  static const String staff = "Staff";
  static const String scan = ".Scan";
  static const String preBookings = "PreBookings";
  static const String visitors = "Visitors";
  static const String yardOperations = "YardOperations";

  static const String mobileOperationsCreate = views + operations + gatePassAccess + mobileOperations + create;

  static const String mobileOperationsPreBookings = views + operations + gatePassAccess + mobileOperations + preBookings;
  static const String mobileOperationsStaff = views + operations + gatePassAccess + mobileOperations + staff;

  static const String mobileOperationsVisitors = views + operations + gatePassAccess + mobileOperations + visitors;
  static const String mobileOperationsYardOperations = views + operations + gatePassAccess + mobileOperations + yardOperations;
}
