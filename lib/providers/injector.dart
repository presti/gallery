import 'package:get/get.dart';

import '../images/repository/images_repository.dart';
import '../images/repository/images_service.dart';
import 'http/http_provider.dart';
import 'http/http_service.dart';

T inject<T>() => Get.find<T>();

class Injector {
  const Injector();

  void putDependencies() {
    const httpService = HttpService();
    const httpProvider = HttpProvider(httpService);
    const imagesService = ImagesService(httpProvider);
    const imagesRepository = ImagesRepository(imagesService);
    Get.put(imagesRepository, permanent: true);
  }
}
