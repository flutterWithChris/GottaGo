import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'explore_slideshow_state.dart';

class ExploreSlideshowCubit extends Cubit<ExploreSlideshowState> {
  ExploreSlideshowCubit() : super(ExploreSlideshowInitial());
  void swipe(int photoIndex) {
    emit(ExploreSlideshowSwiped(photoIndex: photoIndex));
  }
}
