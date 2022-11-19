part of 'invite_inbox_bloc.dart';

abstract class InviteInboxEvent extends Equatable {
  final Invite? invite;
  const InviteInboxEvent({this.invite});

  @override
  List<Object?> get props => [invite];
}

class LoadInvites extends InviteInboxEvent {}

class AcceptInvite extends InviteInboxEvent {
  @override
  final Invite invite;
  const AcceptInvite({
    required this.invite,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [invite];
}

class DeclineInvite extends InviteInboxEvent {
  @override
  final Invite invite;
  const DeclineInvite({
    required this.invite,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [invite];
}

class DeleteInvite extends InviteInboxEvent {
  @override
  final Invite invite;
  const DeleteInvite({
    required this.invite,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [invite];
}
