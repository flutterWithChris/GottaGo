import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leggo/repository/auth_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginState.initial());

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  Future<void> logInWithCredentials() async {
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.logInWithEmailAndPassword(
          email: state.email, password: state.password);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> logInWithGoogle() async {
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));

    User? user = await _authRepository.signInWithGoogle();
    user is User
        ? emit(state.copyWith(status: LoginStatus.success))
        : emit(state.copyWith(status: LoginStatus.error));
  }

  Future<void> logInWithApple() async {
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));

    User? user = await _authRepository.signInWithApple();
    user is User
        ? emit(state.copyWith(status: LoginStatus.success))
        : emit(state.copyWith(status: LoginStatus.error));
  }

  void logout() async {
    await _authRepository.signOut();
    emit(state.copyWith(status: LoginStatus.initial));
  }
}
