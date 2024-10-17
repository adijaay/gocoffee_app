class HistoryModel {
  int id;
  int amount;
  String totalPrice;
  String address;
  String addressDetail;
  double latitudeBuyer;
  double longitudeBuyer;
  String? coffee_requested;
  String? doneAt;
  String status;
  int userId;
  int? merchantId;
  DateTime createdAt;
  DateTime updatedAt;
  Merchant? merchant;
  MerchantUser user;

  HistoryModel({
    required this.id,
    required this.amount,
    required this.totalPrice,
    required this.address,
    required this.addressDetail,
    required this.latitudeBuyer,
    required this.longitudeBuyer,
    required this.coffee_requested,
    this.doneAt,
    required this.status,
    required this.userId,
    required this.merchantId,
    required this.createdAt,
    required this.updatedAt,
    required this.merchant,
    required this.user,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      amount: json['amount'],
      totalPrice: json['totalPrice'],
      address: json['address'],
      addressDetail: json['address_detail'],
      latitudeBuyer: double.parse(json['latitude_buyer']),
      longitudeBuyer: double.parse(json['longitude_buyer']),
      coffee_requested: json['coffee_requested'],
      doneAt: json['done_at'],
      status: json['status'],
      userId: json['userID'],
      merchantId: json['merchantID'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      merchant: json['Merchant'] != null ? Merchant.fromJson(json['Merchant']) : null,
      user: MerchantUser.fromJson(json['User']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'totalPrice': totalPrice,
      'address': address,
      'address_detail': addressDetail,
      'latitude_buyer': latitudeBuyer,
      'longitude_buyer': longitudeBuyer,
      'coffee_requested': coffee_requested,
      'done_at': doneAt,
      'status': status,
      'userID': userId,
      'merchantID': merchantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'Merchant': merchant?.toJson(),
      'User': user.toJson(),
    };
  }
}

class Merchant {
  int id;
  double latitude;
  double longitude;
  MerchantUser user;

  Merchant({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.user,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      user: MerchantUser.fromJson(json['User']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'User': user.toJson(),
    };
  }
}

class MerchantUser {
  int id;
  String name;
  String email;
  String phoneNumber;

  MerchantUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory MerchantUser.fromJson(Map<String, dynamic> json) {
    return MerchantUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}
