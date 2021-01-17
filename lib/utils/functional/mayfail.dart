import 'package:meta/meta.dart';

abstract class MayFail<V, F extends Failure> {
  T on<T>({
    @required T Function(V) onSuccess,
    @required T Function(F) onFailure,
  });
}

@immutable
class Success<V> implements MayFail<V, Null> {
  final V _value;

  const Success(this._value);

  const Success.empty() : this(null);

  @override
  T on<T>({@required T Function(V) onSuccess, T Function(Null) onFailure}) =>
      onSuccess(_value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<V> && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Success($_value)';
}

@immutable
class Fail<F extends Failure> implements MayFail<Null, F> {
  final F _failure;

  const Fail(this._failure);

  @override
  T on<T>({T Function(Null) onSuccess, @required T Function(F) onFailure}) =>
      onFailure(_failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Fail<F> && _failure == other._failure;

  @override
  int get hashCode => _failure.hashCode;

  @override
  String toString() => 'Fail($_failure)';
}

class Failure {}
