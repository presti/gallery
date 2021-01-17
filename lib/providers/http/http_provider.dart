import 'dart:convert' as convert;

import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../utils/functional/json_failure.dart';
import '../../utils/functional/mayfail.dart';
import '../../utils/functional/option.dart';
import 'http_response_model.dart';
import 'http_service.dart';

class HttpProvider {
  final HttpService _httpService;
  final Future<Option<String>> Function() _jwt;

  const HttpProvider(this._httpService, [this._jwt]);

  Future<MayFail<HttpResponseModel, HttpFailure>> post({
    String url,
    String body,
    bool headers = true,
  }) async {
    Option<Map<String, String>> headersOption =
        headers ? await _getHeaders() : none;
    return headersOption.on(
      onSome: (headers) {
        headers.addAll(<String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
        return _call(
            () => _httpService.post(url, body: body, headers: headers));
      },
      onNone: () => _call(() => _httpService.post(url, body: body)),
    );
  }

  Future<MayFail<HttpResponseModel, HttpFailure>> get({
    String url,
    bool headers = true,
  }) async {
    Option<Map<String, String>> headersOption =
        headers ? await _getHeaders() : none;
    return headersOption.on(
      onSome: (headers) => _call(() => _httpService.get(url, headers: headers)),
      onNone: () => _call(() => _httpService.get(url)),
    );
  }

  Future<MayFail<T, Failure>> getAndDecode<T>({
    String url,
    T Function(Map<String, dynamic> json) fromJson,
    bool headers = true,
  }) {
    return _getAndDecodeJson(
      url: url,
      fromJson: fromJson,
      headers: headers,
    );
  }

  Future<MayFail<T, Failure>> getAndDecodeList<T>({
    String url,
    T Function(List<Map<String, dynamic>> jsonList) fromJson,
    bool headers = true,
  }) {
    return _getAndDecodeJson(
      url: url,
      fromJson: (List<dynamic> jsonList) =>
          fromJson(jsonList.cast<Map<String, dynamic>>()),
      headers: headers,
    );
  }

  Future<MayFail<T, Failure>> _getAndDecodeJson<T, J>({
    String url,
    T Function(J json) fromJson,
    bool headers = true,
  }) async {
    MayFail<HttpResponseModel, HttpFailure> response =
        await get(url: url, headers: headers);
    return response.on(
      onSuccess: (res) {
        String response = res.body;
        J json;
        try {
          json = convert.json.decode(response) as J;
        } catch (e) {
          return Fail(JsonDecodingFailure('$e : $response'));
        }
        T t;
        try {
          t = fromJson(json);
        } catch (e) {
          return Fail(JsonInvalidFailure('$e : $response'));
        }
        return Success(t);
      },
      onFailure: (f) => Fail(f),
    );
  }

  Future<MayFail<HttpResponseModel, HttpFailure>> _call(
      Future<http.Response> Function() call) async {
    MayFail<HttpResponseModel, HttpFailure> mayfail;
    try {
      http.Response response = await call();
      int statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode < 300) {
        String responseBody = convert.utf8.decode(response.bodyBytes);
        mayfail = Success(
            HttpResponseModel(statusCode: statusCode, body: responseBody));
      } else {
        mayfail = Fail(HttpNotSuccessfulFailure(statusCode: statusCode));
      }
    } catch (e) {
      mayfail = Fail(HttpErrorFailure(error: e));
    }

    return mayfail;
  }

  Future<Option<Map<String, String>>> _getHeaders() async {
    Option<String> jwtOption = (await _jwt?.call()) ?? none;
    return jwtOption.on(
      onSome: (jwt) => Some({'authorization': 'Bearer $jwt'}),
      onNone: () => none,
    );
  }
}

class HttpFailure implements Failure {}

class HttpNotSuccessfulFailure with EquatableMixin implements HttpFailure {
  final int statusCode;

  const HttpNotSuccessfulFailure({this.statusCode});

  @override
  List<Object> get props => [statusCode];

  @override
  bool get stringify => true;
}

class HttpErrorFailure with EquatableMixin implements HttpFailure {
  final Object error;

  const HttpErrorFailure({@required this.error});

  @override
  List<Object> get props => [error];
}

class HeadersNotAvailableFailure implements HttpFailure {
  const HeadersNotAvailableFailure();
}
