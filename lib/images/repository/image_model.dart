import 'package:equatable/equatable.dart';

class ImageModel with EquatableMixin {
  final String id;
  final String title;
  final String thumbUrl;
  final String imageUrl;

  const ImageModel({
    this.id,
    this.title,
    this.thumbUrl,
    this.imageUrl,
  }) : assert(id != null &&
            title != null &&
            thumbUrl != null &&
            imageUrl != null);

  @override
  List<Object> get props => [id, title, thumbUrl, imageUrl];
}
