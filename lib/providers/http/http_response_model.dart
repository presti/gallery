import 'package:equatable/equatable.dart';

class HttpResponseModel with EquatableMixin {
  final int statusCode;
  final String body;

  const HttpResponseModel({this.statusCode, this.body});

  @override
  List<Object> get props => [statusCode, body];

  @override
  bool get stringify => true;
}
