import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:gallery/providers/http/http_service.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

class MockHttpService extends Mock implements HttpService {}

class MockHttpResponse extends Mock implements http.Response {
  MockHttpResponse({@required int statusCode, String body}) {
    when(this.statusCode).thenReturn(statusCode);
    when(this.body).thenReturn(body);
    Uint8List bodyBytes;
    if (body != null) {
      bodyBytes = convert.utf8.encode(body) as Uint8List;
    }
    when(this.bodyBytes).thenReturn(bodyBytes);
  }
}
