import 'package:meta/meta.dart';

const None none = None();

abstract class Option<V> {
  T on<T>({@required T Function(V) onSome, @required T Function() onNone});

  void onSome(void Function(V) onSome);

  void onNone(void Function() onNone);
}

@immutable
class Some<V> implements Option<V> {
  final V _value;

  const Some(this._value);

  @override
  T on<T>({@required T Function(V) onSome, T Function() onNone}) =>
      onSome(_value);

  @override
  void onSome(void Function(V) onSome) => onSome(_value);

  @override
  void onNone(void Function() onNone) {}

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Some<V> &&
            runtimeType == other.runtimeType &&
            _value == other._value;
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Some($_value)';
}

@immutable
class None implements Option<Null> {
  const None();

  @override
  T on<T>({T Function(Null) onSome, @required T Function() onNone}) => onNone();

  @override
  void onSome(void Function(Null) onSome) {}

  @override
  void onNone(void Function() onNone) => onNone();
}
