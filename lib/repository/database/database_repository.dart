import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/bug_report.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/database/base_database_repository.dart';
import 'package:leggo/repository/storage/storage_repository.dart';

class DatabaseRepository extends BaseDatabaseRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Stream<User> getUser(String userId) {
    try {
      return _firebaseFirestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snap) => User.fromSnapshot(snap));
    } on FirebaseException catch (e) {
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

  Future<void> deleteUserData(User user) async {
    try {
      await _firebaseFirestore.collection('users').doc(user.id).delete();
    } on FirebaseException catch (e) {
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
  Future<void> updateUserPictures(User user, String imageName) async {
    try {
      String downloadUrl =
          await StorageRepository().getDownloadUrl(user, imageName);

      await _firebaseFirestore
          .collection('users')
          .doc(user.id)
          .update({'profilePicture': downloadUrl});
    } on FirebaseException catch (e) {
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
  Future<void> createUser(User user) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(user.id)
          .set(user.toDocument());
    } on FirebaseException catch (e) {
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
  Future<void> updateUser(User user) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(user.id)
          .update(user.toDocument());
    } on FirebaseException catch (e) {
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
  Future<bool> checkUsernameAvailability(String userName) async {
    try {
      var doc =
          await _firebaseFirestore.collection('usernames').doc(userName).get();
      return !doc.exists;
    } on FirebaseException catch (e) {
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
  Future<String?> checkUsernameExists(String userName) async {
    try {
      var doc =
          await _firebaseFirestore.collection('usernames').doc(userName).get();
      if (doc.exists == false) {
        return null;
      } else {
        return doc.get('userId');
      }
    } on FirebaseException catch (e) {
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
  Future<void> registerUsername(String userName, String userId) async {
    try {
      await _firebaseFirestore
          .collection('usernames')
          .doc(userName)
          .set({'userId': userId});
    } on FirebaseException catch (e) {
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
  Future<void> deregisterUsername(String userName) async {
    try {
      await _firebaseFirestore.collection('usernames').doc(userName).delete();
    } on FirebaseException catch (e) {
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
  Future<void> sendBugReport(BugReport bugReport) async {
    try {
      await _firebaseFirestore
          .collection('bug-reports')
          .doc()
          .set(bugReport.toDocument());
    } on FirebaseException catch (e) {
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
