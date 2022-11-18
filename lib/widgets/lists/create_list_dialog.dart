import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/model/place_list.dart';

class CreateListDialog extends StatelessWidget {
  const CreateListDialog({
    Key? key,
  }) : super(key: key);

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
            Text(
              'Create New List:',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 24.0,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: listNameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "ex. Breakfast Ideas",
                    focusedBorder: Theme.of(context)
                        .inputDecorationTheme
                        .focusedBorder!
                        .copyWith(borderSide: const BorderSide()),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(fixedSize: const Size(150, 35)
                      // backgroundColor: FlexColor.espressoDarkTertiary,
                      ),
                  onPressed: () {
                    print('PlaceList Added: ${listNameController.value.text}');
                    context.read<SavedListsBloc>().add(AddList(
                            placeList: PlaceList(
                          placeCount: 0,
                          contributorIds: [],
                          listOwnerId: FirebaseAuth.instance.currentUser!.uid,
                          name: listNameController.value.text,
                        )));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Create List')),
            )
          ],
        ),
      ),
    );
  }
}
