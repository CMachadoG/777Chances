import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:chances/services/auth_interceptor.dart';

late http.Client client;

void configureInterceptor(String accessToken) {
  // Inicializa el cliente con el interceptor
  client = InterceptedClient.build(
    interceptors: [AuthInterceptor(accessToken)],
    retryPolicy: ExpiredTokenRetryPolicy(),
  );
}
