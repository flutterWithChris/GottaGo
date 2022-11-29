import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/repository/invite_repository.dart';

import '../../../model/invite.dart';

part 'invite_inbox_event.dart';
part 'invite_inbox_state.dart';

class InviteInboxBloc extends Bloc<InviteInboxEvent, InviteInboxState> {
  final InviteRepository _inviteRepository;
  StreamSubscription? inviteStream;
  List<Invite> invites = [];
  InviteInboxBloc({
    required InviteRepository inviteRepository,
  })  : _inviteRepository = inviteRepository,
        super(InviteInboxState.loading()) {
    inviteStream = _inviteRepository.getInvites().listen((invite) {
      LoadInvites();
    });
    on<LoadInvites>((event, emit) async {
      invites.clear();
      if (state != InviteInboxState.loading()) {
        emit(InviteInboxState.loading());
      }
      int inviteCount = await _inviteRepository.getInviteCount();
      if (inviteCount > 0) {
        await emit.forEach(
          _inviteRepository.getInvites(),
          onData: (invite) {
            invites.add(invite);
            return InviteInboxState.loaded(invites);
          },
        );
      } else {
        emit(InviteInboxState.loaded(const []));
      }

      // await Future.delayed(const Duration(milliseconds: 250));
    });
    on<AcceptInvite>((event, emit) async {
      emit(InviteInboxState.loading());
      _inviteRepository.acceptInvite(event.invite);
      emit(InviteInboxState.accepted());
      await Future.delayed(
          const Duration(seconds: 2), () => add(LoadInvites()));
    });
    on<DeclineInvite>((event, emit) async {
      emit(InviteInboxState.loading());
      _inviteRepository.declineInvite(event.invite);
      emit(InviteInboxState.declined());
      await Future.delayed(
          const Duration(seconds: 2), () => add(LoadInvites()));
    });
    on<DeleteInvite>((event, emit) async {
      emit(InviteInboxState.loading());
      _inviteRepository.deleteInvite(event.invite);
      emit(InviteInboxState.deleted());
      await Future.delayed(
          const Duration(seconds: 2), () => add(LoadInvites()));
    });
  }
}
