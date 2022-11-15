import 'package:image_picker/image_picker.dart';

import '../../model/user.dart';

abstract class BaseStorageRepository {
  Future<void> uploadImage(User user, XFile image);
  Future<String> getDownloadUrl(User user, String imageName);
}
