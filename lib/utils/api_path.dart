class APIpath {
  /// AUTH
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String getUserData = '/api/user'; // By ID
  static const String updateTokenFcmUser =
      '/api/user'; // By ID (if fcm empty use this api to patch fcm token)
  static const String changeName = '/api/user';

  /// ORDER
  static const String getOrderById = '/api/order/search'; // need param ID
  static const String getOrderByUser = '/api/order/user'; // need param ID
  static const String getOrderByMerchant =
      '/api/order/merchant'; // need param ID
  static const String createOrder = '/api/order/create';
  static const String ongoingOrder = '/api/order/ongoing';
  static const String cancleOrder = '/api/order/cancle';
  static const String completeOrder = '/api/order/complete';

  /// MERCHANT
  static const String nearbyMerchant = '/api/merchant/nearby';
  static const String getAllMerchant = '/api/merchant';
  static const String getMerchantById = '/api/merchant'; // need param ID
  static const String updateMerchantInfo =
      '/api/updatemerchant'; // need param ID

  static const String getCoffee = '/api/coffee';
  static const String deleteCoffee = '/api/merchant/deleteCoffee';
  /// ADMIN
  static const String getAllUser = '/api/admin/users';
  static const String getAllOrder = '/api/admin/orders';
  static const String verifyUser = '/api/admin/verifyuser';
}
