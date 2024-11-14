class ApiResponse {
  dynamic result;
  String? targetUrl;
  String? message;
  bool? success;
  bool? showMessage;
  Error? error;
  bool? unAuthorizedRequest;
  bool? bAbp;

  ApiResponse(
      {this.result,
      this.targetUrl,
      this.message,
      this.success,
      this.error,
      this.unAuthorizedRequest,
      this.bAbp,
      this.showMessage = false});

  ApiResponse.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    targetUrl = json['targetUrl'];
    message = json['message'];
    success = json['success'];
    error = json['error'] != null ? new Error.fromJson(json['error']) : null;
    unAuthorizedRequest = json['unAuthorizedRequest'];
    bAbp = json['__abp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['targetUrl'] = this.targetUrl;
    data['message'] = this.message;
    data['success'] = this.success;
    if (this.error != null) {
      data['error'] = this.error!.toJson();
    }
    data['unAuthorizedRequest'] = this.unAuthorizedRequest;
    data['__abp'] = this.bAbp;
    return data;
  }
}

class Error {
  int? code;
  String? message;
  String? details;
  List<ValidationErrors>? validationErrors;

  Error({this.code, this.message, this.details, this.validationErrors});

  Error.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    details = json['details'];
    if (json['validationErrors'] != null) {
      validationErrors = <ValidationErrors>[];
      json['validationErrors'].forEach((v) {
        validationErrors!.add(new ValidationErrors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    data['details'] = this.details;
    if (this.validationErrors != null) {
      data['validationErrors'] =
          this.validationErrors!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ValidationErrors {
  String? message;
  List<String>? members;

  ValidationErrors({this.message, this.members});

  ValidationErrors.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    members = json['members'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['members'] = this.members;
    return data;
  }
}

class BaseResponse {
  bool? success;
  List<String>? messages;
  String? message;

  BaseResponse({this.success, this.messages, this.message});

  BaseResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message']?.cast<String>();
    messages = json['messages']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['messages'] = messages;
    data['message'] = message;
    return data;
  }

  String messagesToString() {
    return messages != null ? messages!.join(", ") : "";
  }
}
