import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leggo/bloc/bloc/auth/bloc/auth_bloc.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/storage/storage_repository.dart';
import 'package:leggo/repository/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;
  StreamSubscription? _userSubscription;
  ProfileBloc(
      {required UserRepository userRepository,
      required StorageRepository storageRepository,
      required AuthBloc authBloc})
      : _userRepository = userRepository,
        _storageRepository = storageRepository,
        super(ProfileLoading()) {
    on<LoadProfile>((event, emit) async {
      _userSubscription =
          await _userRepository.getUser(event.userId).listen((user) {
        emit(ProfileLoaded(user: user));
      }).asFuture();
    });
    on<ResetProfile>((event, emit) => emit(ProfileLoading()));
    on<UpdateProfile>((event, emit) async {
      await _userRepository.updateUser(event.user);
      add(LoadProfile(userId: event.user.id!));
    });
    on<UpdateProfilePicture>((event, emit) async {
      emit(ProfileLoading());
      await _storageRepository.uploadImage(event.user, event.image);
      add(LoadProfile(userId: event.user.id!));
    });
  }
  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
