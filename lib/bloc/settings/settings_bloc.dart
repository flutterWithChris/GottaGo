import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/bug_report.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/auth_repository.dart';
import 'package:leggo/repository/database/database_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final DatabaseRepository _databaseRepository;
  final AuthRepository _authRepository;
  SettingsBloc(
      {required DatabaseRepository databaseRepository,
      required AuthRepository authRepository})
      : _databaseRepository = databaseRepository,
        _authRepository = authRepository,
        super(SettingsInitial()) {
    on<UpdateName>((event, emit) async {
      emit(SettingsLoading());
      await _databaseRepository.updateUser(event.user);
      emit(SettingsUpdated());
      await Future.delayed(const Duration(seconds: 2));
      emit(SettingsLoaded());
    });
    on<UpdateUsername>((event, emit) async {
      emit(SettingsLoading());
      await _databaseRepository.deregisterUsername(event.user.userName!);
      await _databaseRepository.registerUsername(
          event.userName, event.user.id!);
      await _databaseRepository
          .updateUser(event.user.copyWith(userName: event.userName));
      emit(SettingsUpdated());
      await Future.delayed(const Duration(seconds: 2));
      emit(SettingsLoaded());
    });
    on<SignOut>((event, emit) => null);
    on<DeleteAccount>((event, emit) async {
      emit(SettingsLoading());
      await _authRepository.deleteUser();
      await _databaseRepository.deleteUserData(event.user);
      emit(SettingsLoaded());
    });
    on<ReportIssue>((event, emit) async {
      emit(SettingsLoading());
      await _databaseRepository.sendBugReport(event.bugReport);
      emit(SettingsUpdated());
      await Future.delayed(
          const Duration(seconds: 2), () => emit(SettingsLoaded()));
    });
    on<ContactRequest>((event, emit) => null);
  }
}
