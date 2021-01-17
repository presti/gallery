import 'mayfail.dart';

class JsonFailure implements Failure {}

class JsonDecodingFailure implements JsonFailure {
  final String source;

  const JsonDecodingFailure(this.source);
}

class JsonInvalidFailure implements JsonFailure {
  final String source;

  const JsonInvalidFailure(this.source);
}
