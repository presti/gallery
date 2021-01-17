import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../image_description/image_description_page.dart';
import '../images/repository/image_model.dart';

abstract class Routes {
  static Future<Widget> detail(BuildContext context, ImageModel image) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDescriptionPage(image: image),
      ),
    );
  }
}
