class ImageRequestDto {
  static const String _keyData = 'data';
  static const String _keySuccess = 'success';

  final bool success;
  final List<ImageDto> images;

  const ImageRequestDto._(this.success, this.images);

  factory ImageRequestDto.fromJson(Map<String, dynamic> json) {
    List<ImageDto> images;
    bool success = json[_keySuccess] as bool;
    if (success) {
      var data = json[_keyData] as List;
      images = data.map((dynamic json) {
        return ImageDto.fromJson(json as Map<String, dynamic>);
      }).toList();
    }
    return ImageRequestDto._(success, images);
  }
}

class ImageDto {
  static const String _keyTitle = 'title';
  static const String _keyIsAlbum = 'is_album';
  static const String _keyCover = 'cover';
  static const String _keyId = 'id';

  final String id;
  final String title;

  const ImageDto._(this.id, this.title);

  factory ImageDto.fromJson(Map<String, dynamic> json) {
    String title = json[_keyTitle] as String;
    bool isAlbum = json[_keyIsAlbum] as bool;
    String id = json[isAlbum ? _keyCover : _keyId] as String;
    return ImageDto._(id, title);
  }
}
