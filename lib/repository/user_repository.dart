import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/base_user_repository.dart';

class UserRepository extends BaseUserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createUser(User user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .set(user.toDocument());
  }

  @override
  Stream<User> getUser(String userId) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => User.fromSnapshot(snap));
  }

  Future<Stream<User>?> getUserByUsername(String userId) async {
    try {
      return _firebaseFirestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((event) => User.fromSnapshot(event));
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  @override
  Future<void> updateUser(User user) {
    // TODO: implement updateUser
    return _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .update(user.toDocument());
  }
}
