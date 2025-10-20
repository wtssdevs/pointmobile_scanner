class AppPermissions {
  AppPermissions._();

  static const String views = "Views.";
  static const String operations = "Operations.";
  static const String gatePassAccess = "GatePassAccess.";
  static const String mobileOperations = "MobileOperations.";
  static const String create = "Create";

  static const String staff = "Staff";
  static const String scan = ".Scan";
  static const String preBookCheckIn = ".PreBookCheckIn";
  static const String checkIn = ".CheckIn";
  static const String checkOut = ".CheckOut";
  static const String preBookings = "PreBookings";
  static const String visitors = "Visitors";
  static const String yardOperations = "YardOperations";
  static const String gateAccess = "GateAccess";

  static const String mobileOperationsCreate =
      views + operations + gatePassAccess + mobileOperations + create;

  static const String mobileOperationsPreBookings =
      views + operations + gatePassAccess + mobileOperations + preBookings;
  static const String mobileOperationsStaff =
      views + operations + gatePassAccess + mobileOperations + staff;

  static const String mobileOperationsVisitors =
      views + operations + gatePassAccess + mobileOperations + visitors;
  static const String mobileOperationsVisitorsScan =
      views + operations + gatePassAccess + mobileOperations + visitors + scan;
  static const String mobileOperationsVisitorsCheckIn = views +
      operations +
      gatePassAccess +
      mobileOperations +
      visitors +
      checkIn;
  static const String mobileOperationsVisitorsCheckOut = views +
      operations +
      gatePassAccess +
      mobileOperations +
      visitors +
      checkOut;
  static const String mobileOperationsVisitorsPreBookCheckIn = views +
      operations +
      gatePassAccess +
      mobileOperations +
      visitors +
      preBookCheckIn;

  static const String mobileOperationsYardOperations =
      views + operations + gatePassAccess + mobileOperations + yardOperations;

  static const String mobileOperationsGateAccess =
      views + operations + gatePassAccess + mobileOperations + gateAccess;
}
