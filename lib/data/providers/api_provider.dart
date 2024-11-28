/*

import 'package:get/get.dart';

class ApiProvider extends GetConnect {
  static const String _baseUrl = 'http://192.168.100.40:3000/api/';

  ApiProvider() {
    timeout = const Duration(seconds: 5); // Default timeout for API calls
    httpClient.baseUrl = _baseUrl;
  }

  Future<void> getData(
    String endpoint, {
    Map<String, dynamic>? params,
    required Function(dynamic) successCallback,
    required Function(String) onError,
  }) async {
    try {
      final response = await get(endpoint, query: params);
      if (response.isOk) {
        final data = response.body['data'];
        successCallback(data);
      } else {
        onError('Failed to fetch data: ${response.statusText}');
      }
    } catch (e) {
      print('Error: $e');
      onError('Failed to connect: $e');
    }
  }

  Future<void> postData(
    String endpoint, {
    required Map<String, dynamic> body,
    required Function(dynamic) successCallback,
    required Function(String) onError,
  }) async {
    try {
      final response = await post(endpoint, body);
      print(response.body);
      if (response.isOk) {
        successCallback(response.body['data']);
      } else {
        onError(response.body['message']);
      }
    } catch (e) {
      onError('Failed to connect: $e');
    }
  }
}
*/