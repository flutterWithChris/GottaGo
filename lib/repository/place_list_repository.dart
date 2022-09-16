import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leggo/model/place_list.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class PlaceListRepository {
  final FirebaseFirestore _firebaseFirestore;

  PlaceListRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<void> createPlaceList(PlaceList placeList) async {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    await _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .doc(placeList.name)
        .set(placeList.toDocument());
  }

  Stream<PlaceList> getPlaceLists() {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    return _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .doc()
        .snapshots()
        .map((snap) => PlaceList.fromSnapshot(snap));
  }

  Future<void> updatePlaceLists(PlaceList placeList) {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    return _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .doc(placeList.name)
        .update(placeList.toDocument());
  }
}
