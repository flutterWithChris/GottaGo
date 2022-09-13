part of 'saved_categories_bloc.dart';

abstract class SavedCategoriesEvent extends Equatable {
  const SavedCategoriesEvent();

  @override
  List<Object> get props => [];
}

class AddCategory extends SavedCategoriesEvent {
  final Category category;
  const AddCategory({required this.category});
  @override
  // TODO: implement props
  List<Object> get props => [category];
}

class RemoveCategory extends SavedCategoriesEvent {
  final Category category;
  const RemoveCategory({
    required this.category,
  });
  @override
  // TODO: implement props
  List<Object> get props => [props];
}

class EditCategory extends SavedCategoriesEvent {
  final Category category;
  const EditCategory({
    required this.category,
  });
  @override
  // TODO: implement props
  List<Object> get props => [category];
}

class LoadSavedCategories extends SavedCategoriesEvent {}

class UpdateSavedCategories extends SavedCategoriesEvent {}
