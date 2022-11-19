import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/database/base_database_repository.dart';
import 'package:leggo/repository/storage/storage_repository.dart';

class DatabaseRepository extends BaseDatabaseRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Stream<User> getUser(String userId) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => User.fromSnapshot(snap));
  }

  @override
  Future<void> updateUserPictures(User user, String imageName) async {
    String downloadUrl =
        await StorageRepository().getDownloadUrl(user, imageName);

    _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .update({'profilePicture': downloadUrl});
  }

  @override
  Future<void> createUser(User user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .set(user.toDocument());
  }

  @override
  Future<void> updateUser(User user) async {
    return _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .update(user.toDocument());
  }

  @override
  Future<bool> checkUsernameAvailability(String userName) async {
    var doc =
        await _firebaseFirestore.collection('usernames').doc(userName).get();
    return !doc.exists;
  }

  @override
  Future<String?> checkUsernameExists(String userName) async {
    var doc =
        await _firebaseFirestore.collection('usernames').doc(userName).get();
    if (doc.exists == false) {
      return null;
    } else {
      print('User Exist: ${doc.get('userId')}');
      return doc.get('userId');
    }
  }

  @override
  Future<void> registerUsername(User user) async {
    await _firebaseFirestore
        .collection('usernames')
        .doc(user.userName)
        .set({'userId': user.id});
  }
}
