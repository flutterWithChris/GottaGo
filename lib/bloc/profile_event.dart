part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;
  const LoadProfile({
    required this.userId,
  });
  @override
  List<Object> get props => [userId];
}

class ResetProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final User user;
  const UpdateProfile({
    required this.user,
  });
  @override
  List<Object> get props => [user];
}

class UpdateProfilePicture extends ProfileEvent {
  final User user;
  final XFile image;
  const UpdateProfilePicture({
    required this.user,
    required this.image,
  });
  @override
  List<Object> get props => [user, image];
}
