import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../images/repository/image_model.dart';
import '../theme/color.dart';
import '../theme/strings.dart';
import 'image_description_widget.dart';

class ImageDescriptionPage extends StatelessWidget {
  final ImageModel image;

  const ImageDescriptionPage({Key key, @required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.imageDescriptionBackground,
      appBar: AppBar(
        title: const Text(Strings.imageTitle),
      ),
      body: ImageDescriptionWidget(image: image),
    );
  }
}
