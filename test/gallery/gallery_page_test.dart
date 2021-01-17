import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/gallery/gallery_page.dart';
import 'package:gallery/gallery/gallery_widget.dart';
import 'package:gallery/images/repository/image_model.dart';
import 'package:gallery/images/repository/images_repository.dart';
import 'package:gallery/theme/images.dart';
import 'package:gallery/utils/functional/mayfail.dart';

import '../utils/test_utils.dart';

void main() {
  _testInit();
  _testQuery();
}

void _testInit() {
  group('Init', () {
    testWidgets('build AppBar and GalleryWidget', (WidgetTester tester) async {
      await _pumpWidget(tester);

      expect(_appBar, findsOneWidget);
      expect(_searchButton, findsOneWidget);
      expect(_galleryWidget, findsOneWidget);
    });
  });
}

void _testQuery() {
  group('Opening SearchBar', () {
    testWidgets('SearchBar elements are shown', (WidgetTester tester) async {
      await _pumpSearchBar(tester);
      expect(_searchField, findsOneWidget);
      expect(_searchFieldWithText(''), findsOneWidget);
      expect(_cancelButton, findsOneWidget);
      expect(_backButton, findsOneWidget);
      expect(_galleryWidget, findsNothing);
    });
  });

  group('Query Images', () {
    var cases = {
      'empty String': '',
      'one letter': 'q',
      'one number': '1',
      'an emoji': TestUtils.emoji,
      'special chars': TestUtils.symbolsExceptMinusAndUnderscore
    };
    cases.forEach((description, query) {
      testWidgets('searching for "$description"', (WidgetTester tester) async {
        await _pumpSearchBar(tester);
        await tester.enterText(_searchField, query);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(_galleryWidget, findsOneWidget);
        GalleryWidget widget =
        _galleryWidget.evaluate().single.widget as GalleryWidget;
        expect(widget.query, query);
      });
    });
  });

  group('SearchBar Actions', () {
    testWidgets('pressing X clears query', (WidgetTester tester) async {
      await _pumpSearchBar(tester);
      String query = 'wq';
      for (int i = 0; i < 3; i++) {
        await tester.tap(_cancelButton);
        expect(_searchFieldWithText(''), findsOneWidget);
        await tester.enterText(_searchField, query);
        expect(_searchFieldWithText(query), findsOneWidget);
      }
    });

    Future<void> testBackButton(WidgetTester tester) async {
      await tester.tap(_backButton);
      await tester.pumpAndSettle();
      expect(_searchButton, findsOneWidget);
      expect(_galleryWidget, findsOneWidget);
      expect(_searchField, findsNothing);
      expect(_cancelButton, findsNothing);
      expect(_backButton, findsNothing);
    }

    testWidgets('pressing back without query pops Widget',
            (WidgetTester tester) async {
          await _pumpSearchBar(tester);
          await testBackButton(tester);
        });

    testWidgets('pressing back with query not searched pops Widget',
            (WidgetTester tester) async {
          await _pumpSearchBar(tester);
          await tester.enterText(_searchField, 'query');
          await testBackButton(tester);
        });

    testWidgets('pressing back with searched query pops Widget',
            (WidgetTester tester) async {
          await _pumpSearchBar(tester);
          await tester.enterText(_searchField, 'query');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          await testBackButton(tester);
        });
  });
}

Future<void> _pumpWidget(WidgetTester tester) {
  Widget widget = const GalleryPage(_FakeImageRepository());
  return tester.pumpWidget(TestUtils.buildTestableWidget(widget));
}

Future<void> _pumpSearchBar(WidgetTester tester) async {
  await _pumpWidget(tester);
  await tester.tap(_searchButton);
  await tester.pumpAndSettle();
}

Finder get _appBar => find.byType(AppBar);

Finder get _searchButton => find.byIcon(Images.search);

Finder get _searchField => find.byType(EditableText);

Finder get _galleryWidget => find.byType(GalleryWidget);

Finder get _cancelButton => find.byIcon(Images.close);

Finder get _backButton => find.byIcon(Images.arrowBack);

Finder _searchFieldWithText(String text) {
  return find.descendant(
    of: _searchField,
    matchRoot: true,
    matching: find.text(text),
  );
}

class _FakeImageRepository implements ImagesRepository {
  const _FakeImageRepository();

  @override
  Future<MayFail<List<ImageModel>, Failure>> getImages(int page,
      {String query}) async {
    return const Success([]);
  }

  @override
  double get thumbSize => 24;
}
