import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/database/database_repository.dart';
import 'package:leggo/repository/storage/storage_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final DatabaseRepository _databaseRepository;
  final StorageRepository _storageRepository;
  OnboardingBloc(
      {required DatabaseRepository databaseRepository,
      required StorageRepository storageRepository})
      : _databaseRepository = databaseRepository,
        _storageRepository = storageRepository,
        super(OnboardingLoading()) {
    on<StartOnboarding>((event, emit) async {
      await _databaseRepository.createUser(event.user);
      emit(OnboardingLoaded(user: event.user));
    });
    on<UpdateUserProfilePicture>((event, emit) async {
      User user = (state as OnboardingLoaded).user;
      emit(OnboardingLoading());
      await _storageRepository.uploadImage(user, event.image);

      _databaseRepository.getUser(user.id!).listen((user) {
        add(UpdateUser(user: user));
      });
    });
    on<UpdateUser>((event, emit) async {
      if (state is OnboardingLoaded) {
        emit(OnboardingLoading());
      }

      // * Set Username if passed check & not null.
      if (event.user.userName != '') {
        await _databaseRepository.registerUsername(
            event.user.userName!, event.user.id!);
      }
      await _databaseRepository.updateUser(event.user);
      emit(OnboardingLoaded(user: event.user));
    });
  }
}
