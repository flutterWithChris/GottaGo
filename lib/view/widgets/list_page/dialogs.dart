import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/place_list.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditListDialog extends StatefulWidget {
  final PlaceList placeList;
  const EditListDialog({
    required this.placeList,
    Key? key,
  }) : super(key: key);

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  final TextEditingController listNameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    listNameController.text = widget.placeList.name;
    super.initState();
  }

  IconData? selectedIcon;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 160,
        height: 210,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Edit List',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: BlocBuilder<PurchasesBloc, PurchasesState>(
                      builder: (context, state) {
                        if (state is PurchasesLoading) {
                          return LoadingAnimationWidget.staggeredDotsWave(
                              color: FlexColor.bahamaBlueDarkSecondary,
                              size: 20.0);
                        }
                        if (state is PurchasesLoaded) {
                          if (state.isSubscribed == false) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size.fromHeight(50),
                                  side: BorderSide(
                                      width: 2.0,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .enabledBorder!
                                          .borderSide
                                          .color)),
                              onPressed: () async {
                                Navigator.pop(context, true);
                              },
                              child: selectedIcon == null
                                  ? Icon(
                                      deserializeIcon(widget.placeList.icon) ??
                                          Icons.list_alt_rounded)
                                  : Icon(selectedIcon),
                            );
                          }
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size.fromHeight(50),
                                side: BorderSide(
                                    width: 2.0,
                                    color: Theme.of(context)
                                        .inputDecorationTheme
                                        .enabledBorder!
                                        .borderSide
                                        .color)),
                            onPressed: () async {
                              IconData? icon = await pickIcon(context);

                              if (icon == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'No Icon Selected!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              }
                            },
                            child: selectedIcon == null
                                ? Icon(deserializeIcon(widget.placeList.icon) ??
                                    Icons.list_alt_rounded)
                                : Icon(selectedIcon),
                          );
                        } else {
                          return const Center(
                            child: Text('Error'),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Flexible(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        // onChanged: (value) {
                        //   setState(() {
                        //     textLength = value.length;
                        //   });
                        // },
                        // maxLength: 20,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[A-Za-z0-9#+-. ]*")),
                        ],
                        textCapitalization: TextCapitalization.words,
                        controller: listNameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          // suffixText:
                          //     '${textLength.toString()}/${maxLength.toString()}',
                          // suffixStyle: Theme.of(context).textTheme.bodySmall,
                          //   counterText: "",
                          isDense: true,
                          filled: true,
                          hintText: "ex. Breakfast Ideas...",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  width: 2.0, color: Colors.redAccent)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  width: 2.0, color: Colors.redAccent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  width: 2.0,
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .enabledBorder!
                                      .borderSide
                                      .color)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              BlocConsumer<SavedListsBloc, SavedListsState>(
                listener: (context, state) async {
                  if (state is SavedListsUpdated) {
                    await Future.delayed(const Duration(seconds: 1),
                        () => Navigator.pop(context));
                  }
                },
                builder: (context, state) {
                  if (state is SavedListsLoading) {
                    return ElevatedButton(
                        onPressed: () {},
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: FlexColor.bahamaBlueDarkSecondary,
                            size: 18.0));
                  }
                  if (state is SavedListsUpdated) {
                    return ElevatedButton(
                        onPressed: () {},
                        child: Icon(
                          Icons.check,
                          color: Colors.green.shade400,
                        ));
                  }
                  return ElevatedButton(
                      onPressed: () {
                        if (selectedIcon != null) {
                          context.read<SavedListsBloc>().add(UpdateSavedLists(
                              placeList: widget.placeList.copyWith(
                                  name: listNameController.value.text,
                                  icon: serializeIcon(selectedIcon!))));
                          // context
                          //     .read<SavedPlacesBloc>()
                          //     .add(LoadPlaces(placeList: widget.placeList));
                        } else {
                          context.read<SavedListsBloc>().add(UpdateSavedLists(
                              placeList: widget.placeList.copyWith(
                                  name: listNameController.value.text)));
                        }
                      },
                      child: const Text('Update List'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
