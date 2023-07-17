import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leggo/globals.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'base_auth_repository.dart';

class AuthRepository extends BaseAuthRepository {
  final auth.FirebaseAuth _firebaseAuth;
  AuthRepository({auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  @override
  Future<void> anonymousSignIn() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on auth.FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
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
    } on auth.FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
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
    } on auth.FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
    }
  }

  @override
  Stream<auth.User?> get user => _firebaseAuth.userChanges();

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // final GoogleSignInAuthentication? googleAuth =
      //     await googleUser?.authentication;

      // final credential = auth.GoogleAuthProvider.credential(
      //   accessToken: googleAuth?.accessToken,
      //   idToken: googleAuth?.idToken,
      // );
      final credential = await auth.FirebaseAuth.instance
          .signInWithProvider(auth.GoogleAuthProvider());
      var googleCredentials = await auth.FirebaseAuth.instance
          .signInWithCredential(credential.credential!);
      final user = googleCredentials.user;
      return user;

      /*   DatabaseRepository().storeUserInfoDB(
          _firebaseAuth.currentUser!.uid,
          const User().copyWith(
              id: _firebaseAuth.currentUser!.uid,
              email: _firebaseAuth.currentUser!.email));*/
    } on auth.FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
    }
  }

  Future<auth.UserCredential?> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      var googleCredentials =
          await auth.FirebaseAuth.instance.signInWithCredential(credential);

      return googleCredentials;
    } on auth.FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
    }
  }

  Future<auth.User?> signInWithApple() async {
    try {
      // 1. perform the sign-in request
      final result = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      // 2. check the result

      final appleIdCredential = result;
      final oAuthProvider = auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken!,
        accessToken: appleIdCredential.authorizationCode,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      if (appleIdCredential.givenName != null &&
          appleIdCredential.familyName != null) {
        final displayName =
            '${appleIdCredential.givenName} ${appleIdCredential.familyName}';
        await firebaseUser.updateDisplayName(displayName);
      }

      return firebaseUser;
    } on SignInWithAppleException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
    }
  }

  Future<auth.UserCredential?> reauthenticateWithApple() async {
    try {
      // 1. perform the sign-in request
      final result = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      // 2. check the result
      final appleIdCredential = result;
      final oAuthProvider = auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken!,
        accessToken: appleIdCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential;
    } on SignInWithAppleException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
    }
    return null;
  }

  // Future<auth.UserCredential?> reauthenticateWithApple(
  //     {List<Scope> scopes = const [Scope.email, Scope.fullName]}) async {
  //   // 1. perform the sign-in request
  //   final result = await TheAppleSignIn.performRequests(
  //       [AppleIdRequest(requestedScopes: scopes)]);
  //   // 2. check the result
  //   switch (result.status) {
  //     case AuthorizationStatus.authorized:
  //       final appleIdCredential = result.credential!;
  //       final oAuthProvider = auth.OAuthProvider('apple.com');
  //       final credential = oAuthProvider.credential(
  //         idToken: String.fromCharCodes(appleIdCredential.identityToken!),
  //         accessToken:
  //             String.fromCharCodes(appleIdCredential.authorizationCode!),
  //       );
  //       final userCredential =
  //           await _firebaseAuth.signInWithCredential(credential);

  //       return userCredential;

  //     case AuthorizationStatus.error:
  //       {
  //         throw PlatformException(
  //           code: 'ERROR_AUTHORIZATION_DENIED',
  //           message: result.error.toString(),
  //         );
  //       }

  //     case AuthorizationStatus.cancelled:
  //       throw PlatformException(
  //         code: 'ERROR_ABORTED_BY_USER',
  //         message: 'Sign in aborted by user',
  //       );
  //     default:
  //       throw UnimplementedError();
  //   }
  // }

  Future<void> updateDisplayName(String name) async {
    try {
      await _firebaseAuth.currentUser!.updateDisplayName(name);
    } on auth.FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
    }
  }

  Future<void> deleteUser() async {
    try {
      String providerId =
          _firebaseAuth.currentUser!.providerData.first.providerId;
      auth.UserCredential? userCredential;
      switch (providerId) {
        case 'google.com':
          userCredential = await reauthenticateWithGoogle();
          break;

        case 'apple.com':
          userCredential = await reauthenticateWithApple();
          break;
      }
      if (userCredential != null) {
        await _firebaseAuth.currentUser!
            .reauthenticateWithCredential(userCredential.credential!);
        await _firebaseAuth.currentUser!.delete();
      } else {
        throw auth.FirebaseAuthException;
      }
    } on auth.FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      throw Exception();
    }
  }
}
