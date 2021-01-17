import 'package:http/http.dart' as http;

class HttpService {
  const HttpService();

  Future<http.Response> get(String url, {Map<String, String> headers}) {
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(
      String url, {
        Map<String, String> headers,
        String body,
      }) {
    return http.post(url, body: body, headers: headers);
  }
}
