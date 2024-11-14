class AppConst {
  AppConst._();

  //Local Database
  static const String internalDatabaseName = "Internal.db";
  static const String App_Gallery_Album = "XstreamGallery";
  static const String is_logged_in = "isLoggedIn";
  static const String auth_token = "authToken";
  static const String access_token = "accessToken";
  static const String current_language = "current_language";
  static const String current_UserProfile = "current_UserProfile";
  static const String is_OTP_Pin_Request = "is_OTP_Pin_Request";
  static const String has_disclosed_background_permission =
      "has_disclosed_background_permission";
  static const String recentSearches = "recent_Searches";
  //ENV File maps
  static const String GoogleMapsEnvKey = 'GOOGLE_MAPS_API_KEY';
  static const String NoKey = 'NO_KEY';
  static const String API_Base_Url = 'API_Base_Url_Key';
  static const String Base_hostname = 'Base_hostname';

  static const String DB_BackgroundJobInfo = "BackgroundJobInfo";
  static const String DB_FileStore = "FileStore";
  static const String DB_Customers = "Customers";

  //API Methods

  static const String FileUploading_Images = "/api/FileUpload/Uploads/1";
  static const String GetAllCustomers =
      "/api/services/app/Customer/GetAllCustomersLookup";

  static const String GetAllGatePass = "/api/services/app/GatePass/GetAll";

  static const String CreateGatePass = "/api/services/app/GatePass/Create";

  static const String UpdateGatePass = "/api/services/app/gatePass/Update";
  static const String AuthorizeForEntryGatePass =
      "/api/services/app/gatePass/AuthorizeForEntry";
  static const String AuthorizeForExitGatePass =
      "/api/services/app/gatePass/AuthorizeForExit";
  static const String RejectEntryGatePass =
      "/api/services/app/gatePass/RejectEntry";

  //INTERNET TIMEOUT
  static const String InternetConnectionStatus =
      "The Network connection was lost.";
}
