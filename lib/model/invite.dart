import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leggo/model/place_list.dart';

class Invite {
  final String invitedUserId;
  final String listOwnerId;
  final PlaceList placeList;

  Invite({
    required this.invitedUserId,
    required this.listOwnerId,
    required this.placeList,
  });

  Invite copyWith({
    String? invitedUserId,
    String? listOwnerId,
    PlaceList? placeList,
  }) {
    return Invite(
      invitedUserId: invitedUserId ?? this.invitedUserId,
      listOwnerId: listOwnerId ?? this.listOwnerId,
      placeList: placeList ?? this.placeList,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'invitedUserId': invitedUserId,
      'listOwnerId': listOwnerId,
      'placeList': placeList,
    };
  }

  factory Invite.fromSnapshot(DocumentSnapshot snap) {
    return Invite(
      invitedUserId: snap['invitedUserId'],
      listOwnerId: snap['listOwnerId'],
      placeList: snap['placeList'],
    );
  }
}
