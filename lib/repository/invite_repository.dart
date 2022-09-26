import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leggo/model/invite.dart';
import 'package:rxdart/rxdart.dart';

class InviteRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendInvite(Invite invite) async {
    try {
      await _firebaseFirestore
          .collection('invites')
          .doc()
          .set(invite.toDocument());
    } catch (e) {
      print('Error sending invite!');
    }
  }

  Stream<Invite> getInvites() {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return _firebaseFirestore
        .collection('invites')
        .where('invitedUserId', isEqualTo: firebaseAuth.currentUser!.uid)
        .snapshots()
        .switchMap(((snapshot) {
      final references = snapshot.docs;
      return MergeStream(references.map((snap) => _firebaseFirestore
          .collection('invites')
          .doc(snap.id)
          .snapshots()
          .map((snap) => Invite.fromSnapshot(snap))));
    }));
  }
}
