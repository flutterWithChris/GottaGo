part of 'profile_picture_bloc.dart';

abstract class ProfilePictureEvent extends Equatable {
  const ProfilePictureEvent();

  @override
  List<Object> get props => [];
}

class LoadProfilePicture extends ProfilePictureEvent {}

class UpdateProfilePicture extends ProfilePictureEvent {
  final String profilePictureUrl;

  const UpdateProfilePicture(this.profilePictureUrl);

  @override
  // TODO: implement props
  List<Object> get props => [profilePictureUrl];
}
