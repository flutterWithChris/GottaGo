import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/invite.dart';
import 'package:leggo/repository/place_list_repository.dart';

part 'invite_event.dart';
part 'invite_state.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final PlaceListRepository _placeListRepository;
  InviteBloc({required PlaceListRepository placeListRepository})
      : _placeListRepository = placeListRepository,
        super(InviteState.initial()) {
    on<InviteEvent>((event, emit) {
      if (event is SendInvite) {}
      if (event is AcceptInvite) {
        placeListRepository.addContributorToList(
            event.invite.placeList, event.invite.invitedUserId);
      }
      if (event is DeclineInvite) {}
      if (event is RevokeInvite) {}
    });
  }
}
