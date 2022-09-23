part of 'invite_bloc.dart';

abstract class InviteEvent extends Equatable {
  final Invite? invite;
  const InviteEvent({this.invite});

  @override
  List<Object> get props => [invite!];
}

class SendInvite extends InviteEvent {
  @override
  final String userEmail;
  const SendInvite({required this.userEmail});
  @override
  List<Object> get props => [userEmail];
}

class AcceptInvite extends InviteEvent {
  @override
  final Invite invite;
  const AcceptInvite({required this.invite});
  @override
  List<Object> get props => [invite];
}

class DeclineInvite extends InviteEvent {
  @override
  final Invite invite;
  const DeclineInvite({required this.invite});
  @override
  List<Object> get props => [invite];
}

class RevokeInvite extends InviteEvent {
  @override
  final Invite invite;
  const RevokeInvite({required this.invite});
  @override
  List<Object> get props => [invite];
}
