import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class ImageModel with EquatableMixin {
  final String id;
  final String title;
  final String thumbUrl;
  final String imageUrl;

  const ImageModel({
    @required this.id,
    @required this.title,
    @required this.thumbUrl,
    @required this.imageUrl,
  }) : assert(id != null &&
            title != null &&
            thumbUrl != null &&
            imageUrl != null);

  @override
  List<Object> get props => [id, title, thumbUrl, imageUrl];
}
