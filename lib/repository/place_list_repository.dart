import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/user_repository.dart';
import 'package:rxdart/rxdart.dart';

class PlaceListRepository {
  final FirebaseFirestore _firebaseFirestore;

  PlaceListRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<void> createPlaceList(PlaceList placeList) async {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    DocumentReference doc = _firebaseFirestore.collection('place_lists').doc();
    await doc.set(placeList.toDocument());
  }

  Future<User?> addContributorToList(PlaceList placeList, String userId) async {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    User? invitedUser;
    UserRepository userRepository = UserRepository();
    userRepository.getUser(userId).listen((user) {
      invitedUser = user;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (invitedUser is User) {
      await _firebaseFirestore
          .collection('place_lists')
          .doc(placeList.placeListId)
          .collection('contributors')
          .doc(userId)
          .update({
        'name': FieldValue.arrayUnion([invitedUser!.name]),
        'profileIcon': FieldValue.arrayUnion([invitedUser!.profilePicture])
      });
      return invitedUser;
    } else {
      return null;
    }
  }

  Stream<User>? getListContributors(PlaceList placeList) {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    User? invitedUser;
    UserRepository userRepository = UserRepository();
    userRepository.getUser(firebaseUser.uid).listen((user) {
      invitedUser = user;
    });
    Future.delayed(const Duration(milliseconds: 500));

    Future<List<dynamic>> contributorIds = _firebaseFirestore
        .collection('place_lists')
        .doc(placeList.placeListId)
        .get()
        .then((value) => value.get('contributorIds') as List);

    if (placeList.contributorIds![0] != '') {
      for (String id in placeList.contributorIds!) {
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
  }

  Stream<User> getListOwner(PlaceList placeList) {
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
  }

  Future<void> removeContributorFromList(
      PlaceList placeList, String userId) async {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
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
          .collection('contributors')
          .doc(userId)
          .delete();
    }
  }

  Future<void> addPlaceToList(Place place, PlaceList placeList) async {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;
    _firebaseFirestore
        .collection('place_lists')
        .doc(placeList.placeListId)
        .collection('places')
        .doc(place.name)
        .set(place.toDocument());
  }

  Stream<Place> getPlaces(PlaceList placeList) {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;

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
  }

  Stream<PlaceList> getMyPlaceLists() {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;

    return _firebaseFirestore
        .collection('place_lists')
        .where('listOwnerId', isEqualTo: firebaseUser.uid)
        .snapshots()
        .switchMap(((snapshot) {
      final references = snapshot.docs;
      return MergeStream(references.map((snap) => _firebaseFirestore
          .collection('place_lists')
          .doc(snap.id)
          .snapshots()
          .map((snap) => PlaceList.fromSnapshot(snap))));
    }));
  }

  Stream<PlaceList> getSharedPlaceLists() {
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
  }

  Future<int> getPlaceListItemCount(PlaceList placeList) {
    final auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser!;

    return _firebaseFirestore
        .collection('place_lists')
        .doc(placeList.placeListId)
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
