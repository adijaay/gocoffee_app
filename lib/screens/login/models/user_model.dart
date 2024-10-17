class UserDataModel {
  final int id;
  final String name;
  final String password;
  final String salt;
  final String email;
  final String phoneNumber;
  final String? token;
  final String type;
  final bool verified;
  final int? merchId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserDataModel({
    required this.id,
    required this.name,
    required this.password,
    required this.salt,
    required this.email,
    required this.phoneNumber,
    this.token,
    required this.type,
    required this.verified,
    this.merchId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      salt: json['salt'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      token: json['token'],
      type: json['type'],
      verified: json['verified'],
      merchId: json['merchantId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'salt': salt,
      'email': email,
      'phone_number': phoneNumber,
      'token': token,
      'type': type,
      'verified': verified,
      'merchantId': merchId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
