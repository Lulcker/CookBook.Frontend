class AuthModel {
  String login;
  String password;

  AuthModel({
    required this.login,
    required this.password
  });
}

class AuthResponseModel {
  String jwtToken;
  String login;
  UserRole role;
  bool isAuthorized;

  AuthResponseModel({
    required this.jwtToken,
    required this.login,
    required this.role,
    required this.isAuthorized
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
        jwtToken: json['jwtToken'],
        login: json['login'],
        role: UserRole.values[json['role']],
        isAuthorized: true
    );
  }
}

enum UserRole {
  anonymous,

  customer,

  administrator
}