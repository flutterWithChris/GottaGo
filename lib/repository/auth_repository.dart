import 'base_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AuthRepository extends BaseAuthRepository {
  final auth.FirebaseAuth _firebaseAuth;
  AuthRepository({auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  @override
  Future<void> anonymousSignIn() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<auth.User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user;
      return user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Stream<auth.User?> get user => _firebaseAuth.userChanges();

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
