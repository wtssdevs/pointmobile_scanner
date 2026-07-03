// ignore_for_file: constant_identifier_names

class AppConst {
  AppConst._();

  //Local Database
  static const String internalDatabaseName = "Internal.db";
  static const String App_Gallery_Album = "AppGallery";
  static const String DB_LocalizeValues = "LocalizeKeyTextValues";

  static const String is_logged_in = "isLoggedIn";
  static const String auth_token = "authToken";
  static const String access_token = "accessToken";
  static const String requiresAuthExtraKey = "requiresAuth";
  static const String lastSessionPortal = "lastSessionPortal";
  static const String xac_auth_token = "xac_authToken";
  static const String cms_auth_token = "cms_authToken";
  static const String xac_is_logged_in = "xac_isLoggedIn";
  static const String cms_is_logged_in = "cms_isLoggedIn";
  static const String xac_tenantId = "xac_tenantId";
  static const String cms_tenantId = "cms_tenantId";
  static const String xac_currentUserProfile = "xac_currentUserProfile";
  static const String cms_currentUserProfile = "cms_currentUserProfile";
  static const String cms_currentLoginInformation = "cms_currentLoginInformation";
  static const String cms_currentLoginInformationRefreshedAt = "cms_currentLoginInformationRefreshedAt";
  static const String cms_defaultInspectionDepotId = "cms_defaultInspectionDepotId";
  static const String xac_tenantCode = "xac_tenantCode";
  static const String cms_tenantCode = "cms_tenantCode";
  static const String current_language = "current_language";
  static const String current_UserProfile = "current_UserProfile";
  static const String is_OTP_Pin_Request = "is_OTP_Pin_Request";
  static const String has_disclosed_background_permission = "has_disclosed_background_permission";
  static const String recentSearches = "recent_Searches";

  static const String deviceConfig = "device_config";
  static const String tenantId = "tenantId";
  static const String scannerBranchId = "scannerBranchId";
  //ENV File maps
  static const String GoogleMapsEnvKey = 'GOOGLE_MAPS_API_KEY';
  static const String NoKey = 'NO_KEY';
  static const String API_Base_Url = 'API_Base_Url_Key';
  static const String Base_hostname = 'Base_hostname';
  static const String CMS_API_Base_Url = 'CMS_API_Base_Url_Key';
  static const String CMS_Base_hostname = 'CMS_Base_hostname';
  static const String AppPortalModeKey = 'APP_PORTAL_MODE';

  static const String DB_BackgroundJobInfo = "BackgroundJobInfo";
  static const String DB_FileStore = "FileStore";
  static const String DB_Customers = "Customers";
  static const String DB_ServiceTypes = "DB_ServiceTypes";
  static const String DB_CmsInspectionLocations = "cms_inspection_locations";
  static const String DB_CmsInspectionActions = "cms_inspection_actions";
  static const String DB_CmsInspectionDamages = "cms_inspection_damages";
  static const String DB_CmsInspectionItems = "cms_inspection_items";
  static const String DB_CmsItemCodes = "cms_item_codes";
  static const String DB_CmsConditionTypes = "cms_condition_types";
  static const String DB_CmsInspectionLinePhotos = "cms_inspection_line_photos";
  static const String DB_CmsMediaUploads = "cms_media_uploads";
  static const String DB_CmsSyncMeta = "cms_sync_meta";

  //API AUTH

  ///api/Account/ExternalAuth
  static const String cms_authentication = "/api/Account/Authenticate";
  static const String authentication = "/api/TokenAuth/Authenticate";

  static const String isTenantAvailable = "/api/services/app/Account/IsTenantAvailable";
  static const String getCurrentLoginInformations = "/api/services/app/Session/GetCurrentLoginInformations";

  //API Methods

  //static const String FileUploading_Images = "/api/FileUpload/Uploads/1";
  static const String FileUploading_Images = "/api/FileStore/Upload";

  static const String GetAllCustomers = "/api/services/app/Customer/GetAllCustomersLookup";

  static const String GetAllServiceTypesCached = "/api/services/app/ServiceType/GetAllCached";

  static const String CmsGetAllInspectionLocationsPagedEdit = "/api/InspectionLocations/GetAllPagedEdit";
  static const String CmsGetAllInspectionActionsPagedEdit = "/api/InspectionActions/GetAllPagedEdit";
  static const String CmsGetAllInspectionDamagesPagedEdit = "/api/InspectionDamages/GetAllPagedEdit";
  static const String CmsGetAllInspectionItemsPagedEdit = "/api/InspectionItems/GetAllPagedEdit";
  static const String CmsGetAllItemCodesPagedEdit = "/api/LoadItemCodes/GetAllItemCodes";
  static const String CmsGetConditionTypes = "/api/services/app/SystemFiles/GetConditionTypes";
  static const String CmsGetInspectableContainers = "/api/services/app/MobileInspections/GetInspectableContainers";
  static const String CmsGetContainerInspectionBundle = "/api/services/app/MobileInspections/GetContainerInspections";
  static const String CmsGetContainerInspectionHistory = "/api/services/app/MobileInspections/GetContainerInspectionHistory";
  static const String CmsStartInspectionForContainer = "/api/services/app/MobileInspections/StartInspection";
  static const String CmsCancelInspection = "/api/services/app/MobileInspections/CancelInspection";
  static const String CmsGetInspectionForEdit = "/api/services/app/Inspec/GetInspectionForEditById";
  static const String CmsSaveInspection = "/api/services/app/Inspec/AddUpdateInspection";
  static const String CmsCompleteInspection = "/api/services/app/Inspec/AddUpdateInspection";
  static const String CmsSetInspectionRepairDatesNow = "/api/services/app/Inspec/SetRepairDatesNow";
  static const String CmsMobileSurveyGetList = "/api/services/app/MobileSurvey/GetList";
  static const String CmsMobileSurveyGetById = "/api/services/app/MobileSurvey/GetById";
  static const String CmsMobileSurveyAddUpdate = "/api/services/app/MobileSurvey/AddUpdate";
  static const String CmsMobileSurveyGetEmailAddresses = "/api/services/app/MobileSurvey/GetEmailAddresses";
  static const String CmsMobileSurveySendEmail = "/api/services/app/MobileSurvey/SendEmail";
  static const String CmsReportSurveyInfoBase = "/api/Report/SurveyInfo/";
  static const String CmsReportGatePassSurveyInfoBase = "/api/Report/GatePassSurveyInfo/";
  static const String CmsInspectionLinePhotoUpload = "/api/mobile/inspections/files/upload";
  static const int CmsInspectionLinePhotoMaxBytes = 8388608;
  static const int CmsInspectionLinePhotoUploadConcurrency = 2;
  static const String CmsLegacyFileUpload = "/api/FileUpload/Upload";
  static const String CmsFileUploadGetAllDocsByRefId = "/api/services/app/FileUpload/GetAllDocsByRefID";
  static const String CmsFileUploadDeleteDocument = "/api/services/app/FileUpload/DeleteDocument";
  static const String CmsFileUploadDownloadBase = "/api/FileUpload/Download/";
  static const int CmsMediaUploadMaxBytes = CmsInspectionLinePhotoMaxBytes;
  static const int CmsMediaDocumentMaxBytes = 26214400;
  static const int CmsMediaUploadConcurrency = CmsInspectionLinePhotoUploadConcurrency;

  static String cmsInspectionLinePhotosForLine(int inspectionLineId) => "/api/mobile/inspections/files/line/$inspectionLineId";

  static String cmsInspectionLinePhotoDownload(int documentId) => "/api/mobile/inspections/files/download/$documentId";

  static String cmsInspectionLinePhotoDelete(int documentId) => "/api/mobile/inspections/files/$documentId";

  static String cmsSurveyReport(int containerId) => "$CmsReportSurveyInfoBase$containerId";

  static String cmsGatePassSurveyReport(int gatePassId) => "$CmsReportGatePassSurveyInfoBase$gatePassId";

  static String cmsFileUploadDownload(int documentId) => "$CmsFileUploadDownloadBase$documentId";

  static const String GetAllGatePass = "/api/services/app/MobileGatePassAccess/GetAllPaged";

  static const String GetAllVisitorPaged = "/api/services/app/MobileGatePassAccess/GetAllVisitorPaged";
  static const String GetAllTransporters = "/api/services/app/Transporter/GetAll";

//Checklists
  ///api/services/app/GatePassChecklist/GetEmptyChecklistForGatePass
  static const String getEmptyChecklistForGatePass = "/api/services/app/GatePassChecklist/GetEmptyChecklistForGatePass";

  ///api/services/app/GatePassChecklist/SubmitResponses
  static const String submitResponses = "/api/services/app/GatePassChecklist/SubmitResponses";

  static const String findChecklistTemplate = "/api/services/app/GatePassChecklist/FindChecklistTemplate";

  ///api/services/app/Incident/Create
  static const String CreateIncident = "/api/services/app/Incident/Create";

  ///api/services/app/Incident/GetAll
  static const String GetAllIncidents = "/api/services/app/Incident/GetAll";

// PRE BOOKINGS **********

  static const String findPreBookedLoad = "/api/services/app/MobileGatePassAccess/FindPreBookedLoad";
  static const String findPreBookedLoadByVoyageNo = "/api/services/app/MobileGatePassAccess/FindPreBookedLoadByVoyageNo";

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
    "http://localhost:6636",
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
  static const String msgForeignLicensePhotoRequired = "Foreign license photo is required";

  // Trailer Validation Messages
  static const String msgRegMismatch = "registration number does not match the scanned :";

  // General Validation Messages
  static const String msgCustomerRequired = "Customer is required!";
  static const String msgScanDataProcessingFailed = "Failed to process scan data";

  // Network and Connection Messages
  static const String msgInternetConnectionLost = "The Network connection was lost.";

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

  static const String resolveChecklistType = '/api/services/app/GatePassChecklist/ResolveChecklistType';
}
