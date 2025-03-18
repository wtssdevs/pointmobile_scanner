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
  static const String has_disclosed_background_permission = "has_disclosed_background_permission";
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

  static const String isTenantAvailable = "/api/services/app/Account/IsTenantAvailable";

  //API Methods

  //static const String FileUploading_Images = "/api/FileUpload/Uploads/1";
  static const String FileUploading_Images = "/api/FileStore/Upload";

  static const String GetAllCustomers = "/api/services/app/Customer/GetAllCustomersLookup";

  static const String GetAllServiceTypesCached = "/api/services/app/ServiceType/GetAllCached";

  static const String GetAllGatePass = "/api/services/app/MobileGatePassAccess/GetAllPaged";

  static const String GetAllVisitorPaged = "/api/services/app/MobileGatePassAccess/GetAllVisitorPaged";

// PRE BOOKINGS **********

  static const String findPreBookedLoad = "/api/services/app/MobileGatePassAccess/FindPreBookedLoad";

//STAFF*************
  static const String GetAllStaffPaged = "/api/services/app/MobileGatePassAccess/GetAllStaffPaged";
  static const String scanStaffIn = "/api/services/app/MobileGatePassAccess/ScanStaffIn";
  static const String scanStaffOut = "/api/services/app/MobileGatePassAccess/ScanStaffOut";

  static const String scanVisitorIn = "/api/services/app/MobileGatePassAccess/ScanVisitorIn";
  static const String scanVisitorOut = "/api/services/app/MobileGatePassAccess/ScanVisitorOut";
// VISITORS **********************
  static const String findPreBookedVisitor = "/api/services/app/MobileGatePassAccess/FindPreBookedVisitor";
  static const String scanPreBookedVisitorIn = "/api/services/app/MobileGatePassAccess/ScanPreBookedVisitorIn";
  static const String scanPreBookedVisitorOut = "/api/services/app/MobileGatePassAccess/ScanPreBookedVisitorOut";
  static const String setCmsGatePassEvent = "/api/services/app/MobileGatePassAccess/SetCmsGatePassEvent";

  ///api/services/app/MobileGatePassAccess/GetAllPaged

  ///GATE PASS **********************
  static const String CreateGatePass = "/api/services/app/GatePassAccess/Create";

  static const String UpdateGatePass = "/api/services/app/GatePassAccess/Update";
  static const String AuthorizeForEntryGatePass = "/api/services/app/GatePassAccess/AuthorizeForEntry";

  static const String AuthorizeForExitGatePass = "/api/services/app/GatePassAccess/AuthorizeForExit";
  static const String RejectEntryGatePass = "/api/services/app/GatePassAccess/RejectEntry";

  //INTERNET TIMEOUT
  static const String InternetConnectionStatus = "The Network connection was lost.";

  static const String GetLocalizeValues = "/AbpUserConfiguration/GetAll/";
}
