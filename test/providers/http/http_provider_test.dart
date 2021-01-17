import 'package:gallery/providers/http/http_provider.dart';
import 'package:gallery/providers/http/http_response_model.dart';
import 'package:gallery/providers/http/http_service.dart';
import 'package:gallery/utils/functional/json_failure.dart';
import 'package:gallery/utils/functional/mayfail.dart';
import 'package:gallery/utils/functional/option.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../fakes/mock_http_service.dart';

void main() {
  _testPost();
  _testGet();
  _testGetAndDecode();
  _testGetAndDecodeList();
}

void _testPost() {
  group('post', () {
    test('with no header', _postTest);
    test('with failing header', () {
      _postTest(headerFail: true);
    });
    test('with header', () {
      _postTest(headerSuccess: true);
    });
    test('http request throws', () {
      _postTest(requestThrows: true);
    });
  });
}

void _testGet() {
  group('get', () {
    test('with no header', _getTest);
    test('with failing header', () {
      _getTest(headerFail: true);
    });
    test('with header', () {
      _getTest(headerSuccess: true);
    });
    test('http request throws', () {
      _postTest(requestThrows: true);
    });
  });
}

void _testGetAndDecode() {
  group('getAndDecode', () {
    test('with response ok', _getAndDecodeTest);
    test('with response failure', () {
      _getAndDecodeTest(responseFailure: true);
    });
    test('with json response error', () {
      _getAndDecodeTest(jsonError: true);
    });
    test('with json response invalid', () {
      _getAndDecodeTest(jsonInvalid: true);
    });
  });
}

void _testGetAndDecodeList() {
  group('getAndDecodeList', () {
    test('with response ok', _getAndDecodeListTest);
    test('with response failure', () {
      _getAndDecodeListTest(responseFailure: true);
    });
    test('with json response error', () {
      _getAndDecodeListTest(jsonError: true);
    });
    test('with json response invalid', () {
      _getAndDecodeListTest(jsonInvalid: true);
    });
  });
}

class RequestException implements Exception {
  const RequestException();
}

String _url = 'myUrl';
String _body = '{"key":"value"}';
String _jwt = 'myJwt';

String _fromJson(Map<String, dynamic> json) => json['key'] as String;
http.Response httpResponseSuccess =
    MockHttpResponse(body: _body, statusCode: 200);
var _getHeader = {
  'authorization': 'Bearer $_jwt',
};
HttpService _httpService = MockHttpService();
HttpProvider _provider = HttpProvider(_httpService);

Future<void> _requestTest({
  bool responseSuccess = true,
  bool headerFail = false,
  bool headerSuccess = false,
  bool requestThrows = false,
  Future<http.Response> Function() request,
  Future<http.Response> Function() requestWithoutHeader,
  Future<MayFail<HttpResponseModel, HttpFailure>> Function() functionToTest,
}) async {
  assert(!(headerFail && headerSuccess));
  bool hasHeaders = headerSuccess || headerFail;
  if (hasHeaders) {
    Option<String> jwt;
    if (headerSuccess) {
      jwt = Some(_jwt);
    } else {
      jwt = none;
    }
    _provider = HttpProvider(_httpService, () async => jwt);
  }
  MayFail<HttpResponseModel, HttpFailure> expected;
  if (requestThrows) {
    const RequestException _requestException = RequestException();
    when(requestWithoutHeader()).thenThrow(_requestException);
    when(request()).thenThrow(_requestException);
    expected =
        const Fail<HttpFailure>(HttpErrorFailure(error: _requestException));
  } else {
    var mockResponse = responseSuccess
        ? httpResponseSuccess
        : MockHttpResponse(statusCode: 400);
    Future<http.Response> answer(Invocation _) => Future.value(mockResponse);
    when(requestWithoutHeader()).thenAnswer(answer);
    when(request()).thenAnswer(answer);
    expected = Success(HttpResponseModel(
        statusCode: mockResponse.statusCode, body: mockResponse.body));
  }
  var res = await functionToTest();
  if (headerSuccess) {
    verify(request());
  } else {
    verify(requestWithoutHeader());
  }
  expect(res, equals(expected));
}

Future<void> _postTest({
  bool responseSuccess = true,
  bool headerFail = false,
  bool headerSuccess = false,
  bool requestThrows = false,
}) async {
  var _postHeader = {
    'authorization': 'Bearer $_jwt',
    'Content-Type': 'application/json; charset=UTF-8',
  };
  return _requestTest(
    responseSuccess: responseSuccess,
    headerSuccess: headerSuccess,
    headerFail: headerFail,
    requestThrows: requestThrows,
    requestWithoutHeader: () => _httpService.post(_url, body: _body),
    request: () => _httpService.post(_url, body: _body, headers: _postHeader),
    functionToTest: () => _provider.post(
        url: _url, body: _body, headers: headerSuccess || headerFail),
  );
}

Future<void> _getTest({
  bool responseSuccess = true,
  bool headerFail = false,
  bool headerSuccess = false,
}) async {
  return _requestTest(
    responseSuccess: responseSuccess,
    headerSuccess: headerSuccess,
    headerFail: headerFail,
    requestWithoutHeader: () => _httpService.get(_url),
    request: () => _httpService.get(_url, headers: _getHeader),
    functionToTest: () =>
        _provider.get(url: _url, headers: headerSuccess || headerFail),
  );
}

Future<void> _getAndDecodeJsonTest<T>({
  @required http.Response responseSuccess,
  @required http.Response responseSuccessJsonInvalid,
  bool hasHeader = true,
  int responseErrorCode,
  bool jsonError = false,
  bool jsonInvalid = false,
  bool returnsOption = false,
  Future<MayFail<T, Failure>> Function() functionToTest,
}) async {
  assert(!(jsonError && jsonInvalid));
  bool badJson = jsonError || jsonInvalid;
  bool hasResponseError = responseErrorCode != null;
  assert(!(hasResponseError && badJson));
  http.Response mockResponse;
  if (badJson) {
    if (jsonError) {
      mockResponse = MockHttpResponse(body: 'no-json', statusCode: 200);
    } else {
      mockResponse = responseSuccessJsonInvalid;
    }
  } else {
    mockResponse = hasResponseError
        ? MockHttpResponse(statusCode: responseErrorCode)
        : responseSuccess;
  }
  Future<http.Response> requestAnswer(Invocation _) =>
      Future.value(mockResponse);
  Future<http.Response> request() =>
      _httpService.get(_url, headers: _getHeader);
  Future<http.Response> requestWithoutHeader() => _httpService.get(_url);
  when(hasHeader ? request() : requestWithoutHeader())
      .thenAnswer(requestAnswer);
  if (hasHeader) {
    _provider = HttpProvider(_httpService, () async => Some(_jwt));
  }
  var res = await functionToTest();
  if (hasHeader) {
    verify(request());
  } else {
    verify(requestWithoutHeader());
  }
  if (badJson) {
    res.on(
      onSuccess: (s) => fail('Should be Failure'),
      onFailure: (f) {
        if (jsonError) {
          expect(f, isA<JsonDecodingFailure>());
        } else {
          expect(f, isA<JsonInvalidFailure>());
        }
      },
    );
  } else {
    const Map<String, dynamic> _successJson = <String, dynamic>{'key': 'value'};
    MayFail<dynamic, Failure> expected;
    if (returnsOption) {
      if (responseErrorCode == 404) {
        expected = const Success<dynamic>(none);
      } else if (hasResponseError) {
        expected =
            Fail(HttpNotSuccessfulFailure(statusCode: responseErrorCode));
      } else {
        expected = Success<dynamic>(Some(_fromJson(_successJson)));
      }
    } else {
      if (hasResponseError) {
        expected =
            Fail(HttpNotSuccessfulFailure(statusCode: responseErrorCode));
      } else {
        expected = Success<dynamic>(_fromJson(_successJson));
      }
    }
    expect(res, equals(expected));
  }
}

Future<void> _getAndDecodeTest({
  bool responseFailure = false,
  bool jsonError = false,
  bool jsonInvalid = false,
}) {
  http.Response httpResponseSuccessJsonInvalid =
      MockHttpResponse(body: '{"key":2}', statusCode: 200);
  _getAndDecodeJsonTest(
    hasHeader: false,
    responseErrorCode: responseFailure ? 404 : null,
    jsonError: jsonError,
    jsonInvalid: jsonInvalid,
    functionToTest: () =>
        _provider.getAndDecode(url: _url, fromJson: _fromJson, headers: false),
    responseSuccess: httpResponseSuccess,
    responseSuccessJsonInvalid: httpResponseSuccessJsonInvalid,
  );
  return _getAndDecodeJsonTest(
    hasHeader: true,
    responseErrorCode: responseFailure ? 401 : null,
    jsonError: jsonError,
    jsonInvalid: jsonInvalid,
    functionToTest: () =>
        _provider.getAndDecode(url: _url, fromJson: _fromJson, headers: true),
    responseSuccess: httpResponseSuccess,
    responseSuccessJsonInvalid: httpResponseSuccessJsonInvalid,
  );
}

Future<void> _getAndDecodeListTest({
  bool responseFailure = false,
  bool jsonError = false,
  bool jsonInvalid = false,
}) {
  String _fromJsonList(List<Map<String, dynamic>> json) =>
      json[0]['key'] as String;
  http.Response httpResponseSuccessList =
      MockHttpResponse(body: '[{"key":"value"}]', statusCode: 200);
  http.Response httpResponseSuccessJsonInvalidList =
      MockHttpResponse(body: '[{"key":2}]', statusCode: 200);
  _getAndDecodeJsonTest(
    hasHeader: false,
    responseErrorCode: responseFailure ? 404 : null,
    jsonError: jsonError,
    jsonInvalid: jsonInvalid,
    functionToTest: () => _provider.getAndDecodeList(
        url: _url, fromJson: _fromJsonList, headers: false),
    responseSuccess: httpResponseSuccessList,
    responseSuccessJsonInvalid: httpResponseSuccessJsonInvalidList,
  );
  return _getAndDecodeJsonTest(
    hasHeader: true,
    responseErrorCode: responseFailure ? 401 : null,
    jsonError: jsonError,
    jsonInvalid: jsonInvalid,
    functionToTest: () => _provider.getAndDecodeList(
        url: _url, fromJson: _fromJsonList, headers: true),
    responseSuccess: httpResponseSuccessList,
    responseSuccessJsonInvalid: httpResponseSuccessJsonInvalidList,
  );
}
