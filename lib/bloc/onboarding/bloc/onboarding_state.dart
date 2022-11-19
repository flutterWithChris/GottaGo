part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  final User? user;
  const OnboardingState({this.user});

  @override
  List<Object?> get props => [user];
}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  @override
  final User user;

  const OnboardingLoaded({required this.user});

  @override
  // TODO: implement props
  List<Object?> get props => [user];
}
