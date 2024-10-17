import 'package:coffeonline/utils/print_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIservice {
  final dio = Dio();

  APIservice() {
    dio.options.baseUrl = dotenv.env['BASEURL'].toString();
    dio.options.headers = {'Content-Type': 'application/json'};
  }

  Future<Response> postApi({
    required String path,
    required Map<String, dynamic> data, // Request body
    Map<String, dynamic>? params, // Query parameters
    Map<String, dynamic>? headers, // Additional headers
  }) async {
    try {
      Uri uri = Uri.parse(path);
      if (params != null) {
        uri = uri.replace(queryParameters: params);
      }

      Response response = await dio.post(
        uri.toString(),
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      Response response = e.response!;
      printLog(e);
      return response;
    }
  }

  Future<Response> getApi({
    required String path,
    Map<String, dynamic>? headers,
  }) async {
    try {
      Response response = await dio.get(
        path,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      Response response = e.response!;
      printLog(e);
      return response;
    }
  }

  Future<Response> getwithparamandbodyApi({
    required String path,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      Response response = await dio.get(
        path,
        queryParameters: data,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      Response response = e.response!;
      printLog(e);
      return response;
    }
  }

  Future<Response> patchApi({
    required String path,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      Response response = await dio.patch(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      Response response = e.response!;
      printLog(e);
      return response;
    }
  }
}
