import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/invite.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/repository/place_list_repository.dart';

part 'invite_event.dart';
part 'invite_state.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final PlaceListRepository _placeListRepository;
  InviteBloc({required PlaceListRepository placeListRepository})
      : _placeListRepository = placeListRepository,
        super(InviteState.initial()) {
    on<InviteEvent>((event, emit) async {
      if (event is SendInvite) {
        emit(InviteState.sending());
        bool? inviteSent = await _placeListRepository.inviteContributorToList(
            event.placeList, event.userName, event.inviterUsername);
        if (inviteSent == true) {
          emit(InviteState.sent());
          await Future.delayed(
              const Duration(seconds: 2), () => emit(InviteState.initial()));
        } else {
          emit(InviteState.failed());
          await Future.delayed(
              const Duration(seconds: 2), () => emit(InviteState.initial()));
        }
      }
    });
  }
}
