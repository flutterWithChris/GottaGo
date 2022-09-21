import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:rxdart/rxdart.dart';

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

  Future<void> addPlaceToList(Place place, PlaceList placeList) async {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .doc(placeList.name)
        .collection('places')
        .doc(place.name)
        .set(place.toDocument());
  }

  Stream<Place> getPlaces(PlaceList placeList) {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;

    return _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .doc(placeList.name)
        .collection('places')
        .snapshots()
        .switchMap(((snapshot) {
      final references = snapshot.docs;
      return MergeStream(references.map((snap) => _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('place_lists')
          .doc(placeList.name)
          .collection('places')
          .doc(snap.id)
          .snapshots()
          .map((snap) => Place.fromSnapshot(snap))));
    }));
  }

  Stream<PlaceList> getPlaceLists() {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;

    return _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .snapshots()
        .switchMap(((snapshot) {
      final references = snapshot.docs;
      return MergeStream(references.map((snap) => _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('place_lists')
          .doc(snap.id)
          .snapshots()
          .map((snap) => PlaceList.fromSnapshot(snap))));
    }));
  }

  Future<int> getPlaceListItemCount(PlaceList placeList) {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;

    return _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .doc(placeList.name)
        .collection('places')
        .get()
        .then((value) => value.size);
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

  Future<void> removePlaceList(PlaceList placeList) {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    return _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('place_lists')
        .doc(placeList.name)
        .delete();
  }
}
