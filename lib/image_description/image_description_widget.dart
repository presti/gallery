import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../images/repository/image_model.dart';
import '../providers/logger.dart';
import '../theme/color.dart';
import '../theme/dimen.dart';
import '../theme/images.dart';

class ImageDescriptionWidget extends StatelessWidget {
  final ImageModel image;

  const ImageDescriptionWidget({
    Key key,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimen.imageDescriptionTitlePadding),
          child: Text(
            image.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.imageDescriptionTitle,
              fontSize: Dimen.imageDescriptionTitleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Image.network(
          image.imageUrl,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null) return child;
            return const CircularProgressIndicator();
          },
          errorBuilder: (context, exception, stackTrace) {
            String errorMsg = 'An error occurred loading "${image.id}"';
            Logger.logError(errorMsg, exception, stackTrace);
            return const Padding(
              padding: EdgeInsets.all(Dimen.imageDescriptionErrorPadding),
              child: Icon(
                Images.error,
                color: Color.imageDescriptionErrorColor,
                size: Dimen.imageDescriptionErrorIconSize,
              ),
            );
          },
        ),
      ],
    );
  }
}
