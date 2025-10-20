class ForgotPassword {
  String? emailAddress;
  String? resetCode;
  int? userId;

  ForgotPassword({this.emailAddress, this.resetCode, this.userId});

  ForgotPassword.fromJson(Map<String, dynamic> json) {
    emailAddress = json['emailAddress'] as String?;
    resetCode = json['resetCode'] as String?;
    userId = json['userId'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emailAddress'] = emailAddress;
    data['resetCode'] = resetCode;
    data['userId'] = userId;
    return data;
  }
}
