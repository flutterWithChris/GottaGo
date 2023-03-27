part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  final User user;
  const ProfileState({
    this.user = User.empty,
  });

  @override
  List<Object> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  @override
  final User user;
  const ProfileLoaded({
    required this.user,
  });
  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class ProfileIncomplete extends ProfileState {
  @override
  final User user;
  const ProfileIncomplete({
    required this.user,
  });
  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class ProfileFailed extends ProfileState {}
