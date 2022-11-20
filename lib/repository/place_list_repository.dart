import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/invite.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/database/database_repository.dart';
import 'package:leggo/repository/invite_repository.dart';
import 'package:leggo/repository/user_repository.dart';
import 'package:rxdart/rxdart.dart';

class PlaceListRepository {
  final FirebaseFirestore _firebaseFirestore;

  PlaceListRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<void> createPlaceList(PlaceList placeList) async {
    try {
      final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
      DocumentReference doc =
          _firebaseFirestore.collection('place_lists').doc();
      await doc.set(placeList.copyWith(placeListId: doc.id).toDocument());
      await _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
        'placeListIds': FieldValue.arrayUnion([doc.id])
      });
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

  Stream<PlaceList>? getPlaceList(String placeListId) {
    try {
      return _firebaseFirestore
          .collection('place_lists')
          .doc(placeListId)
          .snapshots()
          .map((snap) => PlaceList.fromSnapshot(snap));
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

  Future<User?> addContributorToList(String placeListId, String userId) async {
    try {
      User? invitedUser;
      UserRepository userRepository = UserRepository();
      userRepository.getUser(userId).listen((user) {
        invitedUser = user;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (invitedUser is User) {
        await _firebaseFirestore
            .collection('place_lists')
            .doc(placeListId)
            .update({
          'contributorIds': FieldValue.arrayUnion([invitedUser!.id]),
        });
        await _firebaseFirestore
            .collection('users')
            .doc(invitedUser!.id)
            .update({
          'placeListIds': FieldValue.arrayUnion([placeListId])
        });
        return invitedUser;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      return null;
    }
  }

  Future<bool?> inviteContributorToList(
      PlaceList placeList, String userName) async {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    try {
      String? userId = await DatabaseRepository().checkUsernameExists(userName);
      if (userId == null) {
        print('USER ID IS NULL');
        return false;
      } else {
        print('GETTING USER INVITE CONTRIBUTOR');
        UserRepository().getUser(userId).listen((user) async {
          print('Listener Got User: ${user.id}');

          Invite invite = Invite(
              invitedUserId: user.id!,
              inviteeName: user.name!,
              listOwnerId: firebaseUser.uid,
              inviterName: firebaseUser.displayName!,
              placeListId: placeList.placeListId!,
              placeListName: placeList.name,
              inviteStatus: 'sent');
          await InviteRepository().sendInvite(invite);
        });
      }
      return true;
    } on FirebaseException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      return null;
    }
  }

  Stream<User>? getListContributors(PlaceList placeList) {
    try {
      // User? invitedUser;
      // UserRepository userRepository = UserRepository();
      // userRepository.getUser(firebaseUser.uid).listen((user) {
      //   invitedUser = user;
      // });
      Future.delayed(const Duration(milliseconds: 500));

      // List<dynamic> contributorIds =  _firebaseFirestore
      //     .collection('place_lists')
      //     .doc(placeList.placeListId)
      //     .get()
      //     .then((value) => value.get('contributorIds') as List);

      if (placeList.contributorIds.isNotEmpty) {
        for (String id in placeList.contributorIds) {
          return _firebaseFirestore
              .collection('users')
              .doc(id)
              .snapshots()
              .map((snap) => User.fromSnapshot(snap));
        }
      } else {
        return null;
      }
      return null;
    } on FirebaseException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      return null;
    }
  }

  Stream<User> getListOwner(PlaceList placeList) {
    try {
      final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
      User? invitedUser;
      UserRepository userRepository = UserRepository();
      userRepository.getUser(firebaseUser.uid).listen((user) {
        invitedUser = user;
      });
      Future.delayed(const Duration(milliseconds: 500));

      return _firebaseFirestore
          .collection('users')
          .doc(placeList.listOwnerId)
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

  Future<void> removeContributorFromList(
      PlaceList placeList, String userId) async {
    try {
      Object invitedUser;
      UserRepository userRepository = UserRepository();
      invitedUser = userRepository.getUser(userId).listen((user) {
        invitedUser = user;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (invitedUser is User) {
        await _firebaseFirestore
            .collection('place_lists')
            .doc(placeList.placeListId)
            .update({
          'contributorIds': FieldValue.arrayRemove([userId])
        });
        await _firebaseFirestore.collection('users').doc(userId).update({
          'placeListIds': FieldValue.arrayRemove([placeList.placeListId])
        });
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

  Future<void> addPlaceToList(Place place, PlaceList placeList) async {
    try {
      _firebaseFirestore
          .collection('place_lists')
          .doc(placeList.placeListId)
          .collection('places')
          .doc(place.placeId)
          .set(place.toDocument());
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

  Stream<Place> getPlaces(PlaceList placeList) {
    try {
      return _firebaseFirestore
          .collection('place_lists')
          .doc(placeList.placeListId)
          .collection('places')
          .snapshots()
          .switchMap(((snapshot) {
        final references = snapshot.docs;
        return MergeStream(references.map((snap) => _firebaseFirestore
            .collection('place_lists')
            .doc(placeList.placeListId)
            .collection('places')
            .doc(snap.id)
            .snapshots()
            .map((snap) => Place.fromSnapshot(snap))));
      }));
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

  Stream<PlaceList?> getMyPlaceLists(List<String> placeListIds) {
    try {
      for (String placeListId in placeListIds) {
        return _firebaseFirestore
            .collection('place_lists')
            .doc(placeListId)
            .snapshots()
            .map((snap) => PlaceList.fromSnapshot(snap));
      }
      throw Exception();
    } on FirebaseException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      (e, stack) =>
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      //return null;
      throw Exception();
    }
  }

  Stream<PlaceList> getSharedPlaceLists() {
    try {
      final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;

      return _firebaseFirestore
          .collection('place_lists')
          .where('contributorIds', arrayContains: firebaseUser.uid)
          .snapshots()
          .switchMap(((snapshot) {
        final references = snapshot.docs;

        return MergeStream(references.map((snap) => _firebaseFirestore
            .collection('place_lists')
            .doc(snap.id)
            .snapshots()
            .map((snap) => PlaceList.fromSnapshot(snap))));
      }));
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

  Future<int> getPlaceListItemCount(PlaceList placeList) {
    try {
      return _firebaseFirestore
          .collection('place_lists')
          .doc(placeList.placeListId)
          .collection('places')
          .get()
          .then((value) => value.size);
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

  Future<void> updatePlaceLists(PlaceList placeList) {
    try {
      final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
      return _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('place_lists')
          .doc(placeList.name)
          .update(placeList.toDocument());
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

  Future<void> removePlaceList(PlaceList placeList) {
    try {
      final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
      return _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('place_lists')
          .doc(placeList.name)
          .delete();
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
