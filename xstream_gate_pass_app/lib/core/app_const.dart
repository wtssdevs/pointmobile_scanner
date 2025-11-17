class AppConst {
  AppConst._();

  //Local Database
  static const String internalDatabaseName = "Internal.db";
  static const String App_Gallery_Album = "AppGallery";
  static const String DB_LocalizeValues = "LocalizeKeyTextValues";

  static const String is_logged_in = "isLoggedIn";
  static const String auth_token = "authToken";
  static const String access_token = "accessToken";
  static const String current_language = "current_language";
  static const String current_UserProfile = "current_UserProfile";
  static const String is_OTP_Pin_Request = "is_OTP_Pin_Request";
  static const String has_disclosed_background_permission =
      "has_disclosed_background_permission";
  static const String recentSearches = "recent_Searches";

  static const String deviceConfig = "device_config";
  static const String tenantId = "tenantId";
  //ENV File maps
  static const String GoogleMapsEnvKey = 'GOOGLE_MAPS_API_KEY';
  static const String NoKey = 'NO_KEY';
  static const String API_Base_Url = 'API_Base_Url_Key';
  static const String Base_hostname = 'Base_hostname';

  static const String DB_BackgroundJobInfo = "BackgroundJobInfo";
  static const String DB_FileStore = "FileStore";
  static const String DB_Customers = "Customers";
  static const String DB_ServiceTypes = "DB_ServiceTypes";

  //API AUTH

  ///api/Account/ExternalAuth
  //static const String authentication = "/api/Account/ExternalAuth";
  static const String authentication = "/api/TokenAuth/Authenticate";

  static const String isTenantAvailable =
      "/api/services/app/Account/IsTenantAvailable";

  //API Methods

  //static const String FileUploading_Images = "/api/FileUpload/Uploads/1";
  static const String FileUploading_Images = "/api/FileStore/Upload";

  static const String GetAllCustomers =
      "/api/services/app/Customer/GetAllCustomersLookup";

  static const String GetAllServiceTypesCached =
      "/api/services/app/ServiceType/GetAllCached";

  static const String GetAllGatePass =
      "/api/services/app/MobileGatePassAccess/GetAllPaged";

  static const String GetAllVisitorPaged =
      "/api/services/app/MobileGatePassAccess/GetAllVisitorPaged";
  static const String GetAllTransporters =
      "/api/services/app/Transporter/GetAll";

//Checklists
  ///api/services/app/GatePassChecklist/GetEmptyChecklistForGatePass
  static const String getEmptyChecklistForGatePass =
      "/api/services/app/GatePassChecklist/GetEmptyChecklistForGatePass";

  ///api/services/app/GatePassChecklist/SubmitResponses
  static const String submitResponses =
      "/api/services/app/GatePassChecklist/SubmitResponses";

  static const String findChecklistTemplate =
      "/api/services/app/GatePassChecklist/FindChecklistTemplate";

  ///api/services/app/Incident/Create
  static const String CreateIncident = "/api/services/app/Incident/Create";

  ///api/services/app/Incident/GetAll
  static const String GetAllIncidents = "/api/services/app/Incident/GetAll";

// PRE BOOKINGS **********

  static const String findPreBookedLoad =
      "/api/services/app/MobileGatePassAccess/FindPreBookedLoad";
  static const String findPreBookedLoadByVoyageNo =
      "/api/services/app/MobileGatePassAccess/FindPreBookedLoadByVoyageNo";

//STAFF*************
  static const String GetAllStaffPaged =
      "/api/services/app/MobileGatePassAccess/GetAllStaffPaged";
  static const String scanStaffIn =
      "/api/services/app/MobileGatePassAccess/ScanStaffIn";
  static const String scanStaffOut =
      "/api/services/app/MobileGatePassAccess/ScanStaffOut";

  static const String scanVisitorIn =
      "/api/services/app/MobileGatePassAccess/ScanVisitorIn";
  static const String scanVisitorOut =
      "/api/services/app/MobileGatePassAccess/ScanVisitorOut";
// VISITORS **********************
  static const String findPreBookedVisitor =
      "/api/services/app/MobileGatePassAccess/FindPreBookedVisitor";
  static const String scanPreBookedVisitorIn =
      "/api/services/app/MobileGatePassAccess/ScanPreBookedVisitorIn";
  static const String scanPreBookedVisitorOut =
      "/api/services/app/MobileGatePassAccess/ScanPreBookedVisitorOut";
  static const String setCmsGatePassEvent =
      "/api/services/app/MobileGatePassAccess/SetCmsGatePassEvent";

  ///api/services/app/MobileGatePassAccess/GetAllPaged

  ///GATE PASS **********************
  static const String CreateGatePass =
      "/api/services/app/GatePassAccess/Create";

  static const String UpdateGatePass =
      "/api/services/app/GatePassAccess/Update";
  static const String AuthorizeForEntryGatePass =
      "/api/services/app/GatePassAccess/AuthorizeForEntry";

  static const String AuthorizeForExitGatePass =
      "/api/services/app/GatePassAccess/AuthorizeForExit";
  static const String RejectEntryGatePass =
      "/api/services/app/GatePassAccess/RejectEntry";

  //INTERNET TIMEOUT
  static const String InternetConnectionStatus =
      "The Network connection was lost.";

  static const String GetLocalizeValues = "/AbpUserConfiguration/GetAll/";

  static const String tenantCode = "tenantCode";
  //SSL Certificate Configuration
  /// List of hosts that are allowed to have SSL certificate validation bypassed.
  /// This is used across the application for both main thread and isolate HTTP requests.
  ///
  /// Important: Only add trusted hosts to this list. These hosts will bypass
  /// SSL certificate validation which could be a security risk if not properly managed.
  ///
  /// Used by:
  /// - MyHttpOverrides in main.dart for main thread requests
  /// - FileStoreManager isolate for background file uploads
  /// - Any other HTTP clients that need SSL certificate bypass
  static const List<String> sslAllowedHosts = [
    "xstream-tms.com",
    "localhost",
    "192.168.1.65:8080",
    "localhost:44311",
    "a50f-102-66-86-121.ngrok-free.app",
    "18.231.93.153",
    "18.229.146.63",
    "18.228.115.60",
    "54.94.248.37",
    "18.229.248.167",
    "xacapi.xstream-wtss.com"
  ];

  /// Check if a host is allowed for SSL connections
  static bool isSSLHostAllowed(String host) {
    return sslAllowedHosts.contains(host);
  }

  /// Get the SSL allowed hosts list
  static List<String> getSSLAllowedHosts() {
    return List.from(sslAllowedHosts); // Return a copy to prevent modification
  }

  // Validation Messages - Centralized validation messages to avoid magic strings

  // Driver Validation Messages

  static const String msgDriverNameRequired = "Driver Name is required";
  static const String msgDriverIdRequired = "Driver ID Number is required";

  // Vehicle Validation Messages
  static const String msgVehicleRegRequired = "Vehicle Reg Number is required";
  static const String msgVehicleRegMismatch = "Vehicle registration";
  static const String msgForeignLicensePhotoRequired =
      "Foreign license photo is required";

  // Trailer Validation Messages
  static const String msgRegMismatch =
      "registration number does not match the scanned :";

  // General Validation Messages
  static const String msgCustomerRequired = "Customer is required!";
  static const String msgScanDataProcessingFailed =
      "Failed to process scan data";

  // Network and Connection Messages
  static const String msgInternetConnectionLost =
      "The Network connection was lost.";

  // Form Validation Messages
  static const String msgFieldRequired = "is required";
  static const String msgPhotoRequired = "photo is required";

  // Helper methods for generating field-specific validation messages
  static String getFieldRequiredMessage(String fieldName) {
    return "$fieldName $msgFieldRequired";
  }

  static String getPhotoRequiredMessage(String photoType) {
    return "$photoType $msgPhotoRequired";
  }

  static String getScanDataProcessingFailedMessage(String error) {
    return "$msgScanDataProcessingFailed: $error";
  }

  static const String resolveChecklistType =
      '/api/services/app/GatePassChecklist/ResolveChecklistType';
}
