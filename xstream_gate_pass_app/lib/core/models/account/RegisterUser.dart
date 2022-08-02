class RegisterUser {
  String? name;
  String? surname;
  String? userName;
  String? emailAddress;
  String? password;
  String? confirmPassword;
  String? captchaResponse;
  String? dateOfBirth;
  String? phoneNumber;

  RegisterUser({name, surname, userName, emailAddress, password, confirmPassword, captchaResponse, dateOfBirth, phoneNumber});

  RegisterUser.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    surname = json['surname'] as String?;
    userName = json['userName'] as String?;
    emailAddress = json['emailAddress'] as String?;
    password = json['password'] as String?;
    confirmPassword = json['confirmPassword'] as String?;
    captchaResponse = json['captchaResponse'] as String?;
    dateOfBirth = json['dateOfBirth'] as String?;
    phoneNumber = json['phoneNumber'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['surname'] = surname;
    data['userName'] = userName;
    data['emailAddress'] = emailAddress;
    data['password'] = password;
    data['confirmPassword'] = confirmPassword;
    data['captchaResponse'] = captchaResponse;
    data['dateOfBirth'] = dateOfBirth;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}
