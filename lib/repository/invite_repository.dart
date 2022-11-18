import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/invite.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:rxdart/rxdart.dart';

class InviteRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendInvite(Invite invite) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(invite.invitedUserId)
          .collection('invites')
          .doc()
          .set(invite.toDocument());
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

  Future<void> acceptInvite(Invite invite) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(invite.listOwnerId)
          .collection('invites')
          .doc(invite.inviteId)
          .set(invite.copyWith(inviteStatus: 'accepted').toDocument());
      await PlaceListRepository()
          .addContributorToList(invite.placeListId, invite.invitedUserId);
      await _firebaseFirestore
          .collection('users')
          .doc(invite.invitedUserId)
          .collection('invites')
          .doc(invite.inviteId)
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

  Future<void> declineInvite(Invite invite) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(invite.listOwnerId)
          .collection('invites')
          .doc(invite.inviteId)
          .set(invite.copyWith(inviteStatus: 'declined').toDocument());
      await _firebaseFirestore
          .collection('users')
          .doc(invite.invitedUserId)
          .collection('invites')
          .doc(invite.inviteId)
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

  Future<void> deleteInvite(Invite invite) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(invite.listOwnerId)
          .collection('invites')
          .doc(invite.inviteId)
          .delete();
      await _firebaseFirestore
          .collection('users')
          .doc(invite.invitedUserId)
          .collection('invites')
          .doc(invite.inviteId)
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

  Future<int> getInviteCount() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      AggregateQuerySnapshot inviteCount = await _firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('invites')
          .count()
          .get();
      return inviteCount.count;
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

  Stream<Invite> getInvites() {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      return _firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('invites')
          .snapshots()
          .switchMap(((snapshot) {
        final references = snapshot.docs;
        return MergeStream(references.map((snap) => _firebaseFirestore
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .collection('invites')
            .doc(snap.id)
            .snapshots()
            .map((snap) => Invite.fromSnapshot(snap))));
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
}
