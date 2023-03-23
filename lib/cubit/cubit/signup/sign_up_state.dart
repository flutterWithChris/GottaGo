part of 'sign_up_cubit.dart';

enum SignupStatus { initial, submitting, success, error }

class SignUpState extends Equatable {
  final String email;
  final String password;
  final String name;
  final SignupStatus status;
  final auth.User? user;
  const SignUpState({
    required this.user,
    required this.email,
    required this.name,
    required this.password,
    required this.status,
  });

  factory SignUpState.initial() {
    return const SignUpState(
      user: null,
      name: '',
      email: '',
      password: '',
      status: SignupStatus.initial,
    );
  }

  SignUpState copyWith({
    auth.User? user,
    String? email,
    String? name,
    String? password,
    SignupStatus? status,
  }) {
    return SignUpState(
      user: user ?? this.user,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [user, email, password, status];
}
