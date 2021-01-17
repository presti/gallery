import 'package:flutter/material.dart';
import 'package:gallery/images/repository/images_repository.dart';

import '../theme/color.dart';
import '../theme/images.dart';
import '../theme/strings.dart';
import 'gallery_widget.dart';

class GalleryPage extends StatelessWidget {
  final ImagesRepository repository;

  const GalleryPage(this.repository, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.galleryBackground,
      appBar: AppBar(
        title: const Text(Strings.galleryTitle),
        actions: [
          IconButton(
            onPressed: () =>
                showSearch(context: context, delegate: _Search(repository)),
            icon: const Icon(Images.search),
          ),
        ],
      ),
      body: GalleryWidget(repository),
    );
  }
}

class _Search extends SearchDelegate<void> {
  final ImagesRepository repository;

  _Search(this.repository);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Images.close),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Images.arrowBack),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return GalleryWidget(repository, query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
