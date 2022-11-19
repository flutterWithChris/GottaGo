import 'package:cloud_firestore/cloud_firestore.dart';

class Invite {
  final String? inviteId;
  final String invitedUserId;
  final String listOwnerId;
  final String placeListId;
  final String inviteStatus;
  final String placeListName;
  final String inviterName;
  final String inviteeName;

  Invite({
    this.inviteId,
    required this.invitedUserId,
    required this.listOwnerId,
    required this.placeListId,
    required this.inviteStatus,
    required this.placeListName,
    required this.inviterName,
    required this.inviteeName,
  });

  Invite copyWith({
    String? inviteId,
    String? invitedUserId,
    String? listOwnerId,
    String? placeListId,
    String? inviteStatus,
    String? placeListName,
    String? inviterName,
    String? inviteeName,
  }) {
    return Invite(
      inviteId: inviteId ?? this.inviteId,
      invitedUserId: invitedUserId ?? this.invitedUserId,
      listOwnerId: listOwnerId ?? this.listOwnerId,
      placeListId: placeListId ?? this.placeListId,
      inviteStatus: inviteStatus ?? this.inviteStatus,
      placeListName: placeListName ?? this.placeListName,
      inviteeName: inviteeName ?? this.inviteeName,
      inviterName: inviterName ?? this.inviterName,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'invitedUserId': invitedUserId,
      'inviteeName': inviteeName,
      'listOwnerId': listOwnerId,
      'inviterName': inviterName,
      'placeListId': placeListId,
      'placeListName': placeListName,
      'inviteStatus': inviteStatus,
    };
  }

  factory Invite.fromSnapshot(DocumentSnapshot snap) {
    return Invite(
      inviteId: snap.id,
      invitedUserId: snap['invitedUserId'],
      inviteeName: snap['inviteeName'],
      listOwnerId: snap['listOwnerId'],
      inviterName: snap['inviterName'],
      placeListId: snap['placeListId'],
      placeListName: snap['placeListName'],
      inviteStatus: snap['inviteStatus'],
    );
  }
}
