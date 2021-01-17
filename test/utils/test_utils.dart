import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class TestUtils {
  static const String emoji =
      '\u{1F3F4}\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}';
  static const String symbolsExceptMinusAndUnderscore =
      '{}+!|#&/()=?\$,.-;:_<>\\^`~¨[]*äá"\'';

  static Widget buildTestableWidget(Widget widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }
}
