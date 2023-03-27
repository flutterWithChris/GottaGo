import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/auth_repository.dart';
import 'package:leggo/repository/purchases_repository.dart';
import 'package:leggo/repository/user_repository.dart';
import 'package:leggo/router/app_router.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final PurchasesRepository _purchasesRepository;
  StreamSubscription<auth.User?>? _authUserSubscription;
  StreamSubscription<User?>? _userSubscription;
  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required PurchasesRepository purchasesRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _purchasesRepository = purchasesRepository,
        super(const AuthState.unknown()) {
    on<AuthUserChanged>(_onAuthUserChanged);
    _authUserSubscription = _authRepository.user.listen((authUser) {
      if (authUser != null) {
        _userRepository.getUser(authUser.uid).listen((user) {
          add(AuthUserChanged(authUser: authUser, user: user));
        });
      } else {
        add(const AuthUserChanged(authUser: null));
      }
    });
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    bool? isUserAnonymous = await _purchasesRepository.isUserAnonymous();
    if (event.user != null) {
      await _purchasesRepository.loginToRevCat(event.authUser!.uid);
    } else if (isUserAnonymous == false) {
      await _purchasesRepository.logoutOfRevCat();
    }

    event.authUser != null
        ? emit(AuthState.authenticated(
            authUser: event.authUser!, user: event.user!))
        : emit(const AuthState.unauthenticated());

    event.authUser != null ? router.refresh() : null;
  }

  @override
  Future<void> close() {
    _authUserSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }
}
