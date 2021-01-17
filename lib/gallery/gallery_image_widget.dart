import 'package:flutter/widgets.dart';

import '../images/repository/image_model.dart';
import '../providers/routes.dart';
import '../theme/images.dart';
import '../theme/values.dart';

class GalleryImageWidget extends StatelessWidget {
  final ImageModel image;

  const GalleryImageWidget({Key key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Routes.detail(context, image),
      child: FadeInImage.assetNetwork(
        fadeInDuration: Values.galleryImageFadeInDuration,
        placeholder: Images.imagePlaceholder,
        image: image.thumbUrl,
      ),
    );
  }
}
