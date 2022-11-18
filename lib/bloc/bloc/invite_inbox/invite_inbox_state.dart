part of 'invite_inbox_bloc.dart';

enum InviteInboxStatus { loading, loaded, error, accepted, declined, deleted }

class InviteInboxState extends Equatable {
  final InviteInboxStatus status;
  final List<Invite>? invites;
  const InviteInboxState({required this.status, this.invites});

  factory InviteInboxState.loading() {
    return const InviteInboxState(status: InviteInboxStatus.loading);
  }

  factory InviteInboxState.loaded(List<Invite> invites) {
    return InviteInboxState(status: InviteInboxStatus.loaded, invites: invites);
  }

  factory InviteInboxState.error() {
    return const InviteInboxState(status: InviteInboxStatus.error);
  }

  factory InviteInboxState.accepted() {
    return const InviteInboxState(status: InviteInboxStatus.accepted);
  }

  factory InviteInboxState.declined() {
    return const InviteInboxState(status: InviteInboxStatus.declined);
  }

  factory InviteInboxState.deleted() {
    return const InviteInboxState(status: InviteInboxStatus.deleted);
  }

  @override
  List<Object?> get props => [status, invites];
}
