import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/bloc/bloc/auth/bloc/auth_bloc.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  StreamSubscription? _userSubscription;
  ProfileBloc(
      {required UserRepository userRepository, required AuthBloc authBloc})
      : _userRepository = userRepository,
        super(ProfileLoading()) {
    on<LoadProfile>((event, emit) async {
      _userSubscription =
          await _userRepository.getUser(event.userId).listen((user) {
        emit(ProfileLoaded(user: user));
      }).asFuture();
    });
    on<ResetProfile>((event, emit) => emit(ProfileLoading()));
  }
  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
