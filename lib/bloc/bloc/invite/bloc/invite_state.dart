part of 'invite_bloc.dart';

enum InviteStatus {
  initial,
  sending,
  sent,
  accepted,
  declined,
  revoked,
  failed
}

class InviteState extends Equatable {
  final InviteStatus status;
  final Invite? invite;

  const InviteState({this.invite, required this.status});

  factory InviteState.initial() {
    return const InviteState(status: InviteStatus.initial);
  }

  factory InviteState.sending() {
    return const InviteState(status: InviteStatus.sending);
  }

  factory InviteState.sent() {
    return const InviteState(status: InviteStatus.sent);
  }

  factory InviteState.accepted(Invite invite) {
    return InviteState(invite: invite, status: InviteStatus.accepted);
  }

  factory InviteState.declined(Invite invite) {
    return InviteState(invite: invite, status: InviteStatus.declined);
  }

  factory InviteState.failed() {
    return const InviteState(status: InviteStatus.failed);
  }

  factory InviteState.revoked(Invite invite) {
    return InviteState(invite: invite, status: InviteStatus.revoked);
  }

  @override
  List<Object?> get props => [invite, status];
}
