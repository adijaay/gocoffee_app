import 'package:coffeonline/screens/home-merchant/models/merchant_model.dart';
import 'package:coffeonline/utils/api.dart';
import 'package:coffeonline/utils/api_path.dart';
import 'package:coffeonline/utils/print_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MerchantService with ChangeNotifier {
  final APIservice apiService = APIservice();

  int count = 0;

  List<Merchant> listMerchant = [];

  void incrementCount() {
    count++;
    notifyListeners();
  }

  void decrementCount() {
    count = 0;
    notifyListeners();
  }

  Future<void> updateLocation({required String latitude, required String longitude, required String token, required String id}) async {
    try {
      Response response = await apiService.postApi(
        path: APIpath.updateMerchLocation,
        headers: {'Authorization': 'Bearer $token'},
        data: {
          "latitude": latitude,
          "longitude": longitude,
          "orderID": id
        },
      );
      if (response.statusCode == 200) {
        printLog(response.data);
        notifyListeners();
      } else {
        printLog('Gagal, code: ${response.data}');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> searchNearbyMerchant({
    required String token,
    required String lat,
    required String long,
    required int stock,
  }) async {
    try {
      Response response = await apiService.postApi(
        path: APIpath.nearbyMerchant,
        headers: {'Authorization': 'Bearer $token'},
        data: {
          "lat": lat,
          "long": long,
          "stock": stock,
        },
      );

      if (response.statusCode == 200) {
        printLog(response.data);
        var list = response.data as List;
        printLog(list);
        listMerchant = list.map((e) => Merchant.fromJson(e)).toList();
        notifyListeners();
      } else {
        printLog('Gagal, code: ${response.data}');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> getAllMerchant({required String token}) async {
    try {
      Response response = await apiService.getApi(
        path: APIpath.getAllMerchant,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        printLog(response.data);
      } else {
        printLog('Gagal, code: ${response.data}');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> getMerchantById({
    required String token,
    required String id,
  }) async {
    try {
      Response response = await apiService.getApi(
        path: '${APIpath.getMerchantById}/$id',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        printLog(response.data);
      } else {
        printLog('Gagal, code: ${response.data}');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> updateMerchInfo(
      {required String id,
      required String token,
      required String latitude,
      required String longitude,
      required String? stock,
      required String? price,
      required List<int>? coffeeID}) async {
    try {
      if (coffeeID != null && coffeeID.isNotEmpty) {
        await apiService.postApi(
            path: '${APIpath.deleteCoffee}',
            headers: {'Authorization': 'Bearer $token'},
            data: {"merchantID": id});
      }
      Response response = await apiService.postApi(
        path: '${APIpath.updateMerchantInfo}/$id',
        headers: {'Authorization': 'Bearer $token'},
        data: {
          "latitude": latitude,
          "longitude": longitude,
          if (stock != null && stock.isNotEmpty) 'stock': stock,
          if (price != null && price.isNotEmpty) 'price': price,
          if (coffeeID != null && coffeeID.isNotEmpty) 'coffeeID': coffeeID,
        },
      );

      if (response.statusCode == 200) {
        printLog(response.data);
      } else {
        printLog('Gagal, code: ${response.data}');
      }
    } catch (e) {
      printLog(e);
    }
  }
}
