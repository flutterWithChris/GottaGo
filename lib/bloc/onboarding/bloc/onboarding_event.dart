part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class StartOnboarding extends OnboardingEvent {
  final User user;
  const StartOnboarding(
      {this.user = const User(
          id: '',
          userName: '',
          name: '',
          email: '',
          profilePicture: '',
          placeListIds: [])});
  @override
  // TODO: implement props
  List<Object?> get props => [user];
}

class UpdateUser extends OnboardingEvent {
  final User user;

  const UpdateUser({required this.user});

  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class UpdateUserProfilePicture extends OnboardingEvent {
  final User user;
  final XFile image;

  const UpdateUserProfilePicture({required this.user, required this.image});

  @override
  // TODO: implement props
  List<Object?> get props => [user, image];
}
