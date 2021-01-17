import 'package:flutter/material.dart';

import 'gallery/gallery_page.dart';
import 'providers/injector.dart';

void main() {
  runApp(const GalleryApp(Injector()));
}

class GalleryApp extends StatelessWidget {
  final Injector injector;

  const GalleryApp(this.injector, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    injector.putDependencies();
    return MaterialApp(
      title: 'Flutter Demo',
      home: GalleryPage(inject()),
    );
  }
}
