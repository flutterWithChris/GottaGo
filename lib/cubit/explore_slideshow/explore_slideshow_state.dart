part of 'explore_slideshow_cubit.dart';

abstract class ExploreSlideshowState extends Equatable {
  int? photoIndex;
  ExploreSlideshowState({this.photoIndex});

  @override
  List<Object?> get props => [photoIndex];
}

class ExploreSlideshowInitial extends ExploreSlideshowState {}

class ExploreSlideshowSwiped extends ExploreSlideshowState {
  ExploreSlideshowSwiped({required int photoIndex})
      : super(photoIndex: photoIndex);
}
