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
  final AuthBloc _authBloc;
  StreamSubscription? _authSubscription;
  ProfileBloc(
      {required UserRepository userRepository, required AuthBloc authBloc})
      : _userRepository = userRepository,
        _authBloc = authBloc,
        super(ProfileLoading()) {
    _authSubscription = _authBloc.stream.listen((state) {
      state.status == AuthStatus.authenticated
          ? add(LoadProfile(userId: state.authUser!.uid))
          : add(ResetProfile());
    });
    on<LoadProfile>((event, emit) async {
      await emit.forEach(_userRepository.getUser(event.userId), onData: (user) {
        return ProfileLoaded(user: user);
      });
    });
    on<ResetProfile>((event, emit) => emit(ProfileLoading()));
  }
}
