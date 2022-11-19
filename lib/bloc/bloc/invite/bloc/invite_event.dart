part of 'invite_bloc.dart';

abstract class InviteEvent extends Equatable {
  final Invite? invite;
  const InviteEvent({this.invite});

  @override
  List<Object> get props => [invite!];
}

class SendInvite extends InviteEvent {
  @override
  final PlaceList placeList;
  final String userName;
  const SendInvite({required this.placeList, required this.userName});
  @override
  List<Object> get props => [placeList, userName];
}
