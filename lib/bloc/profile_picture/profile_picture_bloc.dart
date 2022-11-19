import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/repository/database/database_repository.dart';

part 'profile_picture_event.dart';
part 'profile_picture_state.dart';

class ProfilePictureBloc
    extends Bloc<ProfilePictureEvent, ProfilePictureState> {
  final DatabaseRepository _databaseRepository;
  StreamSubscription? _databaseSubscription;
  ProfilePictureBloc({required DatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(ProfilePictureLoading()) {
    on<LoadProfilePicture>((event, emit) async {
      _databaseSubscription?.cancel();
    });
    on<UpdateProfilePicture>((event, emit) {
      emit(ProfilePictureLoaded(profilePictureUrl: event.profilePictureUrl));
    });
  }
}
