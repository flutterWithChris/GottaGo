import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/database/database_repository.dart';
import 'package:leggo/repository/storage/base_storage_repository.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageRepository extends BaseStorageRepository {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Future<void> uploadImage(User user, XFile image) async {
    try {
      await storage
          .ref('${user.id}/${image.name}')
          .putFile(File(image.path))
          .then((p0) =>
              DatabaseRepository().updateUserPictures(user, image.name));
    } catch (e) {}
  }

  @override
  Future<String> getDownloadUrl(User user, String imageName) async {
    String downloadUrl =
        await storage.ref('${user.id}/$imageName').getDownloadURL();
    return downloadUrl;
  }
}
