part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class UpdateName extends SettingsEvent {
  final User user;
  const UpdateName({
    required this.user,
  });
}

class UpdateUsername extends SettingsEvent {
  final User user;
  final String userName;
  const UpdateUsername({
    required this.user,
    required this.userName,
  });
}

class SignOut extends SettingsEvent {}

class DeleteAccount extends SettingsEvent {
  final User user;
  const DeleteAccount({
    required this.user,
  });
}

class ReportIssue extends SettingsEvent {
  final BugReport bugReport;
  const ReportIssue({
    required this.bugReport,
  });
}

class ContactRequest extends SettingsEvent {}
