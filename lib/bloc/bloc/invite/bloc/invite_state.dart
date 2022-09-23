part of 'invite_bloc.dart';

enum InviteStatus { sent, accepted, declined, revoked, failed }

class InviteState extends Equatable {
  final Invite? invite;
  const InviteState({this.invite});

  factory InviteState.initial() {
    return const InviteState();
  }

  factory InviteState.sent(Invite invite) {
    return InviteState(invite: invite);
  }

  factory InviteState.accepted(Invite invite) {
    return InviteState(invite: invite);
  }

  factory InviteState.declined(Invite invite) {
    return InviteState(invite: invite);
  }

  factory InviteState.failed(Invite invite) {
    return InviteState(invite: invite);
  }

  factory InviteState.revoked(Invite invite) {
    return InviteState(invite: invite);
  }

  @override
  List<Object> get props => [invite!];
}
