import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:leggo/repository/auth_repository.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;
  SignUpCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SignUpState.initial());

  void emailChanged(String email) {
    emit(state.copyWith(email: email, status: SignupStatus.initial));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(password: password, status: SignupStatus.initial));
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: name, status: SignupStatus.initial));
  }

  void signUpWithCredential() async {
    emit(state.copyWith(status: SignupStatus.submitting));
    try {
      await _authRepository.signUp(
          email: state.email, password: state.password);
      emit(state.copyWith(status: SignupStatus.success));
    } catch (_) {}
  }

  Future<void> signUpWithGoogle() async {
    emit(state.copyWith(status: SignupStatus.submitting));
    try {
      auth.User? user = await _authRepository.signInWithGoogle();
      emit(state.copyWith(status: SignupStatus.success, user: user));
    } catch (_) {}
  }

  Future<void> signUpWithApple() async {
    emit(state.copyWith(status: SignupStatus.submitting));
    try {
      auth.User? user = await _authRepository.signInWithApple();
      emit(state.copyWith(status: SignupStatus.success, user: user));
    } catch (_) {}
  }
}
