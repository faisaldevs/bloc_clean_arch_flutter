class LoginRequestModel {
  const LoginRequestModel({required this.mobile, required this.password});

  final String mobile;
  final String password;

  Map<String, dynamic> toJson() => {'mobile': mobile, 'password': password};
}
