import 'package:sprintf/sprintf.dart';

import '../../providers/http/http_provider.dart';
import '../../utils/functional/mayfail.dart';
import 'image_dto.dart';

class ImagesService {
  static const _postsUrl =
      // 'https://api.imgur.com/post/v1/posts?client_id=546c25a59c58ad7&filter%5Bsection%5D=eq%3Ahot&sort=-viral&page=';
      'https://api.imgur.com/3/gallery/hot/viral/day/%s?client_id=546c25a59c58ad7&album_previews=false';

  static const _queryUrl =
      'https://api.imgur.com/3/gallery/search/viral/%s/?client_id=546c25a59c58ad7&q=%s';

  static const _imageUrl = 'https://i.imgur.com/';

  final HttpProvider _httpProvider;

  double get thumbSize => 160;

  const ImagesService(this._httpProvider);

  String thumbUrl(String imageId) => '$_imageUrl${imageId}b.jpeg';

  String imageUrl(String imageId) => '$_imageUrl$imageId.jpeg';

  Future<MayFail<List<ImageDto>, Failure>> get(int page, {String query}) {
    return _request(_getUrl(page, query: query));
  }

  Future<MayFail<List<ImageDto>, Failure>> _request(String url) async {
    var searchRequest = await _httpProvider.getAndDecode(
      url: url,
      headers: false,
      fromJson: (json) {
        var dto = ImageRequestDto.fromJson(json);
        if (dto.success) {
          return dto.images;
        } else {
          // We return null so we can check for it and return a Failure.
          return null;
        }
      },
    );
    return searchRequest ?? Fail(HttpFailure());
  }

  String _getUrl(int page, {String query}) {
    if (query == null) {
      return _imagesUrl(page);
    } else {
      return _searchUrl(page, query);
    }
  }

  String _searchUrl(int page, String query) {
    return sprintf(_queryUrl, [page, query]);
  }

  String _imagesUrl(int page) => sprintf(_postsUrl, [page]);
}
