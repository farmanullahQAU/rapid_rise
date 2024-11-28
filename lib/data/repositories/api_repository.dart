
/*
class ApiRepository {
  final _apiProvider = Get.find<ApiProvider>();

  Future<dynamic> fetchData(
    String endpoint, {
    Map<String, dynamic>? params,
    required String storageKey,
    bool useCache = true,
  }) async {
    late dynamic data;

    await _apiProvider.getData(
      endpoint,
      params: params,
      successCallback: (response) {
        data = response;
      },
      onError: (errorMessage) {
        data = errorMessage;
      },
    );

    return data;
  }

  Future<dynamic> login({
    required String userName,
    required String password,
    required Function(dynamic) successCallback,
    required Function(String) onError,
  }) async {
    Employee employee;
    await _apiProvider
        .postData('/login', body: {"username": userName, "password": password},
            successCallback: (data) {
      employee = Employee.fromJson(data);

      return successCallback(employee);
    }, onError: onError);
  }

  /// Single method to check and insert component scan entry
  Future<void> checkAndInsertComponentStatus({
    required int componentId,
    required int flightId,
    required int userId,
    required Function(dynamic) successCallback,
    required Function(String) onError,
  }) async {
    // Construct the endpoint
    const endpoint = '/check-and-insert-component';

    // Add query parameters
    final params = {
      "componentId": componentId,
      "flightId": flightId,
      "userId": userId,
    };

    await _apiProvider.postData(
      endpoint,
      body: params,
      successCallback: (response) {
        successCallback(response);
      },
      onError: (errorMessage) {
        onError(errorMessage);
      },
    );
  }
}
*/