import 'package:flutter/material.dart';
import 'package:gallery/gallery/gallery_image_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../images/repository/image_model.dart';
import '../images/repository/images_repository.dart';
import '../theme/dimen.dart';
import '../utils/functional/mayfail.dart';

typedef _ImageBuilder = Widget Function(
  BuildContext context,
  ImageModel item,
  int index,
);

class GalleryWidget extends StatefulWidget {
  final String query;
  final ImagesRepository repository;
  final _ImageBuilder imageBuilder;

  const GalleryWidget(
    this.repository, {
    Key key,
    this.query,
    this.imageBuilder = _builder,
  }) : super(key: key);

  static Widget _builder(BuildContext context, ImageModel item, int index) {
    return GalleryImageWidget(image: item);
  }

  @override
  _GalleryWidgetState createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  final PagingController<int, ImageModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, ImageModel>(
      padding: const EdgeInsets.only(bottom: Dimen.gallerySpacing),
      pagingController: _pagingController,
      builderDelegate:
          PagedChildBuilderDelegate(itemBuilder: widget.imageBuilder),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.repository.thumbSize,
        mainAxisSpacing: Dimen.gallerySpacing,
        crossAxisSpacing: Dimen.gallerySpacing,
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    MayFail<List<ImageModel>, Failure> images =
        await widget.repository.getImages(pageKey, query: widget.query);
    images.on(
      onSuccess: (images) {
        if (images.isEmpty) {
          _pagingController.appendLastPage(images);
        } else {
          int nextPage = pageKey + 1;
          _pagingController.appendPage(images, nextPage);
        }
      },
      onFailure: (f) => _pagingController.error = f,
    );
  }
}
