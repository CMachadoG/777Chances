import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;
import 'auth_manager.dart';

class AuthInterceptor extends InterceptorContract {
  String accessToken;

  AuthInterceptor(this.accessToken);

  void setToken(String newToken) {
    accessToken = newToken;
  }

  @override
  Future<BaseRequest> interceptRequest(
      {required http.BaseRequest request}) async {
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.headers['Content-type'] = 'application/json';
    request.headers['Accept'] = 'application/json';

    return request;
  }

  @override
  Future<http.BaseResponse> interceptResponse(
      {required BaseResponse response}) async {

    if (response.statusCode == 401) {
      AuthManager().logout();
    }

    return response;
  }
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  Future<bool> shouldAttemptRetryOnRespons({
    required BaseResponse response,
    required int retryCount,
  }) async {
    return response.statusCode == 401 &&
        retryCount <
            3; // Reintentar si el token expiró, cuanats horas como limite?
  }
}
