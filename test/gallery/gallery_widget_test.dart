import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/gallery/gallery_widget.dart';
import 'package:gallery/images/repository/image_model.dart';
import 'package:gallery/images/repository/images_repository.dart';
import 'package:gallery/utils/functional/mayfail.dart';

import '../utils/test_utils.dart';

void main() {
  _testBuild();
}

void _testBuild() {
  group('Build Widget', () {
    testWidgets('with error result', (WidgetTester tester) async {
      await _pumpWidget(tester, _FakeImagesRepository(requestFail: true));
      expect(_imageWidget, findsNothing);
    });

    testWidgets('with empty result', (WidgetTester tester) async {
      await _pumpWidget(tester, _FakeImagesRepository(imagesLength: 0));
      expect(_imageWidget, findsNothing);
    });

    Future<void> testResults(WidgetTester tester,
        {int pageSize, int maxImages}) async {
      var repository = _FakeImagesRepository(
          imagesPerPage: pageSize, imagesLength: maxImages);
      await _pumpWidget(tester, repository);
      await tester.pumpAndSettle();
      expect(_imageWidget, findsNWidgets(maxImages));
      _imageWidget.evaluate().every((element) {
        var widget = element.widget as _FakeImage;
        return widget.image == repository.images[widget.index];
      });
    }

    testWidgets('with results in one page', (WidgetTester tester) async {
      await testResults(tester, pageSize: 5, maxImages: 4);
    });

    testWidgets('with results in one full page', (WidgetTester tester) async {
      await testResults(tester, pageSize: 8, maxImages: 8);
    });

    testWidgets('with results in two pages', (WidgetTester tester) async {
      await testResults(tester, pageSize: 6, maxImages: 10);
    });

    testWidgets('with results in multiple pages', (WidgetTester tester) async {
      await testResults(tester, pageSize: 4, maxImages: 16);
    });
  });
}

Finder get _imageWidget => find.byType(_FakeImage);

Future<void> _pumpWidget(
    WidgetTester tester, _FakeImagesRepository repository) {
  Widget widget = GalleryWidget(
    repository,
    imageBuilder: (context, item, index) => _FakeImage(item, index),
  );
  return tester.pumpWidget(TestUtils.buildTestableWidget(widget));
}

class _FakeImagesRepository implements ImagesRepository {
  final bool requestFail;
  final int imagesLength;
  final int imagesPerPage;
  List<ImageModel> images = [];

  int _currentIndex = 0;

  _FakeImagesRepository({
    this.requestFail = false,
    this.imagesLength = 100,
    this.imagesPerPage = 10,
  });

  @override
  Future<MayFail<List<ImageModel>, Failure>> getImages(int page,
      {String query}) async {
    if (requestFail) return const Fail(null);

    List<ImageModel> imagesOfPage = [
      for (int i = 0; i < imagesPerPage && _currentIndex < imagesLength; i++)
        _makeImage(_currentIndex++)
    ];
    images.addAll(imagesOfPage);

    return Success(imagesOfPage);
  }

  @override
  double get thumbSize => 64;

  ImageModel _makeImage(int n) {
    return ImageModel(
        id: 'id$n',
        title: 'title$n',
        imageUrl: 'imageUrl$n',
        thumbUrl: 'thumbUrl$n');
  }
}

class _FakeImage extends StatelessWidget {
  final ImageModel image;
  final int index;

  const _FakeImage(this.image, this.index, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}
