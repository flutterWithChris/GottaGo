part of 'profile_picture_bloc.dart';

abstract class ProfilePictureState extends Equatable {
  const ProfilePictureState();

  @override
  List<Object> get props => [];
}

class ProfilePictureLoading extends ProfilePictureState {}

class ProfilePictureLoaded extends ProfilePictureState {
  String profilePictureUrl;

  ProfilePictureLoaded({this.profilePictureUrl = ''});

  @override
  // TODO: implement props
  List<Object> get props => [profilePictureUrl];
}

class ProfilePictureFailed extends ProfilePictureState {}
