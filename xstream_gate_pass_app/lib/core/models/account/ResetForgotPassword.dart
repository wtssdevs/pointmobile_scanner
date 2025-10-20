class ResetForgotPassword {
  String? newPassword;
  String? resetCode;
  int? userId;

  ResetForgotPassword({this.newPassword, this.resetCode, this.userId});

  ResetForgotPassword.fromJson(Map<String, dynamic> json) {
    newPassword = json['newPassword'] as String?;
    resetCode = json['resetCode'] as String?;
    userId = json['userId'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['newPassword'] = this.newPassword;
    data['resetCode'] = this.resetCode;
    data['userId'] = this.userId;
    return data;
  }
}
