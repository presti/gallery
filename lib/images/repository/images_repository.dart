import 'package:gallery/providers/logger.dart';

import '../../utils/functional/mayfail.dart';
import 'image_dto.dart';
import 'image_model.dart';
import 'images_service.dart';

class ImagesRepository {
  final ImagesService _imagesService;

  double get thumbSize => _imagesService.thumbSize;

  const ImagesRepository(this._imagesService);

  Future<MayFail<List<ImageModel>, Failure>> getImages(int page,
      {String query}) async {
    MayFail<List<ImageDto>, Failure> request =
        await _imagesService.get(page, query: query);
    return request.on(
      onSuccess: (imageDtos) {
        List<ImageModel> images = [];
        for (final dto in imageDtos) {
          _modelFromDto(dto).on(
            onSuccess: (image) => images.add(image),
            onFailure: (_) {},
          );
        }
        return Success(images);
      },
      onFailure: (f) => Fail(f),
    );
  }

  MayFail<ImageModel, Failure> _modelFromDto(ImageDto dto) {
    try {
      ImageModel image = ImageModel(
        id: dto.id,
        title: dto.title,
        thumbUrl: _imagesService.thumbUrl(dto.id),
        imageUrl: _imagesService.imageUrl(dto.id),
      );
      return Success(image);
    } catch (e, st) {
      Logger.logError('ImageModel creation error', e, st);
      return const Fail(null);
    }
  }
}
