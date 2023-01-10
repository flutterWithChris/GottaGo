import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/model/place_list.dart';

class CreateListDialog extends StatefulWidget {
  const CreateListDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  var maxLength = 15;
  var textLength = 0;
  @override
  Widget build(BuildContext context) {
    final TextEditingController listNameController = TextEditingController();
    return Dialog(
      //backgroundColor: FlexColor.,
      child: SizedBox(
        height: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.post_add_outlined),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    'Create a List:',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  // onChanged: (value) {
                  //   setState(() {
                  //     textLength = value.length;
                  //   });
                  // },
                  maxLength: 30,
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
                    filled: true,
                    hintText: "ex. Breakfast Ideas...",

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
                )),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(fixedSize: const Size(150, 35)
                      // backgroundColor: FlexColor.espressoDarkTertiary,
                      ),
                  onPressed: () {
                    context.read<SavedListsBloc>().add(AddList(
                            placeList: PlaceList(
                          placeCount: 0,
                          icon: {},
                          contributorIds: [],
                          listOwnerId:
                              context.read<ProfileBloc>().state.user.id!,
                          name: listNameController.value.text,
                        )));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.post_add_outlined),
                  label: const Text('Create List')),
            )
          ],
        ),
      ),
    );
  }
}
